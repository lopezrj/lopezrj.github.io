---
layout: default
title: Projects
permalink: /project/
---

<div class="container-fluid">
<h2>Coreos</h2>
  <ul class="post-list">
    {% for post in site.posts %}
      {% if post.tags contains "coreos" %}
      <li>
        <span>
          <a class="post-link" href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a>
        </span>
        <span class="post-meta">{{ post.date | date: "%b %-d, %Y" }}</span>
      </li>
      {% endif %}
    {% endfor %}
  </ul>
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
  {% for tag in site.tags %}
    {{ tag | first}}
  {% endfor %}
</div>
