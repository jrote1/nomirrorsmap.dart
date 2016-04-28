part of nomirrorsmap.transformer;

class _EnumsGenerator implements _Generator {
  @override
  String generate(_GeneratorParameters parameters) {
    var stringBuilder = new StringBuffer();
    stringBuilder.write('''\tstatic void _registerEnums()
	{\n''');

    var enums = parameters.typesToMap.where((type) => type.isEnum).toList();
    if (enums.length == 0) stringBuilder.writeln("");

    for (var type in enums) {
      var importedTypeName = parameters.libraryImportAliases[type.library] + "." + type.displayName;
      stringBuilder.writeln("\t\tNoMirrorsMapStore.registerEnum( $importedTypeName, $importedTypeName.values );");
    }

    stringBuilder.writeln("\t}");
    return stringBuilder.toString();
  }
}
