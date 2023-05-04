import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:myradio/features/favoritelist/model/favorite_station.dart';
import 'package:myradio/features/playerctl/index.dart';

import '../../appdata.dart';

class PlayerctlScreen extends StatefulWidget {
  const PlayerctlScreen({
    required PlayerctlBloc playerctlBloc,
    Key? key,
  })  : _playerctlBloc = playerctlBloc,
        super(key: key);

  final PlayerctlBloc _playerctlBloc;

  @override
  PlayerctlScreenState createState() {
    return PlayerctlScreenState();
  }
}

class PlayerctlScreenState extends State<PlayerctlScreen> {
  BannerAd? _ad;
  @override
  void initState() {
    super.initState();
    BannerAd(
      adUnitId: AppData.bannerAdUnitId(AdBannerPosition.top500),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _ad = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();
        },
      ),
    ).load();
    widget._playerctlBloc.add(InitAudioPlayerEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerctlBloc, PlayerctlState>(
        bloc: widget._playerctlBloc,
        builder: (
          BuildContext context,
          PlayerctlState currentState,
        ) {
          if (currentState is InitAudioPlayerState) {
            return ValueListenableBuilder<FavoriteStation?>(
                builder: (context, value, child) {
                  return (value == null) ? const Center(child: CircularProgressIndicator()) : _buildPlayer(currentState.player, value);
                },
                valueListenable: AppData.currentTune);
          }
          if (currentState is ErrorPlayerctlState) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(currentState.errorMessage),
                const Padding(
                  padding: EdgeInsets.only(top: 32.0),
                  child: Text('error loading player'),
                ),
              ],
            ));
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  Widget _buildPlayer(PlayerSingleton playerCtl, FavoriteStation station) {
    const bannerHeight = 300.0;
    double svgWidth = min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) - bannerHeight;
    return ListView(shrinkWrap: true, children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: _ad == null ? svgWidth : _ad!.size.width.toDouble(),
            height: 72.0,
            alignment: Alignment.center,
            child: _ad == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : AdWidget(ad: _ad!),
          ),
          IconButton(
              alignment: AlignmentDirectional.topCenter,
              onPressed: () {
                _bookMarkCurrentStation(playerCtl, station).then((_) {
                  setState(() {
                    AppData.currentTuneBookmarked = !AppData.currentTuneBookmarked;
                  });
                });
              },
              iconSize: 64.0,
              icon: Icon(
                AppData.currentTuneBookmarked ? Icons.favorite : Icons.favorite_border,
                color: AppData.currentTuneBookmarked ? Colors.red : null,
              )),
          ValueListenableBuilder<Map<String, String>?>(
              builder: (context, value, child) {
                var title = station.name;
                var url = '';
                if (value != null && value['title']!.isNotEmpty) {
                  title = "${station.name}: \n ${value['title']}";
                  url = value['url'] ?? '';
                }
                return Column(
                  children: [
                    _showImage(url, station, svgWidth),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                      child: Text(title, style: Theme.of(context).textTheme.headline6),
                    ),
                  ],
                );
              },
              valueListenable: AppData.currentTuneMeta),
          AudioPlayerCtlBtn(playerCtl, 64),
        ],
      )
    ]);
  }

  _showImage(String url, FavoriteStation station, double svgWidth) {
    if (svgWidth <= 0) {
      return Container();
    }
    if (url.isEmpty) {
      return (station.logo.isNotEmpty)
          ? CachedNetworkImage(imageUrl: station.logo)
          : SvgPicture.asset(
              (station.assetlogo == 'art/sun-60.png') ? 'art/sun.svg' : 'art/moon.svg',
              width: svgWidth,
              height: svgWidth,
            );
    }
    return CachedNetworkImage(imageUrl: url);
  }

  Future<void> _bookMarkCurrentStation(PlayerSingleton playerCtl, FavoriteStation station) {
    if (AppData.currentTuneBookmarked) {
      return playerCtl.removeBookmark(station);
    } else {
      return playerCtl.addBookmark(station);
    }
  }
}
