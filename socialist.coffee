Items = new Meteor.Collection 'items'

reset_data = -> # Executes on both client and server.
  Items.remove {list: vm.listName?() or 'Sample'}
  samples = [{"isEditing":false,"isMoving":false,"item":"Current Sprint","indent":0,"archived":false,"list":"Sample","sortOrder":0,"_id":"18b8cab5-c3ff-4146-8857-f05f13343ca1"},{"isEditing":false,"isMoving":false,"item":"Archive before delete","indent":1,"archived":true,"list":"Sample","sortOrder":8,"_id":"6ccf87a0-15af-44fe-8af3-724b06ede53e"},{"isEditing":false,"isMoving":false,"item":"Ability to unarchive","indent":1,"archived":true,"list":"Sample","sortOrder":16,"_id":"d068666e-a6f8-41d5-9d6a-5972922b07d1"},{"isEditing":false,"isMoving":false,"item":"Bigger, better action icons. Change to buttons?","indent":1,"archived":true,"list":"Sample","sortOrder":24,"_id":"ce5a2b43-20c4-4668-8f95-eee40a9aaa70"},{"isEditing":false,"isMoving":false,"item":"Ability to rearrange items","indent":1,"archived":true,"list":"Sample","sortOrder":32,"_id":"bfbcf42e-3e27-4843-805b-f0816239d1fa"},{"isEditing":false,"isMoving":false,"item":"Should not be able to outdent past 0","indent":1,"archived":true,"list":"Sample","sortOrder":40,"_id":"93e1f66c-7658-4721-9178-a478287592f7"},{"isEditing":false,"isMoving":false,"item":"Ability to create a new uniquely named list","indent":1,"archived":true,"list":"Sample","sortOrder":44,"_id":"ea3c97d9-785c-46d2-9b4a-0e3e821c1b29"},{"isEditing":false,"isMoving":false,"item":"Shareable url for each list","indent":1,"archived":true,"list":"Sample","sortOrder":46,"_id":"480c53f2-2ab8-4d27-babc-9facd88dd0fb"},{"isEditing":false,"isMoving":false,"item":"Ability to clear archived items","indent":1,"archived":true,"list":"Sample","sortOrder":47,"_id":"4272ebcd-15a9-46f1-8bfc-5e7019d45e6a"},{"isEditing":false,"isMoving":false,"item":"Ability to archive all items","indent":1,"archived":true,"list":"Sample","sortOrder":47.5,"_id":"5948255b-fe56-4e16-be29-92b20f8e3173"},{"isEditing":false,"isMoving":false,"item":"Should not be able to indent more than one level below parent","indent":1,"archived":true,"list":"Sample","sortOrder":47.75,"_id":"1881c8f3-cb81-4ef1-85d8-d2c4d06d8ca2"},{"isEditing":false,"isMoving":false,"item":"Children should move with parent","indent":1,"archived":true,"list":"Sample","sortOrder":48,"_id":"3832b582-36a4-4cf0-a896-b49bf296c9bb"},{"isEditing":false,"isMoving":false,"item":"Children should archive/delete with parent","indent":1,"archived":true,"list":"Sample","sortOrder":64,"_id":"d0e6f0e0-0bfa-4be7-ae2f-15fbfaf69282"},{"isEditing":false,"isMoving":false,"item":"Children should indent/outdent with parent","indent":1,"archived":true,"list":"Sample","sortOrder":72,"_id":"af8725c6-1013-4f13-803c-aaaf611644d5"},{"isEditing":false,"isMoving":false,"item":"Ability to insert an item anywhere in the list","indent":1,"archived":false,"list":"Sample","sortOrder":92,"_id":"f83b131e-7cd6-4f0a-83f1-384a9f8154f8"},{"isEditing":false,"isMoving":false,"item":"Backlog","indent":0,"archived":false,"list":"Sample","sortOrder":104,"_id":"4b7adb1e-5f4f-41b6-9697-d11c5b187885"},{"isEditing":false,"isMoving":false,"item":"Ability to password protect a list","indent":1,"archived":false,"list":"Sample","sortOrder":112,"_id":"934c0752-c323-44f6-bf25-e51128b5d4b9"},{"isEditing":false,"isMoving":false,"item":"Ability to add a checkbox column, parent indicates number of checked children","indent":1,"archived":false,"list":"Sample","sortOrder":120,"_id":"5608c834-fa53-4767-b47b-f2f90ea53fac"},{"isEditing":false,"isMoving":false,"item":"Ability to add a numeric column, parent shows sum of children","indent":1,"archived":false,"list":"Sample","sortOrder":128,"_id":"6a7e6a6f-9379-4dcb-878a-ded43f6e6341"},{"isEditing":false,"isMoving":false,"item":"Textarea instead of single line textbox. Should grow instead of scroll and allow line breaks","indent":1,"archived":false,"list":"Sample","sortOrder":136,"_id":"796952aa-f787-449e-97cc-736c990bcad3"}]
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
