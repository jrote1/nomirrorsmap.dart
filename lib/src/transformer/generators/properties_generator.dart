part of nomirrorsmap.transformer;

class _FieldsGenerator extends _Generator with _TypeInformationRetriever {
  @override
  String generate(_GeneratorParameters parameters) {
    var stringBuilder = new StringBuffer();
    stringBuilder.write('''static void _registerFields()
	{''');

    var fieldNames = parameters.typesToMap
        .where((type) => !type.isEnum && _typeHasConstructor(type))
        .expand((type) => _getAllTypeFields(type, parameters))
        .map((field) => field.name)
        .toList();

    for (var field in _uniquifyList(fieldNames)) {
      stringBuilder
          .writeln('''NoMirrorsMapStore.registerField( "$field", ( object, value ) => object.$field = value, (object) => object.$field );''');
    }

    stringBuilder.write("\t}");
    return stringBuilder.toString();
  }

  List<String> _uniquifyList(List<String> list) {
    var result = new List<String>();

    for (var element in list) if (!result.contains(element)) result.add(element);

    return result;
  }
}
