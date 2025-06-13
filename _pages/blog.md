---
title: "Blog"
permalink: /blog/
author_profile: true
---

## Blog Posts

Here you'll find my thoughts, tutorials, and insights about technology and development.

{% for post in site.posts %}
  {% capture year %}{{ post.date | date: '%Y' }}{% endcapture %}
  {% if year != nyear %}
    {% assign nyear = year %}
    <h2>{{ nyear }}</h2>
  {% endif %}
  <article class="post-item">
    <span class="post-meta">{{ post.date | date: "%b %-d, %Y" }}</span>
    <h3>
      <a class="post-link" href="{{ post.url | relative_url }}">
        {{ post.title }}
      </a>
    </h3>
    {% if post.description %}
      <p>{{ post.description }}</p>
    {% endif %}
  </article>
{% endfor %} 