books = @books
authors = @authors
Session.set 'nameModal', {name: ''}
Meteor.subscribe 'bookById', '0'

@renderAuthors = (x) -> Blaze.toHTMLWithData(Template.authors, x)
@valueAuthors = (x) ->
  console.log x
  x.name + ' ' + x.surname

Template.hello.helpers
  obj: -> books.findOne()
  dataModal: -> Session.get 'nameModal'

dict =
  onDeny    : -> console.log 'cancel'
  onApprove : ->
    x = $(this).find('#user-email')[0]
    console.log $(x).val()

Template.hello.events
  'click #button': (e,t)->
    Session.set 'nameModal', {name: 'miguel angel'}
    $('#my-modal').modal(dict).modal('show')