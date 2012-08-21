Items = new Meteor.Collection 'items'

reset_data = -> # Executes on both client and server.
  Items.remove {list: vm.listName?() or 'Sample'}
  samples = [{"isEditing":false,"isMoving":false,"item":"Previous Sprint","indent":0,"archived":true,"sortOrder":4,"list":"Sample","_id":"2f884a84-456e-4646-8042-fe4058c5b741"},{"_id":"34b60b26-b1b5-4d85-89c7-2b84ac1f5f38","isEditing":false,"isMoving":false,"item":"Archive before delete","indent":1,"archived":true,"list":"Sample","sortOrder":8},{"_id":"1bf4e1e1-b5e8-4810-8361-429d24ff22c5","isEditing":false,"isMoving":false,"item":"Ability to unarchive","indent":1,"archived":true,"list":"Sample","sortOrder":16},{"_id":"43ce221a-f62d-46d4-8a08-4a09d419aecf","isEditing":false,"isMoving":false,"item":"Bigger, better action icons. Change to buttons?","indent":1,"archived":true,"list":"Sample","sortOrder":24},{"_id":"2e1a1f76-bb68-4cec-a470-cd387c77088e","isEditing":false,"isMoving":false,"item":"Ability to rearrange items","indent":1,"archived":true,"list":"Sample","sortOrder":32},{"_id":"69af6e82-b659-4736-b7cb-325811dfd7ab","isEditing":false,"isMoving":false,"item":"Should not be able to outdent past 0","indent":1,"archived":true,"list":"Sample","sortOrder":40},{"_id":"5cd6bfcf-041b-4859-984e-cf4e884bb6de","isEditing":false,"isMoving":false,"item":"Ability to create a new uniquely named list","indent":1,"archived":true,"list":"Sample","sortOrder":44},{"_id":"d7f3a09e-64f3-452c-9dbf-68cf0a0eeaf8","isEditing":false,"isMoving":false,"item":"Shareable url for each list","indent":1,"archived":true,"list":"Sample","sortOrder":46},{"_id":"73c1db90-8765-4f9b-9f2b-98529a34618c","isEditing":false,"isMoving":false,"item":"Ability to clear archived items","indent":1,"archived":true,"list":"Sample","sortOrder":47},{"_id":"1fe201cd-a048-4d48-8aa7-cfc35ec5fd67","isEditing":false,"isMoving":false,"item":"Ability to archive all items","indent":1,"archived":true,"list":"Sample","sortOrder":47.5},{"_id":"8c73b9f7-ec5b-41f3-9697-e4743b0e4584","isEditing":false,"isMoving":false,"item":"Should not be able to indent more than one level below parent","indent":1,"archived":true,"list":"Sample","sortOrder":47.75},{"_id":"96c96405-b1ef-4015-815c-47f5c9024ad8","isEditing":false,"isMoving":false,"item":"Children should move with parent","indent":1,"archived":true,"list":"Sample","sortOrder":48},{"_id":"41aff2e8-6066-48d4-86a5-09281fe4bd33","isEditing":false,"isMoving":false,"item":"Children should archive/delete with parent","indent":1,"archived":true,"list":"Sample","sortOrder":64},{"_id":"0cb566ca-ca6f-46d2-aee1-5e273c55061a","isEditing":false,"isMoving":false,"item":"Children should indent/outdent with parent","indent":1,"archived":true,"list":"Sample","sortOrder":72},{"_id":"7173118c-98ac-4627-8a33-9ce46de41b99","isEditing":false,"isMoving":false,"item":"Current Sprint","indent":0,"archived":false,"list":"Sample","sortOrder":88.34285714285714},{"_id":"cc1d52a6-3d9a-4750-8cd6-1a0133df65c6","archived":false,"indent":1,"isEditing":false,"isMoving":false,"item":"Ability to collapse/expand a parent","list":"Sample","sortOrder":88.38095238095238},{"_id":"08b205ed-0ea5-4022-8044-97567a3fa77b","archived":false,"indent":1,"isEditing":false,"isMoving":false,"item":"Actions column on right","list":"Sample","sortOrder":88.41904761904762},{"_id":"75609ba3-8315-484c-8d86-c25eab76d27c","archived":false,"indent":2,"isEditing":false,"isMoving":false,"item":"Header has slider buttons to switch to different action set","list":"Sample","sortOrder":88.43809523809524},{"_id":"8e9e003e-a55b-479f-aad9-63c039dcc46f","archived":false,"indent":3,"isEditing":false,"isMoving":false,"item":"Max 2 buttons","list":"Sample","sortOrder":88.45714285714286},{"_id":"89b7c91d-3203-47d0-a9e2-e3c45609011b","archived":false,"indent":3,"isEditing":false,"isMoving":false,"item":"Indent/outdent","list":"Sample","sortOrder":88.47619047619048},{"_id":"480991cd-a902-4086-aa54-eb11a3a0703f","archived":false,"indent":3,"isEditing":false,"isMoving":false,"item":"Archive/Unarchive","list":"Sample","sortOrder":88.4952380952381},{"_id":"c537f9a7-e6ec-41c6-a8c0-b1a29b8a44a5","archived":false,"indent":3,"isEditing":false,"isMoving":false,"item":"Collapse/Expand","list":"Sample","sortOrder":88.51428571428572},{"_id":"a631d34d-489b-4e4a-84aa-87c5d00dc317","archived":false,"indent":1,"isEditing":false,"isMoving":false,"item":"Textarea instead of single line textbox. Should grow instead of scroll and allow line breaks","list":"Sample","sortOrder":96.25714285714287},{"_id":"f97ca1f5-71e9-4898-ae0e-3f10e86dd9b7","archived":false,"indent":1,"isEditing":false,"isMoving":false,"item":"Natural keyboard behaviour","list":"Sample","sortOrder":97.80571428571429},{"_id":"74969a71-d9d4-4a57-b9f6-bcb9e6d7edb3","archived":false,"indent":2,"isEditing":false,"isMoving":false,"item":"Up/down arrows edits rows above or below","list":"Sample","sortOrder":99.35428571428572},{"_id":"7c2ca1d4-ef6c-4deb-abcb-b0287f4289fe","archived":false,"indent":2,"isEditing":false,"isMoving":false,"item":"Enter creates new item below","list":"Sample","sortOrder":100.90285714285714},{"_id":"63bb4e2f-6ea6-4ce8-9851-5936a2db5328","archived":false,"indent":2,"isEditing":false,"isMoving":false,"item":"Backspace deletes characters until the start, then outdents until 0, then deletes item ","list":"Sample","sortOrder":102.45142857142858},{"_id":"a64d6eae-e2a2-4718-8126-bf01d51d557a","isEditing":false,"isMoving":false,"item":"Backlog","indent":0,"archived":false,"list":"Sample","sortOrder":104},{"_id":"035e3c04-f58e-4168-bd7b-fbb80ec80040","isEditing":false,"isMoving":false,"item":"Ability to password protect a list","indent":1,"archived":false,"list":"Sample","sortOrder":112},{"_id":"7358c0ad-39e2-4a48-b2d3-d16f6573732a","isEditing":false,"isMoving":false,"item":"Ability to add a checkbox column, parent indicates number of checked children","indent":1,"archived":false,"list":"Sample","sortOrder":120},{"_id":"814d7eac-e123-4e02-8e65-7a04f0bff70e","isEditing":false,"isMoving":false,"item":"Ability to add a numeric column, parent shows sum of children","indent":1,"archived":false,"list":"Sample","sortOrder":128}]
  for sample in samples
    Items.insert
      item: sample.item
      indent: sample.indent
      archived: sample.archived
      list: vm.listName?() or 'Sample'
      sortOrder: _i * 8
      #sortOrder: sample.sortOrder
  return

if Meteor.is_client
  itemMapping = 
    item:
      # item observable is created
      create: (options) ->
        parent = options.parent
        observable = ko.observable(options.data)
        parent.isEditing = ko.observable(false)
        parent.isMoving = ko.observable(false)
        parent.modeTemplate = -> 
          if parent.isEditing() then 'itemEditing' else 'item'
        parent.setEditing = -> parent.isEditing(true)
        parent.clearEditing = -> parent.isEditing(false)
        parent.doIndent = -> 
          maxIndent = 0
          pos = vm.vm().items().indexOf(parent) # current position in items
          maxIndent = vm.vm().items()[pos-1].indent() + 1 if pos > 0 # indent of previous item
          if parent.indent() < maxIndent
            pi = parent.indent()
            Items.update parent._id(),
              $inc: indent: 1
            for itm in vm.vm().items[pos+1..]
              break if itm.indent() <= pi
              Items.update itm._id(),
                $inc: indent: 1
        parent.doOutdent = -> 
          if parent.indent() > 0
            pos = vm.vm().items().indexOf(parent) # current position in items
            pi = parent.indent()
            Items.update parent._id(), 
              $inc: indent: -1
            for itm in vm.vm().items[pos+1..]
              break if itm.indent() <= pi
              Items.update itm._id(),
                $inc: indent: -1
        parent.save = -> 
          parent.isEditing(false)
          Items.update parent._id(),
            $set: 
              item: parent.item()
              indent: parent.indent()
              archived: false
        parent.remove = -> 
          pos = vm.vm().items().indexOf(parent) # current position in items
          pi = parent.indent()
          if parent.archived()
            Items.remove parent._id()
            for itm in vm.vm().items[pos+1..]
              break if itm.indent() <= pi
              Items.remove itm._id()
          else
            Items.update parent._id(), 
              $set: archived: true
            for itm in vm.vm().items[pos+1..]
              break if itm.indent() <= pi
              Items.update itm._id(), 
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
      maxIndent = 0
      try
        maxIndent = vm.vm().items()[vm.vm().items().length - 1].indent() + 1 # indent of last item
      @indent(@indent() + 1) if @indent() < maxIndent
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
    itemsToMove = []
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
      pos = items.indexOf(data)
      itemsToMove = []
      itemsToMove.push(data)
      data.isMoving true
      for itm in items[pos+1..]
        break if itm.indent() <= data.indent()
        itemsToMove.push itm
        itm.isMoving true
      isMoving true
    moveHere = (data) ->
      nextItem = items()[items.indexOf(data) + 1]
      sortIncrement = 8
      indentIncrement = if data.indent() < itemsToMove[0].indent() - 1 then data.indent() - itemsToMove[0].indent() + 1 else 0
      try
        sortIncrement = (nextItem.sortOrder() - data.sortOrder()) / (itemsToMove.length + 1)
      for itm, i in itemsToMove
        newSortOrder = data.sortOrder() + (sortIncrement * (i+1))
        Items.update itm._id(),
          $set: sortOrder: newSortOrder
          $inc: indent: indentIncrement
        itm.isMoving false
      itemsToMove = []
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
