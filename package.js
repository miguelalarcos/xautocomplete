Package.describe({
  name: 'miguelalarcos:xautocomplete',
  summary: 'An autocomplete widget. Values can be string or array of strings.',
  version: '0.1.0',
  git: 'https://github.com/miguelalarcos/xautocomplete.git'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0.1');
  api.use('coffeescript', 'client');
  api.use('underscore', 'client');
  api.use('jquery', 'client');
  api.use('session', 'client');
  api.use('templating', 'client');
  api.addFiles(['xautocomplete.html', 'xautocomplete.coffee', 'xautocomplete.css'], 'client');
});

