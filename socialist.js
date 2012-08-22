// Generated by CoffeeScript 1.3.3
(function() {
  var Items, blankItem, canonicalListName, itemMapping, listModel, newListModel, reset_data, samples, viewModel, vm;

  Items = new Meteor.Collection('items');

  samples = (typeof exports !== "undefined" && exports !== null ? exports : this).samples || [];

  reset_data = function() {
    var a, newid, s, sample, _i, _j, _len, _len1;
    Items.remove({
      list: (typeof vm.listName === "function" ? vm.listName() : void 0) || 'Sample'
    });
    for (_i = 0, _len = samples.length; _i < _len; _i++) {
      sample = samples[_i];
      newid = Items.insert({
        item: sample.item,
        archived: sample.archived,
        list: (typeof vm.listName === "function" ? vm.listName() : void 0) || 'Sample',
        sortOrder: _i,
        parent: sample.parent,
        ancestors: sample.ancestors
      });
      for (_j = 0, _len1 = samples.length; _j < _len1; _j++) {
        s = samples[_j];
        if (s.parent) {
          s.parent = s.parent.replace(sample._id, newid);
        }
        s.ancestors = (function() {
          var _k, _len2, _ref, _results;
          _ref = s.ancestors;
          _results = [];
          for (_k = 0, _len2 = _ref.length; _k < _len2; _k++) {
            a = _ref[_k];
            _results.push(a.replace(sample._id, newid));
          }
          return _results;
        })();
      }
    }
  };

  if (Meteor.is_client) {
    itemMapping = {
      item: {
        create: function(options) {
          var itemObject, observable;
          itemObject = options.parent;
          observable = ko.observable(options.data);
          itemObject.isEditing = ko.observable(false);
          itemObject.isMoving = ko.observable(false);
          itemObject.indent = ko.computed(function() {
            if (this.ancestors) {
              return this.ancestors().length;
            } else {
              return 0;
            }
          }, itemObject);
          itemObject.modeTemplate = function() {
            if (itemObject.isEditing()) {
              return 'itemEditing';
            } else {
              return 'item';
            }
          };
          itemObject.setEditing = function() {
            return itemObject.isEditing(true);
          };
          itemObject.clearEditing = function() {
            return itemObject.isEditing(false);
          };
          itemObject.doIndent = function() {
            var ancestors, items, itm, pos, _i, _len;
            pos = vm.vm().items.indexOf(itemObject);
            items = vm.vm().items.slice(0, (pos - 1) + 1 || 9e9).reverse();
            for (_i = 0, _len = items.length; _i < _len; _i++) {
              itm = items[_i];
              if (itm._id() === itemObject.parent()) {
                break;
              }
              if (itm.parent() === itemObject.parent()) {
                ancestors = itm.ancestors();
                ancestors.push(itm._id());
                Items.update(itemObject._id(), {
                  $set: {
                    parent: itm._id(),
                    ancestors: ancestors
                  }
                });
                break;
              }
            }
          };
          itemObject.doOutdent = function() {
            var parent;
            parent = Items.findOne(itemObject.parent());
            return Items.update(itemObject._id(), {
              $set: {
                parent: parent != null ? parent.parent : void 0,
                ancestors: parent != null ? parent.ancestors : void 0
              }
            });
          };
          itemObject.save = function() {
            itemObject.isEditing(false);
            return Items.update(itemObject._id(), {
              $set: {
                item: itemObject.item(),
                archived: false
              }
            });
          };
          itemObject.remove = function() {};
          return observable;
        }
      }
    };
    blankItem = function() {
      var _this = this;
      this.item = ko.observable('');
      this.indent = ko.observable(0);
      this.save = function() {
        var items;
        items = vm.vm().items();
        Items.insert({
          item: _this.item(),
          indent: _this.indent(),
          archived: false,
          sortOrder: items.length ? items[items.length - 1].sortOrder() + 8 : 0,
          list: vm.listName()
        });
        return _this.item('');
      };
      this.doIndent = function() {
        var maxIndent;
        maxIndent = 0;
        try {
          maxIndent = vm.vm().items()[vm.vm().items().length - 1].indent() + 1;
        } catch (_error) {}
        if (_this.indent() < maxIndent) {
          return _this.indent(_this.indent() + 1);
        }
      };
      this.doOutdent = function() {
        if (_this.indent() > 0) {
          return _this.indent(_this.indent() - 1);
        }
      };
    };
    newListModel = function(parent) {
      var _this = this;
      this.name = ko.observable('');
      this.saveOnEnter = function(model, event) {
        if (event.which !== 13) {
          return true;
        }
        model.save();
        return false;
      };
      this.save = function() {
        Session.set('listName', canonicalListName(_this.name()));
        window.location.href = 'http://' + window.location.host + '/#!' + canonicalListName(_this.name());
        window.location.reload();
      };
    };
    listModel = function(parent) {
      var checkIndentationKeyBindings, indentOn2LeadingSpaces, isMoving, itemToInsert, items, itemsToMove, moveHere, moveItem, outdentOnBackspaceAndEmpty, saveOnEnter, _this;
      _this = this;
      items = ko.meteor.find(Items, {
        list: parent.listName()
      }, {
        sort: {
          sortOrder: 1
        }
      }, itemMapping);
      itemToInsert = new blankItem();
      isMoving = ko.observable(false);
      itemsToMove = [];
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
      moveItem = function(data) {
        var itm, pos, _i, _len, _ref;
        pos = items.indexOf(data);
        itemsToMove = [];
        itemsToMove.push(data);
        data.isMoving(true);
        _ref = items.slice(pos + 1);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          itm = _ref[_i];
          if (itm.indent() <= data.indent()) {
            break;
          }
          itemsToMove.push(itm);
          itm.isMoving(true);
        }
        return isMoving(true);
      };
      moveHere = function(data) {
        var i, indentIncrement, itm, newSortOrder, nextItem, sortIncrement, _i, _j, _len, _len1, _ref;
        _ref = items().slice(items.indexOf(data) + 1);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          itm = _ref[_i];
          if (!itm.isMoving()) {
            nextItem = itm;
            break;
          }
        }
        sortIncrement = 8;
        indentIncrement = data.indent() < itemsToMove[0].indent() - 1 ? data.indent() - itemsToMove[0].indent() + 1 : 0;
        try {
          sortIncrement = (nextItem.sortOrder() - data.sortOrder()) / (itemsToMove.length + 1);
        } catch (_error) {}
        for (i = _j = 0, _len1 = itemsToMove.length; _j < _len1; i = ++_j) {
          itm = itemsToMove[i];
          newSortOrder = data.sortOrder() + (sortIncrement * (i + 1));
          Items.update(itm._id(), {
            $set: {
              sortOrder: newSortOrder
            },
            $inc: {
              indent: indentIncrement
            }
          });
          itm.isMoving(false);
        }
        itemsToMove = [];
        return isMoving(false);
      };
      return {
        items: items,
        itemToInsert: itemToInsert,
        checkIndentationKeyBindings: checkIndentationKeyBindings,
        saveOnEnter: saveOnEnter,
        moveItem: moveItem,
        isMoving: isMoving,
        moveHere: moveHere
      };
    };
    viewModel = function() {
      var _this = this;
      this.listName = ko.observable(canonicalListName(Session.get('listName')));
      this.showingJSON = ko.observable(false);
      this.json = ko.observable('');
      this.templateToUse = function() {
        if (_this.listName()) {
          return 'socialist';
        } else {
          return 'newList';
        }
      };
      this.vm = ko.observable(this.listName() === '' ? new newListModel(this) : new listModel(this));
      this.listName.subscribe(function() {
        if (_this.listName() === '') {
          return _this.vm(new newListModel(_this));
        } else {
          return _this.vm(new listModel(_this));
        }
      });
      this.resetData = function() {
        return reset_data();
      };
      this.showJSON = function() {
        if (_this.vm().items) {
          _this.json(ko.mapping.toJSON(_this.vm().items));
        }
        return _this.showingJSON(true);
      };
      this.newList = function() {
        Session.set('listName', '');
        return true;
      };
      this.delArchived = function() {
        return Items.remove({
          list: this.listName(),
          archived: true
        });
      };
      this.archiveAll = function() {
        var itm, _i, _len, _ref;
        if (_this.vm().items) {
          _ref = _this.vm().items();
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            itm = _ref[_i];
            Items.update(itm._id(), {
              $set: {
                archived: true
              }
            });
          }
        }
      };
    };
    canonicalListName = function(name) {
      return name.replace(/[^-A-z0-9\s]*/g, '').replace(/\s+/g, '-');
    };
    Session.set('listName', window.location.hash.replace('#!', '') || '');
    vm = new viewModel();
    Meteor.startup(function() {
      return ko.applyBindings(vm);
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
