@renderAuthors = renderAuthors = (x, query) ->
  #txt = '<td>' +x.name + ' ' + x.surname+ '</td>'
  #txt.replace(query, "<b>$&</b>")
  Blaze.toHTMLWithData(Template.authors, x)
@valueAuthor = (x) -> x.surname + ', ' + x.name
@myCallback = myCallback= (x) -> console.log x.doc

Template.hello.events
  'click #button': (event, template)->
    console.log 'values are:'
    for el in template.findAll('.xautocomplete')
      console.log $(el).val()

@settings01 =
  renderKey : 'surname'
  valueKey : 'surname'
  call : 'authors'
  callbackFunction : myCallback

@settings02 =
  renderFunction: renderAuthors
  reference : 'authors'
  valueKey: 'surname'
  call : 'authors'