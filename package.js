Package.describe({
  name: 'miguelalarcos:xautocomplete',
  summary: 'An autocomplete widget. Values can be strings, array of strings or reference _ids.',
  version: '0.1.2',
  git: 'https://github.com/miguelalarcos/xautocomplete.git'
});

Package.onUse(function(api) {
  api.versionsFrom('1.0.1');
  api.use('coffeescript', 'client');
  api.use('underscore', 'client');
  api.use('jquery', 'client');
  api.use('session', 'client');
  api.use('templating', 'client');
  api.use('reactive-var', 'client');
  api.addFiles(['xautocomplete.html', 'xautocomplete.coffee', 'xautocomplete.css'], 'client');
});

