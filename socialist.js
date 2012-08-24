// Generated by CoffeeScript 1.3.3
(function() {
  var Items, canonicalListName, itemMapping, listModel, newListModel, reset_data, samples, viewModel, vm;

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
          itemObject.isMoving = ko.observable(false);
          itemObject.indent = ko.computed(function() {
            var _ref;
            return (_ref = typeof this.ancestors === "function" ? this.ancestors().length : void 0) != null ? _ref : 0;
          }, itemObject);
          itemObject.canMoveHere = ko.computed(function() {
            return vm.vm().isMoving() && !this.isMoving();
          }, itemObject);
          itemObject.doIndent = function() {
            var ancestors, itemsUpward, itm, pos, _i, _len;
            pos = vm.vm().items.indexOf(itemObject);
            itemsUpward = vm.vm().items.slice(0, (pos - 1) + 1 || 9e9).reverse();
            for (_i = 0, _len = itemsUpward.length; _i < _len; _i++) {
              itm = itemsUpward[_i];
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
                Items.update({
                  ancestors: itemObject._id()
                }, {
                  $push: {
                    ancestors: itm._id()
                  }
                });
                break;
              }
            }
          };
          itemObject.doOutdent = function() {
            var parent;
            parent = Items.findOne(itemObject.parent());
            Items.update(itemObject._id(), {
              $set: {
                parent: parent != null ? parent.parent : void 0,
                ancestors: parent != null ? parent.ancestors : void 0
              }
            });
            return Items.update({
              ancestors: itemObject._id()
            }, {
              $pull: {
                ancestors: parent != null ? parent._id : void 0
              }
            });
          };
          itemObject.save = function() {
            return Items.update(itemObject._id(), {
              $set: {
                item: itemObject.item()
              }
            });
          };
          itemObject.unarchive = function() {
            Items.update({
              ancestors: itemObject._id()
            }, {
              $set: {
                archived: false
              }
            }, {
              multi: true
            });
            return Items.update(itemObject._id(), {
              $set: {
                archived: false
              }
            });
          };
          itemObject.remove = function() {
            if (itemObject.archived()) {
              Items.remove({
                ancestors: itemObject._id()
              });
              return Items.remove(itemObject._id());
            } else {
              Items.update({
                ancestors: itemObject._id()
              }, {
                $set: {
                  archived: true
                }
              }, {
                multi: true
              });
              return Items.update(itemObject._id(), {
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
      var checkKeydownBindings, createNewItem, focusNextOnDown, focusPreviousOnUp, indentOn3Spaces, isMoving, items, itemsToMoveCount, itemsToMoveIndex, moveHere, moveItem, outdentOnBackspaceAndEmpty, saveOnEnter, _this;
      _this = this;
      items = ko.meteor.find(Items, {
        list: parent.listName()
      }, {
        sort: {
          sortOrder: 1
        }
      }, itemMapping);
      isMoving = ko.observable(false);
      itemsToMoveIndex = ko.observable();
      itemsToMoveCount = ko.observable();
      createNewItem = function() {
        var newid;
        newid = Items.insert({
          item: '',
          archived: false,
          sortOrder: items().length,
          list: vm.listName(),
          parent: '',
          ancestors: []
        });
        return Meteor.defer(function() {
          return $("." + newid + " input")[0].focus();
        });
      };
      indentOn3Spaces = function(model, event) {
        var myId;
        if (event.which !== 32) {
          return;
        }
        if (model.item().substr(0, 2) !== '  ') {
          return;
        }
        model.item(model.item().substring(2));
        model.doIndent();
        myId = model._id();
        return Meteor.defer(function() {
          return $("." + myId + " input")[0].focus();
        });
      };
      outdentOnBackspaceAndEmpty = function(model, event) {
        var focusid, myId, _ref;
        if (event.which !== 8) {
          return;
        }
        if (model.item() !== '') {
          return;
        }
        model.save();
        if (!model.parent()) {
          focusid = model._id();
          if (model.archived()) {
            focusid = (_ref = items()[items.indexOf(model) - 1]) != null ? _ref._id() : void 0;
          }
          model.remove();
          return Meteor.defer(function() {
            return $("." + focusid + " input").each(function() {
              return $(this).focus();
            });
          });
        } else {
          model.doOutdent();
          myId = model._id();
          return Meteor.defer(function() {
            return $("." + myId + " input")[0].focus();
          });
        }
      };
      checkKeydownBindings = function(model, event) {
        indentOn3Spaces(model, event);
        outdentOnBackspaceAndEmpty(model, event);
        saveOnEnter(model, event);
        focusPreviousOnUp(model, event);
        focusNextOnDown(model, event);
        return true;
      };
      focusPreviousOnUp = function(model, event) {
        var prevId, _ref;
        if (event.which !== 38) {
          return;
        }
        prevId = (_ref = items()[items.indexOf(model) - 1]) != null ? _ref._id() : void 0;
        model.save();
        if (prevId) {
          return Meteor.defer(function() {
            return $("." + prevId + " input")[0].focus();
          });
        }
      };
      focusNextOnDown = function(model, event) {
        var nextId, _ref;
        if (event.which !== 40) {
          return;
        }
        nextId = (_ref = items()[items.indexOf(model) + 1]) != null ? _ref._id() : void 0;
        model.save();
        if (nextId) {
          return Meteor.defer(function() {
            return $("." + nextId + " input")[0].focus();
          });
        }
      };
      saveOnEnter = function(model, event) {
        var newid, nextOrder, pos, _ref;
        if (event.which !== 13) {
          return true;
        }
        model.save();
        pos = items.indexOf(model);
        nextOrder = ((_ref = items()[pos + 1]) != null ? _ref.sortOrder() : void 0) || model.sortOrder() + 2;
        newid = Items.insert({
          item: '',
          archived: false,
          sortOrder: model.sortOrder() + ((nextOrder - model.sortOrder()) / 2),
          list: vm.listName(),
          parent: typeof model.parent === "function" ? model.parent() : void 0,
          ancestors: typeof model.ancestors === "function" ? model.ancestors() : void 0
        });
        Meteor.defer(function() {
          return $("." + newid + " input")[0].focus();
        });
        return false;
      };
      moveItem = function(data) {
        var countOfItems, itm, pos, _i, _len, _ref;
        itemsToMoveIndex(items.indexOf(data));
        data.isMoving(true);
        pos = items.indexOf(data);
        countOfItems = 1;
        _ref = items.slice(pos + 1);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          itm = _ref[_i];
          if (itm.indent() <= data.indent()) {
            break;
          }
          countOfItems++;
          itm.isMoving(true);
        }
        isMoving(true);
        return itemsToMoveCount(countOfItems);
      };
      moveHere = function(data) {
        var cutItems, i, id, itm, pastePos, prevItem, rootItemOldIndent, rootItemToMove, tail, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref, _ref1, _ref2;
        cutItems = items.splice(itemsToMoveIndex(), itemsToMoveCount());
        rootItemToMove = cutItems[0];
        rootItemOldIndent = rootItemToMove.indent();
        rootItemToMove.ancestors(data.ancestors().slice(0));
        rootItemToMove.ancestors.push(data._id());
        rootItemToMove.parent(data.parent());
        _ref = cutItems.slice(1);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          itm = _ref[_i];
          itm.ancestors.splice(0, rootItemOldIndent);
          _ref1 = rootItemToMove.ancestors.slice(0).reverse();
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            id = _ref1[_j];
            itm.ancestors.unshift(id);
          }
        }
        pastePos = items.indexOf(data) + 1;
        tail = items.splice(pastePos, 9e9);
        for (_k = 0, _len2 = cutItems.length; _k < _len2; _k++) {
          itm = cutItems[_k];
          items.push(itm);
        }
        for (_l = 0, _len3 = tail.length; _l < _len3; _l++) {
          itm = tail[_l];
          items.push(itm);
        }
        isMoving(false);
        _ref2 = items();
        for (i = _m = 0, _len4 = _ref2.length; _m < _len4; i = ++_m) {
          itm = _ref2[i];
          Items.update(itm._id(), {
            $set: {
              sortOrder: i,
              parent: itm.parent(),
              ancestors: itm.ancestors()
            }
          });
          itm.isMoving(false);
          prevItem = itm;
        }
      };
      return {
        items: items,
        createNewItem: createNewItem,
        checkKeydownBindings: checkKeydownBindings,
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
        if (_this.vm().items) {
          Items.update({
            list: vm.listName
          }, {
            $set: {
              archived: true
            }
          }, {
            multi: true
          });
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
