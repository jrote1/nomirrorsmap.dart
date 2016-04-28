part of nomirrorsmap.transformer;

class _FieldsGenerator extends _Generator with _TypeInformationRetriever {
  @override
  String generate(_GeneratorParameters parameters) {
    var stringBuilder = new StringBuffer();
    stringBuilder.write('''\tstatic void _registerFields()
	{\n''');

    var fieldNames = parameters.typesToMap.where((type) => !type.isEnum).expand((type) => _getAllTypeFields(type, parameters)).map((field) => field.name).toList();

    var fields = TransformerHelpers.uniquifyList(fieldNames).toList();
    if (fields.length == 0) stringBuilder.writeln("");

    for (var field in fields) {
      stringBuilder.writeln('''\t\tNoMirrorsMapStore.registerField( "$field", ( object, value ) => object.$field = value, (object) => object.$field );''');
    }

    stringBuilder.writeln("\t}");
    return stringBuilder.toString();
  }
}
