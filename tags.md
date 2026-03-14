---
title: Tags
layout: menu-page
permalink: /tags/
---

## Tag Index

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
