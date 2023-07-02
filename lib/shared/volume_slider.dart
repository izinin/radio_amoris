import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

class VolumeSlider extends StatefulWidget {
  const VolumeSlider({super.key});

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  double _volume = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    FlutterVolumeController.addListener((volume) {
      setState(() {
        _volume = volume;
      });
    });
  }

  @override
  void dispose() {
    FlutterVolumeController.removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
        value: _volume,
        min: 0,
        max: 1,
        divisions: 100,
        onChanged: (val) {
          _volume = val;
          setState(() {});
          _timer?.cancel();
          _timer = Timer(const Duration(milliseconds: 200), () {
            FlutterVolumeController.setVolume(val);
          });
        });
  }
}
