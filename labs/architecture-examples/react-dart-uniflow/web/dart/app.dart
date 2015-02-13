library todomvc;

import 'dispatcher.dart';
import 'package:react/react_client.dart';
import 'package:vacuum_persistent/persistent.dart';

// This is an example of unidirectional flow architecture of a SPA based on React
// and persistent data structures.
//
// The idea is that we have one global state of the app, which fully describes what is currently
// shown on the screen. There are no state anymore except this one. Basically our app at the current
// moment is a result of executing of a function with that global state as an argument.
//
// That global state is based on persistent data structures - arrays and maps. It is important
// they are persistent - persistent data structures have one very cool property we use here -
// they are very fast to compare. You don't need to do deep recursive comparsement, you can
// just check the references of the objects. If they are different - that whole subtree was changed.
//
// React itself does pretty good job comparing what was changed in the component and rerendering
// only the necessary changes in the real DOM. But we can help it a lot, advicing whether it should
// care about checking for changes in that particular component and rerendering it at all.
// React provides shouldComponentUpdate hook, and in that hook we will check if our persistent data
// structure, which was passed into the component with 'props', was changed. Again, that check
// is very cheap, so this way we can really speed-up our React app.
//
// During rendering, we assign (via React) various event handlers to DOM elements. These handlers
// will just send proper messages to Dispatcher, which will change the global state appropriately,
// and then rerender the whole app again. So, we always rerender the whole app for every single event,
// even a small one (like e.g. if we typed one more character in some input field). But using
// React together with shouldComponentUpdate hook, the rerendering is usually pretty fast, taking
// just a couple milliseconds.
//
// This is why it's called unidirectional - our app lifecycle is basically something like:
//
//      main -------> render view --------> dispatcher
//                        ^                      |
//                        |                      |
//                        |                      v
//                        +------------ change global state
//
// Very simple but still performant, and very declarative. We don't really care about rendering, DOM, etc -
// we just change the global state, and let React do the heavy lifting.

// Entry point of the app. We just render the view here for the first time.
void main() {
  setClientConfiguration();
  rerender();
}
