@renderAuthors = (x) -> Blaze.toHTMLWithData(Template.authors, x)

Template.hello.events
  'click #button': (e,t)->
    console.log 'button'