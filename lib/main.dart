import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/stations/stations_page.dart';
import 'appdata.dart';
import 'shared/volume_slider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  var settings = await Hive.openBox(PlayerSingleton.settingsBoxName);
  GetIt.I.registerSingleton<AppData>(AppData());
  GetIt.I.registerFactoryAsync<PlayerSingleton>(PlayerSingleton.instance);
  runApp(AppUI(settings));
}

class AppUI extends StatefulWidget {
  final Box _settings;
  const AppUI(this._settings, {Key? key}) : super(key: key);

  @override
  State<AppUI> createState() => _AppUIState();
}

class _AppUIState extends State<AppUI> {
  late bool useLightMode;
  int colorSelected = 0;
  final PageController controller = PageController();

  late ThemeData themeData;

  @override
  initState() {
    super.initState();
    useLightMode = widget._settings.get('useLightMode', defaultValue: true);
    colorSelected = widget._settings.get('colorSelected', defaultValue: 0);
    themeData = _updateThemes(colorSelected, useLightMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: apptitle,
      themeMode: useLightMode ? ThemeMode.light : ThemeMode.dark,
      theme: themeData,
      home: LayoutBuilder(builder: (context, constraints) {
        double ctrlPanelWidth = min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
        return Scaffold(
            appBar: createAppBar(),
            body: Column(
              children: [
                Container(
                  width: ctrlPanelWidth,
                  height: 72.0,
                  alignment: Alignment.center,
                  child: const VolumeSlider(),
                  // color: Colors.amber[600],
                ),
                const Expanded(child: StationsPage()),
              ],
            ));
      }),
    );
  }

  ThemeData _updateThemes(int colorIndex, bool useLightMode) {
    return ThemeData(colorSchemeSeed: colorOptions[colorSelected], useMaterial3: true, brightness: useLightMode ? Brightness.light : Brightness.dark);
  }

  PreferredSizeWidget createAppBar() {
    return AppBar(
      title: const Text(apptitle),
      actions: [
        ValueListenableBuilder<Box>(
            valueListenable: Hive.box(PlayerSingleton.settingsBoxName).listenable(),
            builder: (context, box, widget) {
              useLightMode = box.get('useLightMode', defaultValue: true);
              return IconButton(
                icon: useLightMode ? const Icon(Icons.dark_mode) : const Icon(Icons.wb_sunny),
                onPressed: () {
                  useLightMode = !useLightMode;
                  box.put('useLightMode', useLightMode);
                  setState(() {
                    themeData = _updateThemes(colorSelected, useLightMode);
                  });
                },
                tooltip: "Toggle dark mode",
              );
            }),
        PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          itemBuilder: (context) {
            return List.generate(colorOptions.length, (index) {
              return PopupMenuItem(
                  value: index,
                  child: Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(
                          index == colorSelected ? Icons.color_lens : Icons.color_lens_outlined,
                          color: colorOptions[index],
                        ),
                      ),
                      Padding(padding: const EdgeInsets.only(left: 20), child: Text(colorText[index]))
                    ],
                  ));
            });
          },
          onSelected: (value) {
            widget._settings.put('colorSelected', value);
            setState(() {
              colorSelected = value;
              themeData = _updateThemes(colorSelected, useLightMode);
            });
          },
        ),
      ],
    );
  }
}
