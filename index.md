---
layout: home
title: Welcome
---

# Welcome to My Website

This is my personal website and blog. Here you'll find my thoughts, projects, and experiences.

## Recent Posts

{% for post in site.posts limit:5 %}
- [{{ post.title }}]({{ post.url | relative_url }}) - {{ post.date | date: "%B %d, %Y" }}
{% endfor %}

## About Me

I'm passionate about technology and sharing knowledge. This site serves as a platform for me to document my journey and share insights with others.
