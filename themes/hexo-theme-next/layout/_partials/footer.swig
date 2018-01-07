<div class="copyright" >
  {% set current = date(Date.now(), "YYYY-MM-DD") %}
  &copy; {% if theme.since and theme.since != current %} {{ theme.since }} - {% endif %}
  <span itemprop="copyrightYear">{{ current }}</span>
  <span class="with-love">
    <i class="fa fa-{{ theme.authoricon }}"></i>
  </span>
  <span class="author" itemprop="copyrightHolder">{{ config.author }}</span>
</div>

{% if theme.copyright %}
<div class="powered-by">
  {{ __('footer.powered', '<a class="theme-link" href="https://github.com/">Github</a>') }}
</div>

<div class="theme-info">
  {{ __('footer.theme') }}
</div>
{% endif %}
