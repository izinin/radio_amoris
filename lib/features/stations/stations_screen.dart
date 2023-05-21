import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:radioamoris/appdata.dart';
import 'package:radioamoris/features/stations/index.dart';
import '../../shared/model/mem_station.dart';
import '../../shared/model/audio_player_ctl_btn.dart';

class StationsScreen extends StatefulWidget {
  const StationsScreen({
    required StationsBloc stationsBloc,
    Key? key,
  })  : _stationsBloc = stationsBloc,
        super(key: key);

  final StationsBloc _stationsBloc;

  @override
  StationsScreenState createState() {
    return StationsScreenState();
  }
}

class StationsScreenState extends State<StationsScreen> {
  PlayerSingleton? _playerCtl;
  StationsScreenState();
  static const _playerStateStream = EventChannel('com.zindolla.radioamoris/player-state');
  static const _playlistCtrlStream = EventChannel('com.zindolla.radioamoris/playlist-ctrl');

  @override
  void initState() {
    super.initState();
    _setupPlatformChannel();
    widget._stationsBloc.add(InitAppDataEvent());
  }

  _setupPlatformChannel() async {
    final playerCtl = await GetIt.I.getAsync<PlayerSingleton>();
    _playerStateStream.receiveBroadcastStream().listen(playerCtl.listenPlayerStateStream);
    _playlistCtrlStream.receiveBroadcastStream().listen(playerCtl.listenPlaylistCtrlStream);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StationsBloc, StationsState>(
        bloc: widget._stationsBloc,
        builder: (
          BuildContext context,
          StationsState currentState,
        ) {
          if (currentState is ErrorStationsState) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(currentState.errorMessage),
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: ElevatedButton(
                    onPressed: _load,
                    child: const Text('reload'),
                  ),
                ),
              ],
            ));
          }
          if (currentState is InitAppDataState) {
            _playerCtl = currentState.playerSingleton;
            widget._stationsBloc.add(LoadStationsEvent());
            return const Center(
              child: Text('audio player is being initialized'),
            );
          }
          if (currentState is LoadStationsState || currentState is PlayingStationState || currentState is ErrorPlayerState) {
            return Column(
              children: [
                Expanded(
                    child: ListView.builder(
                  itemBuilder: (context, i) {
                    return Column(children: [
                      _buildRow(i, currentState),
                      const Divider(),
                    ]);
                  },
                  itemCount: widget._stationsBloc.repo.data?.length ?? 0,
                )),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  void _load() {
    widget._stationsBloc.add(LoadStationsEvent());
  }

  Widget _buildRow(int idx, StationsState state) {
    MemStation? station = widget._stationsBloc.repo.data?.elementAt(idx);
    return ListTile(
      title: Text(station?.name ?? "no name"),
      subtitle: ValueListenableBuilder<StationMetadata>(
          builder: (context, value, child) {
            return Text('${value.songtitle}, listeners:${value.uniquelisteners}');
          },
          valueListenable: station!.metadata),
      onTap: () {
        widget._stationsBloc.add(LoadTuneForStationEvent(station));
      },
      trailing: (state is PlayingStationState)
          ? _getPlayerControlForStation(station)
          : (station.state == TuneState.invalid)
              ? const Icon(Icons.error_outline_rounded)
              : const SizedBox(width: 50, height: 50),
    );
  }

  Widget _getPlayerControlForStation(MemStation? station) {
    if (station == null) {
      return const SizedBox(width: 50, height: 50);
    }
    return ValueListenableBuilder<MemStation?>(
        builder: (context, value, child) {
          return (station.id == value?.id && _playerCtl != null) ? AudioPlayerCtlBtn(_playerCtl!, 32.0) : const SizedBox(width: 50, height: 50);
        },
        valueListenable: AppData.currentTune);
  }
}
