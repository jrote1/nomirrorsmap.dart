part of nomirrorsmap.converters;

class JsonConverter implements Converter {
  String _hashcodeName;
  bool _includeMetadata;

  TypeInformationRetriever get _typeInformationRetriever =>
      TypeInformationRetrieverLocator.instance;

  JsonConverter(
      {String hashcodeName: "\$hashcode", bool includeMetadata: true}) {
    _hashcodeName = hashcodeName;
    _includeMetadata = includeMetadata;
  }

  BaseIntermediateObject toBaseIntermediateObject(dynamic value) {
    if (!(value is String)) throw new Exception("value is not a String");
    var json = JSON.decode(value);
    return _jsonToBaseObjectData(json);
  }

  String getPreviousHashcode(Map json) => json[_hashcodeName];

  Type findObjectType(dynamic json) {
    return json.containsKey("\$type")
        ? _typeInformationRetriever
            .getClassGeneratedMapByQualifiedName(json["\$type"])
            .type
        : null;
  }

  void afterCreatingClassObjectData(ClassIntermediateObject classObjectData) {}

  BaseIntermediateObject _jsonToBaseObjectData(dynamic json) {
    if (json is Map) {
      var classObjectData = new ClassIntermediateObject();
      classObjectData.previousHashCode = getPreviousHashcode(json);
      classObjectData.objectType = findObjectType(json);

      afterCreatingClassObjectData(classObjectData);
      Map<String, BaseIntermediateObject> properties = {};
      (json as Map).forEach((key, value) {
        properties[key] = _jsonToBaseObjectData(value);
      });

      classObjectData.properties = properties;

      return classObjectData;
    } else if (json is List)
      return new ListIntermediateObject()
        ..values = json.map((o) => _jsonToBaseObjectData(o)).toList();
    return new NativeIntermediateObject()..value = json;
  }

  dynamic fromBaseIntermediateObject(BaseIntermediateObject baseObjectData) {
    var stringBuffer = new StringBuffer();
    _fromBaseObjectData(baseObjectData, stringBuffer);
    return stringBuffer.toString();
  }

  void setMetaData(
      StringBuffer stringBuffer, ClassIntermediateObject classObjectData) {
    stringBuffer
        .write("\"$_hashcodeName\":\"${classObjectData.previousHashCode}\",");

    setTypeFromObjectType(stringBuffer, classObjectData);
  }

  void setTypeFromObjectType(
      StringBuffer stringBuffer, ClassIntermediateObject classObjectData) {
    var map = classObjectData.objectType == null
        ? null
        : _typeInformationRetriever
            .getClassGeneratedMapWithNoCheck(classObjectData.objectType);
    if (map != null) {
      stringBuffer.write("\"\$type\":\"${map.fullName}\"");
      stringBuffer.write(classObjectData.properties.length > 0 ? "," : "");
    }
  }

  void _fromBaseObjectData(
      BaseIntermediateObject baseObjectData, StringBuffer stringBuffer) {
    if (baseObjectData is ClassIntermediateObject) {
      stringBuffer.write("{");

      if (_includeMetadata) setMetaData(stringBuffer, baseObjectData);

      var lastKey = baseObjectData.properties.keys.length > 0 ? baseObjectData.properties.keys.last : null;
      baseObjectData.properties.forEach((key,value){
        stringBuffer.write("\"$key\":");
        _fromBaseObjectData(value, stringBuffer);
        if (lastKey != key) stringBuffer.write(",");
      });

      stringBuffer.write("}");
    }
    if (baseObjectData is ListIntermediateObject) {
      stringBuffer.write("[");
      var lastIndex = baseObjectData.values.length - 1;
      for (var i = 0; i < baseObjectData.values.length; i++) {
        var value = baseObjectData.values[i];
        _fromBaseObjectData(value, stringBuffer);
        if (i != lastIndex) stringBuffer.write(",");
      }
      stringBuffer.write("]");
    }

    if (baseObjectData is NativeIntermediateObject) {
      if (baseObjectData.value is String)
        stringBuffer.write("\"" +
            baseObjectData.value
                .replaceAll(r"\", r'\\')
                .replaceAll("\"", '\\"') +
            "\"");
      else if (baseObjectData.value is DateTime)
        stringBuffer.write('"${baseObjectData.value.toString()}"');
      else
        stringBuffer.write(baseObjectData.value);
    }
  }
}
