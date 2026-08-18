const PIXELLAB_API_BASE = 'https://api.pixellab.ai/v2';
const DEFAULT_DESTINATION = 'fs_map_candidates';

function doGet(e) {
  const path = normalizePath_(e && e.pathInfo);
  if (path === '' || path === 'health') {
    return json_({
      ok: true,
      service: 'game-asset-forge-apps-script-finalizer',
      version: '1.0.0'
    });
  }
  return json_({ ok: false, error: 'NOT_FOUND', path: path });
}

function doPost(e) {
  const path = normalizePath_(e && e.pathInfo);
  if (path !== 'finalize') {
    return json_({ ok: false, error: 'NOT_FOUND', path: path });
  }

  try {
    const body = parseJsonBody_(e);
    return json_(finalizePixelLabJob_(body));
  } catch (err) {
    return json_({
      ok: false,
      status: 'failed',
      error: 'FINALIZER_EXCEPTION',
      message: String(err && err.message ? err.message : err)
    });
  }
}

function finalizePixelLabJob_(body) {
  const jobId = requiredString_(body.job_id, 'job_id');
  const assetId = sanitizeAssetId_(requiredString_(body.asset_id, 'asset_id'));
  const destination = body.destination || DEFAULT_DESTINATION;
  const folder = resolveDestinationFolder_(destination);
  const filename = assetId + '__' + jobId + '.png';

  const existing = folder.getFilesByName(filename);
  if (existing.hasNext()) {
    return completedResponse_(existing.next(), jobId, assetId, destination, true);
  }

  const props = PropertiesService.getScriptProperties();
  const token = props.getProperty('PIXELLAB_API_TOKEN');
  if (!token) {
    throw new Error('Missing Script Property PIXELLAB_API_TOKEN');
  }

  const response = UrlFetchApp.fetch(
    PIXELLAB_API_BASE + '/background-jobs/' + encodeURIComponent(jobId),
    {
      method: 'get',
      headers: { Authorization: 'Bearer ' + token },
      muteHttpExceptions: true
    }
  );

  const responseCode = response.getResponseCode();
  const text = response.getContentText();
  let payload;
  try {
    payload = JSON.parse(text);
  } catch (err) {
    return {
      ok: false,
      status: 'failed',
      error: 'PIXELLAB_NON_JSON_RESPONSE',
      http_status: responseCode
    };
  }

  if (responseCode < 200 || responseCode >= 300) {
    return {
      ok: false,
      status: 'failed',
      error: 'PIXELLAB_HTTP_ERROR',
      http_status: responseCode,
      detail: compactError_(payload)
    };
  }

  const status = String(payload.status || 'unknown').toLowerCase();
  if (status === 'processing' || status === 'queued') {
    return {
      ok: true,
      status: 'processing',
      job_id: jobId,
      asset_id: assetId,
      destination: destination
    };
  }

  if (status === 'failed') {
    return {
      ok: false,
      status: 'failed',
      job_id: jobId,
      asset_id: assetId,
      error: 'PIXELLAB_GENERATION_FAILED',
      detail: compactError_(payload.last_response || payload)
    };
  }

  if (status !== 'completed') {
    return {
      ok: false,
      status: status,
      job_id: jobId,
      asset_id: assetId,
      error: 'UNKNOWN_PIXELLAB_JOB_STATUS'
    };
  }

  const image = payload.last_response && payload.last_response.image;
  const dataUrl = image && image.base64;
  if (!dataUrl || typeof dataUrl !== 'string') {
    return {
      ok: false,
      status: 'failed',
      job_id: jobId,
      asset_id: assetId,
      error: 'PIXELLAB_IMAGE_BASE64_MISSING'
    };
  }

  const bytes = decodeImageDataUrl_(dataUrl);
  assertPngSignature_(bytes);

  const blob = Utilities.newBlob(bytes, 'image/png', filename);
  const file = folder.createFile(blob);

  let publicShare = true;
  try {
    file.setSharing(DriveApp.Access.ANYONE_WITH_LINK, DriveApp.Permission.VIEW);
  } catch (err) {
    publicShare = false;
  }

  const out = completedResponse_(file, jobId, assetId, destination, false);
  out.public_share_enabled = publicShare;
  out.usage = compactUsage_(payload.last_response && payload.last_response.usage);
  return out;
}

function completedResponse_(file, jobId, assetId, destination, cached) {
  const fileId = file.getId();
  return {
    ok: true,
    status: 'completed',
    cached: cached,
    job_id: jobId,
    asset_id: assetId,
    destination: destination,
    filename: file.getName(),
    drive_file_id: fileId,
    image_url: 'https://drive.google.com/uc?export=view&id=' + encodeURIComponent(fileId),
    download_url: 'https://drive.google.com/uc?export=download&id=' + encodeURIComponent(fileId),
    drive_view_url: file.getUrl()
  };
}

function resolveDestinationFolder_(destination) {
  const props = PropertiesService.getScriptProperties();
  const mapping = {
    fs_map_candidates: 'FS_MAP_CANDIDATE_FOLDER_ID'
  };
  const propertyKey = mapping[destination];
  if (!propertyKey) {
    throw new Error('Unsupported destination: ' + destination);
  }
  const folderId = props.getProperty(propertyKey);
  if (!folderId) {
    throw new Error('Missing Script Property ' + propertyKey);
  }
  return DriveApp.getFolderById(folderId);
}

function decodeImageDataUrl_(value) {
  const comma = value.indexOf(',');
  const base64 = comma >= 0 ? value.substring(comma + 1) : value;
  return Utilities.base64Decode(base64);
}

function assertPngSignature_(bytes) {
  const expected = [137, 80, 78, 71, 13, 10, 26, 10];
  if (!bytes || bytes.length < expected.length) {
    throw new Error('Decoded image is too small to be PNG');
  }
  for (let i = 0; i < expected.length; i++) {
    const actual = bytes[i] < 0 ? bytes[i] + 256 : bytes[i];
    if (actual !== expected[i]) {
      throw new Error('Decoded image is not a PNG');
    }
  }
}

function compactUsage_(usage) {
  if (!usage || typeof usage !== 'object') return null;
  return {
    type: usage.type || null,
    usd: typeof usage.usd === 'number' ? usage.usd : null
  };
}

function compactError_(payload) {
  if (!payload || typeof payload !== 'object') return String(payload || '');
  return {
    detail: payload.detail || null,
    description: payload.description || null,
    message: payload.message || null
  };
}

function parseJsonBody_(e) {
  if (!e || !e.postData || !e.postData.contents) {
    throw new Error('Missing JSON request body');
  }
  return JSON.parse(e.postData.contents);
}

function requiredString_(value, name) {
  if (typeof value !== 'string' || !value.trim()) {
    throw new Error('Missing required field: ' + name);
  }
  return value.trim();
}

function sanitizeAssetId_(value) {
  const safe = value.replace(/[^A-Za-z0-9_-]/g, '_').replace(/_+/g, '_');
  if (!safe) throw new Error('asset_id becomes empty after sanitization');
  return safe.substring(0, 120);
}

function normalizePath_(pathInfo) {
  return String(pathInfo || '').replace(/^\/+|\/+$/g, '');
}

function json_(obj) {
  return ContentService
    .createTextOutput(JSON.stringify(obj))
    .setMimeType(ContentService.MimeType.JSON);
}
