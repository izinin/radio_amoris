// https://flutterbyexample.com/set-up-inherited-widget-app-state/
import 'package:flutter/widgets.dart';
import 'package:radio_amoris/audioctl.dart';

class SharedSelection extends InheritedWidget {
  // The data is whatever this widget is passing down.
  final int uid;
  final PlayerState playerstate;

  SharedSelection({
    Key key,
    @required this.uid,
    @required this.playerstate,
    @required Widget child,
  }) : super(key: key, child: child);

  static SharedSelection of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(SharedSelection);
  }

  @override
  bool updateShouldNotify(SharedSelection old) => (uid != old.uid || playerstate != old.playerstate);
}
