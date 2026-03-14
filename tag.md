---
title: Tag Archive
layout: menu-page
permalink: /tag/
---

<p id="tag-summary">Showing all tags.</p>

{% assign sorted_tags = site.tags | sort %}
{% for tag in sorted_tags %}
  <section class="tag-group" data-tag="{{ tag[0] | downcase }}">
    <h2 id="{{ tag[0] | slugify }}">{{ tag[0] }} ({{ tag[1].size }})</h2>
    {% for post in tag[1] %}
      <article class="post-item">
        <span class="post-meta">{{ post.date | date: "%b %-d, %Y" }}</span>
        <h3>
          <a class="post-link" href="{{ post.url | relative_url }}">{{ post.title }}</a>
        </h3>
        {% if post.description %}
          <p>{{ post.description }}</p>
        {% endif %}
      </article>
    {% endfor %}
  </section>
{% endfor %}

<script>
  (function () {
    var params = new URLSearchParams(window.location.search);
    var selectedTag = (params.get("tag") || "").trim().toLowerCase();
    if (!selectedTag) return;

    var sections = document.querySelectorAll(".tag-group");
    var matches = 0;
    for (var i = 0; i < sections.length; i++) {
      var tag = sections[i].getAttribute("data-tag");
      var keep = tag === selectedTag;
      sections[i].style.display = keep ? "block" : "none";
      if (keep) matches++;
    }

    var summary = document.getElementById("tag-summary");
    if (matches > 0) {
      summary.textContent = "Showing posts tagged: " + selectedTag;
    } else {
      summary.textContent = "No posts found for tag: " + selectedTag;
    }
  })();
</script>
