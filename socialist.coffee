Items = new Meteor.Collection 'items'

reset_data = -> # Executes on both client and server.
  Items.remove {}
  samples = [{"_id":"6d89bb8b-a0b0-4c8f-8e28-094687d3b71b","isEditing":false,"item":"Current Sprint","indent":0,"archived":false},{"_id":"91c6674e-e56b-4332-b572-111c442d0174","isEditing":false,"item":"Archive before delete","indent":1,"archived":true},{"_id":"6a036be0-c1d6-4550-9b5e-81829542be0b","isEditing":false,"item":"Ability to unarchive","indent":1,"archived":true},{"_id":"d511303a-f2bd-4539-95af-48a42c4ebc15","isEditing":false,"item":"Bigger, better action icons. Change to buttons?","indent":1,"archived":true},{"_id":"fad1dff7-e007-43ba-921b-5f9e726ee492","isEditing":false,"item":"Ability to rearrange items. Children should move with parent.","indent":1,"archived":false},{"_id":"22d8d6f3-af5a-4227-82da-ca5fb95f7d40","isEditing":false,"item":"Ability to insert an item anywhere in the list","indent":1,"archived":false},{"_id":"e105cbc7-f751-4872-8369-85316f5e306e","isEditing":false,"item":"Children should archive/delete with parent","indent":1,"archived":false},{"_id":"670f398e-9f1a-4116-8211-62001781124f","isEditing":false,"item":"Children should indent/outdent with parent","indent":1,"archived":false},{"_id":"27c3c3f0-fd15-4bf5-b827-f3638cce8fff","isEditing":false,"item":"Should not be able to indent more than one level below parent","indent":1,"archived":false},{"_id":"c959bd10-eb8a-4ee1-8ba2-ac4a650632e2","isEditing":false,"item":"Should not be able to outdent past 0","indent":1,"archived":true},{"_id":"5fdec09f-3eef-4836-bc8c-5edfe31e8fdf","isEditing":false,"item":"Ability to create a new uniquely named list","indent":1,"archived":false},{"_id":"7a178206-ca5b-49f0-8546-e5862c34105c","isEditing":false,"item":"Shareable url for each list","indent":1,"archived":false},{"_id":"a877bb40-98d5-4420-bd7c-6fc72f6d6bb7","isEditing":false,"item":"Backlog","indent":0,"archived":false},{"_id":"0f9c0c16-563a-478a-81ee-00fc0248a4aa","isEditing":false,"item":"Ability to password protect a list","indent":1,"archived":false},{"_id":"ccbf38f0-a3b2-4971-8ed1-9d75af29bd6e","isEditing":false,"item":"Ability to add a checkbox column, parent indicates number of checked children","indent":1,"archived":false},{"_id":"c6655047-1e45-4944-a4ef-f691275de9c3","isEditing":false,"item":"Ability to add a numeric column, parent shows sum of children","indent":1,"archived":false},{"_id":"f95766f3-c06e-496d-8a85-85d3e1156821","isEditing":false,"item":"Textarea instead of single line textbox. Should grow instead of scroll and allow line breaks","indent":1,"archived":false}]
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
      @item('')
    @doIndent = =>
      @indent(@indent() + 1)
    @doOutdent = =>
      @indent(@indent() - 1) if @indent() > 0
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
