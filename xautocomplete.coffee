# query is Reactive var where we are going to keep the text that the user is writing in the current autocomplete input
#Session.set 'query', null
query = new ReactiveVar('')
# we are going to keep the items to show in the popover as the user is writing in the autocomplete input
@items = items = new Meteor.Collection null
# in data we keep the values of the all autocomplete inputs
@data = data = new Meteor.Collection null
# index is the index in the popover where the user click
index = -1
# the path of the current autocomplete input where the user is typing
current_input = null

# each autocomplete input is identified by the formid and name
path = (formid, name) -> formid + ':' + name


Template.xautocomplete.helpers
  # this function setup the widget
  init: ->
    atts = this.atts or this
    path_ = path(atts.formid, atts.name)
    data.remove(path: path_)
    if _.isArray(this.value)
      for value in this.value
        data.insert({path: path_, value:value})
    else
      if this.reference
        console.log this.reference, this.value
        obj = (window[this.reference]).findOne(this.value)
        data.insert({path: path_, value: window[this.valuefunction](obj), remote_id: this._id})
      else
        data.insert({path: path_, value: this.value, remote_id: -1})

    null

  # this is reactive based on data collection and formid and name
  value: ->
    atts = this.atts or this
    if atts.multiple == 'true'
      return null
    item = data.findOne(path: path(atts.formid, atts.name))
    if item then item.value else null

  # this is reactive based on data collection and formid and name
  multiple: ->
    if this.multiple == 'true'
      data.find({path: path(this.formid, this.name)})
    else
      null

  # this is reactive based on query Reactive var. It makes a call to the server to get the items of the popover
  items: ->
    query_ = query.get()
    atts = this.atts or this
    call = atts.call
    renderFunction = atts.renderfunction
    valueFunction = atts.valuefunction
    if path(atts.formid, atts.name) == current_input
      Meteor.call call, query_, (error, result)->
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

    atts = t.data.atts or t.data
    path_ = path(atts['formid'], atts['name'])
    selected = items.findOne({selected: 'xselected'})
    if atts.multiple == 'true'
      if not data.findOne({path: path_, value: selected.value})
        data.insert({path: path_, value: selected.value, remote_id: selected.remote_id})
    else
      data.update({path: path_}, {$set: {value: selected.value, remote_id: selected.remote_id}})

    items.remove({})
    #Session.set 'query',''
    query.set('')
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
        atts = t.data.atts or t.data
        path_ = path(atts.formid, atts.name)

        if atts.multiple == 'true'
          if not data.findOne({path: path_, value: selected.value})
            data.insert({path: path_, value: selected.value, remote_id: selected.remote_id})
        else
          data.update({path: path_}, {$set: {value: selected.value, remote_id: selected.remote_id}})

        # close popover

        items.remove({})
        #Session.set('query','')
        query.set('')
        index = -1
        #$(t.find '.xautocomplete-input').val('')
    else if e.keyCode == 27
      items.remove({})
      #Session.set('query','')
      query.set('')
      index = -1
    else
      val = $(e.target).val()
      atts = t.data.atts or t.data
      path_ = path(atts.formid, atts.name)
      #Session.set 'query', val
      query.set(val)
      current_input = path_

      if not atts.multiple
        item = items.findOne(value: val)
        if item then remote_id = item.remote_id else remote_id = null
        data.update({path: path_}, {$set: {value: val, remote_id: remote_id}})

  'click .xclose':(e,t)->
    value = $(e.target).attr('value')
    atts = t.data.atts or t.data
    data.remove({path: path(atts.formid, atts.name), value:value})

  'focusin .xautocomplete-input': (e,t) ->
    val = $(e.target).val()
    #Session.set 'query', ''
    #Session.set 'query', val
    query.set('')
    query.set(val)
    atts = t.data.atts or t.data
    path_ = path(atts.formid, atts.name)
    current_input = path_


  'focusout .xautocomplete': (e,t)->
    if not $(e.relatedTarget).is('.xpopover')
      items.remove({})
      #Session.set('query','')
      query.set('')
      index = -1


$.valHooks['xautocomplete'] =
  get : (el)->
    ismultiple = $(el).attr('multiple')
    path_ = path($(el).attr('formid'), $(el).attr('name'))

    if ismultiple == 'true'
      if $(el).attr('reference') not in [undefined, 'false']
        return (x.remote_id for x in data.find(path: path_).fetch())
      else
        return (x.value for x in data.find(path: path_).fetch())
    else
      item = data.findOne(path: path_)
      if $(el).attr('reference') not in [undefined, 'false']
        return item.remote_id

      if item.remote_id == null
        return null
      return item.value
  set : (el, value)->

    path_ = path($(el).attr('formid'), $(el).attr('name'))
    reference = $(el).attr('reference')
    if reference not in [undefined, 'false']
      obj = window[reference].findOne(value)
      valueFunction = $(el).attr('valueFunction')
      data.insert({path: path_, value: window[valueFunction](obj), remote_id: value})
    else
      if not data.findOne({path: path_})
        data.insert({path: path_, value: value})
      else
        data.update({path: path_}, {$set:{value:value, remote_id:-1}})

    #if not data.findOne({path: path_, value: obj.value})



$.fn.xautocomplete = ->
  this.each -> this.type = 'xautocomplete'
  this

Template.xautocomplete.rendered = ->
  $(this.findAll('.xautocomplete')).xautocomplete()