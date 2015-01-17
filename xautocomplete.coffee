# query is Reactive var where we are going to keep the text that the user is writing in the current autocomplete input
@query = query = new ReactiveVar('')

# we are going to keep the items to show in the popover as the user is writing in the autocomplete input
@items = items = new Meteor.Collection null

# in data we keep the values of the all autocomplete inputs
@data = data = new Meteor.Collection null

# index is the index in the popover where the user click
index = -1

# the path of the current autocomplete input where the user is typing
current_input = null
#@current_input = current_input = {value: null}

# each autocomplete input is identified by the formid and name
path = (formid, name) -> formid + ':' + name


Template.xautocomplete.helpers
  # this function setup the widget
  init: (obj)-> #pensar en implementarlo con set, pues parece repetitivo
    # if we come from autoform, the attributes are in this.atts. Else in this directly
    atts = this.atts or this
    path_ = path(atts.formid, atts.name)
    data.remove(path: path_)
    #if we come from autoform, the value come in this.value. Else in the object passed

    value = this.value or obj[atts.name]
    valueFunction = atts.valuefunction

    if atts.xmultiple == 'true'
      if value is undefined then value = []
      for val in value
        if atts.reference not in [undefined, 'false']
          collection = atts.reference
          obj = (window[collection]).findOne(val)
          data.insert({path: path_, value: window[valueFunction](obj), remote_id: val})
        else
          data.insert({path: path_, value: val, remote_id: null})
    else
      if atts.reference not in [undefined, 'false']
        collection = atts.reference
        obj = (window[collection]).findOne(value)
        data.insert({path: path_, value: window[valueFunction](obj), remote_id: value})
      else
        data.insert({path: path_, value: value, remote_id: null})

    null

  # this is reactive based on data collection and formid and name
  value: ->
    atts = this.atts or this
    if atts.xmultiple == 'true'
      return null
    item = data.findOne(path: path(atts.formid, atts.name))
    if item then item.value else null

  # this is reactive based on data collection and formid and name
  xmultiple: ->
    atts = this.atts or this
    if atts.xmultiple == 'true'
      data.find({path: path(atts.formid, atts.name)})
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
          value = window[valueFunction](item)
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
    if atts.xmultiple == 'true'
      if not data.findOne({path: path_, value: selected.value})
        data.insert({path: path_, value: selected.value, remote_id: selected.remote_id})
    else
      data.update({path: path_}, {$set: {value: selected.value, remote_id: selected.remote_id}})

    items.remove({})
    query.set('')
    index = -1
    $(t.find '.xautocomplete-input').val('')
    if atts.callbackfunction
      window[atts.callbackfunction](selected)

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
        path_ = path(atts.formid, atts.name)

        if atts.xmultiple == 'true'
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
          window[atts.callbackfunction](selected)

    else if e.keyCode == 27
      items.remove({})
      query.set('')
      index = -1
    else
      val = $(e.target).val()
      atts = t.data.atts or t.data
      path_ = path(atts.formid, atts.name)

      query.set(val)
      current_input = path_

      if atts.xmultiple != 'true'
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


$.valHooks['xautocomplete'] =
  get : (el)->
    ismultiple = $(el).attr('xmultiple')
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

      #if item.remote_id == null
      #  return null

      return item.value

  set : (el, value)->
    ismultiple = $(el).attr('xmultiple')
    path_ = path($(el).attr('formid'), $(el).attr('name'))
    reference = $(el).attr('reference')
    valueFunction = $(el).attr('valuefunction')

    if ismultiple == 'true'
      if reference not in [undefined, 'false']
        collection = reference
        for val in value
          obj = window[collection].findOne(val)
          if not data.findOne({path:path_, remote_id: val})
            data.insert({path: path_, value: window[valueFunction](obj), remote_id: val})
          else
            data.update({path:path_}, {$set: {value: window[valueFunction](obj), remote_id: val}})
      else
        for val in value
          if not data.findOne({path: path_, value: val})
            data.insert({path: path_, value: val})
          else
            data.update({path: path_}, {$set:{value:val, remote_id: null}})
    else
      if reference not in [undefined, 'false']
        collection = reference
        obj = window[collection].findOne(value)
        if not data.findOne({path:path_})
          data.insert({path: path_, value: window[valueFunction](obj), remote_id: value})
        else
          data.update({path:path_}, {$set: {value: window[valueFunction](obj), remote_id: value}})
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