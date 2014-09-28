library todomvc;

import 'dispatcher.dart';
import 'package:react/react_client.dart';

// Entry point of the app. We just render the view here for the first time.
void main() {
  setClientConfiguration();
  rerender();
}