# Journal webfonts

Locally hosted OFL-licensed WOFF2 fonts. See each family directory's `OFL.txt` and `SOURCES.json` for exact upstream URLs, sizes and SHA-256 checksums (retrieved 2026-10-25).

- Geist: Latin headings and interface.
- Noto Sans SC: Chinese headings and interface.
- Noto Serif SC: Chinese article prose and the homepage verse.
- Source Serif 4: Latin prose with proportional punctuation and optical sizing.
- Geist Mono: code.

`assets/css/fonts.css` preserves the full published Unicode ranges. Small priority subsets cover the shared interface, current Chinese prose, and the verse; their exact ranges, source font checksums and transformation method are recorded in `SOURCES.json` under `derived`. They were generated with fontTools 4.67.0 and the original OFL licenses apply. Latin prose uses the separate Source Serif 4 family, so English pages do not download the Chinese reading core.

All supplied upstream subsets remain available behind those priority subsets: later articles can use new characters without rebuilding fonts. A browser downloads only ranges used by a page. Font display uses `swap`; installed system fonts are fallbacks. No external font service is needed by readers.

Selection rationale and source links: `.hallmark/typography-research.md`. Font roles and reading size: `assets/css/tokens.css`.
