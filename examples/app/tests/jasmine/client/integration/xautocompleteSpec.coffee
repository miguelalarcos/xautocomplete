query = @query
items = @items

describe "test type D and set query", ->
  it "test", ->
    $('[formid=5]>.xautocomplete-input').val('F')
    event = jQuery.Event('keyup', {keyCode:70})
    $('[formid=5]>.xautocomplete-input').trigger(event)
    expect(query.get()).toBe('F')

describe "test query set and length items", ->
  it "test", ->
    window.current_input.value = '5:coauthorsID'
    result = [{_id:'0', name: 'Richard', surname:'Dawkins'},
       {_id: '1', name: 'Daniel', surname:'Dennet'},
       {_id: '2', name: 'Charles', surname:'Darwin'}]
    meteor_call = (call, query_, f) -> f(null, result)
    spyOn(Meteor, 'call').and.callFake meteor_call
    query.set('D')
    Meteor.flush()

    long = items.find().fetch().length
    expect(long).toBe(3)


