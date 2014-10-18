library todomvc.data;

import 'package:persistent/persistent.dart';

// Our global application data class. I added some methods to it, which allows to
// work conveniently with deep persistent structures, like 'get-in' or 'update-in' functions
// in Clojure. Unfortunately, it looks like a poor ugly twin of wonderful Clojure functions now...
//
// You usually need to provide a `path` in methods arguments. This is just a List or a String, which defines
// the path for accessing the data in the nested data structure. E.g. if we have a data looking like:
//
//   {'foo': [{'bar': 'bla', 'bar2': 'bla2'}]}
//
// we could update 'bar2' value by
//
//   update(["foo", 1, "bar2"], 'bla3')
//
// and it will return new data:
//
//   {'foo': [{'bar': 'bla', 'bar2': 'bla3'}]}
//
class Data {
  PersistentMap _value;
  PersistentMap get value => _value;

  Data(this._value);

  remove(Object path, [d = null]) {
    if (path is String) {
       path = [path];
     }

     var beginning = false;
     if (d == null) {
       beginning = true;
       d = value;
     }

     var nextPart = (path as List).removeAt(0);
     if ((path as List).isEmpty) {
       if (d is PersistentVector) {
         // There is no efficient way to remove an item from PersistentVector so far, unfortunately
         var list = d.toList().getRange(0, nextPart).toList()..addAll(d.toList().getRange(nextPart + 1, d.length));
         d = new PersistentVector.from(list);
       } else {
         d = d.delete(nextPart);
       }
     } else {
       var newVal = remove(path, d[nextPart]);
       if (d is PersistentVector) {
         d = d.set(nextPart, newVal);
       } else {
         d = d.insert(nextPart, newVal);
       }
     }

     if (beginning) {
       _value = d;
     }
     return d;
  }

  add(Object path, v, [d = null]) {
    if (path is String) {
      path = [path];
    }
    (path as List).add((get(path) as PersistentVector).length);
    _value = insertIn(value, path, v);
  }

  update(Object path, v) {
    if (path is String) {
      path = [path];
    }
    _value = insertIn(value, path, v);
  }

  get(Object path, [d = null]) {
    if (path is String) {
      path = [path];
    }
    return lookupIn(value, path);
  }
}

var _appData = new Data(persist({
    'autoincrement': 0,
    'new-input': '',
    'list': [],
    'filter': 'all',
    'edit': null}));

Data get appData => _appData;