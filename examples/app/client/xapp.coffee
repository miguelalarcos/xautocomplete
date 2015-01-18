@renderAuthors = (x, query) ->
  #txt = '<td>' +x.name + ' ' + x.surname+ '</td>'
  #txt.replace(query, "<b>$&</b>")
  Blaze.toHTMLWithData(Template.authors, x)
@valueAuthor = (x) -> x.surname + ', ' + x.name
@myCallback = (x) -> console.log x.doc

Template.hello.events
  'click #button': (event, template)->
    console.log 'values are:'
    for el in template.findAll('.xautocomplete')
      console.log $(el).val()