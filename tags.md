---
title: 标签索引
eyebrow: "TERMINUS LOG / TOPICS"
description: "沿着一个关键词，找到相关的文章。"
layout: menu-page
permalink: /tags/
---


{% assign sorted_tags = site.tags | sort %}
<div class="tag-cloud">
  <ul class="tags">
  {% for tag in sorted_tags %}
    <li>
      <a href="{{ '/tag/' | relative_url }}?tag={{ tag[0] | url_encode }}" class="tag">
        {{ tag[0] }} <span>({{ tag[1].size }})</span>
      </a>
    </li>
  {% endfor %}
  </ul>
</div>
