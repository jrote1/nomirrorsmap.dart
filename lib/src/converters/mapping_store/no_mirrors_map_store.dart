part of nomirrorsmap.converters;

class NoMirrorsMapStore implements TypeInformationRetriever {
  static List<FieldMapping> _fieldMappings = [];
  static List<ClassMapping> _classMappings = [];
  static Map<Type, List> _enumMappings = {};

  static void registerField(
      String fieldName,
      void setter(dynamic object, dynamic value),
      dynamic getter(dynamic object)) {
    _fieldMappings.add(new FieldMapping()
      ..getter = getter
      ..setter = setter
      ..name = fieldName);
  }

  static Map<Type, ClassMapping> _classMappingsByType = {};

  ClassMapping getClassGeneratedMap(Type type) {
    var classMapping = _classMappingsByType[type];
    if (classMapping == null) {
      if (_classMappings
          .any((m) => m.type == type)) return _classMappingsByType[type] =
          _classMappings.firstWhere((m) => m.type == type);
      else {
        throw "Can't find map for type '${type.toString( )}' is it missing the @Mappable() annotation ";
      }
    }
    return classMapping;
  }

  ClassMapping getClassGeneratedMapWithNoCheck(Type type) {
    var classMapping = _classMappingsByType[type];
    if (classMapping == null) {
      if (_classMappings
          .any((m) => m.type == type)) return _classMappingsByType[type] =
          _classMappings.firstWhere((m) => m.type == type);
      return null;
    }
    return classMapping;
  }

  static Map<Type, ClassMapping> _classMappingsByListType = {};

  ClassMapping getClassGeneratedMapByListType(Type type) {
    var classMapping = _classMappingsByListType[type];
    if (classMapping == null) {
      if (!type.toString().contains("<")) return null;
      if (_classMappings
          .any((m) => m.listType == type)) return _classMappingsByListType[
          type] = _classMappings.firstWhere((m) => m.listType == type);
      throw "Can't find map for type '${type.toString( )}' is it missing the @Mappable() annotation ";
    }
    return classMapping;
  }

  ClassMapping getClassGeneratedMapByQualifiedName(String qualifiedName) {
    if (_classMappings
        .any((m) => m.fullName == qualifiedName)) return _classMappings
        .firstWhere((m) => m.fullName == qualifiedName);
    throw "Can't find map for type '$qualifiedName' is it missing the @Mappable() annotation ";
  }

  static void registerClass(String fullName, Type type, Type listType,
      dynamic instantiate(), Map<String, Type> fields) {
    var classFields = [];
    fields.forEach((k, v) {
      classFields.add(new ClassField()
        ..type = v
        ..fieldMapping = _fieldMappings.firstWhere((p) => p.name == k));
    });

    _classMappings.add(new ClassMapping()
      ..type = type
      ..listType = listType
      ..fullName = fullName
      ..instantiate = instantiate
      ..fields = classFields);
  }

  static void registerEnum(Type type, List values) {
    _enumMappings[type] = values;
  }

  bool containsEnumGeneratedMap(Type type) => _enumMappings.containsKey(type);
  List getEnumGeneratedMap(Type type) => _enumMappings[type];
}
