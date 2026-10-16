const REQUEST_TIMEOUT_MS = 15_000;

const DEFAULT_BASES = {
  datacite: 'https://api.datacite.org',
  openalex: 'https://api.openalex.org',
  crossref: 'https://api.crossref.org',
  zotero: 'https://api.zotero.org',
};

export class ScholarlyClient {
  #fetch;
  #bases;
  #contactEmail;

  constructor({ fetch: fetchImpl = globalThis.fetch, bases = {}, contactEmail }) {
    this.#fetch = fetchImpl;
    this.#bases = { ...DEFAULT_BASES };
    for (const [source, value] of Object.entries(bases)) {
      if (!(source in DEFAULT_BASES)) throw new Error(`Unknown scholarly source "${source}".`);
      this.#bases[source] = assertBaseUrl(source, value);
    }
    this.#contactEmail = contactEmail?.trim() || null;
  }

  async request(sourceName, path, { params = {}, headers = {} } = {}) {
    // Relative resolution preserves a path prefix in an overridden base URL.
    const url = new URL(path.replace(/^\//, ''), `${this.#bases[sourceName]}/`);
    for (const [key, value] of Object.entries(params)) {
      if (value !== undefined) url.searchParams.set(key, String(value));
    }

    const source = { url: url.href, retrieved_at: null };
    try {
      const response = await this.#fetch(url, {
        headers: this.#headers(headers),
        redirect: 'error',
        signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
      });
      source.retrieved_at = new Date().toISOString();
      if (!response.ok) {
        await response.body?.cancel();
        return upstreamFailure(source, response.status);
      }
      return { status: 'ok', source, body: await response.json() };
    } catch (error) {
      source.retrieved_at = new Date().toISOString();
      if (error.name === 'TimeoutError') {
        return failure(source, 'timeout', 'The upstream source did not respond within 15 seconds.');
      }
      if (error instanceof SyntaxError) {
        return failure(source, 'invalid_response', 'The upstream source did not return valid JSON.');
      }
      // Exception messages can contain configuration or response data.
      return failure(source, 'connection_error', 'Could not reach the upstream source; redirects are not followed.');
    }
  }

  #headers(extra) {
    // Identified callers are routed to faster pools by several providers.
    return {
      Accept: 'application/json',
      ...extra,
      'User-Agent': `rams-mcp/0.1.0${this.#contactEmail ? ` (mailto:${this.#contactEmail})` : ''}`,
    };
  }
}

function assertBaseUrl(source, value) {
  let url;
  try {
    url = new URL(value);
  } catch {
    throw new Error(`Scholarly source "${source}" needs an absolute base URL.`);
  }
  const local = ['localhost', '127.0.0.1', '[::1]'].includes(url.hostname);
  if ((url.protocol !== 'https:' && !(local && url.protocol === 'http:')) ||
      url.username || url.password || url.search || url.hash) {
    throw new Error(`Scholarly source "${source}" must use HTTPS (HTTP only on loopback) and carry no credentials, query, or fragment.`);
  }
  return url.href.replace(/\/$/, '');
}

function upstreamFailure(source, status) {
  const message = {
    401: 'The upstream source rejected the request credential.',
    403: 'The upstream source refused this query.',
    429: 'The upstream source rate limited this client; retry later.',
  }[status] ?? 'The upstream source could not complete this query.';
  return failure(source, 'upstream_error', message, status);
}

function failure(source, code, message, httpStatus) {
  return {
    status: 'error',
    source,
    error: { code, message, ...(httpStatus === undefined ? {} : { http_status: httpStatus }) },
  };
}
