library todomvc.components;

import 'dart:html';
import 'package:react/react.dart';
import 'package:vacuum_persistent/persistent.dart';
import 'dispatcher.dart';

// React components are defined here. They can assign events to the elements, but these
// events only should send some payload about the event happened to Dispatcher, and should not
// make any changes in the global data by themselves

// We are going to subclass from this class for all our React components.
// We are going to not use React's 'props' directly, but put everything to 'props['value']' instead.
// Then, we can check if that new props['value'] is actually changed, and if it is not - we'll just
// skip updating this component.
//
// This allows to speed up React even more - it even won't try to apply its diff algorithms to the
// components where the input wasn't changed.
abstract class _Component extends Component {
  get value => props['value'];
  bool shouldComponentUpdate(nextProps, nextState) {
    return props['value'] != nextProps['value'];
  }
}


class TodoApp extends _Component {
  render() {
    return
      div({'id': 'todo-app', 'className': value['filter']}, [
        headerComponent({'value': value["new-input"]}),
        mainComponent({'value': persist({
          'list': value["list"],
          'edit': value["edit"]})}),
        footerComponent({'value': persist({
          'count': value["list"].length,
          'filter': value["filter"],
          'countCompleted': value["list"].where((i) => i["isCompleted"]).length})})]);
  }
}
var todoAppComponent = registerComponent(() => new TodoApp());


class Header extends _Component {
  Map getInitialState() {
    return {'value': value};
  }

  void _inputChange(event) {
    dispatch({'action': 'new-input', 'value': event.target.value});
    setState({'value': event.target.value});
  }

  void _onKeyDown(event) {
    if (event.keyCode == KeyCode.ENTER) {
      dispatch({'action': 'create', 'value': event.target.value});
    }
  }

  render() {
    return
      header({'id': 'header'}, [
        h1({}, 'todos'),
        input({
          'id': 'new-todo', 'placeholder': 'What needs to be done?', 'autofocus': 'autofocus',
          'value': value, 'onChange': _inputChange, 'onKeyDown': _onKeyDown})]);
  }
}
var headerComponent = registerComponent(() => new Header());


class Main extends _Component {
  void _toggleAll(_) {
    dispatch({'action': 'toggle-all'});
  }

  render() {
    return
      section({'id': 'main'}, [
        input({
          'id': 'toggle-all', 'type': 'checkbox', 'onClick': _toggleAll,
          'checked': value['list'].every((i) => i['isCompleted'])}),
        label({'htmlFor': 'toggle-all'}, "Mark all as complete"),
        todoListComponent({'value': value})]);
  }
}
var mainComponent = registerComponent(() => new Main());


class TodoList extends _Component {
  render() {
    return
      ul({'id': 'todo-list'}, (value['list'] as PVec).toList().reversed.map((PMap item) =>
        todoListItemComponent({'value': persist({
          'item': item,
          'isEditing': value['edit'] == item['id']})})));
  }
}
var todoListComponent = registerComponent(() => new TodoList());


class TodoListItem extends _Component {
  PMap get item => value['item'];

  Map getInitialState() {
    return {'value': item['text']};
  }

  void _updateText(event) {
    dispatch({'action': 'update-text', 'text': event.target.value, 'id': item['id']});
    setState({'value': event.target.value});
  }

  String get _itemClassName {
    var classes = [];
    classes.add(item['isCompleted'] ? 'completed' : 'active');
    if (value['isEditing']) {
      classes.add("editing");
    }
    return classes.join(" ");
  }

  void _toggle(_) {
    dispatch({'action': 'toggle', 'id': item['id']});
  }

  void _destroy(_) {
    dispatch({'action': 'destroy', 'id': item['id']});
  }

  void _edit(_) {
    dispatch({'action': 'edit', 'id': item['id']});
  }

  void _commit(_) {
    dispatch({'action': 'commit'});
  }

  componentDidUpdate(prevProps, prevState, rootNode) {
    if (value['isEditing'] && !prevProps['value']['isEditing']) {
      InputElement input = rootNode.querySelector(".edit");
      input.focus();
      input.setSelectionRange(input.value.length, input.value.length);
    }
  }

  render() {
    return
      li({'className': _itemClassName}, [
        div({'className': 'view'}, [
          input({'className': 'toggle', 'type': 'checkbox', 'onClick': _toggle, 'checked': item['isCompleted']}),
          label({'onDoubleClick': _edit}, item['text']),
          button({'className': 'destroy', 'onClick': _destroy})]),
        input({'className': 'edit', 'value': item['text'], 'onChange': _updateText, 'onBlur': _commit, 'ref': 'edit'})]);
  }
}
var todoListItemComponent = registerComponent(() => new TodoListItem());


class Footer extends _Component {
  String get filter => value['filter'];
  int get count => value['count'];
  int get countCompleted => value['countCompleted'];

  String _filterClassName(String filterType) {
    return filterType == filter ? 'selected' : '';
  }

  String get _buttonClassName {
    return countCompleted == 0 ? 'hidden' : '';
  }

  String get _footerClassName {
    return count == 0 ? 'hidden' : '';
  }

  void _clearCompleted(_) {
    dispatch({'action': 'clear-completed'});
  }

  void _filter(SyntheticEvent e, String filterType) {
    e.preventDefault();
    dispatch({'action': 'filter', 'filter': filterType});
  }

  render() {
    return
      footer({'id': 'footer', 'className': _footerClassName}, [
        span({'id': 'todo-count'}, [
          strong({}, count),
          " items left"]),
        ul({'id': 'filters'}, [
          li({},
            a({'className': _filterClassName('all'), 'href': '#', 'onClick': (e) => _filter(e, 'all')}, "All")),
          li({},
            a({'className': _filterClassName('active'), 'href': '#', 'onClick': (e) => _filter(e, 'active')}, "Active")),
          li({},
            a({'className': _filterClassName('completed'), 'href': '#', 'onClick': (e) => _filter(e, 'completed')}, "Completed"))]),
        button(
          {'id': 'clear-completed', 'className': _buttonClassName, 'onClick': _clearCompleted},
          "Clear Completed ($countCompleted)")]);
  }
}
var footerComponent = registerComponent(() => new Footer());