Items = new Meteor.Collection 'items'

reset_data = -> # Executes on both client and server.
  Items.remove {}
  items = [ 'Item 1',
            'Item 1.1',
            'Item 1.1.1',
            'Item 1.1.2',
            'Item 1.1.2.1'
            'Item 2',
            'Item 2.1',
            'Item 2.1.1',
            'Item 2.2',
            'Item 3'
          ]
  indent = 0
  for item, i in items
    Items.insert
      item: item
      indent: item.length - item.replace(/\./g, '').length,
      value: Math.floor(Math.random() * 10) * 5
  Session.set 'sort_by_item', true
  
if Meteor.is_client

  _.extend Template.navbar,
    events:
      'click .sort_by_item': -> Session.set 'sort_by_item', true
      'click .sort_by_value': -> Session.set 'sort_by_item', false
      'click .reset_data': -> reset_data()

  _.extend Template.socialist,
    items: ->
      sort = if Session.get('sort_by_item') is false then value: -1 else item: 1
      Items.find {}, sort: sort

    events:
      'click #add_button, keyup #item': (evt) ->
        return if evt.type is 'keyup' and evt.which isnt 13 # Key is not Enter.
        input = $('#item')
        if input.val()
          Items.insert
            item: input.val()
            value: Math.floor(Math.random() * 10) * 5
          input.val ''

  _.extend Template.item,
    events:
      'click .increment': -> Items.update @_id, $inc: {value: 5}
      'click .remove': -> Items.remove @_id
      'click': -> $('.tooltip').remove()  # To prevent zombie tooltips.

    enable_tooltips: ->
      # Update tooltips after the template has rendered.
      _.defer -> $('[rel=tooltip]').tooltip()
      ''

# On server startup, create some players if the database is empty.
if Meteor.is_server
  Meteor.startup ->
    reset_data() if Items.find().count() is 0
