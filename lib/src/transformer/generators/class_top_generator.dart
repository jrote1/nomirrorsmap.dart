part of nomirrorsmap.transformer;

class _ClassTopGenerator implements _Generator {
  final Resolver _resolver;

  _ClassTopGenerator(this._resolver);

  @override
  String generate(_GeneratorParameters parameters) {
    var stringBuilder = new StringBuffer();
    stringBuilder.writeln("library ${parameters.mappingsClassName};");
    stringBuilder.writeln();
    stringBuilder.writeln("import 'package:nomirrorsmap/nomirrorsmap.dart';");

    var libraries = parameters.libraryImportAliases.keys;
    if (libraries.length == 0) stringBuilder.writeln();

    for (var library in libraries) {
      var importPath =
          _resolver.getImportUri(library, from: parameters.assetId);
      stringBuilder.writeln(
          "import '$importPath' as ${parameters.libraryImportAliases[library]};");
    }

    return '''${stringBuilder.toString( )}class ${parameters.mappingsClassName}
{
	static void register( )
	{
		_registerFields( );
		_registerClasses( );
		_registerEnums( );
	}\n''';
  }
}
