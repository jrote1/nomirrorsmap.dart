part of nomirrorsmap.transformer;

class MappingsGenerator
{
	final Resolver _resolver;
	final AssetId _assetId;

	List<Element> _typesToMap = [];
	Map<LibraryElement, String> _libraryImportAliases = {};

	MappingsGenerator( this._resolver, this._assetId );

	void _addTypes( )
	{
		var allTypes = _resolver.libraries
			.expand( ( lib )
					 => lib.units )
			.expand( ( compilationUnit )
					 => compilationUnit.types ).toList( );


		_typesToMap.addAll( allTypes.where( _shouldBeMapped ) );

		_generateLibraryAliases( );
	}

	void _generateLibraryAliases( )
	{
		for ( var type in _typesToMap )
		{
			if ( !_libraryImportAliases.containsKey( type.library ) )
			{
				var libraryFullPath = type.library.definingCompilationUnit.source.assetId.path as String;
				var libraryImportAlias = libraryFullPath
					.replaceAll( "/", "_" )
					.replaceAll( ".", "_" )
					.replaceAll( ":", "_" );
				_libraryImportAliases[ type.library ] = libraryImportAlias;
			}
		}
	}

	bool _shouldBeMapped( ClassElement type )
	{
		var mappableMetadataType = _resolver.getType( "nomirrorsmap.Mappable" );
		if ( mappableMetadataType == null )
			return false;

		var metadata = type.metadata
			.map( ( meta )
				  => meta.element )
			.where( ( element )
					=> element is ConstructorElement );

		for ( ConstructorElement meta in metadata )
		{
			DartType metaType = meta.enclosingElement.type;
			if ( metaType.isAssignableTo( mappableMetadataType.type ) )
			{
				if ( type.unnamedConstructor == null || type.unnamedConstructor.parameters.length > 0 )
					throw "The type '${type.displayName}' has a @Mappable() annotation but no DefaultConstructor";
				return true;
			}
		}
		return false;
	}

	String generate( )
	{
		_addTypes( );
		var output = _generateClassTop( );
		output += "\n\n";
		output += _generateProperties( );
		output += "\n\n";
		output += _generateClasses( );
		output += "\n\n";
		output += _generateEnums( );
		output += "\n";
		output += _generateClassBottom( );
		return output;
	}

	String _generateClassTop( )
	{
		var stringBuilder = new StringBuffer( );
		stringBuilder.writeln( "import 'package:nomirrorsmap/src/transformer.dart';" );

		for ( var library in _libraryImportAliases.keys )
		{
			var importPath = _resolver.getImportUri( library, from: _assetId );
			stringBuilder.writeln( "import '$importPath' as ${_libraryImportAliases[library]};" );
		}

		return '''${stringBuilder.toString( )}
class TestProjectMappings
{
	void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}''';
	}

	String _generateProperties( )
	{
		var stringBuilder = new StringBuffer( );
		stringBuilder.write( '''\tvoid _registerAccessors()
	{\n''' );

		var propertyNames = _typesToMap
			.expand( ( type )
					 => type.fields )
			.map( ( field )
				  => field.name )
			.toList( );
		_uniqifyList( propertyNames );

		for ( var property in propertyNames )
		{
			stringBuilder.writeln(
				'''\t\tNoMirrorsMapStore.registerAccessor( "$property", ( object, value ) => object.$property = value, (object) => object.$property );''' );
		}

		stringBuilder.write( "\t}" );
		return stringBuilder.toString( );
	}

	String _generateClasses( )
	{
		var stringBuilder = new StringBuffer( );
		stringBuilder.write( '''\tvoid _registerClasses()
	{\n''' );

		for ( var type in _typesToMap )
		{
			var fullTypeName = type.library.displayName;
			if ( fullTypeName.length > 0 ) fullTypeName += ".";
			fullTypeName += type.displayName;
			var importedTypeName = _libraryImportAliases[type.library] + "." + type.displayName;
			stringBuilder.writeln(
				"\t\tNoMirrorsMapStore.registerClass( \"$fullTypeName\", $importedTypeName, () => new $importedTypeName(), const {" );

			for ( var field in type.fields )
			{
				var typeName = field.type.name;
				if ( _libraryImportAliases.containsKey( field.type.element.library ) )
					typeName = _libraryImportAliases[field.type.element.library] + "." + typeName;
				stringBuilder.write( "\t\t\t'${field.name}': $typeName" );
				if ( type.fields.last != field )
					stringBuilder.writeln( "," );
				else
					stringBuilder.writeln( "" );
			}

			stringBuilder.writeln( "\t\t} );" );
		}

		stringBuilder.write( "\t}" );
		return stringBuilder.toString( );
	}

	String _generateEnums( )
	{
		return '''\tvoid _registerEnums()
	{
	}''';
	}

	String _generateClassBottom( )
	{
		return '''}''';
	}

	void _uniqifyList( List<dynamic> list )
	{
		for ( int i = 0; i < list.length; i++ )
		{
			dynamic o = list[i];
			int index;
			do
			{
				index = list.indexOf( o, i + 1 );
				if ( index != -1 )
				{
					list.removeRange( index, 1 );
				}
			} while ( index != -1 );
		}
	}
}