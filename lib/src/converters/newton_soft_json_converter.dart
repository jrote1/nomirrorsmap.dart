part of nomirrorsmap.converters;

class NewtonSoftJsonConverter extends JsonConverter {
  Map<String, Type> fromJsonHashCodesAndTypes = new Map<String, Type>();
  List<String> toJsonSeenHashcodes = new List<String>();

  NewtonSoftJsonConverter({bool includeMetadata: true})
      : super(includeMetadata: includeMetadata) {}

  TypeInformationRetriever get _typeInformationRetriever =>
      TypeInformationRetrieverLocator.instance;

  @override
  void setMetaData(
      StringBuffer stringBuffer, ClassIntermediateObject classObjectData) {
    if (toJsonSeenHashcodes.contains(classObjectData.previousHashCode)) {
      stringBuffer.write("\"\$ref\":\"${classObjectData.previousHashCode}\"");
      stringBuffer.write(classObjectData.properties.length > 0 ? "," : "");
    } else {
      toJsonSeenHashcodes.add(classObjectData.previousHashCode);
      stringBuffer.write("\"\$id\":\"${classObjectData.previousHashCode}\",");
      setTypeFromObjectType(stringBuffer, classObjectData);
    }
  }

  @override
  String getPreviousHashcode(Map json) {
    if (json.containsKey("\$ref")) return json["\$ref"];

    return json["\$id"];
  }

  @override
  Type findObjectType(dynamic json) {
    Type objectType = null;

    if (json.containsKey("\$type")) {
      var typeString = json["\$type"].toString().split(",")[0];
      objectType = _typeInformationRetriever
          .getClassGeneratedMapByQualifiedName(typeString)
          .type;
    } else {
      if (!json.containsKey("\$type") &&
          fromJsonHashCodesAndTypes.containsKey(json["\$ref"]))
        objectType = fromJsonHashCodesAndTypes[json["\$ref"]];
    }

    return objectType;
  }

  @override
  void afterCreatingClassObjectData(ClassIntermediateObject classObjectData) {
    if (!fromJsonHashCodesAndTypes
            .containsKey(classObjectData.previousHashCode) &&
        classObjectData.objectType != null)
      fromJsonHashCodesAndTypes[classObjectData.previousHashCode] =
          classObjectData.objectType;
  }
}
