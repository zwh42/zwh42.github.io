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
2. Fill `title`, `description` and `tags`; `img` is optional
3. Keep image paths relative to `assets/img/` (example: `posts/welcome.svg`)
4. Commit and push to `master` to publish via GitHub Pages

## License

This project is licensed under the MIT License - see the LICENSE file for details. 

## Design

The shared design uses locally hosted Geist / Noto Sans SC for titles and interface, Source Serif 4 / Noto Serif SC for articles and the homepage verse, and Geist Mono for code. Full WOFF2 Unicode subsets support future writing without regenerating fonts. Font sources and licenses live in `assets/fonts/journal/`; the selection research is recorded in `.hallmark/typography-research.md`. Styles live in `assets/css/journal.css`, font roles and scales in `assets/css/tokens.css`, and the design direction in `design.md`. Navigation is configured in `_data/navigation.yml`.

- Dark appearance is the default; the header toggle saves a light/dark preference.
- Search supports titles, tags and article text, with `Cmd/Ctrl + K` and `Esc` shortcuts.
- Post covers are optional. Set `toc: true` for a table of contents and `mathjax: true` for formulas.
- The existing Jekyll pagination, RSS feed, tag routes and post URLs are retained.

Build check: `bundle exec jekyll build`.

## Hallmark

The October 2026 revision uses [Hallmark](https://github.com/Nutlope/hallmark) v2.0.0. The user's visual reference is [Dan Koe](https://thedankoe.com/), limited to monochrome typography and spacing. The site has no personal introduction and its article index is topic-neutral.

Hallmark provenance and the design decisions live in `.hallmark/`. Generated screenshots and comparisons are ignored by Git. Open-source font licenses are included beside the local font files.
