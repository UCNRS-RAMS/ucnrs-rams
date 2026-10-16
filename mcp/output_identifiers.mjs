const DOI_PREFIX = /^10\.\d{4,9}\//;
const ORCID = /^\d{4}-\d{4}-\d{4}-\d{3}[\dX]$/;
const ROR = /^0[0-9a-hj-km-np-tv-z]{6}\d{2}$/;

export function normalizeDoi(value) {
  if (typeof value !== 'string') return null;
  let doi = value.trim().toLowerCase().replace(/^https?:\/\/(dx\.)?doi\.org\//, '').replace(/^doi:\s*/, '');
  try {
    doi = decodeURIComponent(doi);
  } catch {
    return null;
  }
  doi = doi.replace(/[.,;:\])}]+$/, '');
  return DOI_PREFIX.test(doi) ? doi : null;
}

export function normalizeOrcid(value) {
  if (typeof value !== 'string') return null;
  const orcid = value.trim().replace(/^https?:\/\/orcid\.org\//i, '').toUpperCase();
  return ORCID.test(orcid) ? orcid : null;
}

export function normalizeRor(value) {
  if (typeof value !== 'string') return null;
  const id = value.trim().replace(/^https?:\/\/(?:www\.)?ror\.org\//i, '').replace(/\/$/, '').toLowerCase();
  return ROR.test(id) ? `https://ror.org/${id}` : null;
}

// Award numbers are free text in RAMS, so retain both the query value and a
// letters-and-digits key for deduplication.
export function normalizeAward(value) {
  if (typeof value !== 'string') return null;
  const award = value.trim();
  if (!award) return null;
  return { value: award, key: award.toUpperCase().replace(/[^0-9A-Z]/g, '') };
}

export function emptyOutputKeys() {
  return { dois: [], rors: [], orcids: [], grants: [] };
}

export function dedupeOutputKeys(keys) {
  return {
    dois: dedupe(keys.dois, entry => entry.doi),
    rors: dedupe(keys.rors, entry => entry.ror),
    orcids: dedupe(keys.orcids, entry => entry.orcid),
    grants: dedupe(keys.grants, entry => entry.key),
  };
}

export function addExplicitOutputKeys(keys, { orcid, ror, grant_number, doi }) {
  const combined = {
    dois: [...keys.dois],
    rors: [...keys.rors],
    orcids: [...keys.orcids],
    grants: [...keys.grants],
  };

  for (const value of arrayOf(orcid)) {
    const normalized = normalizeOrcid(value);
    if (normalized) combined.orcids.push({ orcid: normalized, role: 'caller_supplied' });
  }
  for (const value of arrayOf(ror)) {
    const normalized = normalizeRor(value);
    if (normalized) combined.rors.push({ ror: normalized, source: 'caller_supplied' });
  }
  const award = normalizeAward(grant_number);
  if (award) combined.grants.push({ ...award, sponsor: null });
  const explicitDoi = normalizeDoi(doi);
  if (explicitDoi) combined.dois.push({ doi: explicitDoi });

  return dedupeOutputKeys(combined);
}

export function selectOutputKeys(keys, { maxOrcids, maxRors, maxGrants }) {
  return {
    usable: {
      dois: keys.dois,
      rors: keys.rors.slice(0, maxRors).map(entry => entry.ror),
      orcids: keys.orcids.slice(0, maxOrcids).map(entry => entry.orcid),
      grants: keys.grants.slice(0, maxGrants),
    },
    truncated: {
      orcids: keys.orcids.length > maxOrcids,
      rors: keys.rors.length > maxRors,
      grants: keys.grants.length > maxGrants,
    },
  };
}

export function outputKeyReport(keys, usable, truncated, reads) {
  return {
    reserve_dois: keys.dois.map(entry => entry.doi),
    rors: keys.rors.map(entry => ({ ror: entry.ror, source: entry.source })),
    orcids: keys.orcids.map(entry => ({ orcid: entry.orcid, role: entry.role })),
    award_numbers: keys.grants.map(entry => ({ award_number: entry.value, sponsor: entry.sponsor })),
    queried: {
      dois: usable.dois.length,
      rors: usable.rors.length,
      orcids: usable.orcids.length,
      award_numbers: usable.grants.length,
    },
    truncated,
    read_coverage: reads.filter(read => read.coverage).map(read => ({ resource: read.resource, ...read.coverage })),
  };
}

function arrayOf(value) {
  if (value === undefined) return [];
  return Array.isArray(value) ? value : [value];
}

function dedupe(entries, keyFor) {
  const seen = new Set();
  return entries.filter(entry => {
    const key = keyFor(entry);
    if (!key || seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}
