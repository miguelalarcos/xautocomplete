books = @books
authors = @authors

Meteor.subscribe 'bookById', '0'

@renderAuthors = (x) -> Blaze.toHTMLWithData(Template.authors, x)
@valueAuthors = (x) -> x.surname + ', ' + x.name

Template.hello.helpers
  obj: -> books.findOne()

Template.hello.events
  'click #button': (e,t)->
    console.log 'button'