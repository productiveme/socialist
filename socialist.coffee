Items = new Meteor.Collection 'items'

reset_data = -> # Executes on both client and server.
  Items.remove {}
  Items.insert
    item: 'First Item'
    indent: 0
  Items.insert
    item: 'Second Item'
    indent: 0
  return

if Meteor.is_client
  itemMapping = 
    item:
      # item observable is created
      create: (options) ->
        parent = options.parent
        observable = ko.observable(options.data)
        parent.isEditing = ko.observable(false)
        parent.modeTemplate = -> 
          if parent.isEditing() then 'itemEditing' else 'item'
        parent.setEditing = -> parent.isEditing(true)
        parent.clearEditing = -> parent.isEditing(false)
        parent.doIndent = -> parent.indent(parent.indent() + 1)
        parent.doOutdent = -> parent.indent(parent.indent() - 1)
        parent.save = -> 
          parent.isEditing(false)
          Items.update parent._id(),
            $set: 
              item: parent.item()
              indent: parent.indent()
        parent.remove = -> Items.remove parent._id()

        return observable

  viewModel = ->
    items = ko.meteor.find(Items, {}, {}, itemMapping)
    resetData = -> reset_data()
    indentOn2LeadingSpaces = (model,event) ->
      return unless event.which is 32
      return unless model.item().substr(0,2) is '  '
      model.item(model.item().substring(2))
      model.doIndent()
    outdentOnBackspaceAndEmpty = (model, event) ->
      return unless event.which is 8
      return unless model.item() is ''
      model.doOutdent()
      # model.remove() if model.indent() is -1
    checkIndentationKeyBindings = (model, event) ->
      indentOn2LeadingSpaces model, event
      outdentOnBackspaceAndEmpty model, event
    saveOnEnter = (model, event) ->
      return true unless event.which is 13
      model.save()
      return false

    return {
      resetData: resetData
      items: items
      # indentOn2LeadingSpaces: indentOn2LeadingSpaces
      # outdentOnBackspaceAndEmpty: outdentOnBackspaceAndEmpty
      checkIndentationKeyBindings: checkIndentationKeyBindings
      saveOnEnter: saveOnEnter
    }

  Meteor.startup ->
    ko.applyBindings new viewModel()

if Meteor.is_server
  Meteor.startup -> 
    reset_data() if Items.find().count() is 0
