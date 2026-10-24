# Typography selection · 2026-10-25

User direction: modest, unforced tone; monochrome editorial design inspired by thedankoe.com; technical and non-technical writing; homepage verse “泥上偶然留指爪，鸿飞那复计东西。”

The visual judgments below are decisions for this site, not claims that one family is universally more readable.

| Candidate | Official source and evidence | Decision for this blog |
| --- | --- | --- |
| Noto Serif SC / Source Han Serif | [Adobe specimen](https://source.typekit.com/source-han-serif/) describes the shared CJK design and coordinated Latin derived from Source Serif. [Noto repository](https://github.com/notofonts/noto-cjk) documents Google Fonts naming. | Selected for the poem and article prose: restrained Song/Ming texture, suitable for essays as well as technical explanation. Use 18px text; keep mathematical code and tables in their own roles. |
| Noto Sans SC / Source Han Sans | [Adobe designer interview](https://blog.typekit.com/2014/08/14/interview-with-ryoko-nishizuka/) discusses smartphone and long-text design. [Noto CJK](https://github.com/notofonts/noto-cjk) supplies SC language coverage. | Selected Chinese companion for the existing bold, modern interface. Chinese headings become consistent across platforms instead of relying exclusively on installed system fonts. |
| LXGW WenKai / WenKai Screen | [Author repository](https://github.com/lxgw/LxgwWenKai-Screen) describes adjusted weight and metrics, and explicitly cautions about macOS rendering. | Considered; calligraphic character is stronger than needed for this site. Do not make every essay or technical passage look handwritten. |
| Source Serif 4 | [Adobe repository](https://github.com/adobe-fonts/source-serif) provides a multilingual text serif with sizes and weights. | Selected Latin companion to Noto Serif SC. Inspection of the actual English post revealed a wide apostrophe in “I'll” when the SC punctuation was used. Source Serif 4 provides proportional Western punctuation and optical sizing, and lets English prose avoid the Chinese punctuation subset. |
| Geist Sans / Geist Mono | [Official repository](https://github.com/vercel/geist-font) describes Sans's legibility and Swiss influence and Mono's code role. | Keep Geist Sans for Latin titles and interface; use its Mono partner for code. Both align with the existing quiet geometric design. |
| JetBrains Mono | [Official specimen](https://www.jetbrains.com/lp/mono/) describes distinguishable 1/l/I and zero/O, small-size construction and code ligatures. | Valid alternative, but Geist Mono gives this small site a more cohesive Latin family. Operator ligatures remain disabled. |

## Loading and maintenance

[web.dev font best practices](https://web.dev/articles/font-best-practices) supports WOFF2, Unicode subsets and attention to preload scope. Fonts are self-hosted, with original Google Fonts Unicode ranges and all supplied subsets retained, not a one-off extraction of today's article characters. Browsers request only ranges used in the current page. `font-display: swap` and system fallbacks keep text visible. Do not preload the full CJK set.

`assets/fonts/journal/SOURCES.json` records the downloaded upstream URLs, SHA-256 and bytes. The derived priority subsets also record the exact Unicode coverage and original source TTF hashes. Small interface, Chinese reading and verse subsets avoid fetching many large fragments just for the poem; original full ranges remain behind them for future writing. Latin body text stays in its separate upstream subset so English pages avoid the Chinese reading core. The fontTools transformation restricts the weight axis to 400–700 and retains OFL licensing.

Original OFL licenses ship beside each family. Source Markdown stays unchanged. Inspect the homepage, both real articles, mobile/desktop, and both color schemes after type changes.

## Final verification

- Jekyll build succeeds; ten generated pages retain valid local assets, links, unique IDs, search JSON, RSS and JSON-LD.
- Full font files and priority subsets decode; local CSS paths and recorded SHA-256 values match.
- Homepage, Chinese OPC article and English welcome article inspected at 1440×900 and 390×844. Light mode also checked in the browser. No font errors, external font requests or horizontal overflow in those six captures.
- Cold font transfer: homepage 224,088 bytes (~219 KiB), OPC article 331,172 bytes (~323 KiB), English article 217,240 bytes (~212 KiB). Homepage had required 1,218,572 bytes before priority subsets. These are font payloads, not total page size or a real-network speed benchmark.
- Hallmark rendered check: 0 FAIL, 0 open REFLEX, 0 WARN; the two documented layout waivers remain.
