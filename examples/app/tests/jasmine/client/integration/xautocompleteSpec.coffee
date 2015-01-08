query = @query
items = @items

describe "test xautocomplete.", ->
  it "should be 3 items because of type D", ->
    backup = Meteor.call
    window.current_input.value = '5:coauthorsID'
    result = [{_id:'0', name: 'Richard', surname:'Dawkins'},
       {_id: '1', name: 'Daniel', surname:'Dennet'},
       {_id: '2', name: 'Charles', surname:'Darwin'}]
    Meteor.call = (call, query_, f) -> f(null, result)
    query.set('D')
    Meteor.flush()

    long = items.find().fetch().length
    expect(long).toBe(3)
    Meteor.call = backup


