import { readFile } from 'node:fs/promises';

export async function configFromEnvironment(env) {
  const { token, source: credentialSource } = await resolveCredential(env);
  const scholarlyBases = resolveScholarlyBases(env);
  return {
    config: {
      baseUrl: env.RAMS_API_URL,
      token,
      contactEmail: env.RAMS_OUTPUT_CONTACT_EMAIL,
      zoteroApiKey: env.ZOTERO_API_KEY,
      scholarlyBases,
    },
    credentialSource,
    scholarlyBaseNames: Object.keys(scholarlyBases),
  };
}

// The source is safe to log; the credential never is.
async function resolveCredential(env) {
  const direct = env.RAMS_API_TOKEN?.trim();
  if (direct) return { token: direct, source: 'RAMS_API_TOKEN' };

  const path = env.RAMS_API_TOKEN_FILE?.trim();
  if (!path) return {};
  try {
    return {
      token: (await readFile(path, 'utf8')).trim(),
      source: `RAMS_API_TOKEN_FILE=${path}`,
    };
  } catch (error) {
    throw new Error(`cannot read RAMS_API_TOKEN_FILE (${path}): ${error.code ?? error.message}`);
  }
}

function resolveScholarlyBases(env) {
  const raw = env.RAMS_SCHOLARLY_BASES?.trim();
  if (!raw) return {};

  let bases;
  try {
    bases = JSON.parse(raw);
  } catch {
    throw new Error('RAMS_SCHOLARLY_BASES must be a JSON object mapping source names to base URLs.');
  }
  if (!bases || typeof bases !== 'object' || Array.isArray(bases)) {
    throw new Error('RAMS_SCHOLARLY_BASES must be a JSON object mapping source names to base URLs.');
  }
  return bases;
}
