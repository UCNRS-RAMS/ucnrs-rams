import assert from 'node:assert/strict';
import test from 'node:test';
import {
  addExplicitOutputKeys,
  emptyOutputKeys,
  normalizeAward,
  normalizeDoi,
  normalizeOrcid,
  normalizeRor,
} from './output_identifiers.mjs';

const ORCID = '0000-0002-3004-1423';

test('normalizes scholarly identifiers and rejects unusable values', () => {
  assert.equal(normalizeDoi('https://doi.org/10.21973/N30T0K'), '10.21973/n30t0k');
  assert.equal(normalizeDoi('doi:10.1038/S41586-020-2649-2.'), '10.1038/s41586-020-2649-2');
  assert.equal(normalizeDoi('10.21973/N3FT0M'), '10.21973/n3ft0m');
  // Reserve records store free text here: a ROR, a placeholder, or nothing.
  assert.equal(normalizeDoi('https://ror.org/04sk0et52'), null);
  assert.equal(normalizeDoi('doi:number'), null);
  assert.equal(normalizeDoi(''), null);
  assert.equal(normalizeDoi(undefined), null);

  assert.equal(normalizeOrcid(`https://orcid.org/${ORCID}`), ORCID);
  assert.equal(normalizeOrcid('0000-0001-5732-5613'), '0000-0001-5732-5613');
  assert.equal(normalizeOrcid('0000-0002-3004'), null);
  assert.equal(normalizeOrcid(''), null);

  assert.equal(normalizeRor('https://ror.org/04SK0ET52'), 'https://ror.org/04sk0et52');
  assert.equal(normalizeRor('04sk0et52'), 'https://ror.org/04sk0et52');
  assert.equal(normalizeRor('https://ror.org/not-a-ror'), null);
  assert.equal(normalizeRor(''), null);

  assert.deepEqual(normalizeAward(' DEB-1234567 '), { value: 'DEB-1234567', key: 'DEB1234567' });
  assert.equal(normalizeAward('   '), null);
});

test('caller-supplied identifiers compose with collected keys without duplicates', () => {
  const collected = emptyOutputKeys();
  collected.orcids.push({ orcid: ORCID, role: 'owner' });

  const keys = addExplicitOutputKeys(collected, {
    orcid: [`https://orcid.org/${ORCID}`, '0000-0001-5732-5613'],
    ror: '04SK0ET52',
    grant_number: 'DEB-1234567',
    doi: 'https://doi.org/10.21973/N30T0K',
  });

  assert.deepEqual(keys.orcids, [
    { orcid: ORCID, role: 'owner' },
    { orcid: '0000-0001-5732-5613', role: 'caller_supplied' },
  ]);
  assert.deepEqual(keys.rors, [{ ror: 'https://ror.org/04sk0et52', source: 'caller_supplied' }]);
  assert.deepEqual(keys.grants, [{ value: 'DEB-1234567', key: 'DEB1234567', sponsor: null }]);
  assert.deepEqual(keys.dois, [{ doi: '10.21973/n30t0k' }]);
});
