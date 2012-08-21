Items = new Meteor.Collection 'items'

reset_data = -> # Executes on both client and server.
  Items.remove {list: vm.listName?() or 'Sample'}
  samples = [{"isEditing":false,"isMoving":false,"item":"Roadmap","indent":0,"archived":false,"sortOrder":4,"list":"Roadmap","_id":"97d4abee-6867-442c-b2e9-3424438849b0"},{"isEditing":false,"isMoving":false,"item":"Previous Sprint","indent":1,"archived":true,"list":"Roadmap","sortOrder":6,"_id":"3ebe06d6-01b7-42e4-9323-71428e2b1cd7"},{"isEditing":false,"isMoving":false,"item":"Archive before delete","indent":2,"archived":true,"list":"Roadmap","sortOrder":8,"_id":"890f7b23-ce7d-490f-8730-19d714598c3f"},{"isEditing":false,"isMoving":false,"item":"Ability to unarchive","indent":2,"archived":true,"list":"Roadmap","sortOrder":16,"_id":"b1b94d12-dcd4-43c0-8a9b-2c51456672f1"},{"isEditing":false,"isMoving":false,"item":"Bigger, better action icons. Change to buttons?","indent":2,"archived":true,"list":"Roadmap","sortOrder":24,"_id":"2aa3c11a-5fba-4337-8c0b-bb073f77ab90"},{"isEditing":false,"isMoving":false,"item":"Ability to rearrange items","indent":2,"archived":true,"list":"Roadmap","sortOrder":32,"_id":"ffa8a7c6-96a1-456c-8355-73bf3f1f442f"},{"isEditing":false,"isMoving":false,"item":"Should not be able to outdent past 0","indent":2,"archived":true,"list":"Roadmap","sortOrder":40,"_id":"7720cf5e-a0a1-4e06-854d-ec469c1d4bfb"},{"isEditing":false,"isMoving":false,"item":"Ability to create a new uniquely named list","indent":2,"archived":true,"list":"Roadmap","sortOrder":48,"_id":"9a1c15b3-b407-4a72-8d39-9cf3ae4a5ccf"},{"isEditing":false,"isMoving":false,"item":"Shareable url for each list","indent":2,"archived":true,"list":"Roadmap","sortOrder":56,"_id":"d2d146f1-b2d5-401c-b3b8-d422aa665f3a"},{"isEditing":false,"isMoving":false,"item":"Ability to clear archived items","indent":2,"archived":true,"list":"Roadmap","sortOrder":64,"_id":"6179d1b4-9f0b-4ae9-8f4f-c3a5a4a85cbc"},{"isEditing":false,"isMoving":false,"item":"Ability to archive all items","indent":2,"archived":true,"list":"Roadmap","sortOrder":72,"_id":"52d7ed7b-0e9d-4bf6-bcb0-d3385bd27f9d"},{"isEditing":false,"isMoving":false,"item":"Should not be able to indent more than one level below parent","indent":2,"archived":true,"list":"Roadmap","sortOrder":80,"_id":"9aa9a414-2069-41ac-800e-702de48cad1f"},{"isEditing":false,"isMoving":false,"item":"Children should move with parent","indent":2,"archived":true,"list":"Roadmap","sortOrder":88,"_id":"628781f9-d057-46f0-aadb-92b6538232f4"},{"isEditing":false,"isMoving":false,"item":"Children should archive/delete with parent","indent":2,"archived":true,"list":"Roadmap","sortOrder":96,"_id":"fc9b0d45-3b23-40b4-b1f8-b3b3ee8d3312"},{"isEditing":false,"isMoving":false,"item":"Children should indent/outdent with parent","indent":2,"archived":true,"list":"Roadmap","sortOrder":104,"_id":"b11f97da-1c16-4dba-8b62-d602eb05ae65"},{"isEditing":false,"isMoving":false,"item":"Current Sprint","indent":1,"archived":false,"list":"Roadmap","sortOrder":112,"_id":"9a3a83a2-2a3d-4288-a290-492f577cdec5"},{"isEditing":false,"isMoving":false,"item":"Ability to collapse/expand a parent","indent":2,"archived":false,"list":"Roadmap","sortOrder":120,"_id":"af96c717-ced6-4773-80f6-8059545804fb"},{"isEditing":false,"isMoving":false,"item":"Actions column on right","indent":2,"archived":false,"list":"Roadmap","sortOrder":128,"_id":"7cd07624-5aef-4d76-a9dc-28c024f89d9b"},{"isEditing":false,"isMoving":false,"item":"Header has slider buttons to switch to different action set","indent":3,"archived":false,"list":"Roadmap","sortOrder":136,"_id":"d85c1a9b-8369-480d-bdeb-716ff4caf385"},{"isEditing":false,"isMoving":false,"item":"Max 2 buttons","indent":4,"archived":false,"list":"Roadmap","sortOrder":144,"_id":"c9d5aae7-4b39-4103-810d-c51d10c32a7c"},{"isEditing":false,"isMoving":false,"item":"Indent/outdent","indent":4,"archived":false,"list":"Roadmap","sortOrder":152,"_id":"5e0c8e90-51ef-4ddf-917a-03e1dbda5869"},{"isEditing":false,"isMoving":false,"item":"Archive/Unarchive","indent":4,"archived":false,"list":"Roadmap","sortOrder":160,"_id":"6f6a43fa-10c2-4695-80f1-461aa36a81f5"},{"isEditing":false,"isMoving":false,"item":"Collapse/Expand","indent":4,"archived":false,"list":"Roadmap","sortOrder":168,"_id":"6078cf6b-4d4f-458c-a5e9-e7284d717506"},{"isEditing":false,"isMoving":false,"item":"Textarea instead of single line textbox. Should grow instead of scroll and allow line breaks","indent":2,"archived":false,"list":"Roadmap","sortOrder":176,"_id":"d878bf36-1004-4be6-b5fc-cf90109906e9"},{"isEditing":false,"isMoving":false,"item":"Natural keyboard behaviour","indent":2,"archived":false,"list":"Roadmap","sortOrder":184,"_id":"dce79e63-a20e-4c9f-a084-7bb38a5b1100"},{"isEditing":false,"isMoving":false,"item":"Up/down arrows edits rows above or below","indent":3,"archived":false,"list":"Roadmap","sortOrder":192,"_id":"696970bc-e89d-4e7a-82ed-5a35477b4f7d"},{"isEditing":false,"isMoving":false,"item":"Enter creates new item below","indent":3,"archived":false,"list":"Roadmap","sortOrder":200,"_id":"14ca0a10-fedd-4d4b-af77-b9cbd469a46f"},{"isEditing":false,"isMoving":false,"item":"Backspace deletes characters until the start, then outdents until 0, then deletes item ","indent":3,"archived":false,"list":"Roadmap","sortOrder":208,"_id":"dbf8476b-8a56-4901-a8f4-a5ebbe23ae8d"},{"isEditing":false,"isMoving":false,"item":"Ability to password protect a list","indent":2,"archived":false,"list":"Roadmap","sortOrder":216,"_id":"6cf1cf92-1fb1-443e-acc0-72828b84b556"},{"isEditing":false,"isMoving":false,"item":"Watcher password: if specified, requires a password to view the list","indent":3,"archived":false,"list":"Roadmap","sortOrder":224,"_id":"e608e881-24ac-47bf-8152-fc2a2909b490"},{"isEditing":false,"isMoving":false,"item":"Contributor password: if specified, requires a password to edit the list","indent":3,"archived":false,"list":"Roadmap","sortOrder":232,"_id":"096fd4b9-a447-4970-b36d-d7d511e3f389"},{"isEditing":false,"isMoving":false,"item":"Backlog","indent":1,"archived":false,"list":"Roadmap","sortOrder":240,"_id":"4f20d22d-2ac2-4afd-b19f-b0264baff932"},{"isEditing":false,"isMoving":false,"item":"Ability to add a checkbox column, parent indicates number of checked children","indent":2,"archived":false,"list":"Roadmap","sortOrder":248,"_id":"a6b541e9-4e4f-4e5d-addc-4d1241967c48"},{"isEditing":false,"isMoving":false,"item":"Ability to add a numeric column, parent shows sum of children","indent":2,"archived":false,"list":"Roadmap","sortOrder":256,"_id":"31a634c0-ceb9-4dae-9ff2-041595ddb145"}]
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
