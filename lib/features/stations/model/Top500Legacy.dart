import 'package:xml/xml.dart';
import 'package:xml_annotation/xml_annotation.dart' as annotation;

part 'Top500Legacy.g.dart';

@annotation.XmlRootElement(name: 'stationlist')
@annotation.XmlSerializable()
class Top500Legacy {
  @annotation.XmlElement(name: 'tunein')
  Tunein? tunein;

  @annotation.XmlElement(name: 'station', includeIfNull: false)
  List<Station>? stations;

  factory Top500Legacy.fromXmlElement(String body) {
    final document = XmlDocument.parse(body);
    return _$Top500LegacyFromXmlElement(document.rootElement);
  }

  Top500Legacy({this.tunein, this.stations});

  void buildXmlChildren(XmlBuilder builder, {required Map<String, String> namespaces}) => _$Top500LegacyBuildXmlChildren(
        this,
        builder,
        namespaces: namespaces,
      );

  toXmlAttributes({required Map<String, String?> namespaces}) => _$Top500LegacyToXmlAttributes(
        this,
        namespaces: namespaces,
      );

  Iterable<XmlNode> toXmlChildren({required Map<String, String?> namespaces}) => _$Top500LegacyToXmlChildren(
        this,
        namespaces: namespaces,
      );
}

@annotation.XmlRootElement(name: 'tunein')
@annotation.XmlSerializable()
class Tunein {
  @annotation.XmlAttribute(name: 'base')
  String? base;

  @annotation.XmlAttribute(name: 'base-m3u')
  String? baseM3u;

  @annotation.XmlAttribute(name: 'base-xspf')
  String? baseXspf;

  Tunein({this.base, this.baseM3u, this.baseXspf});

  void buildXmlChildren(XmlBuilder builder, {required Map<String, String> namespaces}) => _$TuneinBuildXmlChildren(
        this,
        builder,
        namespaces: namespaces,
      );

  static fromXmlElement(XmlElement element) {
    final base = element.getAttribute('base');
    final baseM3u = element.getAttribute('base-m3u');
    final baseXspf = element.getAttribute('base-xspf');

    return Tunein(base: base, baseM3u: baseM3u, baseXspf: baseXspf);
  }

  toXmlAttributes({required Map<String, String?> namespaces}) => _$TuneinToXmlAttributes(
        this,
        namespaces: namespaces,
      );

  toXmlChildren({required Map<String, String?> namespaces}) => _$TuneinToXmlChildren(
        this,
        namespaces: namespaces,
      );
}

@annotation.XmlRootElement(name: 'station')
@annotation.XmlSerializable()
class Station {
  @annotation.XmlAttribute(name: 'name')
  String? name;

  @annotation.XmlAttribute(name: 'mt')
  String? mediaType;

  @annotation.XmlAttribute(name: 'id')
  String? id;

  @annotation.XmlAttribute(name: 'br')
  String? bitRate;

  @annotation.XmlAttribute(name: 'genre')
  String? genre;

  @annotation.XmlAttribute(name: 'genre2')
  String? genre2;

  @annotation.XmlAttribute(name: 'genre3')
  String? genre3;

  @annotation.XmlAttribute(name: 'genre4')
  String? genre4;

  @annotation.XmlAttribute(name: 'genre5')
  String? genre5;

  @annotation.XmlAttribute(name: 'genre6')
  String? genre6;

  @annotation.XmlAttribute(name: 'genre7')
  String? genre7;

  @annotation.XmlAttribute(name: 'genre8')
  String? genre8;

  @annotation.XmlAttribute(name: 'genre9')
  String? genre9;

  @annotation.XmlAttribute(name: 'genre10')
  String? genre10;

  @annotation.XmlAttribute(name: 'ct')
  String? channelTitle;

  @annotation.XmlAttribute(name: 'logo')
  String? logo;

  @annotation.XmlAttribute(name: 'lc')
  String? lc;

  Station(
      {this.id,
      this.name,
      this.channelTitle,
      this.genre,
      this.genre2,
      this.genre3,
      this.genre4,
      this.genre5,
      this.genre6,
      this.genre7,
      this.genre8,
      this.genre9,
      this.genre10,
      this.logo,
      this.bitRate,
      this.mediaType,
      this.lc});

  factory Station.fromXmlElement(XmlElement element) => _$StationFromXmlElement(element);

  void buildXmlChildren(XmlBuilder builder, {required Map<String, String> namespaces}) => _$StationBuildXmlChildren(
        this,
        builder,
        namespaces: namespaces,
      );

  Iterable<XmlAttribute> toXmlAttributes({required Map<String, String?> namespaces}) => _$StationToXmlAttributes(
        this,
        namespaces: namespaces,
      );

  Iterable<XmlNode> toXmlChildren({required Map<String, String?> namespaces}) => _$StationToXmlChildren(
        this,
        namespaces: namespaces,
      );
}
