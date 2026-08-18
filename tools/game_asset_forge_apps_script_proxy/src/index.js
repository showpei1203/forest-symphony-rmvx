const ALLOWED_PATHS = new Set(['/health', '/finalize']);

export default {
  async fetch(request, env) {
    try {
      if (!env.APPS_SCRIPT_BASE_URL) {
        return json({ ok: false, error: 'MISSING_APPS_SCRIPT_BASE_URL' }, 500);
      }

      const incoming = new URL(request.url);
      if (!ALLOWED_PATHS.has(incoming.pathname)) {
        return json({ ok: false, error: 'NOT_FOUND' }, 404);
      }

      if (incoming.pathname === '/health' && request.method !== 'GET') {
        return json({ ok: false, error: 'METHOD_NOT_ALLOWED' }, 405);
      }
      if (incoming.pathname === '/finalize' && request.method !== 'POST') {
        return json({ ok: false, error: 'METHOD_NOT_ALLOWED' }, 405);
      }

      const base = String(env.APPS_SCRIPT_BASE_URL).replace(/\/+$/, '');
      const target = new URL(base + incoming.pathname);
      target.search = incoming.search;

      const headers = new Headers();
      const contentType = request.headers.get('content-type');
      if (contentType) headers.set('content-type', contentType);
      headers.set('accept', 'application/json');

      const init = {
        method: request.method,
        headers,
        redirect: 'follow'
      };

      if (request.method !== 'GET' && request.method !== 'HEAD') {
        init.body = await request.arrayBuffer();
      }

      const upstream = await fetch(target.toString(), init);
      const text = await upstream.text();

      let body;
      try {
        body = JSON.parse(text);
      } catch {
        return json({
          ok: false,
          error: 'UPSTREAM_NON_JSON',
          upstream_status: upstream.status,
          upstream_url: upstream.url,
          preview: text.slice(0, 240)
        }, 502);
      }

      return json(body, upstream.ok ? 200 : upstream.status);
    } catch (err) {
      return json({
        ok: false,
        error: 'PROXY_EXCEPTION',
        message: String(err && err.message ? err.message : err)
      }, 500);
    }
  }
};

function json(value, status = 200) {
  return new Response(JSON.stringify(value), {
    status,
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'cache-control': 'no-store'
    }
  });
}
