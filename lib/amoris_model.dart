import 'audioctl.dart';
import 'package:scoped_model/scoped_model.dart';

class AmorisModel extends Model {
  int _selection = 0;
  PlayerState playerstate;
  int get counter => _selection;

  void select(int uid) {
    _selection = uid;
    
    // Then notify all the listeners.
    notifyListeners();
  }
}
