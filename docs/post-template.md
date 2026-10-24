# 写一篇手记

复制下面的内容到 `_posts/YYYY-MM-DD-your-title.md`。日期使用实际发布日期。

```markdown
---
layout: post
title: "手记标题"
date: 2026-10-25
author: 端点星日志
description: "用一句话说清楚这篇手记写什么。"
tags: [随笔]
toc: true
---

直接写引言，页面会自动显示文章标题。

## 问题从哪里来

正文。

## 做了什么

正文。

## 参考资料

- 相关链接与出处。
```

- `img` 可选，路径相对 `assets/img/`。没有封面图也能正常显示。
- `toc: true` 显示可展开的文章目录。
- `mathjax: true` 启用公式，支持 `$...$` 和 `$$...$$`。
- `mermaid: true` 启用 Mermaid 图表。
- 分类、标签及其文章数量在构建时自动汇总到 `/categories/`。
- `categories: [分类名]` 可选；省略时会按标题和已有标签匹配 `_data/taxonomy.yml` 中的规则，没有匹配则归入“随笔”。
- `tags` 可选；省略时按标题和摘要中的关键词提取。已有标签会优先保留，规则在 `_data/taxonomy.yml` 中维护。
- 标题、摘要、分类、标签和正文都会参与搜索。
