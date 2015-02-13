library todomvc.dispatcher;

import 'dart:html';
import 'package:react/react.dart';
import 'data.dart';
import 'components.dart';
import 'models/item.dart';

// Rerenders the whole view, from top to bottom. We always rerender the whole thing, letting
// React decide what should be updated and what should not down the road.
void rerender() {
  render(todoAppComponent({'value': appData.value}), querySelector('#todoapp'));
}

// Our main and only entry for all the events from the view. View sends them in a form of maps,
// and view never actually makes any changes in the appData directly, the only thing it does - sends
// these maps to `dispatch`, which figures out how appData should be changed, and then rerenders
// the whole app with the new appData value.
void dispatch(Map payload) {
  switch (payload["action"]) {
    case 'toggle':
      new Item(payload['id']).toggle();
      break;
    case 'destroy':
      new Item(payload['id']).remove();
      break;
    case 'edit':
      appData.update("edit", payload['id']);
      break;
    case 'commit':
      appData.update("edit", null);
      break;
    case 'update-text':
      new Item(payload['id']).text = payload['text'];
      break;
    case 'new-input':
      appData.update("new-input", payload['value']);
      break;
    case 'create':
      appData.update("new-input", "");
      Item.create(payload['value']);
      break;
    case 'toggle-all':
      Item.toggleAll();
      break;
    case 'clear-completed':
      Item.clearCompleted();
      break;
    case 'filter':
      appData.update("filter", payload["filter"]);
      break;
  }
  rerender();
}