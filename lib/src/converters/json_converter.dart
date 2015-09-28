part of nomirrorsmap.converters;

class JsonConverter implements Converter {
  String _hashcodeName;

  JsonConverter([String hashcodeName = "\$hashcode"]) {
    _hashcodeName = hashcodeName;
  }

  BaseIntermediateObject toBaseIntermediateObject(dynamic value) {
    if (!(value is String)) throw new Exception("value is not a String");
    var json = JSON.decode(value);
    return _jsonToBaseObjectData(json);
  }

  String getPreviousHashcode(Map json) => json[_hashcodeName];

  Type findObjectType(dynamic json) {
    return json.containsKey("\$type") ? NoMirrorsMapStore.getClassGeneratedMapByQualifiedName(json["\$type"]).type : null;
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
    } else if (json is List) return new ListIntermediateObject()..values = json.map((o) => _jsonToBaseObjectData(o)).toList();
    return new NativeIntermediateObject()..value = json;
  }

  dynamic fromBaseIntermediateObject(BaseIntermediateObject baseObjectData) {
    var stringBuffer = new StringBuffer();
    _fromBaseObjectData(baseObjectData, stringBuffer);
    return stringBuffer.toString();
  }

  void setMetaData(StringBuffer stringBuffer, ClassIntermediateObject classObjectData) {
    stringBuffer.write("\"$_hashcodeName\":\"${classObjectData.previousHashCode}\",");

    setTypeFromObjectType(stringBuffer, classObjectData);
  }

  void setTypeFromObjectType(StringBuffer stringBuffer, ClassIntermediateObject classObjectData) {
    var map = NoMirrorsMapStore.getClassGeneratedMapWithNoCheck(classObjectData.objectType);
    if (map != null) {
      stringBuffer.write("\"\$type\":\"${map.fullName}\",");
    }
  }

  void _fromBaseObjectData(BaseIntermediateObject baseObjectData, StringBuffer stringBuffer) {
    if (baseObjectData is ClassIntermediateObject) {
      stringBuffer.write("{");

      setMetaData(stringBuffer, baseObjectData);

      for (var key in baseObjectData.properties.keys) {
        stringBuffer.write("\"$key\":");
        _fromBaseObjectData(baseObjectData.properties[key], stringBuffer);
        if (baseObjectData.properties.keys.last != key) stringBuffer.write(",");
      }

      stringBuffer.write("}");
    }
    if (baseObjectData is ListIntermediateObject) {
      stringBuffer.write("[");
      for (var i = 0; i < baseObjectData.values.length; i++) {
        var value = baseObjectData.values[i];
        _fromBaseObjectData(value, stringBuffer);
        if (i != (baseObjectData.values.length - 1)) stringBuffer.write(",");
      }
      stringBuffer.write("]");
    }

    if (baseObjectData is NativeIntermediateObject) {
      if (baseObjectData.value is String) stringBuffer.write("\"" + baseObjectData.value.replaceAll(r"\", r'\\').replaceAll("\"", '\\"') + "\"");
      else stringBuffer.write(baseObjectData.value);
    }
    /*
		if ( baseObjectData is ClassObjectData )
		{
			var result = {
			};
			setMetaData( result, baseObjectData.previousHashCode, baseObjectData );
			baseObjectData.properties.forEach( ( name, value )
											   {
												   result[name] = _fromBaseObjectData( value );
											   } );
			return result;
		}
		if ( baseObjectData is ListObjectData )
		{
			return baseObjectData.values.map( ( v )
											  => _fromBaseObjectData( v ) ).toList( );
		}
		return (baseObjectData as NativeObjectData).value;
		*/
  }
}
