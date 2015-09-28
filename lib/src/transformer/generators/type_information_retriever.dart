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
            : _getActualTypeText(field.type, parameters);
    });

    if (!isObject(type.supertype)) {
      for (var currentType = type.supertype;
          !isObject(currentType);
          currentType = currentType.element.supertype) {
        var genericParameters = <TypeParameterElement, InterfaceType>{};
        if (currentType.typeArguments.length > 0) {
          for (var generic in currentType.typeArguments) {
            genericParameters[currentType.element.typeParameters[
                currentType.typeArguments.indexOf(generic)]] = generic;
          }
        }

        for (var field
            in _getOnlyAccessibleAndUsageFields(currentType.element.fields)) {
          var type = field.type;
          if (type is TypeParameterType) type = genericParameters[type.element];
          if (type is InterfaceTypeImpl) type = type;

          yield new _Field()
            ..name = field.name
            ..typeText = _getActualTypeText(type, parameters);
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

  String _getActualTypeText(
      InterfaceType type, _GeneratorParameters parameters) {
    var typeName = type.name;
    if (parameters.libraryImportAliases
        .containsKey(type.element.library)) typeName =
        parameters.libraryImportAliases[type.element.library] + "." + typeName;

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
    return type.constructors
            .any((constructor) => constructor.parameters.length == 0) &&
        !type.isAbstract;
  }
}
