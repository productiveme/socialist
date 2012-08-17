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

  setIndentClass = (el, indent) ->
    el.removeClass()
    el.addClass('indent'+indent)

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
      'click .outdent': ->
        Items.update @_id, $inc: {indent: -1}
        Meteor.defer => $('.item_'+@_id).focus()
      'keydown .itemEditingInput': (evt) -> 
        return unless evt.which is 8 and $('.item_'+@_id).val() is '' # backspace when empty
        return if @indent is 0
        Items.update @_id, 
          $set:
            item: $('.item_'+@_id).val()
          $inc: 
            indent: -1
        Meteor.defer => $('.item_'+@_id).focus()
      'click .indent': ->
        Items.update @_id, $inc: {indent: 1}
        Meteor.defer => $('.item_'+@_id).focus()
      'keyup .itemEditingInput': (evt) -> 
        return unless evt.which is 32 and $('.item_'+@_id).val().substr(0,2) is '  ' # starts with 2 spaces
        $('.item_'+@_id).val $('.item_'+@_id).val().substring(2)
        Items.update @_id, 
          $set: 
            item: $('.item_'+@_id).val()
          $inc: 
            indent: 1
        Meteor.defer => $('.item_'+@_id).focus()
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
      'click .outdent': ->
        return if @indent is 0
        @indent--
        setIndentClass $('.item_new').parent(), @indent
        $('.item_new').focus()
      'keydown .itemEditingInput': (evt) -> 
        return unless evt.which is 8 and $('.item_new').val() is '' # backspace when empty
        return if @indent is 0
        @indent--
        setIndentClass $('.item_new').parent(), @indent
        $('.item_new').focus()
      'click .indent': (evt) -> 
        @indent++
        setIndentClass $('.item_new').parent(), @indent
        $('.item_new').focus()
      'keyup .itemEditingInput': (evt) ->
        return unless evt.which is 32 and $('.item_new').val().substr(0,2) is '  ' # starts with 2 spaces
        @indent++
        setIndentClass $('.item_new').parent(), @indent
        $('.item_new').val $('.item_new').val().substring(2)
        $('.item_new').focus()
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
