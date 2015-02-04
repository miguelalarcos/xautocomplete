@renderAuthors = renderAuthors = (x, query) ->
  #txt = '<td>' +x.name + ' ' + x.surname+ '</td>'
  #txt.replace(query, "<b>$&</b>")
  Blaze.toHTMLWithData(Template.authors, x)

@myCallback = myCallback= (x) -> console.log x.doc

Template.hello.events
  'click #button': (event, template)->
    console.log 'values are:'
    for el in template.findAll('.xautocomplete')
      console.log $(el).val()

@settings01 =
  renderKey : 'surname'
  fieldRef: 'surname'
  call : 'authors'
  callbackFunction : myCallback

@settings02 =
  renderFunction: renderAuthors
  reference : 'authors'
  fieldRef: 'surname'
  call : 'authors'