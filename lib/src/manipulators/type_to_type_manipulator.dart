part of nomirrorsmap.manipulators;

class TypeToTypeManipulator extends BaseObjectDataManipulator {
  Type startType;
  Map<Type, Type> typeMaps;

  TypeInformationRetriever get _typeInformationRetriever =>
      TypeInformationRetrieverLocator.instance;

  TypeToTypeManipulator(this.startType, [Map<Type, Type> typeMaps = null]) {
    this.typeMaps = typeMaps == null ? {} : typeMaps;
  }

  void manipulate(BaseIntermediateObject baseObjectData) {
    _manipulate(startType, baseObjectData);
  }

  void _manipulate(Type toType, BaseIntermediateObject baseObjectData) {
    toType = _getMappedType(baseObjectData, toType);
    if (baseObjectData is ClassIntermediateObject) {
      var classGeneratedMap =
          _typeInformationRetriever.getClassGeneratedMapWithNoCheck(toType);
      if (classGeneratedMap == null || classGeneratedMap.instantiate == null) {
        throw 'Are you missing a type map from "class ${baseObjectData.objectType}" to "abstract class $toType" or a @Mappable() attribute on "class ${baseObjectData.objectType}"';
      }

      ClassIntermediateObject classObjectData = baseObjectData;

      classObjectData.objectType = toType;

      classObjectData.properties.forEach((k, v) {
        if (classGeneratedMap.fields.any((p) => p.fieldMapping.name == k))
          _manipulate(
              classGeneratedMap.fields
                  .firstWhere((p) => p.fieldMapping.name == k)
                  .type,
              v);
      });
    }
    if (baseObjectData is ListIntermediateObject) {
      var listGeneratedMap =
          _typeInformationRetriever.getClassGeneratedMapByListType(toType);
      for (var value in baseObjectData.values) {
        _manipulate(listGeneratedMap.type, value);
      }
    }
  }

  Type _getMappedType(BaseIntermediateObject baseObjectData, Type type) {
    if (typeMaps.containsKey(baseObjectData.objectType))
      return typeMaps[baseObjectData.objectType];
    return type;
  }
}
