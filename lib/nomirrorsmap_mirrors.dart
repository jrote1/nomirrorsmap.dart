library nomirrorsmap.mirrors;

import 'src/converters/converters.dart';
import 'package:reflective/reflective.dart' as reflective;

void useMirrors() {
  TypeInformationRetrieverLocator
      .setInstance(new MirrorsTypeInformationRetriever());
}

class MirrorsTypeInformationRetriever implements TypeInformationRetriever {
  @override
  bool containsEnumGeneratedMap(Type type) {
    return new reflective.TypeReflection(type).isEnum;
  }

  @override
  ClassMapping getClassGeneratedMap(Type type) {
    var result = new ClassMapping()..fields = [];
    reflective.TypeReflection reflectiveType = reflective.type(type);
    for (var fieldName in reflectiveType.fields.keys) {
      var field = reflectiveType.field(fieldName);
      if (field.isConst) continue;

      var fieldMapping = new FieldMapping()
        ..name = field.name
        ..setter = field.set
        ..getter = field.value;

      result.fields.add(new ClassField()
        ..type = field.type.rawType
        ..fieldMapping = fieldMapping);
    }
    result.type = type;
    result.fullName = reflectiveType.fullName;
    result.instantiate = () => reflectiveType.construct();

    return result;
  }

  @override
  ClassMapping getClassGeneratedMapByListType(Type type) {
    var classType =
        new reflective.TypeReflection(type).typeArguments.first.rawType;
    return getClassGeneratedMap(classType);
  }

  @override
  ClassMapping getClassGeneratedMapByQualifiedName(String qualifiedName) {
    var classType =
        new reflective.TypeReflection.fromFullName(qualifiedName).rawType;
    return getClassGeneratedMap(classType);
  }

  @override
  ClassMapping getClassGeneratedMapWithNoCheck(Type type) {
    return getClassGeneratedMap(type);
  }

  @override
  List getEnumGeneratedMap(Type type) {
    return new reflective.TypeReflection(type).enumValues;
  }
}
