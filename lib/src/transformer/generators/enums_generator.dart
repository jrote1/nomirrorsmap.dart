part of nomirrorsmap.transformer;

class EnumsGenerator implements _Generator {
  @override
  String generate(_GeneratorParameters parameters) {
    var stringBuilder = new StringBuffer();
    stringBuilder.write('''static void _registerEnums()
	{''');

    for (var type in parameters.typesToMap.where((type) => type.isEnum)) {
      var importedTypeName = parameters.libraryImportAliases[type.library] + "." + type.displayName;
      stringBuilder.writeln("NoMirrorsMapStore.registerEnum( $importedTypeName, $importedTypeName.values );");
    }

    stringBuilder.write("}");
    return stringBuilder.toString();
  }
}
