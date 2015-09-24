part of nomirrorsmap.transformer;

class _ClassTopGenerator implements _Generator {
  final Resolver _resolver;

  _ClassTopGenerator(this._resolver);

  @override
  String generate(_GeneratorParameters parameters) {
    var stringBuilder = new StringBuffer();
    stringBuilder.writeln("library ${parameters.mappingsClassName};");
    stringBuilder.writeln("import 'package:nomirrorsmap/nomirrorsmap.dart';");

    for (var library in parameters.libraryImportAliases.keys) {
      var importPath = _resolver.getImportUri(library, from: parameters.assetId);
      stringBuilder.writeln("import '$importPath' as ${parameters.libraryImportAliases[library]};");
    }

    return '''${stringBuilder.toString( )}
class ${parameters.mappingsClassName}
{
	static void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}''';
  }
}
