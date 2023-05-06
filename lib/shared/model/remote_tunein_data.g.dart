// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_tunein_data.dart';

// **************************************************************************
// XmlSerializableGenerator
// **************************************************************************

void _$RemoteTuneinDataBuildXmlChildren(
    RemoteTuneinData instance, XmlBuilder builder,
    {Map<String, String> namespaces = const {}}) {
  final title = instance.title;
  final titleSerialized = title;
  builder.element('title', nest: () {
    if (titleSerialized != null) {
      builder.text(titleSerialized);
    }
  });
  final container = instance.container;
  final containerSerialized = container;
  builder.element('trackList', nest: () {
    if (containerSerialized != null) {
      containerSerialized.buildXmlChildren(builder, namespaces: namespaces);
    }
  });
}

void _$RemoteTuneinDataBuildXmlElement(
    RemoteTuneinData instance, XmlBuilder builder,
    {Map<String, String> namespaces = const {}}) {
  builder.element('playlist', namespaces: namespaces, nest: () {
    instance.buildXmlChildren(builder, namespaces: namespaces);
  });
}

RemoteTuneinData _$RemoteTuneinDataFromXmlElement(XmlElement element) {
  final title = element.getElement('title')?.getText();
  final container = element.getElement('trackList');
  return RemoteTuneinData(
      title: title,
      container:
          container != null ? TrackList.fromXmlElement(container) : null);
}

List<XmlAttribute> _$RemoteTuneinDataToXmlAttributes(RemoteTuneinData instance,
    {Map<String, String?> namespaces = const {}}) {
  final attributes = <XmlAttribute>[];
  return attributes;
}

List<XmlNode> _$RemoteTuneinDataToXmlChildren(RemoteTuneinData instance,
    {Map<String, String?> namespaces = const {}}) {
  final children = <XmlNode>[];
  final title = instance.title;
  final titleSerialized = title;
  final titleConstructed = XmlElement(XmlName('title'), [],
      titleSerialized != null ? [XmlText(titleSerialized)] : []);
  children.add(titleConstructed);
  final container = instance.container;
  final containerSerialized = container;
  final containerConstructed = XmlElement(
      XmlName('trackList'),
      containerSerialized?.toXmlAttributes(namespaces: namespaces) ?? [],
      containerSerialized?.toXmlChildren(namespaces: namespaces) ?? []);
  children.add(containerConstructed);
  return children;
}

XmlElement _$RemoteTuneinDataToXmlElement(RemoteTuneinData instance,
    {Map<String, String?> namespaces = const {}}) {
  return XmlElement(
      XmlName('playlist'),
      [
        ...namespaces.toXmlAttributes(),
        ...instance.toXmlAttributes(namespaces: namespaces)
      ],
      instance.toXmlChildren(namespaces: namespaces));
}

void _$TrackListBuildXmlChildren(TrackList instance, XmlBuilder builder,
    {Map<String, String> namespaces = const {}}) {}

void _$TrackListBuildXmlElement(TrackList instance, XmlBuilder builder,
    {Map<String, String> namespaces = const {}}) {
  builder.element('trackList', namespaces: namespaces, nest: () {
    instance.buildXmlChildren(builder, namespaces: namespaces);
  });
}

List<XmlAttribute> _$TrackListToXmlAttributes(TrackList instance,
    {Map<String, String?> namespaces = const {}}) {
  final attributes = <XmlAttribute>[];
  return attributes;
}

List<XmlNode> _$TrackListToXmlChildren(TrackList instance,
    {Map<String, String?> namespaces = const {}}) {
  final children = <XmlNode>[];
  return children;
}

XmlElement _$TrackListToXmlElement(TrackList instance,
    {Map<String, String?> namespaces = const {}}) {
  return XmlElement(
      XmlName('trackList'),
      [
        ...namespaces.toXmlAttributes(),
        ...instance.toXmlAttributes(namespaces: namespaces)
      ],
      instance.toXmlChildren(namespaces: namespaces));
}

void _$TrackBuildXmlChildren(Track instance, XmlBuilder builder,
    {Map<String, String> namespaces = const {}}) {
  final title = instance.title;
  final titleSerialized = title;
  builder.element('title', nest: () {
    if (titleSerialized != null) {
      builder.text(titleSerialized);
    }
  });
  final location = instance.location;
  final locationSerialized = location;
  builder.element('location', nest: () {
    if (locationSerialized != null) {
      builder.text(locationSerialized);
    }
  });
}

void _$TrackBuildXmlElement(Track instance, XmlBuilder builder,
    {Map<String, String> namespaces = const {}}) {
  builder.element('track', namespaces: namespaces, nest: () {
    instance.buildXmlChildren(builder, namespaces: namespaces);
  });
}

Track _$TrackFromXmlElement(XmlElement element) {
  final title = element.getElement('title')?.getText();
  final location = element.getElement('location')?.getText();
  return Track(title: title, location: location);
}

List<XmlAttribute> _$TrackToXmlAttributes(Track instance,
    {Map<String, String?> namespaces = const {}}) {
  final attributes = <XmlAttribute>[];
  return attributes;
}

List<XmlNode> _$TrackToXmlChildren(Track instance,
    {Map<String, String?> namespaces = const {}}) {
  final children = <XmlNode>[];
  final title = instance.title;
  final titleSerialized = title;
  final titleConstructed = XmlElement(XmlName('title'), [],
      titleSerialized != null ? [XmlText(titleSerialized)] : []);
  children.add(titleConstructed);
  final location = instance.location;
  final locationSerialized = location;
  final locationConstructed = XmlElement(XmlName('location'), [],
      locationSerialized != null ? [XmlText(locationSerialized)] : []);
  children.add(locationConstructed);
  return children;
}

XmlElement _$TrackToXmlElement(Track instance,
    {Map<String, String?> namespaces = const {}}) {
  return XmlElement(
      XmlName('track'),
      [
        ...namespaces.toXmlAttributes(),
        ...instance.toXmlAttributes(namespaces: namespaces)
      ],
      instance.toXmlChildren(namespaces: namespaces));
}
