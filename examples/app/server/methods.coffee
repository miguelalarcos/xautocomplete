authors = @authors
books = @books

if not authors.findOne()
  authors.insert {_id:'0', name: 'Richard', surname:'Dawkins'}
  authors.insert {_id: '1', name: 'Daniel', surname:'Dennet'}
  authors.insert {_id: '2', name: 'Charles', surname:'Darwin'}
  books.insert {_id:'0', title:'The dangerous idea of Darwin', authorId: '1', authorSurname:'Dennet'}
  books.insert {_id:'1', title:'The selfish gen', authorId:'0', authorSurname:'Dawkins'}
  books.insert {_id:'2', title:'The origin of species', authorId:'2', authorSurname:'Darwin'}

Meteor.methods
  authors: (query)->
    authors.find(surname: {$regex: '^.*'+query+'.*$'}).fetch()

Meteor.publishComposite 'bookById', (_id)->
  find: -> books.find _id: _id
  children: [find: (book) -> authors.find _id: book.authorId]