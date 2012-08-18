// Generated by CoffeeScript 1.3.3
(function() {
  var Items, blankItem, itemMapping, reset_data, viewModel;

  Items = new Meteor.Collection('items');

  reset_data = function() {
    Items.remove({});
    Items.insert({
      item: 'First Item',
      indent: 0,
      archived: true
    });
    Items.insert({
      item: 'Second Item',
      indent: 0,
      archived: false
    });
    Items.insert({
      item: '1st Child of 2nd Item (shortcut: start with 2 or 3 spaces)',
      indent: 1,
      archived: false
    });
    Items.insert({
      item: 'Grandchild of 2nd Item',
      indent: 2,
      archived: false
    });
    Items.insert({
      item: '2nd Child of 2nd Item (shortcut: backspace when empty)',
      indent: 1,
      archived: false
    });
  };

  if (Meteor.is_client) {
    itemMapping = {
      item: {
        create: function(options) {
          var observable, parent;
          parent = options.parent;
          observable = ko.observable(options.data);
          parent.isEditing = ko.observable(false);
          parent.modeTemplate = function() {
            if (parent.isEditing()) {
              return 'itemEditing';
            } else {
              return 'item';
            }
          };
          parent.setEditing = function() {
            return parent.isEditing(true);
          };
          parent.clearEditing = function() {
            return parent.isEditing(false);
          };
          parent.doIndent = function() {
            return parent.indent(parent.indent() + 1);
          };
          parent.doOutdent = function() {
            return parent.indent(parent.indent() - 1);
          };
          parent.save = function() {
            parent.isEditing(false);
            return Items.update(parent._id(), {
              $set: {
                item: parent.item(),
                indent: parent.indent()
              }
            });
          };
          parent.remove = function() {
            if (parent.archived()) {
              return Items.remove(parent._id());
            } else {
              return Items.update(parent._id(), {
                $set: {
                  archived: true
                }
              });
            }
          };
          return observable;
        }
      }
    };
    blankItem = function() {
      var _this = this;
      this.item = ko.observable('');
      this.indent = ko.observable(0);
      this.save = function() {
        Items.insert({
          item: _this.item(),
          indent: _this.indent(),
          archived: false
        });
        return _this.item('');
      };
      this.doIndent = function() {
        return _this.indent(_this.indent() + 1);
      };
      this.doOutdent = function() {
        return _this.indent(_this.indent() - 1);
      };
    };
    viewModel = function() {
      var checkIndentationKeyBindings, indentOn2LeadingSpaces, itemToInsert, items, outdentOnBackspaceAndEmpty, resetData, saveOnEnter;
      items = ko.meteor.find(Items, {}, {}, itemMapping);
      itemToInsert = new blankItem();
      resetData = function() {
        return reset_data();
      };
      indentOn2LeadingSpaces = function(model, event) {
        if (event.which !== 32) {
          return;
        }
        if (model.item().substr(0, 2) !== '  ') {
          return;
        }
        model.item(model.item().substring(2));
        return model.doIndent();
      };
      outdentOnBackspaceAndEmpty = function(model, event) {
        if (event.which !== 8) {
          return;
        }
        if (model.item() !== '') {
          return;
        }
        return model.doOutdent();
      };
      checkIndentationKeyBindings = function(model, event) {
        indentOn2LeadingSpaces(model, event);
        return outdentOnBackspaceAndEmpty(model, event);
      };
      saveOnEnter = function(model, event) {
        if (event.which !== 13) {
          return true;
        }
        model.save();
        return false;
      };
      return {
        resetData: resetData,
        items: items,
        itemToInsert: itemToInsert,
        checkIndentationKeyBindings: checkIndentationKeyBindings,
        saveOnEnter: saveOnEnter
      };
    };
    Meteor.startup(function() {
      return ko.applyBindings(new viewModel());
    });
  }

  if (Meteor.is_server) {
    Meteor.startup(function() {
      if (Items.find().count() === 0) {
        return reset_data();
      }
    });
  }

}).call(this);
