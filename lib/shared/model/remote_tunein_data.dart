import 'package:xml/xml.dart';
import 'package:xml_annotation/xml_annotation.dart' as annotation;

part 'remote_tunein_data.g.dart';

@annotation.XmlRootElement(name: 'playlist')
@annotation.XmlSerializable()
class RemoteTuneinData {
  @annotation.XmlElement(name: 'title')
  String? title;

  @annotation.XmlElement(name: 'trackList')
  TrackList? container;

  factory RemoteTuneinData.fromXmlElement(String body) {
    final document = XmlDocument.parse(body);
    return _$RemoteTuneinDataFromXmlElement(document.rootElement);
  }

  RemoteTuneinData({this.title, this.container});

  void buildXmlChildren(XmlBuilder builder,
          {required Map<String, String> namespaces}) =>
      _$RemoteTuneinDataBuildXmlChildren(
        this,
        builder,
        namespaces: namespaces,
      );

  toXmlAttributes({required Map<String, String?> namespaces}) =>
      _$RemoteTuneinDataToXmlAttributes(
        this,
        namespaces: namespaces,
      );

  Iterable<XmlNode> toXmlChildren({required Map<String, String?> namespaces}) =>
      _$RemoteTuneinDataToXmlChildren(
        this,
        namespaces: namespaces,
      );
}

@annotation.XmlRootElement(name: 'trackList')
@annotation.XmlSerializable()
class TrackList {
  List<Track>? trackList;

  TrackList(this.trackList);

  void buildXmlChildren(XmlBuilder builder,
          {required Map<String, String> namespaces}) =>
      _$TrackListBuildXmlChildren(
        this,
        builder,
        namespaces: namespaces,
      );

  static fromXmlElement(XmlElement e) {
    List<Track>? trackList =
        e.childElements.map((item) => Track.fromXmlElement(item)).toList();
    return TrackList(trackList);
  }

  toXmlAttributes({required Map<String, String?> namespaces}) =>
      _$TrackListToXmlAttributes(
        this,
        namespaces: namespaces,
      );

  toXmlChildren({required Map<String, String?> namespaces}) =>
      _$TrackListToXmlAttributes(
        this,
        namespaces: namespaces,
      );
}

@annotation.XmlRootElement(name: 'track')
@annotation.XmlSerializable()
class Track {
  @annotation.XmlElement(name: 'title')
  String? title;

  @annotation.XmlElement(name: 'location')
  String? location;

  Track({this.title, this.location});

  void buildXmlChildren(XmlBuilder builder,
          {required Map<String, String> namespaces}) =>
      _$TrackBuildXmlChildren(
        this,
        builder,
        namespaces: namespaces,
      );

  static Track fromXmlElement(XmlElement e) => _$TrackFromXmlElement(e);

  Iterable<XmlAttribute> toXmlAttributes(
          {required Map<String, String?> namespaces}) =>
      _$TrackToXmlAttributes(
        this,
        namespaces: namespaces,
      );

  Iterable<XmlNode> toXmlChildren({required Map<String, String?> namespaces}) =>
      _$TrackToXmlChildren(
        this,
        namespaces: namespaces,
      );
}
