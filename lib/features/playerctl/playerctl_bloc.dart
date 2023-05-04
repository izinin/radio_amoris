import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'index.dart';

class PlayerctlBloc extends Bloc<PlayerctlEvent, PlayerctlState> {
  PlayerctlBloc(PlayerctlState initialState) : super(initialState) {
    on<PlayerctlEvent>((event, emit) {
      return emit.forEach<PlayerctlState>(
        event.applyAsync(currentState: state, bloc: this),
        onData: (state) => state,
        onError: (error, stackTrace) {
          developer.log('$error',
              name: 'PlayerctlBloc', error: error, stackTrace: stackTrace);
          return ErrorPlayerctlState(error.toString());
        },
      );
    });
  }
}
