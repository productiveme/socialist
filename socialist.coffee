Items = new Meteor.Collection 'items'

reset_data = -> # Executes on both client and server.
  Items.remove {}
  samples = [{"_id":"87672c89-ac21-4d66-908d-4fc052b33b72","isEditing":false,"item":"Current Sprint","indent":0,"archived":false},{"_id":"6315b739-5f92-45bb-8bfe-5ee06a880fa8","isEditing":false,"item":"Archive before delete","indent":1,"archived":true},{"_id":"c2f29cc1-b5cb-4d6f-8e4b-dacc11f53359","isEditing":false,"item":"Ability to unarchive","indent":1,"archived":true},{"_id":"e6b7f0b1-326c-4a6a-8150-4d8ce6cbc315","isEditing":false,"item":"Bigger, better action icons. Change to buttons?","indent":1,"archived":false},{"_id":"3952ed9d-084c-47bb-8679-77a61c658a8a","isEditing":false,"item":"Ability to rearrange items. Children should move with parent.","indent":1,"archived":false},{"_id":"e0a75528-3809-48a5-ab25-15f699161a95","isEditing":false,"item":"Ability to insert an item anywhere in the list","indent":1,"archived":false},{"_id":"4114f1fb-c297-41aa-9f2e-06324c0daf96","isEditing":false,"item":"Children should archive/delete with parent","indent":1,"archived":false},{"_id":"07d369ce-2540-4e3c-8764-3b64497bbdd7","isEditing":false,"item":"Children should indent/outdent with parent","indent":1,"archived":false},{"_id":"2dc86766-6d63-4e88-983c-69f989b9655e","isEditing":false,"item":"Should not be able to indent more than one level below parent","indent":1,"archived":false},{"_id":"8a88a5c1-2315-42bb-8b68-2a8c5a73201f","isEditing":false,"item":"Should not be able to outdent past 0","indent":1,"archived":false},{"_id":"18b50daf-ce4c-464c-8a5b-570443755811","isEditing":false,"item":"Ability to create a new uniquely named list","indent":1,"archived":false},{"_id":"8710d5d8-1ffa-4e8f-bc13-df3a21e64297","isEditing":false,"item":"Shareable url for each list","indent":1,"archived":false},{"_id":"9c243f36-1e6f-4e69-8062-f9a08b242223","isEditing":false,"item":"Backlog","indent":0,"archived":false},{"_id":"47978728-8916-4dd6-98ea-2de2a8c5a552","isEditing":false,"item":"Ability to password protect a list","indent":1,"archived":false},{"_id":"b4de38bf-e072-4ed6-892a-c008dd9d9d79","isEditing":false,"item":"Ability to add a checkbox column, parent indicates number of checked children","indent":1,"archived":false},{"_id":"db87475b-94fd-489c-b347-0961b5d188ca","isEditing":false,"item":"Ability to add a numeric column, parent shows sum of children","indent":1,"archived":false},{"_id":"adc9dce7-5037-417a-8223-d3e9c0a4d3ba","isEditing":false,"item":"Textarea instead of single line textbox. Should grow instead of scroll and allow line breaks","indent":1,"archived":false}]
  for sample in samples
    Items.insert
      item: sample.item
      indent: sample.indent
      archived: sample.archived
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
        parent.remove = -> 
          if parent.archived()
            Items.remove parent._id()
          else
            Items.update parent._id(), 
              $set: archived: true
        parent.restore = ->
          if parent.archived()
            Items.update parent._id(),
              $set: archived: false

        return observable

  blankItem = ->
    @item = ko.observable('')
    @indent = ko.observable(0)
    @save = =>
      Items.insert
        item: @item()
        indent: @indent()
        archived: false
      @item('')
    @doIndent = =>
      @indent(@indent() + 1)
    @doOutdent = =>
      @indent(@indent() - 1)
    return


  viewModel = ->
    items = ko.meteor.find(Items, {}, {}, itemMapping)
    itemToInsert = new blankItem()
    showingJSON = ko.observable false
    json = ko.observable ''
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
    showJSON = ->
      json(ko.mapping.toJSON(@items))
      showingJSON(true)
      setTimeout -> 
        showingJSON(false)
      , 10000

    return {
      resetData: resetData
      items: items
      itemToInsert: itemToInsert
      showingJSON: showingJSON
      json: json
      # indentOn2LeadingSpaces: indentOn2LeadingSpaces
      # outdentOnBackspaceAndEmpty: outdentOnBackspaceAndEmpty
      checkIndentationKeyBindings: checkIndentationKeyBindings
      saveOnEnter: saveOnEnter
      showJSON: showJSON
    }

  Meteor.startup ->
    ko.applyBindings new viewModel()

if Meteor.is_server
  Meteor.startup -> 
    reset_data() if Items.find().count() is 0
