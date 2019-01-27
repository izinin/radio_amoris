import 'dart:async';

import 'package:flutter/material.dart';

import 'audioctl.dart';
import 'package:scoped_model/scoped_model.dart';

class AmorisModel extends Model {
  int _selection = 0;
  AudioCtl _playerCtl;
  Completer _completer;

  AmorisModel():super(){
    _playerCtl =  new AudioCtl(
      _onCreated,
      _onDestroying,
      _onPaused,
      _onResumed,
      _onError);
  }

  void select(int uid) {
    if(_selection == uid){
      if (PlayerState.paused == _playerCtl.state) {
        _playerCtl.resume();
      } else {
        _playerCtl.pause();
      }
    }else{
      _playerCtl.setState(PlayerState.inprogress);
      _playerCtl.create(uid);
      _playerCtl.resume();
    }
    _selection = uid;
  }

  
  Widget getIgon(int uid) {
    var icondata = Icons.play_circle_outline;
    if(_selection == uid) {
      switch(_playerCtl.state){
        case PlayerState.destroyed:
        case PlayerState.created:
        case PlayerState.paused:
          icondata = Icons.pause_circle_outline;
          break;
        case PlayerState.playing:
          icondata = Icons.play_circle_outline;
          break;
        case PlayerState.inprogress:
          icondata = Icons.loop;
          break;
      }
    }
    return new Icon(icondata);
  }

  isSelected(int uid){
    return _selection == uid;
  }

  _onCreated() {
    _playerCtl.setState(PlayerState.created);
    notifyListeners();
  }

  _onError() {
    print("error received");
    _completer.completeError(null);
  }

  _onDestroying() {
    _playerCtl.setState(PlayerState.destroyed);
    notifyListeners();
  }

  _onPaused(){
    _playerCtl.setState(PlayerState.paused);
    notifyListeners();
  }

  _onResumed() {
    _playerCtl.setState(PlayerState.playing);
    notifyListeners();
  }
}
