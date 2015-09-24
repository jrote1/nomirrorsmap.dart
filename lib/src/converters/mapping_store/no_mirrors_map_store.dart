part of nomirrorsmap.converters;

class NoMirrorsMapStore {
  static List<_PropertyMapping> _propertyMappings = [];
  static List<_ClassMapping> _classMappings = [];
  static Map<Type, List> _enumMappings = {};

  static void registerAccessor(String propertyName, void setter(dynamic object, dynamic value), dynamic getter(dynamic object)) {
    _propertyMappings.add(new _PropertyMapping()
      ..getter = getter
      ..setter = setter
      ..propertyName = propertyName);
  }

  static Map<Type, _ClassMapping> _classMappingsByType = {};

  static _ClassMapping getClassGeneratedMap(Type type) {
    var classMapping = _classMappingsByType[type];
    if (classMapping == null) {
      if (_classMappings.any((m) => m.type == type)) return _classMappingsByType[type] = _classMappings.firstWhere((m) => m.type == type);
      else {
        throw "Can't find map for type '${type.toString( )}' is it missing the @Mappable() annotation ";
      }
    }
    return classMapping;
  }

  static _ClassMapping getClassGeneratedMapWithNoCheck(Type type) {
    var classMapping = _classMappingsByType[type];
    if (classMapping == null) {
      if (_classMappings.any((m) => m.type == type)) return _classMappingsByType[type] = _classMappings.firstWhere((m) => m.type == type);
      return null;
    }
    return classMapping;
  }

  static Map<Type, _ClassMapping> _classMappingsByListType = {};

  static _ClassMapping getClassGeneratedMapByListType(Type type) {
    var classMapping = _classMappingsByListType[type];
    if (classMapping == null) {
      if (!type.toString().contains("<")) return null;
      if (_classMappings.any((m) => m.listType == type)) return _classMappingsByListType[type] = _classMappings.firstWhere((m) => m.listType == type);
      throw "Can't find map for type '${type.toString( )}' is it missing the @Mappable() annotation ";
    }
    return classMapping;
  }

  static _ClassMapping getClassGeneratedMapByQualifiedName(String qualifiedName) {
    if (_classMappings.any((m) => m.fullName == qualifiedName)) return _classMappings.firstWhere((m) => m.fullName == qualifiedName);
    throw "Can't find map for type '$qualifiedName' is it missing the @Mappable() annotation ";
  }

  static void registerClass(String fullName, Type type, Type listType, dynamic instantiate(), Map<String, Type> properties) {
    var classProperties = [];
    properties.forEach((k, v) {
      classProperties.add(new _ClassProperty()
        ..type = v
        ..property = _propertyMappings.firstWhere((p) => p.propertyName == k));
    });

    _classMappings.add(new _ClassMapping()
      ..type = type
      ..listType = listType
      ..fullName = fullName
      ..instantiate = instantiate
      ..properties = classProperties);
  }

  static void registerEnum(Type type, List values) {
    _enumMappings[type] = values;
  }

  static bool containsEnumGeneratedMap(Type type) {
    return _enumMappings.containsKey(type);
  }

  static List getEnumGeneratedMap(Type type) {
    return _enumMappings[type];
  }
}
