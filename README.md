# Personal Homepage

This is my personal homepage built with Jekyll and GitHub Pages.

## Local Development

To run this website locally:

1. Install Ruby and Bundler
2. Run `bundle install`
3. Run `bundle exec jekyll serve`
4. Visit `http://localhost:4000`

## Writing Workflow

Use [`docs/post-template.md`](docs/post-template.md) when creating new posts.

1. Copy the template into `_posts/YYYY-MM-DD-your-title.md`
2. Fill `title` and `description`; `categories`, `tags` and `img` are optional
3. Keep image paths relative to `assets/img/` (example: `posts/welcome.svg`)
4. Commit and push to `master` to publish via GitHub Pages

## Computational lithography series

Each of the fourteen articles is self-contained, with its own definitions, derivations, numbered source citations and figure credits. Articles do not depend on a reading order or cite other posts on this site. Third-party image sources, reuse licenses, changes and checksums are listed in [the image provenance record](assets/images/references/README.md). Research verification notes are kept in `docs/research/` (excluded from the published site).

## License

This project is licensed under the MIT License - see the LICENSE file for details. 

## Design

The shared design follows [Sone Blog](https://s1.work/categories/): a warm dark background, orange accents, narrow reading column, terminal-style navigation and monospace typography. Geist Mono and Noto Sans SC are served locally. Font sources and licenses live in `assets/fonts/journal/`. Styles live in `assets/css/journal.css`, colors and typography in `assets/css/tokens.css`, and navigation in `_data/navigation.yml`.

- Dark appearance is the default; the header toggle saves a light/dark preference.
- Search supports titles, categories, tags and article text, with `Cmd/Ctrl + K` and `Esc` shortcuts.
- Post covers are optional. Set `toc: true` for a table of contents and `mathjax: true` for formulas.
- The existing Jekyll pagination, RSS feed, tag routes and post URLs are retained.

Build and regression checks:

```sh
JEKYLL_ENV=production bundle exec jekyll build
bundle exec ruby scripts/check_site.rb _site
```

## Categories and tags

`/categories/`, `/archive/` and `/blog/` share an automatically generated category/tag index and chronological timeline. Counts and filtered article lists are calculated at build time using Liquid, compatible with GitHub Pages without custom plugins.

Explicit post metadata takes priority. When a category is absent, ordered title and tag rules in `_data/taxonomy.yml` select a category, falling back to 随笔. When tags are absent, keyword rules extract tags from the title and description. This is deterministic keyword matching; new topics can be supported by adding rules or explicit metadata. Existing post URLs and `/tag/?tag=...` links are retained.
