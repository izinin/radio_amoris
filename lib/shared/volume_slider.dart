import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

class VolumeSlider extends StatefulWidget {
  const VolumeSlider({super.key});

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  double _volume = 0;

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
  Widget build(BuildContext context) {
    return Slider(
      value: _volume,
      onChanged: (value) {
        setState(() {
          FlutterVolumeController.setVolume(value);
        });
      },
    );
  }
}
