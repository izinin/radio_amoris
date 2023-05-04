// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Top500Legacy.dart';

// **************************************************************************
// XmlSerializableGenerator
// **************************************************************************

void _$Top500LegacyBuildXmlChildren(Top500Legacy instance, XmlBuilder builder,
    {Map<String, String> namespaces = const {}}) {
  final tunein = instance.tunein;
  final tuneinSerialized = tunein;
  builder.element('tunein', nest: () {
    if (tuneinSerialized != null) {
      tuneinSerialized.buildXmlChildren(builder, namespaces: namespaces);
    }
  });
  final stations = instance.stations;
  final stationsSerialized = stations;
  if (stationsSerialized != null) {
    for (final value in stationsSerialized) {
      builder.element('station', nest: () {
        value.buildXmlChildren(builder, namespaces: namespaces);
      });
    }
  }
}

void _$Top500LegacyBuildXmlElement(Top500Legacy instance, XmlBuilder builder,
    {Map<String, String> namespaces = const {}}) {
  builder.element('stationlist', namespaces: namespaces, nest: () {
    instance.buildXmlChildren(builder, namespaces: namespaces);
  });
}

Top500Legacy _$Top500LegacyFromXmlElement(XmlElement element) {
  final tunein = element.getElement('tunein');
  final stations = element.getElements('station');
  return Top500Legacy(
      tunein: tunein != null ? Tunein.fromXmlElement(tunein) : null,
      stations: stations?.map((e) => Station.fromXmlElement(e)).toList());
}

List<XmlAttribute> _$Top500LegacyToXmlAttributes(Top500Legacy instance,
    {Map<String, String?> namespaces = const {}}) {
  final attributes = <XmlAttribute>[];
  return attributes;
}

List<XmlNode> _$Top500LegacyToXmlChildren(Top500Legacy instance,
    {Map<String, String?> namespaces = const {}}) {
  final children = <XmlNode>[];
  final tunein = instance.tunein;
  final tuneinSerialized = tunein;
  final tuneinConstructed = XmlElement(
      XmlName('tunein'),
      tuneinSerialized?.toXmlAttributes(namespaces: namespaces) ?? [],
      tuneinSerialized?.toXmlChildren(namespaces: namespaces) ?? []);
  children.add(tuneinConstructed);
  final stations = instance.stations;
  final stationsSerialized = stations;
  final stationsConstructed = stationsSerialized?.map((e) => XmlElement(
      XmlName('station'),
      e.toXmlAttributes(namespaces: namespaces),
      e.toXmlChildren(namespaces: namespaces)));
  if (stationsConstructed != null) {
    children.addAll(stationsConstructed);
  }
  return children;
}

XmlElement _$Top500LegacyToXmlElement(Top500Legacy instance,
    {Map<String, String?> namespaces = const {}}) {
  return XmlElement(
      XmlName('stationlist'),
      [
        ...namespaces.toXmlAttributes(),
        ...instance.toXmlAttributes(namespaces: namespaces)
      ],
      instance.toXmlChildren(namespaces: namespaces));
}

void _$TuneinBuildXmlChildren(Tunein instance, XmlBuilder builder,
    {Map<String, String> namespaces = const {}}) {
  final base = instance.base;
  final baseSerialized = base;
  if (baseSerialized != null) {
    builder.attribute('base', baseSerialized);
  }
  final baseM3u = instance.baseM3u;
  final baseM3uSerialized = baseM3u;
  if (baseM3uSerialized != null) {
    builder.attribute('base-m3u', baseM3uSerialized);
  }
  final baseXspf = instance.baseXspf;
  final baseXspfSerialized = baseXspf;
  if (baseXspfSerialized != null) {
    builder.attribute('base-xspf', baseXspfSerialized);
  }
}

void _$TuneinBuildXmlElement(Tunein instance, XmlBuilder builder,
    {Map<String, String> namespaces = const {}}) {
  builder.element('tunein', namespaces: namespaces, nest: () {
    instance.buildXmlChildren(builder, namespaces: namespaces);
  });
}

Tunein _$TuneinFromXmlElement(XmlElement element) {
  final base = element.getAttribute('base');
  final baseM3u = element.getAttribute('base-m3u');
  final baseXspf = element.getAttribute('base-xspf');
  return Tunein(base: base, baseM3u: baseM3u, baseXspf: baseXspf);
}

List<XmlAttribute> _$TuneinToXmlAttributes(Tunein instance,
    {Map<String, String?> namespaces = const {}}) {
  final attributes = <XmlAttribute>[];
  final base = instance.base;
  final baseSerialized = base;
  final baseConstructed = baseSerialized != null
      ? XmlAttribute(XmlName('base'), baseSerialized)
      : null;
  if (baseConstructed != null) {
    attributes.add(baseConstructed);
  }
  final baseM3u = instance.baseM3u;
  final baseM3uSerialized = baseM3u;
  final baseM3uConstructed = baseM3uSerialized != null
      ? XmlAttribute(XmlName('base-m3u'), baseM3uSerialized)
      : null;
  if (baseM3uConstructed != null) {
    attributes.add(baseM3uConstructed);
  }
  final baseXspf = instance.baseXspf;
  final baseXspfSerialized = baseXspf;
  final baseXspfConstructed = baseXspfSerialized != null
      ? XmlAttribute(XmlName('base-xspf'), baseXspfSerialized)
      : null;
  if (baseXspfConstructed != null) {
    attributes.add(baseXspfConstructed);
  }
  return attributes;
}

List<XmlNode> _$TuneinToXmlChildren(Tunein instance,
    {Map<String, String?> namespaces = const {}}) {
  final children = <XmlNode>[];
  return children;
}

XmlElement _$TuneinToXmlElement(Tunein instance,
    {Map<String, String?> namespaces = const {}}) {
  return XmlElement(
      XmlName('tunein'),
      [
        ...namespaces.toXmlAttributes(),
        ...instance.toXmlAttributes(namespaces: namespaces)
      ],
      instance.toXmlChildren(namespaces: namespaces));
}

void _$StationBuildXmlChildren(Station instance, XmlBuilder builder,
    {Map<String, String> namespaces = const {}}) {
  final name = instance.name;
  final nameSerialized = name;
  if (nameSerialized != null) {
    builder.attribute('name', nameSerialized);
  }
  final mediaType = instance.mediaType;
  final mediaTypeSerialized = mediaType;
  if (mediaTypeSerialized != null) {
    builder.attribute('mt', mediaTypeSerialized);
  }
  final id = instance.id;
  final idSerialized = id;
  if (idSerialized != null) {
    builder.attribute('id', idSerialized);
  }
  final bitRate = instance.bitRate;
  final bitRateSerialized = bitRate;
  if (bitRateSerialized != null) {
    builder.attribute('br', bitRateSerialized);
  }
  final genre = instance.genre;
  final genreSerialized = genre;
  if (genreSerialized != null) {
    builder.attribute('genre', genreSerialized);
  }
  final genre2 = instance.genre2;
  final genre2Serialized = genre2;
  if (genre2Serialized != null) {
    builder.attribute('genre2', genre2Serialized);
  }
  final genre3 = instance.genre3;
  final genre3Serialized = genre3;
  if (genre3Serialized != null) {
    builder.attribute('genre3', genre3Serialized);
  }
  final genre4 = instance.genre4;
  final genre4Serialized = genre4;
  if (genre4Serialized != null) {
    builder.attribute('genre4', genre4Serialized);
  }
  final genre5 = instance.genre5;
  final genre5Serialized = genre5;
  if (genre5Serialized != null) {
    builder.attribute('genre5', genre5Serialized);
  }
  final genre6 = instance.genre6;
  final genre6Serialized = genre6;
  if (genre6Serialized != null) {
    builder.attribute('genre6', genre6Serialized);
  }
  final genre7 = instance.genre7;
  final genre7Serialized = genre7;
  if (genre7Serialized != null) {
    builder.attribute('genre7', genre7Serialized);
  }
  final genre8 = instance.genre8;
  final genre8Serialized = genre8;
  if (genre8Serialized != null) {
    builder.attribute('genre8', genre8Serialized);
  }
  final genre9 = instance.genre9;
  final genre9Serialized = genre9;
  if (genre9Serialized != null) {
    builder.attribute('genre9', genre9Serialized);
  }
  final genre10 = instance.genre10;
  final genre10Serialized = genre10;
  if (genre10Serialized != null) {
    builder.attribute('genre10', genre10Serialized);
  }
  final channelTitle = instance.channelTitle;
  final channelTitleSerialized = channelTitle;
  if (channelTitleSerialized != null) {
    builder.attribute('ct', channelTitleSerialized);
  }
  final logo = instance.logo;
  final logoSerialized = logo;
  if (logoSerialized != null) {
    builder.attribute('logo', logoSerialized);
  }
  final lc = instance.lc;
  final lcSerialized = lc;
  if (lcSerialized != null) {
    builder.attribute('lc', lcSerialized);
  }
}

void _$StationBuildXmlElement(Station instance, XmlBuilder builder,
    {Map<String, String> namespaces = const {}}) {
  builder.element('station', namespaces: namespaces, nest: () {
    instance.buildXmlChildren(builder, namespaces: namespaces);
  });
}

Station _$StationFromXmlElement(XmlElement element) {
  final name = element.getAttribute('name');
  final mediaType = element.getAttribute('mt');
  final id = element.getAttribute('id');
  final bitRate = element.getAttribute('br');
  final genre = element.getAttribute('genre');
  final genre2 = element.getAttribute('genre2');
  final genre3 = element.getAttribute('genre3');
  final genre4 = element.getAttribute('genre4');
  final genre5 = element.getAttribute('genre5');
  final genre6 = element.getAttribute('genre6');
  final genre7 = element.getAttribute('genre7');
  final genre8 = element.getAttribute('genre8');
  final genre9 = element.getAttribute('genre9');
  final genre10 = element.getAttribute('genre10');
  final channelTitle = element.getAttribute('ct');
  final logo = element.getAttribute('logo');
  final lc = element.getAttribute('lc');
  return Station(
      name: name,
      mediaType: mediaType,
      id: id,
      bitRate: bitRate,
      genre: genre,
      genre2: genre2,
      genre3: genre3,
      genre4: genre4,
      genre5: genre5,
      genre6: genre6,
      genre7: genre7,
      genre8: genre8,
      genre9: genre9,
      genre10: genre10,
      channelTitle: channelTitle,
      logo: logo,
      lc: lc);
}

List<XmlAttribute> _$StationToXmlAttributes(Station instance,
    {Map<String, String?> namespaces = const {}}) {
  final attributes = <XmlAttribute>[];
  final name = instance.name;
  final nameSerialized = name;
  final nameConstructed = nameSerialized != null
      ? XmlAttribute(XmlName('name'), nameSerialized)
      : null;
  if (nameConstructed != null) {
    attributes.add(nameConstructed);
  }
  final mediaType = instance.mediaType;
  final mediaTypeSerialized = mediaType;
  final mediaTypeConstructed = mediaTypeSerialized != null
      ? XmlAttribute(XmlName('mt'), mediaTypeSerialized)
      : null;
  if (mediaTypeConstructed != null) {
    attributes.add(mediaTypeConstructed);
  }
  final id = instance.id;
  final idSerialized = id;
  final idConstructed =
      idSerialized != null ? XmlAttribute(XmlName('id'), idSerialized) : null;
  if (idConstructed != null) {
    attributes.add(idConstructed);
  }
  final bitRate = instance.bitRate;
  final bitRateSerialized = bitRate;
  final bitRateConstructed = bitRateSerialized != null
      ? XmlAttribute(XmlName('br'), bitRateSerialized)
      : null;
  if (bitRateConstructed != null) {
    attributes.add(bitRateConstructed);
  }
  final genre = instance.genre;
  final genreSerialized = genre;
  final genreConstructed = genreSerialized != null
      ? XmlAttribute(XmlName('genre'), genreSerialized)
      : null;
  if (genreConstructed != null) {
    attributes.add(genreConstructed);
  }
  final genre2 = instance.genre2;
  final genre2Serialized = genre2;
  final genre2Constructed = genre2Serialized != null
      ? XmlAttribute(XmlName('genre2'), genre2Serialized)
      : null;
  if (genre2Constructed != null) {
    attributes.add(genre2Constructed);
  }
  final genre3 = instance.genre3;
  final genre3Serialized = genre3;
  final genre3Constructed = genre3Serialized != null
      ? XmlAttribute(XmlName('genre3'), genre3Serialized)
      : null;
  if (genre3Constructed != null) {
    attributes.add(genre3Constructed);
  }
  final genre4 = instance.genre4;
  final genre4Serialized = genre4;
  final genre4Constructed = genre4Serialized != null
      ? XmlAttribute(XmlName('genre4'), genre4Serialized)
      : null;
  if (genre4Constructed != null) {
    attributes.add(genre4Constructed);
  }
  final genre5 = instance.genre5;
  final genre5Serialized = genre5;
  final genre5Constructed = genre5Serialized != null
      ? XmlAttribute(XmlName('genre5'), genre5Serialized)
      : null;
  if (genre5Constructed != null) {
    attributes.add(genre5Constructed);
  }
  final genre6 = instance.genre6;
  final genre6Serialized = genre6;
  final genre6Constructed = genre6Serialized != null
      ? XmlAttribute(XmlName('genre6'), genre6Serialized)
      : null;
  if (genre6Constructed != null) {
    attributes.add(genre6Constructed);
  }
  final genre7 = instance.genre7;
  final genre7Serialized = genre7;
  final genre7Constructed = genre7Serialized != null
      ? XmlAttribute(XmlName('genre7'), genre7Serialized)
      : null;
  if (genre7Constructed != null) {
    attributes.add(genre7Constructed);
  }
  final genre8 = instance.genre8;
  final genre8Serialized = genre8;
  final genre8Constructed = genre8Serialized != null
      ? XmlAttribute(XmlName('genre8'), genre8Serialized)
      : null;
  if (genre8Constructed != null) {
    attributes.add(genre8Constructed);
  }
  final genre9 = instance.genre9;
  final genre9Serialized = genre9;
  final genre9Constructed = genre9Serialized != null
      ? XmlAttribute(XmlName('genre9'), genre9Serialized)
      : null;
  if (genre9Constructed != null) {
    attributes.add(genre9Constructed);
  }
  final genre10 = instance.genre10;
  final genre10Serialized = genre10;
  final genre10Constructed = genre10Serialized != null
      ? XmlAttribute(XmlName('genre10'), genre10Serialized)
      : null;
  if (genre10Constructed != null) {
    attributes.add(genre10Constructed);
  }
  final channelTitle = instance.channelTitle;
  final channelTitleSerialized = channelTitle;
  final channelTitleConstructed = channelTitleSerialized != null
      ? XmlAttribute(XmlName('ct'), channelTitleSerialized)
      : null;
  if (channelTitleConstructed != null) {
    attributes.add(channelTitleConstructed);
  }
  final logo = instance.logo;
  final logoSerialized = logo;
  final logoConstructed = logoSerialized != null
      ? XmlAttribute(XmlName('logo'), logoSerialized)
      : null;
  if (logoConstructed != null) {
    attributes.add(logoConstructed);
  }
  final lc = instance.lc;
  final lcSerialized = lc;
  final lcConstructed =
      lcSerialized != null ? XmlAttribute(XmlName('lc'), lcSerialized) : null;
  if (lcConstructed != null) {
    attributes.add(lcConstructed);
  }
  return attributes;
}

List<XmlNode> _$StationToXmlChildren(Station instance,
    {Map<String, String?> namespaces = const {}}) {
  final children = <XmlNode>[];
  return children;
}

XmlElement _$StationToXmlElement(Station instance,
    {Map<String, String?> namespaces = const {}}) {
  return XmlElement(
      XmlName('station'),
      [
        ...namespaces.toXmlAttributes(),
        ...instance.toXmlAttributes(namespaces: namespaces)
      ],
      instance.toXmlChildren(namespaces: namespaces));
}
