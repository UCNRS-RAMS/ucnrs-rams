import { pathToFileURL } from 'node:url';
import { McpServer } from '@modelcontextprotocol/server';
import { StdioServerTransport } from '@modelcontextprotocol/server/stdio';
import { RamsApi, evidenceLimits } from './api.mjs';
import { configFromEnvironment } from './config.mjs';
import { OutputSearch } from './outputs.mjs';
import { registerRamsTools } from './tools.mjs';

const SERVER_INFO = { name: 'rams', version: '0.1.0' };
const SERVER_INSTRUCTIONS = [
  'Read-only RAMS research access. Start with list_reserves or a known project ID.',
  'Collections return exactly one page, never an automatic crawl. Follow pagination.next_call explicitly.',
  'Use get_project_context to assemble a bounded evidence dossier. Cite source URLs and record IDs.',
  'search_outputs returns candidate publications and datasets matched on exact RAMS identifiers. Every candidate remains unconfirmed until a downstream curator links it.',
  'Unknown and inaccessible records share a 404. Never interpret a failed read as an empty collection.',
  ...evidenceLimits,
].join('\n');

export async function createServer(config) {
  const api = new RamsApi(config);
  const outputs = new OutputSearch({
    rams: api,
    fetch: config.fetch,
    bases: config.scholarlyBases,
    contactEmail: config.contactEmail,
    zoteroApiKey: config.zoteroApiKey,
  });
  const server = new McpServer(SERVER_INFO, { instructions: SERVER_INSTRUCTIONS });
  await registerRamsTools(server, { api, outputs });
  return server;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    const { config, credentialSource, scholarlyBaseNames } = await configFromEnvironment(process.env);
    const server = await createServer(config);
    await server.connect(new StdioServerTransport());
    const routed = scholarlyBaseNames.length
      ? `; scholarly base overrides: ${scholarlyBaseNames.join(', ')}`
      : '';
    console.error(`RAMS MCP ready; credential source: ${credentialSource ?? 'none'}${routed}`);
  } catch (error) {
    console.error(`RAMS MCP could not start (${error.message}). Check RAMS_API_URL, one of RAMS_API_TOKEN or RAMS_API_TOKEN_FILE, dependencies, and the committed OpenAPI contract.`);
    process.exitCode = 1;
  }
}
