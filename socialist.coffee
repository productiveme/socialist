Items = new Meteor.Collection 'items'

samples = (exports ? this).samples or [] # from the global scope on either server or client

reset_data = -> # Executes on both client and server.
  Items.remove {list: vm.listName?() or 'Sample'}
  for sample,i in samples

    newid = Items.insert
      item: sample.item
      archived: sample.archived
      list: vm.listName?() or 'Shopping-List'
      idx: sample.idx
    
  return # nothing


if Meteor.is_client

  itemMapping = 
    item:
      # item observable is created, actually the text entered for an item object
      create: (options) ->
        itemObject = options.parent # get the real item object
        observable = ko.observable(options.data)
        itemObject.isMoving = ko.observable(false)
        itemObject.indent = ko.observable(@idx?().split('.').length) 
        itemObject.canMoveHere = ko.computed ->
          return vm.vm().isMoving() and not @isMoving()
        , itemObject
        itemObject.doIndent = ->
          # get previous item's index
          items = vm.vm().items
          pos = items.indexOf(itemObject)
          prevIdx = items()[pos-1]?.idx()

          # replace all starting with my index with previous item's index
          itm.idx(itm.idx().replace(itemObject.idx(),prevIdx)) for itm in items

          vm.vm().saveAll()

          return

        itemObject.doOutdent = -> 
          # Grandparent becomes my parent
          parent = Items.findOne itemObject.parent()
          Items.update itemObject._id(),
            $set: 
              parent: parent?.parent
              ancestors: parent?.ancestors
          # Remove my old parent from my children's ancestors
          Items.update { ancestors: itemObject._id() },
            { $pull: ancestors: parent?._id },
            { multi: true }

        itemObject.save = -> 
          Items.update itemObject._id(),
            $set: 
              item: itemObject.item()
              
        itemObject.unarchive = ->
          # unarchive children as well
          Items.update { ancestors: itemObject._id() }, 
            { $set: archived: false },
            { multi: true }
          Items.update itemObject._id(),
            $set: archived: false

        itemObject.remove = ->           
          if itemObject.archived() # remove item and children
            Items.remove 
              ancestors: itemObject._id()
            Items.remove itemObject._id()
          else # archive item and children
            Items.update { ancestors: itemObject._id() }, 
              { $set: archived: true },
              { multi: true }
            Items.update itemObject._id(),
              $set: archived: true

        return observable

  # The form to create a new list
  newListModel = (parent) ->
    @name = ko.observable ''
    @saveOnEnter = (model, event) =>
      return true unless event.which is 13
      model.save()
      return false
    @goShopping = =>
      window.location.href = 'http://' + window.location.host + '/#!Shopping-List'
      window.location.reload()
      return
    @save = =>
      Session.set 'listName', canonicalListName @name()
      window.location.href = 'http://' + window.location.host + '/#!' + canonicalListName(@name())
      window.location.reload()
      return
    return   

  listModel = (parent) ->
    _this = this
    items = ko.meteor.find(Items, {list: parent.listName()}, {sort: {idx: 1}}, itemMapping)   
    isMoving = ko.observable false

    itemsToMoveIndex = ko.observable()
    itemsToMoveCount = ko.observable()

    actionSets = ko.observableArray ['archiveRemove', 'indentOutdent']

    saveAll = ->
      newIdx = []
      for itm,i in items()
        newIdx[itm.indent()] = (newIdx[itm.indent()] or 0) + 1
        idxString = ""
        for i in [0..itm.indent()] 
          idxString += ("." unless idxString is "") + ("000" + newIdx[i]).slice(-3)
        Items.update itm._id(),
          $set:
            item: itm.item()
            idx: idxString

    createNewItem = ->
      newid = Items.insert 
        item: ''
        archived: false
        sortOrder: items().length
        list: vm.listName()
        parent: ''
        ancestors: []
      Meteor.defer ->
        $(".#{newid} input")[0].focus()
    
    indentOn3Spaces = (model,event) ->
      return unless event.which is 32
      return unless model.item().substr(0,2) is '  ' # space event and already 2 leading spaces
      model.item(model.item().substring(2))
      model.doIndent()

      # keep focus on my textbox after update
      myId = model._id()
      Meteor.defer ->
        $(".#{myId} input")[0].focus()
    
    outdentOnBackspaceAndEmpty = (model, event) ->
      return unless event.which is 8
      return unless model.item() is ''
      model.save()
      if !model.parent()
        focusid = model._id()
        focusid = items()[items.indexOf(model)-1]?._id() if model.archived()
        model.remove()
      
        Meteor.defer ->
          $(".#{focusid} input").each ->
            $(@).focus()

      else
        model.doOutdent()

        # keep focus on my textbox after update
        myId = model._id()
        Meteor.defer ->
          $(".#{myId} input")[0].focus()

    checkKeydownBindings = (model, event) ->
      indentOn3Spaces model, event
      outdentOnBackspaceAndEmpty model, event
      saveOnEnter model, event
      focusPreviousOnUp model, event
      focusNextOnDown model, event
      return true

    focusPreviousOnUp = (model, event) ->
      return unless event.which is 38
      prevId = items()[items.indexOf(model)-1]?._id()
      model.save()
      if prevId
        Meteor.defer ->
          $(".#{prevId} input")[0].focus() 

    focusNextOnDown = (model, event) ->
      return unless event.which is 40
      nextId = items()[items.indexOf(model)+1]?._id()
      model.save()
      if nextId
        Meteor.defer ->
          $(".#{nextId} input")[0].focus()

    saveOnEnter = (model, event) ->
      return true unless event.which is 13      
      model.save()
      pos = items.indexOf(model)
      # either I'm the last item or get the next item's sort order
      nextOrder = items()[pos+1]?.sortOrder() or model.sortOrder() + 2
      newid = Items.insert
        item: ''
        archived: false
        sortOrder: model.sortOrder() + ((nextOrder - model.sortOrder()) / 2) # split the difference
        list: vm.listName()
        parent: model.parent?()
        ancestors: model.ancestors?()

      Meteor.defer ->
        $(".#{newid} input")[0].focus()
      return false

    moveItem = (data) ->
      itemsToMoveIndex items.indexOf(data)
      data.isMoving true
      pos = items.indexOf(data)
      countOfItems = 1
      for itm in items[pos+1..]
        break if itm.indent() <= data.indent()
        countOfItems++ #itemsToMove.push itm
        itm.isMoving true
      isMoving true
      itemsToMoveCount countOfItems

    moveHere = (data) ->
      # splice from observableArray and insert in new pos
      cutItems = items.splice itemsToMoveIndex(), itemsToMoveCount()
      
      # root item to move should become sibling of selected item
      rootItemToMove = cutItems[0]
      rootItemOldIndent = rootItemToMove.indent()
      
      rootItemToMove.ancestors data.ancestors()[..] # copy target's ancestors
      rootItemToMove.ancestors.push data._id()      # and add target as the final ancestor
      rootItemToMove.parent data.parent()           # and parent

      # root item's children should get new ancestry
      for itm in cutItems[1..]
        itm.ancestors.splice 0, rootItemOldIndent                                   # throw away old ancestry
        itm.ancestors.unshift(id) for id in rootItemToMove.ancestors[..].reverse()  # and prepend parent's new ancestory

      pastePos = items.indexOf(data) + 1
      tail = items.splice(pastePos, 9e9)
      items.push itm for itm in cutItems
      items.push itm for itm in tail
      isMoving false

      # Save each item in list with new sortOrder based on pos in observableArray
      for itm,i in items()
        Items.update itm._id(),
          $set: 
            sortOrder: i
            parent: itm.parent()
            ancestors: itm.ancestors()
        itm.isMoving false
        prevItem = itm

      return

    rotateActionSets = ->
      actionSets.push actionSets.shift()

    actionSetTemplate = ko.computed ->
      actionSets()[0] + 'Template'
      
    return {
      items: items
      createNewItem: createNewItem
      checkKeydownBindings: checkKeydownBindings
      saveOnEnter: saveOnEnter
      moveItem : moveItem
      isMoving: isMoving
      moveHere: moveHere
      actionSetTemplate: actionSetTemplate
      rotateActionSets: rotateActionSets
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
    @newList = ->
      Session.set 'listName', ''
      return true
    @delArchived = ->
      Items.remove 
        list: @listName()
        archived: true
    @archiveAll = =>
      if @vm().items
        Items.update { list: vm.listName }, 
          { $set: archived: true },
          { multi: true }
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
