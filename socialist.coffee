Items = new Meteor.Collection 'items'

reset_data = -> # Executes on both client and server.
  Items.remove {list: vm.listName?() or 'Sample'}
  samples = [{"isEditing":false,"item":"Current Sprint","indent":0,"archived":false,"list":"Sample","sortOrder":0,"_id":"e5da7063-bebb-41f0-b083-bd8d5a02b632"},{"isEditing":false,"item":"Archive before delete","indent":1,"archived":true,"list":"Sample","sortOrder":8,"_id":"2159a75a-705f-48ae-9605-adb472a6177b"},{"isEditing":false,"item":"Ability to unarchive","indent":1,"archived":true,"list":"Sample","sortOrder":16,"_id":"d90417b7-6fee-466b-8a64-c593b5199483"},{"isEditing":false,"item":"Bigger, better action icons. Change to buttons?","indent":1,"archived":true,"list":"Sample","sortOrder":24,"_id":"1e9a1e68-45f9-41cb-b158-6219852cf84f"},{"isEditing":false,"item":"Ability to rearrange items","indent":1,"archived":true,"list":"Sample","sortOrder":32,"_id":"38065f1d-3c8a-4321-8007-7e3408095cd8"},{"isEditing":false,"item":"Should not be able to outdent past 0","indent":1,"archived":true,"list":"Sample","sortOrder":40,"_id":"3b336c23-5532-4d46-a1cb-98eb3a6a37f5"},{"isEditing":false,"item":"Ability to create a new uniquely named list","indent":1,"archived":true,"list":"Sample","sortOrder":44,"_id":"d0c4ff23-2560-452b-940b-d220e128314a"},{"isEditing":false,"item":"Shareable url for each list","indent":1,"archived":true,"list":"Sample","sortOrder":46,"_id":"d3b8cc8e-bcae-4b13-858f-bb03463002ef"},{"_id":"f741e7c6-71fb-4b01-8ff1-95f78ed81f38","isEditing":false,"item":"Ability to clear archived items","indent":1,"archived":true,"sortOrder":47,"list":"Sample"},{"_id":"74aba5f8-6d52-4cb4-931f-4cd4e40c2293","isEditing":false,"item":"Ability to archive all items","indent":1,"archived":true,"sortOrder":47.5,"list":"Sample"},{"_id":"dde8a646-084c-4073-8cb4-4d415724b904","isEditing":false,"item":"Should not be able to indent more than one level below parent","indent":1,"archived":false,"list":"Sample","sortOrder":47.75},{"isEditing":false,"item":"Children should move with parent","indent":1,"archived":false,"list":"Sample","sortOrder":48,"_id":"2a96fa17-36ca-4536-88ce-94e763d64933"},{"isEditing":false,"item":"Children should archive/delete with parent","indent":1,"archived":false,"list":"Sample","sortOrder":64,"_id":"fef1e673-5369-45c0-bdf7-833134c3a337"},{"isEditing":false,"item":"Children should indent/outdent with parent","indent":1,"archived":false,"list":"Sample","sortOrder":72,"_id":"d0d06cac-382a-48cb-83b0-65d7dd0bbd9e"},{"_id":"3625d6c1-d406-4793-8886-b0294e455ff8","isEditing":false,"item":"Ability to insert an item anywhere in the list","indent":1,"archived":false,"list":"Sample","sortOrder":92},{"isEditing":false,"item":"Backlog","indent":0,"archived":false,"list":"Sample","sortOrder":104,"_id":"5ffcf743-8940-4321-8029-b6b1bbf2be31"},{"isEditing":false,"item":"Ability to password protect a list","indent":1,"archived":false,"list":"Sample","sortOrder":112,"_id":"d0524a04-b728-4f6f-9e45-6443849e44d0"},{"isEditing":false,"item":"Ability to add a checkbox column, parent indicates number of checked children","indent":1,"archived":false,"list":"Sample","sortOrder":120,"_id":"54d8b5c8-d337-40be-aea1-1c71bde1b570"},{"isEditing":false,"item":"Ability to add a numeric column, parent shows sum of children","indent":1,"archived":false,"list":"Sample","sortOrder":128,"_id":"1195ca4b-04d7-4e4f-8aa3-ab46ae8f2f90"},{"isEditing":false,"item":"Textarea instead of single line textbox. Should grow instead of scroll and allow line breaks","indent":1,"archived":false,"list":"Sample","sortOrder":136,"_id":"a12fc44f-077e-421d-82f7-c183038f98b8"}]
  for sample in samples
    Items.insert
      item: sample.item
      indent: sample.indent
      archived: sample.archived
      list: vm.listName?() or 'Sample'
      #sortOrder: _i * 8
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

  # The empty row at the bottom of the list for inserting new items
  blankItem = ->
    @item = ko.observable('')
    @indent = ko.observable(0)
    @save = =>
      items = vm.vm().items();
      Items.insert
        item: @item()
        indent: @indent()
        archived: false
        sortOrder: if items.length then items[items.length-1].sortOrder() + 8 else 0
        list: vm.listName()
      @item('')
    @doIndent = =>
      @indent(@indent() + 1)
    @doOutdent = =>
      @indent(@indent() - 1) if @indent() > 0
    return

  # The form to create a new list
  newListModel = (parent) ->
    @name = ko.observable ''
    @saveOnEnter = (model, event) =>
      return true unless event.which is 13
      model.save()
      return false
    @save = =>
      Session.set 'listName', canonicalListName @name()
      window.location.href = 'http://' + window.location.host + '/#!' + canonicalListName(@name())
      window.location.reload() #parent.listName canonicalListName(@name())
      return
    return   

  listModel = (parent) ->
    _this = this
    items = ko.meteor.find(Items, {list: parent.listName()}, {sort: {sortOrder: 1}}, itemMapping)
    itemToInsert = new blankItem()
    isMoving = ko.observable false
    movingItemId = ''
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
      items: items
      itemToInsert: itemToInsert
      # indentOn2LeadingSpaces: indentOn2LeadingSpaces
      # outdentOnBackspaceAndEmpty: outdentOnBackspaceAndEmpty
      checkIndentationKeyBindings: checkIndentationKeyBindings
      saveOnEnter: saveOnEnter
      # movingItem: movingItem
      moveItem : moveItem
      isMoving: isMoving
      moveHere: moveHere
    }

  viewModel = ->
    @listName = ko.observable canonicalListName(Session.get 'listName')
    @showingJSON = ko.observable false
    @json = ko.observable ''
    @templateToUse = =>
      return if @listName() then 'socialist' else 'newList'
    @vm = ko.observable(if @listName() is '' then new newListModel(@) else new listModel(@))
    @listName.subscribe =>
      if @listName() is '' then @vm(new newListModel(@)) else @vm(new listModel(@))
    @resetData = -> reset_data()
    @showJSON = =>
      if @vm().items then @json ko.mapping.toJSON(@vm().items)
      @showingJSON true
      setTimeout => 
        @showingJSON false
      , 10000
    @newList = ->
      Session.set 'listName', ''
      return true
    @delArchived = ->
      Items.remove 
        list: @listName()
        archived: true
    @archiveAll = =>
      if @vm().items
        for itm in @vm().items()
          Items.update itm._id(), 
            $set: archived: true
      return
    return

  canonicalListName = (name) ->
    name.replace(/[^-A-z0-9\s]*/g,'').replace(/\s+/g, '-')

  Session.set 'listName', window.location.hash.replace('#!', '') or ''

  vm = new viewModel()

  Meteor.startup ->
    ko.applyBindings vm

if Meteor.is_server
  Meteor.startup -> 
    reset_data() if Items.find().count() is 0
