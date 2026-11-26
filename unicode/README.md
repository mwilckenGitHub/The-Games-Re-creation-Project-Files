# Unicode With String Functions for GameMaker

Version 1.1.0 includes Unicode 18.0.0 character data and native GML scripts. The legacy functions for filtering letters, digits, punctuation, symbols, control characters and whitespace keep their existing names. Uppercase, lowercase and titlecase use full Unicode mappings, including multi-character expansions and contextual Greek sigma. The package also exposes `unicode_casefold()`, `unicode_nfc()`, `unicode_search_key()`, `Graphemes` and `Word_breaks`.

Import the .yymps through **Tools → Import Local Package**. Include all five script assets and the Unicode Included Files. The runtime reads the bundled CSVs on demand. No network access or native extension is required.

Applications that directly inspect the old raw data structures can initialize them through `Unicode_set_mode(UNICODE_LOOKUP_MODE_MAP)` or select explicit planes with `Unicode_set_mode(UNICODE_LOOKUP_MODE_GRID, [0, 1])`. Grid rows are indexed by full code point, including unloaded planes. Call `Unicode_release_tables()` when the raw data structures are no longer needed. The public text functions work without that initialization.

For code that adds and drops planes over time, create a cache and release it when finished.

```gml
var cache = new Unicode_plane_cache([0]);
cache.load(1);
var entry = cache.get($10400);
cache.unload(1);
cache.clean_up();
```

`get_planes()` lists the loaded planes. `set_planes([0, 1])` replaces the selection, and a failed read preserves the prior selection. `get()` returns a copy of the legacy 18-column row, or `undefined` when the plane or assignment is absent.

Legacy callers can also select planes with `Unicode_set_mode(UNICODE_LOOKUP_MODE_MAP, [0, 1])`. The map opens only those plane CSVs and retains only their assigned-category rows. Use `[]` for an empty map. Grid mode maintains full code-point indexing and reserves rows for unloaded planes.

Both raw modes use the same 18-column records in Included Files → Unicode. The map includes every code point with a general category other than `Cn`, including the interior of UnicodeData's First/Last ranges. Dense plane files additionally include `Cn` rows with their derived bidirectional class. Algorithmic character names and derived numeric values appear in both modes. The `<surrogate>`, `<private-use>`, `<noncharacter>`, and `<unassigned>` entries are descriptive labels for unnamed code points.

## Rebuild the tables and package

Use Python 3.10 or newer. From the repository root, run the following commands.

```sh
python3 unicode/build_tables.py --fetch \
  --input-dir build/ucd-cache --project-dir build/unicode-project \
  --fixture-dir build/unicode-fixtures
python3 unicode/verify_tables.py build/ucd-cache build/unicode-project/datafiles/Unicode
python3 unicode/package_asset.py \
  --base-package 'Unicode With String Functions.yymps' \
  --scripts unicode/scripts --project-dir build/unicode-project \
  --output 'build/Unicode With String Functions-1.1.0.yymps'
```

The first run downloads the named files from the versioned Unicode Character Database. The pinned SHA-256 hashes in `sources.json` apply to downloaded files and cache hits. Subsequent builds can omit `--fetch` to require a verified local cache. To update the Unicode version, review the upstream release, source paths and hashes together, then regenerate the tables and rerun conformance tests.

The Unicode data license is in [Unicode-license.txt](Unicode-license.txt). Unicode 18.0.0 is documented by the [Unicode Consortium](https://www.unicode.org/versions/Unicode18.0.0/).
