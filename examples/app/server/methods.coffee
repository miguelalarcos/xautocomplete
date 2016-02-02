authors = @authors
books = @books

authors.remove({})
books.remove({})
authors.insert {_id:'0', name: 'Richard', surname:'Dawkins'}
authors.insert {_id: '1', name: 'Daniel', surname:'Dennet'}
authors.insert {_id: '2', name: 'Charles', surname:'Darwin'}
books.insert {_id:'0', title:'The dangerous idea of Darwin', authorId: '1', surname:'Dennet', authorsId:['0','1'], surnames: ['ABC', 'XYZ']}

Meteor.methods
  authors: (query)->
    if query != ''
      authors.find(surname: {$regex: '^.*'+query+'.*$', $options: 'i'}).fetch()
    else
      []

Meteor.publishComposite 'bookById', (_id)->
  find: -> books.find _id: _id
  children: [find: (book) ->
               authors.find _id: book.authorId
             find: (book) ->
               authors.find({_id: {$in: book.authorsId}})
            ]
