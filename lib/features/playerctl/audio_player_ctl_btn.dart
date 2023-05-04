import 'package:flutter/material.dart';

import '../../appdata.dart';

class AudioPlayerCtlBtn extends StatelessWidget {
  final PlayerSingleton _playerCtl;
  final double _iconSize;

  const AudioPlayerCtlBtn(this._playerCtl, this._iconSize, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<MyradioPlayingState>(
          stream: _playerCtl.getPlayerStateStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              final playerState = snapshot.data;
              final processingState = playerState?.state;
              final playing = playerState?.command == MyradioCommand.play;
              if (processingState == MyradioProcessingState.idle || processingState == MyradioProcessingState.buffering) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  width: _iconSize,
                  height: _iconSize,
                  child: const CircularProgressIndicator(),
                );
              } else if (playing) {
                return IconButton(
                  icon: const Icon(Icons.pause),
                  iconSize: _iconSize,
                  onPressed: _playerCtl.exoPlayerPause,
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.play_arrow),
                  iconSize: _iconSize,
                  onPressed: _playerCtl.exoPlayerResume,
                );
              }
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ],
    );
  }
}
