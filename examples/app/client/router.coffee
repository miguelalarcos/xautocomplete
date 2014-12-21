books = @books

class MyController extends RouteController
  waitOn: -> Meteor.subscribe 'bookById', '0'
  data: -> books.findOne()

Router.map ->
  @route 'hello',
    path: '/'
    controller: MyController

