part of nomirrorsmap.transformer;

class _TypeInformationRetriever {
  Iterable<_Field> _getAllTypeFields(
      ClassElement type, _GeneratorParameters parameters) sync* {
    bool isObject(InterfaceType type) =>
        type == null || type.isObject || type.displayName == "Object";

    yield* _getOnlyAccessibleAndUsageFields(type.fields).map((field) {
      return new _Field()
        ..name = field.name
        ..typeText = field.type is TypeParameterTypeImpl
            ? "dynamic"
            : _getPropertyType(type.name, field.name, field.type, parameters);
    });

    for (var mixin in type.mixins)
      yield* _getAllTypeFields(mixin.element, parameters);

    if (!isObject(type.supertype)) {
      var typeArguments = <String, InterfaceType>{};
      for (var currentType = type.supertype;
          !isObject(currentType);
          currentType = currentType.element.supertype) {
        for (var i = 0; i < currentType.typeArguments.length; i++) {
          var typeArgument = currentType.typeArguments[i];
          if (typeArgument is TypeParameterType)
            typeArgument = typeArguments[typeArgument.displayName];
          typeArguments[currentType.typeParameters[i].displayName] =
              typeArgument;
        }

        var genericParameters = <TypeParameterElement, InterfaceType>{};
        if (currentType.typeArguments.length > 0) {
          for (var typeParameter in currentType.typeParameters) {
            genericParameters[typeParameter] =
                typeArguments[typeParameter.displayName];
          }
        }

        for (var field
            in _getOnlyAccessibleAndUsageFields(currentType.element.fields)) {
          var type = field.type;
          if (type is TypeParameterType) type = genericParameters[type.element];
          if (type is InterfaceTypeImpl) type = type;

          yield new _Field()
            ..name = field.name
            ..typeText = _getPropertyType(
                currentType.element.name, field.name, type, parameters);
        }
      }
    }
  }

  List<FieldElement> _getOnlyAccessibleAndUsageFields(
      List<FieldElement> fields) {
    return fields
        .where((field) =>
            field.setter != null && field.getter != null && field.isPublic)
        .toList();
  }

  String _getPropertyType(String containTypeName, String propertyName,
      InterfaceType type, _GeneratorParameters parameters) {
    try {
      return _getActualTypeText(type, parameters);
    } catch (ex) {
      throw "In the type '$containTypeName' for the property '$propertyName' of type '${type.name}', could not generate the type text";
    }
  }

  String _getActualTypeText(
      InterfaceType type, _GeneratorParameters parameters) {
    var typeName = type.name;
    if (parameters.libraryImportAliases.containsKey(type.element.library))
      typeName = parameters.libraryImportAliases[type.element.library] +
          "." +
          typeName;

    if (type.typeArguments.length > 0) {
      var genericPart = "<${type.typeArguments.map( ( typeArgument )
														  {
															  if ( typeArgument is DynamicTypeImpl )
																  return "dynamic";
															  return _getActualTypeText( typeArgument, parameters );
														  } ).join( "," )}>";
      if (genericPart != "<dynamic>") typeName += genericPart;
    }

    return typeName;
  }

  bool _typeHasConstructor(ClassElement type) {
    if (type.unnamedConstructor != null &&
        type.unnamedConstructor.parameters.length > 0 &&
        type.unnamedConstructor.parameters
            .every((p) => p.parameterKind.isOptional)) return true;
    return type.constructors
            .any((constructor) => constructor.parameters.length == 0) &&
        !type.isAbstract &&
        type.library.name != "dart.core";
  }
}
