Items = new Meteor.Collection 'items'

reset_data = -> # Executes on both client and server.
  Items.remove {list: vm.listName?() or 'Sample'}
  samples = [{"_id":"63cdab2e-7402-4397-839a-dc1a4e29a6b8","isEditing":false,"item":"Current Sprint","indent":0,"archived":false,"list":"Sample","sortOrder":0},{"_id":"b088463c-bf98-4350-8a88-c5e82beef6cb","isEditing":false,"item":"Archive before delete","indent":1,"archived":true,"list":"Sample","sortOrder":8},{"_id":"99bf135f-8fa9-4961-959c-0adbb4077a5c","isEditing":false,"item":"Ability to unarchive","indent":1,"archived":true,"list":"Sample","sortOrder":16},{"_id":"a3849832-b67f-4e5e-8f7e-c052df9cf125","isEditing":false,"item":"Bigger, better action icons. Change to buttons?","indent":1,"archived":true,"list":"Sample","sortOrder":24},{"_id":"32b65b93-2a7c-496b-9a68-fcd205f437d7","isEditing":false,"item":"Ability to rearrange items","indent":1,"archived":true,"list":"Sample","sortOrder":32},{"_id":"785122d5-0f49-4390-b8d4-28ba4ed6a493","isEditing":false,"item":"Should not be able to outdent past 0","indent":1,"archived":true,"list":"Sample","sortOrder":40},{"_id":"85b8c0e1-1a2d-41c0-9e3f-6657298a001c","isEditing":false,"item":"Ability to create a new uniquely named list","indent":1,"archived":true,"list":"Sample","sortOrder":44},{"_id":"7b73c85d-63de-4a3e-978d-0ee929ae1a6b","isEditing":false,"item":"Shareable url for each list","indent":1,"archived":true,"list":"Sample","sortOrder":46},{"_id":"039cef9a-36a9-443d-9376-3bb78b01eb09","isEditing":false,"item":"Children should move with parent","indent":1,"archived":false,"list":"Sample","sortOrder":48},{"_id":"e8baf6d3-349a-4a30-aa7c-7f0853e1815e","isEditing":false,"item":"Ability to insert an item anywhere in the list","indent":1,"archived":false,"list":"Sample","sortOrder":56},{"_id":"7795416a-2774-4d3a-b15f-f7472eafbf72","isEditing":false,"item":"Children should archive/delete with parent","indent":1,"archived":false,"list":"Sample","sortOrder":64},{"_id":"e149284a-796c-4e32-8d87-4696f8870e16","isEditing":false,"item":"Children should indent/outdent with parent","indent":1,"archived":false,"list":"Sample","sortOrder":72},{"_id":"b8556c4e-20d1-498b-947d-f3694257fc9c","isEditing":false,"item":"Should not be able to indent more than one level below parent","indent":1,"archived":false,"list":"Sample","sortOrder":80},{"_id":"cd648315-bcae-4cd4-8f01-8f3886fe2271","isEditing":false,"item":"Backlog","indent":0,"archived":false,"list":"Sample","sortOrder":104},{"_id":"4d806c2d-7229-45a5-870f-147b96be2a80","isEditing":false,"item":"Ability to password protect a list","indent":1,"archived":false,"list":"Sample","sortOrder":112},{"_id":"3a03c271-8510-4eb3-8a20-b9695bcd7673","isEditing":false,"item":"Ability to add a checkbox column, parent indicates number of checked children","indent":1,"archived":false,"list":"Sample","sortOrder":120},{"_id":"28445766-f0dd-47a0-8dd0-7bc76808d813","isEditing":false,"item":"Ability to add a numeric column, parent shows sum of children","indent":1,"archived":false,"list":"Sample","sortOrder":128},{"_id":"67a97434-3cc5-4bea-8a0d-781d2b2d0723","isEditing":false,"item":"Textarea instead of single line textbox. Should grow instead of scroll and allow line breaks","indent":1,"archived":false,"list":"Sample","sortOrder":136}]
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

  newListModel = (parent) ->
    @name = ko.observable ''
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
    return

  canonicalListName = (name) ->
    name.replace(/[^A-z0-9\s]*/g,'').replace(/\s+/g, '-')

  Session.set 'listName', window.location.hash.replace('#!', '') or ''

  vm = new viewModel()

  Meteor.startup ->
    ko.applyBindings vm

if Meteor.is_server
  Meteor.startup -> 
    reset_data() if Items.find().count() is 0
