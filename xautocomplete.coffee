@_testing = {}
# query is Reactive var where we are going to keep the text that the user is writing in the current autocomplete input
@_testing.query = query = new ReactiveVar('')

# we are going to keep the items to show in the popover as the user is writing in the autocomplete input
@_testing.items = items = new Meteor.Collection null

# in data we keep the values of the all autocomplete inputs
@_testing.data = data = new Meteor.Collection null
@data = data
# index is the index in the popover where the user click
index = -1

# the path of the current autocomplete input where the user is typing
current_input = null
#@current_input = current_input = {value: null}

# each autocomplete input is identified by the formid and name
path = (formid, name) -> formid + ':' + name

generalValueFunction = (key)->
  (x)-> x[key]

generalRenderFunction = (key)->
  (x, query)->
    txt = '<td>' +x[key]+ '</td>'
    txt.replace(query, "<b>$&</b>")

extendAtts = (atts) ->
  atts = _.clone(atts)
  if atts.settings
    atts.valuefunction = window[atts.settings].valueFunction
    atts.valuekey = window[atts.settings].valueKey
    atts.xmultiple = window[atts.settings].xmultiple
    atts.renderfunction = window[atts.settings].renderFunction
    atts.renderkey = window[atts.settings].renderKey
    atts.reference = window[window[atts.settings].reference]
    atts.call = window[atts.settings].call
    atts.callbackfunction = window[atts.settings].callbackFunction
  else
    atts.valuefunction = window[atts.valuefunction]
    atts.renderfunction = window[atts.renderfunction]
    atts.reference = window[atts.reference]
    atts.callbackfunction = window[atts.callbackfunction]

  atts.settings = undefined
  atts

Template.xautocomplete.helpers
  # this function setup the widget
  init: (obj)-> #pensar en implementarlo con set, pues parece repetitivo
    # if we come from autoform, the attributes are in this.atts. Else in this directly

    atts = this.atts or this
    atts = extendAtts(atts)
    path_ = path(atts.formid, atts.name)
    data.remove(path: path_)
    #if we come from autoform, the value come in this.value. Else in the object passed
    if this.value == '' or this.value
      value = this.value
    else
      value = obj[atts.name]

    valueFunction = atts.valuefunction or generalValueFunction(atts.valuekey)
    xmultiple = atts.xmultiple

    if xmultiple == 'true'
      if value is undefined or value == '' then value = []
      for val in value
        if atts.reference not in [undefined, 'false']
          collection = atts.reference
          obj = collection.findOne(val)
          data.insert({path: path_, value: valueFunction(obj), remote_id: val})
        else
          data.insert({path: path_, value: val, remote_id: null})
    else
      if atts.reference not in [undefined, 'false']
        collection = atts.reference
        obj = collection.findOne(value)
        if obj
          value_ = valueFunction(obj)
        else
          value_ = ''
        data.insert({path: path_, value: value_, remote_id: value})
      else
        data.insert({path: path_, value: value, remote_id: null})

    null

  # this is reactive based on data collection and formid and name
  value: ->
    atts = this.atts or this
    atts = extendAtts(atts)
    multiple = atts.xmultiple
    if multiple == 'true'
      return null
    item = data.findOne(path: path(atts.formid, atts.name))
    if item then item.value else null

  # this is reactive based on data collection and formid and name
  xmultiple: ->
    atts = this.atts or this
    atts = extendAtts(atts)
    multiple = atts.xmultiple
    if multiple == 'true'
      data.find({path: path(atts.formid, atts.name)})
    else
      null

  # this is reactive based on query Reactive var. It makes a call to the server to get the items of the popover
  items: ->
    query_ = query.get()
    atts = this.atts or this
    atts = extendAtts(atts)

    call = atts.call
    valueFunction = atts.valuefunction or generalValueFunction(atts.valuekey)
    renderFunction = atts.renderfunction or generalRenderFunction(atts.renderkey)

    if path(atts.formid, atts.name) == current_input
      Meteor.call call, query_, (error, result)->
        items.remove({})
        for item, i in result
          rendered = renderFunction(item, query_)
          value = valueFunction(item)
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
    atts = extendAtts(atts)

    path_ = path(atts['formid'], atts['name'])
    selected = items.findOne({selected: 'xselected'})
    multiple = atts.xmultiple
    if multiple == 'true'
      if not data.findOne({path: path_, value: selected.value})
        data.insert({path: path_, value: selected.value, remote_id: selected.remote_id})
    else
      data.update({path: path_}, {$set: {value: selected.value, remote_id: selected.remote_id}})

    items.remove({})
    query.set('')
    index = -1
    $(t.find '.xautocomplete-input').val('')
    if atts.callbackfunction
      atts.callbackfunction(selected)


  'keyup .xautocomplete-input': (e,t)->
    if e.keyCode == 38
      items.update({index:index}, {$set:{selected: ''}}) # items.update({}, {$set:{selected: ''}})
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
        atts = extendAtts(atts)
        path_ = path(atts.formid, atts.name)
        multiple = atts.xmultiple

        if multiple == 'true'
          if not data.findOne({path: path_, value: selected.value})
            data.insert({path: path_, value: selected.value, remote_id: selected.remote_id})
        else
          data.update({path: path_}, {$set: {value: selected.value, remote_id: selected.remote_id}})

        # close popover
        items.remove({})
        query.set('')
        index = -1
        $(t.find '.xautocomplete-input').val('')
        if atts.callbackfunction
          atts.callbackfunction(selected)

    else if e.keyCode == 27
      items.remove({})
      query.set('')
      index = -1
    else
      val = $(e.target).val()
      atts = t.data.atts or t.data
      atts = extendAtts(atts)
      path_ = path(atts.formid, atts.name)

      query.set(val)
      current_input = path_
      multiple = atts.xmultiple
      if multiple != 'true'
        item = items.findOne(value: val)
        if item then remote_id = item.remote_id else remote_id = null
        data.update({path: path_}, {$set: {value: val, remote_id: remote_id}})

  'click .xclose':(e,t)->
    value = $(e.target).attr('value')
    atts = t.data.atts or t.data
    data.remove({path: path(atts.formid, atts.name), value:value})

  'focusin .xautocomplete-input': (e,t) ->
    val = $(e.target).val()
    query.set('')
    query.set(val)
    atts = t.data.atts or t.data
    path_ = path(atts.formid, atts.name)
    current_input = path_


  'focusout .xautocomplete': (e,t)->
    if not $(e.relatedTarget).is('.xpopover')
      items.remove({})
      query.set('')
      index = -1

makeAtts = (el) ->
  el = $(el)
  atts = {}
  for at in ['formid', 'name', 'settings', 'xmultiple', 'reference', 'valuefunction']
    atts[at] = el.attr(at)
  atts

$.valHooks['xautocomplete'] =
  get : (el)->
    atts = makeAtts(el)
    atts = extendAtts(atts)
    #path_ = path($(el).attr('formid'), $(el).attr('name'))
    path_ = path(atts.formid, atts.name)

    reference = atts.reference #$(el).attr('reference')
    ismultiple = atts.xmultiple #$(el).attr('xmultiple')

    if ismultiple == 'true'
      if reference not in [undefined, 'false']
        return (x.remote_id for x in data.find(path: path_).fetch())
      else
        return (x.value for x in data.find(path: path_).fetch())
    else
      item = data.findOne(path: path_)
      if reference not in [undefined, 'false']
        return item.remote_id

      return item.value

  set : (el, value)->
    atts = makeAtts(el)
    atts = extendAtts(atts)
    path_ = path(atts.formid, atts.name)
    #path_ = path($(el).attr('formid'), $(el).attr('name'))

    reference = atts.reference #$(el).attr('reference')
    #valueFunction = window[$(el).attr('valuefunction')] or generalValueFunction($(el).attr('valuekey'))
    valueFunction = atts.valuefunction or generalValueFunction(atts.valuekey)
    #ismultiple = $(el).attr('xmultiple')
    ismultiple = atts.xmultiple

    if ismultiple == 'true'
      if reference not in [undefined, 'false']
        collection = reference
        for val in value
          obj = collection.findOne(val)
          if not data.findOne({path:path_, remote_id: val})
            data.insert({path: path_, value: valueFunction(obj), remote_id: val})
          else
            data.update({path:path_}, {$set: {value: valueFunction(obj), remote_id: val}})
      else
        for val in value
          if not data.findOne({path: path_, value: val})
            data.insert({path: path_, value: val})
          else
            data.update({path: path_}, {$set:{value:val, remote_id: null}})
    else
      if reference not in [undefined, 'false']
        collection = reference
        obj = collection.findOne(value)

        if not data.findOne({path:path_})
          data.insert({path: path_, value: valueFunction(obj), remote_id: value})
        else
          data.update({path:path_}, {$set: {value: valueFunction(obj), remote_id: value}})
      else
        if not data.findOne({path: path_})
          data.insert({path: path_, value: value})
        else
          data.update({path: path_}, {$set:{value:value, remote_id: null}})


$.fn.xautocomplete = ->
  this.each -> this.type = 'xautocomplete'
  this

Template.xautocomplete.rendered = ->
  $(this.findAll('.xautocomplete')).xautocomplete()