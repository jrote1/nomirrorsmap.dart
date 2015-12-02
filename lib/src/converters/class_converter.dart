part of nomirrorsmap.converters;

class ClassConverter implements Converter {
  Type startType;

  ClassConverter({this.startType});

  static Map<Type, CustomClassConverter> converters = {};

  Set<int> seenHashCodes = new Set<int>();

  TypeInformationRetriever get _typeInformationRetriever =>
      TypeInformationRetrieverLocator.instance;

  BaseIntermediateObject toBaseIntermediateObject(Object value) {
    var valueType = value.runtimeType;
    if (converters.containsKey(valueType)) return converters[valueType]
        .from(value);

    if (value is List) {
      return new ListIntermediateObject()
        ..values = value.map((v) => toBaseIntermediateObject(v)).toList();
    }

    if (_isPrimitive(value)) return new NativeIntermediateObject()
      ..objectType = valueType
      ..value = value;

    if (_isEnum(value)) {
      return new NativeIntermediateObject()
        ..objectType = int
        ..value = (value as dynamic).index;
    }

    var hashCode = value.hashCode;
    if (seenHashCodes.contains(hashCode)) return new ClassIntermediateObject()
      ..objectType = valueType
      ..previousHashCode = hashCode.toString()
      ..properties = {};
    seenHashCodes.add(hashCode);

    var generatedMap =
        _typeInformationRetriever.getClassGeneratedMap(valueType);

    var properties = {};

    //Faster than foreach loop
    for (var i = 0; i < generatedMap.fields.length; i++) {
      var property = generatedMap.fields[i];
      var getter = property.fieldMapping.getter;
      properties[property.fieldMapping.name] =
          toBaseIntermediateObject(getter(value));
    }

    return new ClassIntermediateObject()
      ..objectType = valueType
      ..previousHashCode = value.hashCode.toString()
      ..properties = properties;
  }

  bool _isEnum(dynamic value) {
    //Not safe
    return _isTypeEnum(value.runtimeType);
  }

  bool _isPrimitive(v) =>
      v is num || v is bool || v is String || v == null || v is DateTime;

  Map<String, ClassConverterInstance> instances =
      new Map<String, ClassConverterInstance>();

  dynamic fromBaseIntermediateObject(BaseIntermediateObject baseObjectData) {
    return _fromBaseObjectData(
        baseObjectData,
        baseObjectData.objectType == null
            ? startType
            : baseObjectData.objectType);
  }

  dynamic _fromBaseObjectData(
      BaseIntermediateObject baseObjectData, Type type) {
    if (baseObjectData is ClassIntermediateObject) {
      var generatedMap = _typeInformationRetriever.getClassGeneratedMap(type);
      if (generatedMap.instantiate ==
          null) throw "Type '$type' does not have a default constructor, make sure it has a default constructor wuth no paramters";
      var instance = generatedMap.instantiate();

      ClassConverterInstance classConverterInstance;
      if (baseObjectData.previousHashCode != null &&
          instances.containsKey(
              baseObjectData.previousHashCode)) classConverterInstance =
          instances[baseObjectData.previousHashCode];
      else {
        classConverterInstance = new ClassConverterInstance()
          ..filled = false
          ..instance = instance;

        if (baseObjectData.previousHashCode != null) instances[
            baseObjectData.previousHashCode] = classConverterInstance;
      }
      if (!classConverterInstance.filled &&
          baseObjectData.properties.length > 0) {
        for (var property in generatedMap.fields) {
          if (baseObjectData.properties
              .containsKey(property.fieldMapping.name)) {
            var setter = property.fieldMapping.setter;

            var propertyObjectData =
                baseObjectData.properties[property.fieldMapping.name];
            var propertyType = propertyObjectData.objectType == null
                ? property.type
                : propertyObjectData.objectType;

            Object value;
            if (converters.containsKey(propertyType)) value =
                converters[propertyType].to(propertyObjectData);
            else value = _fromBaseObjectData(propertyObjectData, propertyType);

            if (value is List) {
              var list = [];
              list.addAll(value);
              value = list;
            }
            setter(classConverterInstance.instance, value);
          }
        }
        classConverterInstance.filled = true;
      }
      return classConverterInstance.instance;
    }
    if (baseObjectData is ListIntermediateObject) {
      var classMap =
          _typeInformationRetriever.getClassGeneratedMapByListType(type);

      var listType = classMap == null ? Object : classMap.type;

      return baseObjectData.values
          .map((v) => _fromBaseObjectData(
              v, v.objectType == null ? listType : v.objectType))
          .toList();
    }
    var nativeObjectValue = (baseObjectData as NativeIntermediateObject).value;

    if (nativeObjectValue == null) return null;

    if (type == DateTime) {
      if (nativeObjectValue is DateTime) return nativeObjectValue;
      return DateTime.parse(nativeObjectValue);
    }
    if (_isTypeEnum(type)) {
      return _typeInformationRetriever.getEnumGeneratedMap(type)[
          nativeObjectValue];
    }

    if (type == double && nativeObjectValue != null) {
      return double.parse(nativeObjectValue.toString());
    }

    return nativeObjectValue;
  }

  bool _isTypeEnum(Type type) {
    return _typeInformationRetriever.containsEnumGeneratedMap(type);
  }
}
