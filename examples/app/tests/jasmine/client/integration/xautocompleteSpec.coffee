query = @query
items = @items
data = @data

describe "several tests...", ->
  result = [{_id:'0', name: 'Richard', surname:'Dawkins'},
    {_id: '1', name: 'Daniel', surname:'Dennet'},
    {_id: '2', name: 'Charles', surname:'Darwin'}]

  el= null
  beforeEach ->
    dataBook = {_id:'0', title:'The dangerous idea of Darwin', authorId: '1', surname:'Dennet, Daniel', authorsId:['0','1'], surnames: ['ABC', 'XYZ']}
    el = Blaze.renderWithData(Template.testing, {data: dataBook},$('body')[0])
  afterEach ->
    Blaze.remove(el)

  it "test 1", ->
    $('[formid=1]>.xautocomplete-input').val('F')
    event = jQuery.Event('keyup', {keyCode:70})
    $('[formid=1]>.xautocomplete-input').trigger(event)
    expect(query.get()).toBe('F')

  it "test 2", ->
    #window.current_input.value = '1:authorSurname'
    event = jQuery.Event('keyup')
    $('[formid=1]>.xautocomplete-input').trigger(event)
    meteor_call = (call, query_, f) -> f(null, result)
    spyOn(Meteor, 'call').and.callFake meteor_call

    query.set('D')
    Meteor.flush()

    expect(Meteor.call.calls.first().args[0]).toBe('authors')
    expect(Meteor.call.calls.first().args[1]).toBe('D')

  it "test 3", ->
    #window.current_input.value = '1:authorSurname'
    event = jQuery.Event('keyup')
    $('[formid=1]>.xautocomplete-input').trigger(event)
    meteor_call = (call, query_, f) -> f(null, result)
    spyOn(Meteor, 'call').and.callFake meteor_call

    query.set('D')
    Meteor.flush()
    long = items.find().fetch().length
    expect(long).toBe(3)
    expect($('[formid=1]>.xpopover>table>tr>td').text()).toBe('Richard DawkinsDaniel DennetCharles Darwin')

  it "test 4", ->
    #window.current_input.value = '1:authorSurname'
    event = jQuery.Event('keyup')
    $('[formid=1]>.xautocomplete-input').trigger(event)
    meteor_call = (call, query_, f) -> f(null, result)
    spyOn(Meteor, 'call').and.callFake meteor_call

    query.set('D')
    Meteor.flush()
    event = jQuery.Event('keyup', {keyCode: 40})
    $('[formid=1]>.xautocomplete-input').trigger(event)
    event = jQuery.Event('keyup', {keyCode: 39})
    $('[formid=1]>.xautocomplete-input').trigger(event)
    expect(data.findOne({path: '1:surname'}).value).toBe('Dawkins, Richard')

  it "test5", ->
    data.update({path: '1:surname'}, {$set:{value:'miguel'}})
    Meteor.flush()
    expect($('[formid=1]>.xautocomplete-input').val()).toBe('miguel')