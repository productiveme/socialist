Items = new Meteor.Collection 'items'

reset_data = -> # Executes on both client and server.
  Items.remove {}
  curItem = Items.insert
    item: 'First Item'
    indent: 0
    isEditing: false
  curItem = Items.insert
    item: 'Second Item'
    indent: 0
    isEditing: false
  return

if Meteor.is_client

  cancelEvent = (e) ->
    e.stopPropogation if e? and e.stopPropogation?
    window.event.cancelBubble = true if window.event? and window.event.cancelBubble?
    e.preventDefault if e? and e.preventDefault?

  setIndentClass = (el, indent) ->
    el.removeClass()
    el.addClass('indent'+indent)

  changeIndent = (evt, el, fn, fnKey) ->
    if evt.type is 'keydown' and fnKey?()
    then return
    else cancelEvent(evt)
    fn?()
    el?.focus?()
    return false

  outdent = (evt, el, fn) ->
    changeIndent evt, el, fn, -> not(evt.which is 9 and evt.shiftKey)

  indent = (evt, el, fn) ->
    changeIndent evt, el, fn, -> evt.which isnt 9 

  _.extend Template.socialist,
    items: ->
      Items.find {}

  _.extend Template.navbar,
    events:
      'click .reset_data': -> reset_data()

  _.extend Template.item,
    events:
      'click .remove': -> Items.remove @_id
      'click .itemView': -> Items.update @_id, 
        isEditing: true
        item: @item
        indent: @indent
      'click .outdent, keydown .itemEditingInput': (evt) -> 
        outdent evt, $('.item_'+@_id), => Items.update @_id, $inc: {indent: -1}
      'click .indent, keydown .itemEditingInput': (evt) -> 
        indent evt, $('.item_'+@_id), => Items.update @_id, $inc: {indent: 1}
      'click .done, keyup .itemEditingInput': (evt) -> 
        return if evt.type is 'keyup' and evt.which isnt 13 # Key is not Enter.
        Items.update @_id, 
          isEditing: false
          item: $('.item_'+@_id).val()
          indent: @indent

  _.extend Template.itemNew, 
    newItem: 
      item: ''
      indent: 0
    events:
      'click .outdent, keydown .itemEditingInput': (evt) -> 
        outdent evt, $('.item_new'), => 
          @indent--
          setIndentClass $('.item_new').parent(), @indent
      'click .indent, keydown .itemEditingInput': (evt) -> 
        indent evt, $('.item_new'), =>
          @indent++
          setIndentClass $('.item_new').parent(), @indent
      'click .done, keyup .itemEditingInput': (evt) -> 
        return if evt.type is 'keyup' and evt.which isnt 13 # Key is not Enter.
        Items.insert
          isEditing: false
          item: $('.item_new').val()
          indent: @indent
        $('.item_new').val('')

if Meteor.is_server
  Meteor.startup -> 
    reset_data() if Items.find().count() is 0
