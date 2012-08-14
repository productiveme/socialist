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
      'click .outdent': -> Items.update @_id, $inc: {indent: -1}
      'click .indent': -> Items.update @_id, $inc: {indent: 1}
      'click .done, keyup .itemEditingInput': (evt) -> 
        return if evt.type is 'keyup' and evt.which isnt 13 # Key is not Enter.
        Items.update @_id, 
          isEditing: false
          item: $('.item_'+@_id).val()
          indent: @indent

if Meteor.is_server
  Meteor.startup -> 
    reset_data() if Items.find().count() is 0
