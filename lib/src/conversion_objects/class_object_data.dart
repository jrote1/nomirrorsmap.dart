part of nomirrorsmap.conversion_objects;

class ClassObjectData extends BaseObjectData {
  bool get isNativeType => false;

  String previousHashCode;

  Map<String, BaseObjectData> properties;
}
