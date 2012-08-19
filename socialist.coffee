Items = new Meteor.Collection 'items'

reset_data = -> # Executes on both client and server.
  Items.remove {}
  samples = [{"isEditing":false,"item":"Current Sprint","indent":0,"archived":false,"sortOrder":0,"_id":"9f1056eb-9064-4973-89e8-6d58f6b7c014"},{"isEditing":false,"item":"Archive before delete","indent":1,"archived":true,"sortOrder":8,"_id":"bdea2f38-ded5-4189-84bf-3dfd3aa029b6"},{"isEditing":false,"item":"Ability to unarchive","indent":1,"archived":true,"sortOrder":16,"_id":"97078551-5005-4e3c-afb4-e0f497ff6a6a"},{"isEditing":false,"item":"Bigger, better action icons. Change to buttons?","indent":1,"archived":true,"sortOrder":24,"_id":"19b6c5f6-482b-4be0-998b-96fa31ac7793"},{"_id":"e05521c0-2206-4f2d-8909-ba4b5ca3963d","isEditing":false,"item":"Ability to rearrange items","indent":1,"archived":true,"sortOrder":32},{"_id":"395b4711-a0fc-46dd-8fde-9acdf7b37374","isEditing":false,"item":"Children should move with parent","indent":1,"archived":false,"sortOrder":36},{"isEditing":false,"item":"Ability to insert an item anywhere in the list","indent":1,"archived":false,"sortOrder":40,"_id":"c6271cdd-df56-454c-88dc-c048dc5392c0"},{"isEditing":false,"item":"Children should archive/delete with parent","indent":1,"archived":false,"sortOrder":48,"_id":"47022ce4-5a9d-403e-b01f-1088702f9817"},{"isEditing":false,"item":"Children should indent/outdent with parent","indent":1,"archived":false,"sortOrder":56,"_id":"b6b4bab6-4792-4595-b2c2-17437b8f7fd9"},{"isEditing":false,"item":"Should not be able to indent more than one level below parent","indent":1,"archived":false,"sortOrder":64,"_id":"2687fef5-6168-4d6d-9154-eb4b2baa5093"},{"isEditing":false,"item":"Should not be able to outdent past 0","indent":1,"archived":true,"sortOrder":72,"_id":"cd5a846b-9420-4637-aaa8-a7f0b8a7d1ac"},{"isEditing":false,"item":"Ability to create a new uniquely named list","indent":1,"archived":false,"sortOrder":80,"_id":"87e66da4-8fe8-4bd6-8c8b-073b46326a2a"},{"isEditing":false,"item":"Shareable url for each list","indent":1,"archived":false,"sortOrder":88,"_id":"035a0a44-a52f-484e-89e4-9c0fa5413c55"},{"isEditing":false,"item":"Backlog","indent":0,"archived":false,"sortOrder":96,"_id":"c907dfd3-0bab-4619-847d-6b83c03ed8b1"},{"isEditing":false,"item":"Ability to password protect a list","indent":1,"archived":false,"sortOrder":104,"_id":"e7cadc57-c93a-4e47-8102-cad6ee5519c2"},{"isEditing":false,"item":"Ability to add a checkbox column, parent indicates number of checked children","indent":1,"archived":false,"sortOrder":112,"_id":"8afbab81-8214-4453-9b51-de3960ac98a2"},{"isEditing":false,"item":"Ability to add a numeric column, parent shows sum of children","indent":1,"archived":false,"sortOrder":120,"_id":"874354c1-d646-4b1a-bb0f-e3b848ecf39b"},{"isEditing":false,"item":"Textarea instead of single line textbox. Should grow instead of scroll and allow line breaks","indent":1,"archived":false,"sortOrder":128,"_id":"4ce58328-61ff-4234-8edd-74f4d7568adf"}]
  for sample in samples
    Items.insert
      item: sample.item
      indent: sample.indent
      archived: sample.archived
      sortOrder: sample.sortOrder  
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
        parent.doOutdent = -> 
          parent.indent(parent.indent() - 1) if parent.indent() > 0
        parent.save = -> 
          parent.isEditing(false)
          Items.update parent._id(),
            $set: 
              item: parent.item()
              indent: parent.indent()
              archived: false
        parent.remove = -> 
          if parent.archived()
            Items.remove parent._id()
          else
            Items.update parent._id(), 
              $set: archived: true

        return observable

  blankItem = ->
    @item = ko.observable('')
    @indent = ko.observable(0)
    @save = =>
      Items.insert
        item: @item()
        indent: @indent()
        archived: false
        sortOrder: vm.items()[vm.items().length-1].sortOrder() + 8
      @item('')
    @doIndent = =>
      @indent(@indent() + 1)
    @doOutdent = =>
      @indent(@indent() - 1) if @indent() > 0
    return


  viewModel = ->
    _this = this
    items = ko.meteor.find(Items, {}, {sort: {sortOrder: 1}}, itemMapping)
    itemToInsert = new blankItem()
    showingJSON = ko.observable false
    json = ko.observable ''
    isMoving = ko.observable false
    movingItemId = ''
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
    moveItem = (data) ->
      movingItemId = data._id()
      items.remove data
      isMoving true
    moveHere = (data) ->
      nextItem = items()[items.indexOf(data) + 1]
      newSortOrder = data.sortOrder() + 10
      try
        newSortOrder = data.sortOrder() + (nextItem.sortOrder() - data.sortOrder()) / 2
      Items.update movingItemId,
        $set: sortOrder: newSortOrder
      movingItemId = ''
      isMoving false

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
      # movingItem: movingItem
      moveItem : moveItem
      isMoving: isMoving
      moveHere: moveHere
    }

  vm = new viewModel()

  Meteor.startup ->
    ko.applyBindings vm

if Meteor.is_server
  Meteor.startup -> 
    reset_data() if Items.find().count() is 0
