library todomvc.models.item;

import '../data.dart';
import 'package:persistent/persistent.dart';

class Item {
  final int _id;
  int _index;

  Item(this._id) {
    var i = 0;
    while (_index == null && i < appData.get("list").length) {
      if (appData.get(["list", i, 'id']) == _id) {
        _index = i;
      }
      i += 1;
    }
    if (_index == null) {
      throw new ArgumentError("Can't find item with id = $_id");
    }
  }

  static void create(String value) {
    appData.update("autoincrement", appData.get("autoincrement") + 1);
    var map = new PersistentMap.fromMap({'text': value, 'id': appData.get("autoincrement"), 'isCompleted': false});
    appData.add("list", map);
  }

  static void toggleAll() {
    PersistentVector list = appData.get("list");
    var areAllCompleted = list.every((PersistentMap item) => item['isCompleted']);
    list.forEach((PersistentMap item) {
      var id = item['id'];
      new Item(id).toggle(!areAllCompleted);
    });
  }

  static void clearCompleted() {
    appData.get("list").forEach((PersistentMap item) {
      new Item(item['id']).toggle(false);
    });
  }

  List get _path => ["list", _index];
  List get _textPath => new List.from(_path)..add("text");
  List get _isCompletedPath => new List.from(_path)..add("isCompleted");

  String get text => appData.get(_textPath);

  void set text(String value) {
    appData.update(_textPath, value);
  }

  bool get isCompleted => appData.get(_isCompletedPath);

  void toggle([bool value = null]) {
    appData.update(_isCompletedPath, value == null ? !isCompleted : value);
  }

  void remove() {
    appData.remove(_path);
  }
}