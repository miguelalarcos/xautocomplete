@renderAuthors = (x) -> Blaze.toHTMLWithData(Template.authors, x)
@valueAuthors = (x) -> x.surname + ', ' + x.name

Template.hello.events
  'click #button': (e,t)->
    console.log 'button'