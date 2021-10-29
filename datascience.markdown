---
layout: page
title: Data Science
permalink: /datascience/
---

<ul>
{% for post in site.posts %}
  {% if post.tags contains "data science" %}
  <li>
    <a href="{{ post.url }}">{{ post.title }}</a>
    <span class="date">{{ post.date | date: "%B %-d, %Y"  }}</span>
  </li>
  {% endif %}
{% endfor %}
</ul>