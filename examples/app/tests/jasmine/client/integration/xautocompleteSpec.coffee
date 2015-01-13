query = @query
items = @items

describe "test type D and set query", ->
  r= null
  beforeEach ->
    dataBook = {_id:'0', title:'The dangerous idea of Darwin', authorId: '1', authorSurname:'Dennet, Daniel', coauthorsID:['0','1'], coauthors: ['ABC', 'XYZ']}
    r = Blaze.renderWithData(Template.testing, {data: dataBook},$('body')[0])
  afterEach ->
    Blaze.remove(r)
  it "test 1", ->
    $('[formid=1]>.xautocomplete-input').val('F')
    event = jQuery.Event('keyup', {keyCode:70})
    $('[formid=1]>.xautocomplete-input').trigger(event)
    expect(query.get()).toBe('F')

  it "test 2", ->
    window.current_input.value = '1:authorSurname'
    result = [{_id:'0', name: 'Richard', surname:'Dawkins'},
       {_id: '1', name: 'Daniel', surname:'Dennet'},
       {_id: '2', name: 'Charles', surname:'Darwin'}]
    meteor_call = (call, query_, f) -> f(null, result)
    spyOn(Meteor, 'call').and.callFake meteor_call

    query.set('D')
    Meteor.flush()

    expect(Meteor.call.calls.first().args[0]).toBe('authors')
    expect(Meteor.call.calls.first().args[1]).toBe('D')
    long = items.find().fetch().length
    expect(long).toBe(3)
    expect($('[formid=1]>.xpopover>table>tr>td').text()).toBe('Richard DawkinsDaniel DennetCharles Darwin')

