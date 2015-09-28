part of nomirrorsmap.transformer;

class _ClassGenerator extends _Generator with _TypeInformationRetriever {
  @override
  String generate(_GeneratorParameters parameters) {
    var stringBuilder = new StringBuffer();
    stringBuilder.write('''static void _registerClasses()
	{''');

    for (var type in parameters.typesToMap.where((type) => !type.isEnum)) {
      var fullTypeName = type.library.displayName;
      if (fullTypeName.length > 0) fullTypeName += ".";
      fullTypeName += type.displayName;

      var importedTypeName =
          _getImportTypeName(parameters.libraryImportAliases, type);

      var hasDefaultConstructor = _typeHasConstructor(type);
      var constructor =
          hasDefaultConstructor ? "() => new $importedTypeName()" : "null";

      stringBuilder.writeln(
          "NoMirrorsMapStore.registerClass( \"$fullTypeName\", $importedTypeName, const TypeOf<List<$importedTypeName>>().type, $constructor, {");

      _outputFields(type, parameters, stringBuilder);

      stringBuilder.writeln("} );");
    }

    stringBuilder.write("}");
    return stringBuilder.toString();
  }

  String _getImportTypeName(
      UnmodifiableMapView<LibraryElement, String> libraryImportAliases,
      ClassElement type) {
    if (libraryImportAliases
        .containsKey(type.library)) return libraryImportAliases[type.library] +
        "." +
        type.displayName;
    return type.displayName;
  }

  void _outputFields(Element type, _GeneratorParameters parameters,
      StringBuffer stringBuilder) {
    var fields = _getAllTypeFields(type, parameters).toList();
    for (var field in fields) {
      var typeText = field.typeText;
      if (typeText.contains("<")) typeText = "const TypeOf<$typeText>().type";

      stringBuilder.write("'${field.name}': $typeText");
      if (fields.last != field) stringBuilder.writeln(",");
    }
  }
}
