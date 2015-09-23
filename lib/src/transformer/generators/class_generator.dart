part of nomirrorsmap.transformer;

class ClassGenerator extends _Generator with TypeInformationRetriever {
  @override
  String generate(_GeneratorParameters parameters) {
    var stringBuilder = new StringBuffer();
    stringBuilder.write('''static void _registerClasses()
	{''');

    for (var type in parameters.typesToMap.where((type) => !type.isEnum)) {
      var fullTypeName = type.library.displayName;
      if (fullTypeName.length > 0) fullTypeName += ".";
      fullTypeName += type.displayName;

      var importedTypeName = type.displayName;
      if (parameters.libraryImportAliases.containsKey(type.library)) importedTypeName =
          parameters.libraryImportAliases[type.library] + "." + type.displayName;

      var hasDefaultConstructor = _typeHasConstructor(type);
      var constructor = hasDefaultConstructor ? "() => new $importedTypeName()" : "null";

      stringBuilder.writeln(
          "NoMirrorsMapStore.registerClass( \"$fullTypeName\", $importedTypeName, const TypeOf<List<$importedTypeName>>().type, $constructor, {");

      if (hasDefaultConstructor) {
        var fields = _getAllTypeFields(type, parameters).toList();
        for (var field in fields) {
          var typeText = field.typeText;
          if (typeText.contains("<")) typeText = "const TypeOf<$typeText>().type";
          stringBuilder.write("'${field.name}': $typeText");
          if (fields.last != field) stringBuilder.writeln(",");
          else stringBuilder.writeln("");
        }
      }

      stringBuilder.writeln("} );");
    }

    stringBuilder.write("}");
    return stringBuilder.toString();
  }
}
