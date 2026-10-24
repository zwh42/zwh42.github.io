# Design: 端点星日志

The October 2026 redesign follows https://s1.work/categories/: a restrained terminal journal with warm charcoal, orange accents, monospace typography and a narrow reading column. Site identity and article URLs remain unchanged.

## Shared system

- All public pages share the same header, navigation, theme controls, reading progress and footer.
- Content column is capped at 700px including gutters. Mobile gutters reduce to 20px, and 16px on the smallest screens.
- Locally served Geist Mono handles Latin; Noto Sans SC handles Chinese. Body text is 16px with generous leading; article text is 15px on narrow screens. No external font requests.
- Warm charcoal is the default. The light theme uses warm paper. Both themes share orange accents and visible keyboard focus.
- Borders and section dividers are quiet and dashed. Category cards include counts and a proportional accent line; tags are compact pills sorted by article count.
- No self-introduction or fixed topic promise. The footer retains the original verse.

## Page structure

- Home: latest article, then a numbered single-column article list and pagination.
- Archive: category cards, tags and a year-grouped timeline. `/categories/`, `/archive/` and `/blog/` share this view.
- Category/tag results: matching articles in reverse chronological order with counts and a return link; unknown terms have an empty state.
- Articles: title, date, categories, tags, optional table of contents, original body and adjacent articles. Figures, formulas and code remain supported.
- Tools/about/404: use the same page structure and tokens.

## Content and behavior

Classification uses the metadata and ordered rules in `_data/taxonomy.yml`. Explicit categories and tags win; missing categories use title/tag keywords, with a 随笔 fallback; missing tags use title/description keywords. All indexes, counts and search metadata use the same Liquid helpers. No unsupported custom Jekyll plugins are required.

Search includes categories and retains Cmd/Ctrl+K, Escape and focus restoration. Theme choice persists locally. Main content, archive and all filter groups remain readable without JavaScript. Images, tables and code fit narrow screens. Native links, buttons, labels and dialogs retain keyboard access; reduced-motion preferences disable transitions.

## Validation

`JEKYLL_ENV=production bundle exec jekyll build` followed by `bundle exec ruby scripts/check_site.rb _site`. Browser checks cover 320px, 768px and 1280px layouts, filtering, search, theme persistence and empty states. The source of truth is `assets/css/tokens.css`, `assets/css/journal.css`, `_data/navigation.yml` and `_data/taxonomy.yml`.
