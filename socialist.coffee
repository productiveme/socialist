Items = new Meteor.Collection 'items'

samples = (exports ? this).samples or []

reset_data = -> # Executes on both client and server.
  Items.remove {list: vm.listName?() or 'Sample'}
  for sample in samples

    newid = Items.insert
      item: sample.item
      # indent: sample.ancestors.length
      archived: sample.archived
      list: vm.listName?() or 'Sample'
      sortOrder: _i
      parent: sample.parent
      ancestors: sample.ancestors
    
    # Correct the ids with the newly created ones
    for s in samples
      s.parent = s.parent.replace sample._id, newid if s.parent
      s.ancestors = for a in s.ancestors 
        a.replace sample._id, newid

  return # nothing


if Meteor.is_client

  itemMapping = 
    item:
      # item observable is created
      create: (options) ->
        itemObject = options.parent
        observable = ko.observable(options.data)
        itemObject.isEditing = ko.observable(false)
        itemObject.isMoving = ko.observable(false)
        #indent2 = ko.observable(itemObject.ancestors?().length)
        itemObject.indent = ko.computed -> 
          if @ancestors then @ancestors().length else 0
        , itemObject
        itemObject.modeTemplate = -> 
          if itemObject.isEditing() then 'itemEditing' else 'item'
        itemObject.setEditing = -> itemObject.isEditing(true)
        itemObject.clearEditing = -> itemObject.isEditing(false)
        itemObject.doIndent = ->
          pos = vm.vm().items.indexOf(itemObject)
          items = vm.vm().items[..pos-1].reverse()
          for itm in items # walk up the list to find first sibling
            if itm._id() is itemObject.parent() # parent found before sibling, cannot indent
              break;
            if itm.parent() is itemObject.parent()
              ancestors = itm.ancestors()
              ancestors.push itm._id()
              Items.update itemObject._id(),
                $set:
                  parent: itm._id()
                  ancestors: ancestors
              break
          return

          # maxIndent = 0
          # pos = vm.vm().items().indexOf(itemObject) # current position in items
          # maxIndent = vm.vm().items()[pos-1].indent() + 1 if pos > 0 # indent of previous item
          # if itemObject.indent() < maxIndent
          #   pi = itemObject.indent()
          #   Items.update itemObject._id(),
          #     $inc: indent: 1
          #   for itm in vm.vm().items[pos+1..]
          #     break if itm.indent() <= pi
          #     Items.update itm._id(),
          #       $inc: indent: 1
        itemObject.doOutdent = -> 
          parent = Items.findOne itemObject.parent() # become sibling of parent
          Items.update itemObject._id(),
            $set: 
              parent: parent?.parent
              ancestors: parent?.ancestors
          # if itemObject.indent() > 0
          #   pos = vm.vm().items().indexOf(itemObject) # current position in items
          #   pi = itemObject.indent()
          #   Items.update itemObject._id(), 
          #     $inc: indent: -1
          #   for itm in vm.vm().items[pos+1..]
          #     break if itm.indent() <= pi
          #     Items.update itm._id(),
          #       $inc: indent: -1
        itemObject.save = -> 
          itemObject.isEditing(false)
          Items.update itemObject._id(),
            $set: 
              item: itemObject.item()
              # indent: itemObject.indent()
              archived: false
        itemObject.remove = -> 

          # archive/remove all items having this one as an ancestor
          # archive/remove this item

          # pos = vm.vm().items().indexOf(itemObject) # current position in items
          # pi = itemObject.indent()
          # if itemObject.archived()
          #   Items.remove itemObject._id()
          #   for itm in vm.vm().items[pos+1..]
          #     break if itm.indent() <= pi
          #     Items.remove itm._id()
          # else
          #   Items.update itemObject._id(), 
          #     $set: archived: true
          #   for itm in vm.vm().items[pos+1..]
          #     break if itm.indent() <= pi
          #     Items.update itm._id(), 
          #     $set: archived: true

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
      for itm in items()[items.indexOf(data) + 1..]
        if not itm.isMoving()
          nextItem = itm
          break
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
      #setTimeout => 
      #  @showingJSON false
      #, 30000
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
