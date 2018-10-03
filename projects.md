---
layout: default
title: Projects
permalink: /project/
---

<div class="container-fluid">
<h2>R</h2>
  <ul class="post-list">
    {% for post in site.posts %}
      {% if post.tags contains "r" %}
      <li>
        <span>
          <a class="post-link" href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a>
        </span>
        <span class="post-meta">{{ post.date | date: "%b %-d, %Y" }}</span>
      </li>
      {% endif %}
    {% endfor %}
  </ul>
  <br>
  {% for tag in site.tags %}
    {{ tag | first}}
  {% endfor %}
  </br>
</div>
