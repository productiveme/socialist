Items = new Meteor.Collection 'items'

reset_data = -> # Executes on both client and server.
  Items.remove {}
  curItem = Items.insert
    item: 'First Item'
    indent: 0
  curItem = Items.insert
    item: 'Second Item'
    indent: 0
  return

if Meteor.is_client

  itemMapping = 
    item:
      # item observable is created
      create: (options) ->
        parent = options.parent
        observable = ko.observable options.data
        parent.isEditing = ko.observable false
        parent.modeTemplate = -> 
          if parent.isEditing() then 'itemEditing' else 'item'
        parent.setEditing = -> parent.isEditing true
        parent.clearEditing = -> parent.isEditing false

        return observable

  viewModel =
    items: ko.meteor.find(Items, {}, {}, itemMapping)
    resetData: -> reset_data

  Meteor.startup ->
    ko.applyBindings viewModel

if Meteor.is_server
  Meteor.startup -> 
    reset_data() if Items.find().count() is 0
