# Design: 端点星日志

Shared system for the Jekyll site. Hallmark checks apply; the user's reference overrides Studio's ornamental material.

## User direction

Reference https://thedankoe.com/ for visual tone, without copying its layout, brand or copy. No self-introduction. Future writing includes non-technical topics.

## System

- Editorial article index with a centered, topic-neutral opening.
- Dark graphite and near-white ink. A light mode remains available through the existing control.
- Large bold sans-serif typography; visible hierarchy from scale and weight, not accent words or labels.
- The homepage shows articles and the real KLayout project. No portrait, personal biography, customer counts, decorative drawing, placeholder photography or sales sections.
- No repeated English eyebrows, ordinal section markers, decorative dots or appended link arrows.

## Tokens

`assets/css/tokens.css` is the source of truth for all colors, spacing and font roles.

- Titles and interface: Geist for Latin, Noto Sans SC for Chinese, with system sans fallbacks.
- Articles and the homepage verse: Noto Serif SC (the Google-branded Source Han Serif family). Source Serif 4 handles Latin text and proportional punctuation, with automatic optical sizing in articles. This avoids CJK-width apostrophes in English prose. System Songti/SimSun are offline fallbacks.
- Code only: Geist Mono; ligatures are disabled so operator characters stay explicit.
- Font weights: 400–700 variable files; interface uses 400/500/700, prose uses 400/700.
- Interface 16px; metadata 14px; article prose 18px with 1.9 leading on both desktop and mobile. Headings and tables retain the sans family.
- All font files are local WOFF2, with OFL licenses and source checksums beside them. Small priority subsets cover the shared interface, current Chinese prose and verse. Full published Unicode subsets remain available behind these, selected lazily by the browser; future posts do not require a font rebuild. Latin body text stays a separate subset so English pages avoid Chinese reading downloads.
- Fonts use `font-display: swap`; text remains available while fonts load or if a font fails. No third-party font requests at runtime.
- Chosen homepage verse: 泥上偶然留指爪，鸿飞那复计东西。 Each half stays together when the narrow viewport requires a line break.
- Capped container: 1184px including desktop gutters. Reading pages: 760px.

## Controls

- One primary reading action, 48px tall; ordinary article links remain typographic.
- Search and appearance controls have 44px targets and instant visible focus.
- Preserve search input/dialog and theme-button IDs, article URLs, RSS, tags and pagination.
- Default dark appearance; an explicitly saved light/dark preference wins.

## Variants

Article pages are long documents, not landing pages. Their original Markdown and headings remain. Short project pages do not gain invented examples or decorative content to meet a marketing-section count.

## Motion

Still. Content is visible without scripting. No entrance animations or automated cycling.

## Exports

`assets/css/tokens.css`, `assets/css/base.css`, `assets/css/fonts.css`, `assets/css/journal.css`.
