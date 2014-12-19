# query is the Session key where we are going to keep the text that the user is writing in the current autocomplete input
Session.set 'query', null
# we are going to keep the items to show in the popover as the user is writing in the autocomplete input
items = new Meteor.Collection null
# in data we keep the values of the all autocomplete inputs
data = new Meteor.Collection null
# index is the index in the popover where the user click
index = -1
# the path of the current autocomplete input where the user is typing
current_input = null

# each autocomplete input is identified by the formId and name
path = (formId, name) -> formId + ':' + name

  
Template.xautocomplete.helpers
  # this function set the initial values of the widget
  init: ->
    path_ = path(this.formId, this.name)
    data.remove(path: path_)
    if _.isArray(this.value)
      for value in this.value
        data.insert({path: path_, value:value})
    #else if _.has(this.value, '_id')
    else if this.reference
      obj = (window[this.reference]).findOne(this.value)
      data.insert({path: path_, value: window[this.valueFunction](obj), remote_id: this.value._id})
    else
      data.insert({path: path_, value: this.value, remote_id: -1})
    null

  # this is reactive based on data collection and formId and name
  value: ->
    if this.array == 'true'
      return null
    item = data.findOne(path: path(this.formId, this.name))
    if item then item.value else null

  # this is reactive based on data collection and formId and name
  array: ->
    if this.array == 'true'
      data.find({path: path(this.formId, this.name)})
    else
      null

  # this is reactive based on query Session key. It makes a call to the server to get the items of the popover
  items: ->
    query = Session.get 'query'
    call = this.call
    renderFunction = this.renderFunction
    valueFunction = this.valueFunction
    if path(this.formId, this.name) == current_input
      Meteor.call call, query, (error, result)->
        items.remove({})
        for item, i in result
          rendered = window[renderFunction] item
          value = window[valueFunction] item
          items.insert({value: value, content:rendered, index: i, remote_id: item._id, doc: item})

      items.find({})
    else
      null

Template.xautocomplete.events
  'click .xitem':(e,t)->
    index = $(e.currentTarget).attr('index')
    items.update({},{$set:{selected: ''}})
    items.update({index: parseInt(index)}, {$set:{selected: 'xselected'}})

    path_ = path(t.data['formId'], t.data['name'])
    selected = items.findOne({selected: 'xselected'})
    if t.data.array == 'true'
      if not data.findOne({path: path_, value: selected.value})
        data.insert({path: path_, value: selected.value, remote_id: selected.remote_id})
    else
      data.update({path: path_}, {$set: {value: selected.value, remote_id: selected.remote_id}})

    items.remove({})
    Session.set 'query',''
    index = -1
    $(t.find '.xautocomplete-input').val('')

  'keyup .xautocomplete-input': (e,t)->
    if e.keyCode == 38
      items.update({index:index}, {$set:{selected: ''}})
      if index == -1 then index = -1 else index -= 1
      items.update({index:index}, {$set:{selected: 'xselected'}})
    else if e.keyCode == 40
      items.update({index:index}, {$set:{selected: ''}})
      count = items.find({}).count() - 1
      if index == count then index = 0 else index += 1
      items.update({index:index}, {$set:{selected: 'xselected'}})
    else if e.keyCode in [13, 39]
      selected = items.findOne({selected: 'xselected'}) or items.findOne({index: 0})
      if selected
        path_ = path(this.formId, this.name)
        if t.data.array == 'true'
          if not data.findOne({path: path_, value: selected.value})
            data.insert({path: path_, value: selected.value, remote_id: selected.remote_id})
        else
          data.update({path: path_}, {$set: {value: selected.value, remote_id: selected.remote_id}})

        # close popover
        items.remove({})
        Session.set('query','')
        index = -1
        $(t.find '.xautocomplete-input').val('')
    else if e.keyCode == 27
      items.remove({})
      Session.set('query','')
      index = -1
    else
      val = $(e.target).val()
      path_ = path(t.data.formId, t.data.name)
      Session.set 'query', val
      current_input = path_

      if not t.data.array
        item = items.findOne(value: val)
        if item then remote_id = item.remote_id else remote_id = null
        data.update({path: path_}, {$set: {value: val, remote_id: remote_id}})

  'click .xclose':(e,t)->
    value = $(e.target).attr('value')
    data.remove({path: path(t.data.formId, t.data.name), value:value})

  'focusin .xautocomplete-input': (e,t) ->
    val = $(e.target).val()
    Session.set 'query', ''
    Session.set 'query', val
    path_ = path(t.data.formId, t.data.name)
    current_input = path_


  'focusout .xautocomplete': (e,t)->
    if not $(e.relatedTarget).is('.xpopover')
      items.remove({})
      Session.set('query','')
      index = -1


$.valHooks['xautocomplete'] =
  get : (el)->
    isArray = $(el).attr('array')
    path_ = path($(el).attr('formId'), $(el).attr('name'))
    if isArray == 'true'
      if $(el).attr('reference') == 'true'
        return (x.remote_id for x in data.find(path: path_).fetch())
      else
        return (x.value for x in data.find(path: path_).fetch())
    else
      item = data.findOne(path: path_)
      if $(el).attr('reference') == 'true'
        return item.remote_id

      if item.remote_id == null
        return null
      return item.value


$.fn.xautocomplete = ->
  this.each -> this.type = 'xautocomplete'
  this

Template.xautocomplete.rendered = ->
  $(this.findAll('.xautocomplete')).xautocomplete()