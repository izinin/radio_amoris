import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:radio_amoris/features/stations/index.dart';

class StationsBloc extends Bloc<StationsEvent, StationsState> {
  final _repository = StationsRepository();
  StationsRepository get repo {
    return _repository;
  }

  StationsBloc(StationsState initialState) : super(initialState) {
    on<StationsEvent>((event, emit) {
      return emit.forEach<StationsState>(
        event.applyAsync(currentState: state, bloc: this),
        onData: (state) => state,
        onError: (error, stackTrace) {
          developer.log('$error', name: 'StationsBloc', error: error, stackTrace: stackTrace);
          return ErrorStationsState(error.toString());
        },
      );
    });
  }
}
