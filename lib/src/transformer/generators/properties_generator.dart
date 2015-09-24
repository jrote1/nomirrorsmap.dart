part of nomirrorsmap.transformer;

class _PropertiesGenerator extends _Generator with _TypeInformationRetriever {
  @override
  String generate(_GeneratorParameters parameters) {
    var stringBuilder = new StringBuffer();
    stringBuilder.write('''static void _registerAccessors()
	{''');

    var propertyNames = parameters.typesToMap
        .where((type) => !type.isEnum && _typeHasConstructor(type))
        .expand((type) => _getAllTypeFields(type, parameters))
        .map((field) => field.name)
        .toList();

    for (var property in _uniqifyList(propertyNames)) {
      stringBuilder.writeln(
          '''NoMirrorsMapStore.registerAccessor( "$property", ( object, value ) => object.$property = value, (object) => object.$property );''');
    }

    stringBuilder.write("\t}");
    return stringBuilder.toString();
  }

  List<String> _uniqifyList(List<String> list) {
    var result = new List<String>();

    for (var element in list) if (!result.contains(element)) result.add(element);

    return result;
  }
}
