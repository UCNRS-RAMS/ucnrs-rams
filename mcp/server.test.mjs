import assert from 'node:assert/strict';
import { createServer as createHttpServer } from 'node:http';
import { once } from 'node:events';
import { spawn } from 'node:child_process';
import { mkdtemp, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';
import { Client } from '@modelcontextprotocol/client';
import { StdioClientTransport } from '@modelcontextprotocol/client/stdio';

const serverPath = fileURLToPath(new URL('./server.mjs', import.meta.url));

async function connect(t, handler, credential = { RAMS_API_TOKEN: 'test-secret' }) {
  const http = createHttpServer((request, response) => {
    const url = new URL(request.url, 'http://localhost');
    if (url.pathname.startsWith('/api/v1') && request.headers.authorization !== 'Bearer test-secret') {
      response.writeHead(401).end();
      return;
    }
    handler(url, response);
  });
  http.listen(0, '127.0.0.1');
  await once(http, 'listening');
  t.after(() => new Promise(resolve => http.close(resolve)));
  const client = new Client({ name: 'rams-regression', version: '1.0.0' });
  const transport = new StdioClientTransport({
    command: process.execPath,
    args: [serverPath],
    env: { RAMS_API_URL: `http://127.0.0.1:${http.address().port}/api/v1`, ...(typeof credential === 'function' ? credential(http.address().port) : credential) },
    stderr: 'pipe',
  });
  t.after(() => client.close());
  await client.connect(transport);
  return client;
}

function json(response, body, status = 200) {
  response.writeHead(status, { 'Content-Type': 'application/json' }).end(JSON.stringify(body));
}

function collection(data, { page = 1, per_page = 1, total_count = data.length } = {}) {
  return { data, meta: { page, per_page, total_count, total_pages: Math.ceil(total_count / per_page) } };
}

test('a final page is not the complete collection; continuation preserves filters', async t => {
  const client = await connect(t, (url, response) => {
    const page = Number(url.searchParams.get('page') ?? 1);
    json(response, collection([{ id: page, type: 'visits' }], { page, total_count: 2 }));
  });
  const first = (await client.callTool({ name: 'list_visits', arguments: { project_id: 7, status: 'approved', per_page: 1 } })).structuredContent;
  assert.equal(first.pagination.complete, false);
  assert.equal(first.pagination.total_count, 2);
  assert.equal(first.pagination.returned_count, 1);
  assert.deepEqual(first.pagination.next_call, {
    tool: 'list_visits', arguments: { project_id: 7, status: 'approved', per_page: 1, page: 2 },
  });
  const second = (await client.callTool({ name: first.pagination.next_call.tool, arguments: first.pagination.next_call.arguments })).structuredContent;
  assert.deepEqual(second.data.map(record => record.id), [2]);
  assert.equal(second.pagination.next_call, null);
  assert.equal(second.pagination.complete, false);
});

test('a dossier distinguishes inaccessible reserve, failed funding, and empty visits', async t => {
  const client = await connect(t, (url, response) => {
    if (url.pathname === '/api/v1/projects/7') {
      json(response, { data: { id: 7, type: 'projects', reserve: { id: 9 } } });
    } else if (url.pathname === '/api/v1/reserves/9') {
      json(response, { error: 'not_found' }, 404);
    } else if (url.pathname === '/api/v1/fundings') {
      json(response, { error: 'unavailable' }, 503);
    } else {
      json(response, collection([]));
    }
  });
  const result = await client.callTool({ name: 'get_project_context', arguments: { project_id: 7 } });
  const dossier = result.structuredContent;
  assert.equal(result.isError, false);
  assert.equal(dossier.status, 'partial');
  assert.equal(dossier.project.data.id, 7);
  assert.equal(dossier.reserve.error.code, 'not_found_or_inaccessible');
  assert.equal(dossier.fundings.status, 'error');
  assert.equal(dossier.fundings.data, undefined);
  assert.equal(dossier.visits.status, 'ok');
  assert.deepEqual(dossier.visits.data, []);
  assert.equal(dossier.visits.pagination.complete, true);
  assert.equal(dossier.coverage.all_matching_collections_returned, false);
});

test('unsupported and contradictory filters fail rather than broadening a query', async t => {
  let reads = 0;
  const client = await connect(t, (_url, response) => {
    reads++;
    json(response, collection([]));
  });
  for (const [name, args] of [
    ['list_projects', { orcid: '0000-0000-0000-0000' }],
    ['list_visits', { starts_on: '2026-10-10', ends_on: '2026-10-01' }],
    ['list_institutions', { state_code: 'CA' }],
    ['get_project_context', { project_id: 7, per_page: 101 }],
  ]) {
    const result = await client.callTool({ name, arguments: args });
    assert.equal(result.isError, true);
  }
  assert.equal(reads, 0);
});

test('redirects never forward credentials or turn an upstream failure into data', async t => {
  let redirected = false;
  const client = await connect(t, (url, response) => {
    if (url.pathname === '/credential-capture') {
      redirected = true;
      json(response, collection([]));
    } else {
      response.writeHead(302, { Location: '/credential-capture' }).end();
    }
  });
  const result = await client.callTool({ name: 'list_projects', arguments: {} });
  assert.equal(result.isError, true);
  assert.equal(result.structuredContent.error.code, 'connection_error');
  assert.equal(redirected, false);
  assert.equal(JSON.stringify(result).includes('test-secret'), false);
});

test('search_outputs turns RAMS identifiers into unconfirmed candidates and never into provenance', async t => {
  const scholarly = port => JSON.stringify({
    datacite: `http://127.0.0.1:${port}/scholarly/datacite`,
    openalex: `http://127.0.0.1:${port}/scholarly/openalex`,
    crossref: `http://127.0.0.1:${port}/scholarly/crossref`,
  });
  const client = await connect(t, (url, response) => {
    switch (url.pathname) {
      case '/api/v1/projects/7':
        return json(response, { data: { id: 7, type: 'projects', reserve: { id: 27 }, owner: { id: 1, orcid: '0000-0002-3004-1423' }, applicant: null } });
      case '/api/v1/reserves/27':
        return json(response, { data: { id: 27, type: 'reserves', name: 'Quail Ridge Reserve', doi: 'doi:10.21973/N30T0K' } });
      case '/api/v1/fundings':
        return json(response, collection([{ id: 13011, type: 'fundings', grant_number: 'DEB-1234567' }]));
      case '/api/v1/visits':
        return json(response, collection([]));
      case '/scholarly/datacite/dois':
        return json(response, { data: [{ id: '10.21973/n30t0k', attributes: { doi: '10.21973/N30T0K', titles: [{ title: 'Quail Ridge plot data' }], publicationYear: 2024, types: { resourceTypeGeneral: 'Dataset' } } }] });
      case '/scholarly/openalex/works':
        return json(response, { results: [] });
      case '/scholarly/crossref/works':
        return json(response, { message: { items: [] } });
      default:
        return response.writeHead(404).end();
    }
  }, port => ({ RAMS_API_TOKEN: 'test-secret', RAMS_SCHOLARLY_BASES: scholarly(port) }));

  const result = await client.callTool({ name: 'search_outputs', arguments: { project_id: 7, ror: '04SK0ET52' } });
  const search = result.structuredContent;

  assert.equal(result.isError, false);
  assert.equal(search.status, 'ok');
  // The reserve record stores its DOI as free text, so the search key is normalized.
  assert.deepEqual(search.search_keys.reserve_dois, ['10.21973/n30t0k']);
  assert.deepEqual(search.search_keys.orcids, [{ orcid: '0000-0002-3004-1423', role: 'owner' }]);
  assert.deepEqual(search.search_keys.rors, [{ ror: 'https://ror.org/04sk0et52', source: 'caller_supplied' }]);
  assert.deepEqual(search.sources.map(source => source.source).sort(), ['crossref', 'datacite', 'openalex']);

  assert.equal(search.candidates.length, 1);
  const [candidate] = search.candidates;
  assert.equal(candidate.doi, '10.21973/n30t0k');
  assert.equal(candidate.title, 'Quail Ridge plot data');
  assert.equal(candidate.year, 2024);
  assert.equal(candidate.relation, 'unconfirmed');
  assert.equal(candidate.url, 'https://doi.org/10.21973/n30t0k');
  // The same dataset answered the reserve-DOI, award-number, and ROR queries.
  assert.deepEqual([...new Set(candidate.observed_in.map(entry => entry.source))], ['datacite']);
  assert.equal(candidate.observed_in.length, 3);
  assert.equal(search.coverage.external_output_search, 'performed');
  assert.equal(search.coverage.linkage_confirmation, 'not_performed');
});

test('search_outputs reports key reads that did not cover a whole record set', async t => {
  const client = await connect(t, (url, response) => {
    switch (url.pathname) {
      case '/api/v1/projects/7':
        return json(response, { data: { id: 7, type: 'projects', reserve: null, owner: { id: 1, orcid: '0000-0002-3004-1423' }, applicant: null } });
      case '/api/v1/fundings':
        return json(response, collection([]));
      case '/api/v1/visits':
        return json(response, collection([{ id: 1, type: 'visits', visitors: [] }], { per_page: 100, total_count: 40 }));
      case '/scholarly/datacite/dois':
      case '/scholarly/openalex/works':
      case '/scholarly/crossref/works':
        return json(response, url.pathname === '/scholarly/datacite/dois' ? { data: [] } : { results: [], message: { items: [] } });
      default:
        return response.writeHead(404).end();
    }
  }, port => ({
    RAMS_API_TOKEN: 'test-secret',
    RAMS_SCHOLARLY_BASES: JSON.stringify({
      datacite: `http://127.0.0.1:${port}/scholarly/datacite`,
      openalex: `http://127.0.0.1:${port}/scholarly/openalex`,
      crossref: `http://127.0.0.1:${port}/scholarly/crossref`,
    }),
  }));

  const search = (await client.callTool({ name: 'search_outputs', arguments: { project_id: 7 } })).structuredContent;

  assert.equal(search.status, 'ok');
  assert.deepEqual(search.search_keys.read_coverage, [
    { resource: 'fundings', returned: 0, total: 0, complete: true },
    { resource: 'visits', returned: 1, total: 40, complete: false },
  ]);
  assert.ok(search.evidence_limits.some(limit => limit.includes('covered 1 of 40')));
});

test('search_outputs rejects a keyless or malformed request without reading RAMS', async t => {
  let reads = 0;
  const client = await connect(t, (_url, response) => {
    reads++;
    json(response, collection([]));
  });
  const names = (await client.listTools()).tools.map(tool => tool.name);
  assert.ok(names.includes('search_outputs'));

  for (const args of [
    {},
    { project_id: 7, doi: 'https://ror.org/04sk0et52' },
    { reserve_id: 27, orcid: 'not-an-orcid' },
    { ror: 'not-a-ror' },
    { project_id: 7, per_source: 101 },
  ]) {
    const result = await client.callTool({ name: 'search_outputs', arguments: args });
    assert.equal(result.isError, true, `expected ${JSON.stringify(args)} to be rejected`);
  }
  assert.equal(reads, 0);
});

test('a token file supplies the credential when RAMS_API_TOKEN is absent', async t => {
  const directory = await mkdtemp(join(tmpdir(), 'rams-mcp-test-'));
  t.after(() => rm(directory, { recursive: true, force: true }));
  const tokenFile = join(directory, 'token');
  await writeFile(tokenFile, 'test-secret\n', { mode: 0o600 });

  const client = await connect(t, (_url, response) => json(response, collection([])), { RAMS_API_TOKEN_FILE: tokenFile });
  const result = await client.callTool({ name: 'list_projects', arguments: {} });
  assert.equal(result.structuredContent.status, 'ok');
});

test('startup fails loudly and names both credential sources when none is usable', async t => {
  const directory = await mkdtemp(join(tmpdir(), 'rams-mcp-test-'));
  t.after(() => rm(directory, { recursive: true, force: true }));

  for (const credential of [{}, { RAMS_API_TOKEN_FILE: join(directory, 'missing') }]) {
    const child = spawn(process.execPath, [serverPath], {
      env: { RAMS_API_URL: 'http://127.0.0.1:1/api/v1', ...credential },
      stdio: ['pipe', 'pipe', 'pipe'],
    });
    let stderr = '';
    child.stderr.on('data', chunk => { stderr += chunk; });
    const code = await new Promise(resolve => child.on('exit', resolve));
    child.stdin.end();

    assert.equal(code, 1);
    assert.match(stderr, /RAMS_API_TOKEN\b/);
    assert.match(stderr, /RAMS_API_TOKEN_FILE/);
  }
});
