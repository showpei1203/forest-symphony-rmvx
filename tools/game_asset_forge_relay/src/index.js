const JSON_HEADERS = {
  'content-type': 'application/json; charset=utf-8',
  'access-control-allow-origin': '*',
};

function json(data, status = 200, extraHeaders = {}) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...JSON_HEADERS, ...extraHeaders },
  });
}

function corsPreflight() {
  return new Response(null, {
    status: 204,
    headers: {
      'access-control-allow-origin': '*',
      'access-control-allow-methods': 'GET,POST,OPTIONS',
      'access-control-allow-headers': 'authorization,content-type',
      'access-control-max-age': '86400',
    },
  });
}

function isAuthorized(request, env) {
  const header = request.headers.get('authorization') || '';
  return header === `Bearer ${env.RELAY_API_KEY}`;
}

function safeAssetId(value) {
  const raw = String(value || '').trim();
  if (!raw) return null;
  const safe = raw.replace(/[^A-Za-z0-9._-]+/g, '_').replace(/^_+|_+$/g, '');
  return safe.slice(0, 120) || null;
}

function parseDataUrl(dataUrl) {
  if (typeof dataUrl !== 'string') throw new Error('IMAGE_BASE64_MISSING');
  const match = /^data:([^;]+);base64,([A-Za-z0-9+/=\r\n]+)$/s.exec(dataUrl.trim());
  if (!match) throw new Error('IMAGE_DATA_URL_INVALID');
  const mimeType = match[1].toLowerCase();
  const base64 = match[2].replace(/\s+/g, '');
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i += 1) bytes[i] = binary.charCodeAt(i);
  return { mimeType, bytes };
}

function extFromMime(mimeType) {
  if (mimeType === 'image/jpeg') return 'jpg';
  if (mimeType === 'image/webp') return 'webp';
  return 'png';
}

async function readJsonObject(bucket, key) {
  const object = await bucket.get(key);
  if (!object) return null;
  try {
    return JSON.parse(await object.text());
  } catch {
    return null;
  }
}

async function writeJsonObject(bucket, key, value) {
  await bucket.put(key, JSON.stringify(value), {
    httpMetadata: { contentType: 'application/json; charset=utf-8' },
  });
}

async function pixelLabFetch(env, path, init = {}) {
  const base = (env.PIXELLAB_API_BASE || 'https://api.pixellab.ai/v2').replace(/\/$/, '');
  const headers = new Headers(init.headers || {});
  headers.set('authorization', `Bearer ${env.PIXELLAB_API_TOKEN}`);
  if (init.body && !headers.has('content-type')) headers.set('content-type', 'application/json');
  return fetch(`${base}${path}`, { ...init, headers });
}

async function upstreamError(response) {
  let payload;
  try {
    payload = await response.json();
  } catch {
    payload = { message: (await response.text()).slice(0, 1000) };
  }
  return {
    error: 'PIXELLAB_UPSTREAM_ERROR',
    upstream_status: response.status,
    upstream: payload,
  };
}

async function handleBalance(env) {
  const response = await pixelLabFetch(env, '/balance');
  if (!response.ok) return json(await upstreamError(response), response.status);
  const data = await response.json();
  return json({ status: 'ok', provider: 'pixellab', balance: data });
}

async function handleStartJob(request, env) {
  let body;
  try {
    body = await request.json();
  } catch {
    return json({ error: 'INVALID_JSON' }, 400);
  }

  const assetId = safeAssetId(body.asset_id);
  if (!assetId) return json({ error: 'ASSET_ID_REQUIRED' }, 400);

  const imageSize = body.image_size;
  if (!imageSize || !Number.isInteger(imageSize.width) || !Number.isInteger(imageSize.height)) {
    return json({ error: 'IMAGE_SIZE_REQUIRED' }, 400);
  }

  const { asset_id, candidate_name, ...pixflux } = body;
  if (!pixflux.description || typeof pixflux.description !== 'string') {
    return json({ error: 'DESCRIPTION_REQUIRED' }, 400);
  }

  const upstream = await pixelLabFetch(env, '/create-image-pixflux-background', {
    method: 'POST',
    body: JSON.stringify(pixflux),
  });

  if (!upstream.ok) return json(await upstreamError(upstream), upstream.status);

  const submitted = await upstream.json();
  const jobId = submitted.background_job_id;
  if (!jobId) return json({ error: 'PIXELLAB_JOB_ID_MISSING', upstream: submitted }, 502);

  const meta = {
    relay_schema_version: '1.0',
    background_job_id: jobId,
    asset_id: assetId,
    candidate_name: candidate_name || null,
    image_size: imageSize,
    seed: pixflux.seed ?? null,
    no_background: pixflux.no_background ?? false,
    submitted_at: new Date().toISOString(),
    usage: submitted.usage || null,
  };
  await writeJsonObject(env.ASSETS, `jobs/${jobId}.json`, meta);

  const origin = new URL(request.url).origin;
  return json({
    status: submitted.status || 'processing',
    background_job_id: jobId,
    asset_id: assetId,
    candidate_name: meta.candidate_name,
    poll_url: `${origin}/v1/pixflux/jobs/${encodeURIComponent(jobId)}`,
    usage: submitted.usage || null,
  }, 202);
}

async function handleGetJob(request, env, jobId) {
  const resultKey = `jobs/${jobId}.result.json`;
  const cached = await readJsonObject(env.ASSETS, resultKey);
  if (cached) return json(cached);

  const meta = await readJsonObject(env.ASSETS, `jobs/${jobId}.json`);
  if (!meta) return json({ error: 'RELAY_JOB_NOT_FOUND', background_job_id: jobId }, 404);

  const upstream = await pixelLabFetch(env, `/background-jobs/${encodeURIComponent(jobId)}`);
  if (!upstream.ok) return json(await upstreamError(upstream), upstream.status);

  const job = await upstream.json();
  const status = job.status || 'processing';

  if (status === 'processing') {
    return json({
      status: 'processing',
      background_job_id: jobId,
      asset_id: meta.asset_id,
      candidate_name: meta.candidate_name,
    });
  }

  if (status === 'failed') {
    const failure = {
      status: 'failed',
      error: 'PIXELLAB_GENERATION_FAILED',
      background_job_id: jobId,
      asset_id: meta.asset_id,
      candidate_name: meta.candidate_name,
      detail: job.last_response?.detail || job.detail || null,
    };
    await writeJsonObject(env.ASSETS, resultKey, failure);
    return json(failure, 502);
  }

  if (status !== 'completed') {
    return json({
      status,
      background_job_id: jobId,
      asset_id: meta.asset_id,
      candidate_name: meta.candidate_name,
    });
  }

  const dataUrl = job.last_response?.image?.base64;
  if (!dataUrl) {
    return json({
      status: 'failed',
      error: 'PIXELLAB_COMPLETED_WITHOUT_IMAGE',
      background_job_id: jobId,
      asset_id: meta.asset_id,
    }, 502);
  }

  let decoded;
  try {
    decoded = parseDataUrl(dataUrl);
  } catch (error) {
    return json({
      status: 'failed',
      error: error instanceof Error ? error.message : 'IMAGE_DECODE_FAILED',
      background_job_id: jobId,
      asset_id: meta.asset_id,
    }, 502);
  }

  const ext = extFromMime(decoded.mimeType);
  const assetKey = `assets/${meta.asset_id}/${jobId}.${ext}`;
  await env.ASSETS.put(assetKey, decoded.bytes, {
    httpMetadata: {
      contentType: decoded.mimeType,
      cacheControl: 'public, max-age=31536000, immutable',
    },
    customMetadata: {
      asset_id: meta.asset_id,
      pixellab_job_id: jobId,
    },
  });

  const origin = new URL(request.url).origin;
  const imageUrl = `${origin}/${assetKey}`;
  const result = {
    status: 'completed',
    background_job_id: jobId,
    asset_id: meta.asset_id,
    candidate_name: meta.candidate_name,
    width: meta.image_size?.width ?? null,
    height: meta.image_size?.height ?? null,
    seed: meta.seed,
    mime_type: decoded.mimeType,
    bytes: decoded.bytes.byteLength,
    image_url: imageUrl,
    download_url: imageUrl,
    image_markdown: `![${meta.asset_id}](${imageUrl})`,
    usage: job.last_response?.usage || job.usage || meta.usage || null,
    stored_at: new Date().toISOString(),
  };

  await writeJsonObject(env.ASSETS, resultKey, result);
  return json(result);
}

async function handleAsset(request, env, key) {
  const object = await env.ASSETS.get(key);
  if (!object) return new Response('Not found', { status: 404 });

  const headers = new Headers();
  object.writeHttpMetadata(headers);
  headers.set('etag', object.httpEtag);
  headers.set('access-control-allow-origin', '*');
  if (!headers.has('cache-control')) headers.set('cache-control', 'public, max-age=31536000, immutable');
  return new Response(object.body, { headers });
}

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') return corsPreflight();

    const url = new URL(request.url);
    const path = url.pathname;

    if (request.method === 'GET' && path === '/health') {
      return json({ status: 'ok', service: 'game-asset-forge-relay', version: '1.0.0' });
    }

    if (request.method === 'GET' && path.startsWith('/assets/')) {
      const key = decodeURIComponent(path.slice(1));
      return handleAsset(request, env, key);
    }

    if (!isAuthorized(request, env)) {
      return json({ error: 'UNAUTHORIZED' }, 401, { 'www-authenticate': 'Bearer' });
    }

    if (request.method === 'GET' && path === '/v1/balance') {
      return handleBalance(env);
    }

    if (request.method === 'POST' && path === '/v1/pixflux/jobs') {
      return handleStartJob(request, env);
    }

    const jobMatch = /^\/v1\/pixflux\/jobs\/([^/]+)$/.exec(path);
    if (request.method === 'GET' && jobMatch) {
      return handleGetJob(request, env, decodeURIComponent(jobMatch[1]));
    }

    return json({ error: 'NOT_FOUND' }, 404);
  },
};
