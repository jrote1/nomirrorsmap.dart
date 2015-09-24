part of nomirrorsmap.manipulators;

class TypeToTypeManipulator extends BaseObjectDataManipulator {
  Type startType;
  Map<Type, Type> typeMaps;

  TypeToTypeManipulator(this.startType, [Map<Type, Type> typeMaps = null]) {
    this.typeMaps = typeMaps == null ? {} : typeMaps;
  }

  void manipulate(BaseObjectData baseObjectData) {
    _manipulate(startType, baseObjectData);
  }

  void _manipulate(Type toType, BaseObjectData baseObjectData) {
    toType = _getMappedType(baseObjectData, toType);
    if (baseObjectData is ClassObjectData) {
      var classGeneratedMap = NoMirrorsMapStore.getClassGeneratedMapWithNoCheck(toType);
      if (classGeneratedMap == null || classGeneratedMap.instantiate == null) {
        throw 'Are you missing a type map from "class ${baseObjectData.objectType}" to "abstract class $toType" or a @Mappable() attribute on "class ${baseObjectData.objectType}"';
      }

      ClassObjectData classObjectData = baseObjectData;

      classObjectData.objectType = toType;

      classObjectData.properties.forEach((k, v) {
        _manipulate(classGeneratedMap.properties.firstWhere((p) => p.property.propertyName == k).type, v);
      });
    }
    if (baseObjectData is ListObjectData) {
      var listGeneratedMap = NoMirrorsMapStore.getClassGeneratedMapByListType(toType);
      for (var value in baseObjectData.values) {
        _manipulate(listGeneratedMap.type, value);
      }
    }
  }

  Type _getMappedType(BaseObjectData baseObjectData, Type type) {
    if (typeMaps.containsKey(baseObjectData.objectType)) return typeMaps[baseObjectData.objectType];
    return type;
  }
}
