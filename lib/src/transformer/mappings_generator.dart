part of nomirrorsmap.transformer;

class MappingsGenerator
{
	final Resolver _resolver;
	final AssetId _assetId;

	List<Element> _typesToMap = [];
	Map<LibraryElement, String> _libraryImportAliases = {};

	MappingsGenerator( this._resolver, this._assetId );

	void _addTypes( List<String> libraryNamesToInclude )
	{
		var allEnums = _resolver.libraries
			.expand( ( lib )
					 => lib.units )
			.expand( ( compilationUnit )
					 => compilationUnit.enums ).toList( );
		_typesToMap.addAll( allEnums.where( _shouldBeMapped ) );

		var allTypes = _resolver.libraries
			.expand( ( lib )
					 => lib.units )
			.expand( ( compilationUnit )
					 => compilationUnit.types ).toList( );
		_typesToMap.addAll( allTypes.where( _shouldBeMapped ) );

		for ( var libraryName in libraryNamesToInclude )
		{
			var library = _resolver.getLibraryByName( libraryName );
			if ( library == null )
				print( "nomirrorsmap: '$libraryName' was not found so will be ignored" );
			else
			{
				_typesToMap.addAll( library.units.expand( ( unit )
														  => unit.enums.where( ( enumeration )
																			   => enumeration.isPublic ) ) );
				_typesToMap.addAll( library.units.expand( ( unit )
														  => unit.types.where( ( type )
																			   => type.isPublic ) ) );
			}
		}

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
				if ( !type.isEnum && (type.unnamedConstructor == null || type.unnamedConstructor.parameters.length > 0) )
					throw "The type '${type.displayName}' has a @Mappable() annotation but no DefaultConstructor";
				return true;
			}
		}
		return false;
	}

	String generate( List<String> libraryNamesToInclude )
	{
		_addTypes( libraryNamesToInclude );
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
		stringBuilder.writeln( "library TestProject.Mappings;\n" );
		stringBuilder.writeln( "import 'package:nomirrorsmap/nomirrorsmap.dart';" );

		for ( var library in _libraryImportAliases.keys )
		{
			var importPath = _resolver.getImportUri( library, from: _assetId );
			stringBuilder.writeln( "import '$importPath' as ${_libraryImportAliases[library]};" );
		}

		return '''${stringBuilder.toString( )}
class TestProjectMappings
{
	static void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}''';
	}

	String _generateProperties( )
	{
		var stringBuilder = new StringBuffer( );
		stringBuilder.write( '''\tstatic void _registerAccessors()
	{\n''' );

		var propertyNames = _typesToMap
			.where( ( type )
					=> !type.isEnum )
			.expand( ( type )
					 => _getAllTypeFields( type ) )
			.map( ( field )
				  => field.name )
			.toList( );

		for ( var property in _uniqifyList( propertyNames ) )
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
		stringBuilder.write( '''\tstatic void _registerClasses()
	{\n''' );

		for ( var type in _typesToMap.where( ( type )
											 => !type.isEnum ) )
		{
			var fullTypeName = type.library.displayName;
			if ( fullTypeName.length > 0 ) fullTypeName += ".";
			fullTypeName += type.displayName;
			var importedTypeName = _libraryImportAliases[type.library] + "." + type.displayName;
			stringBuilder.writeln(
				"\t\tNoMirrorsMapStore.registerClass( \"$fullTypeName\", $importedTypeName, const TypeOf<List<$importedTypeName>>().type, () => new $importedTypeName(), {" );

			var fields = _getAllTypeFields( type ).toList( );
			for ( var field in fields )
			{
				var typeName = _getActualTypeText( field.type );
				if ( typeName.contains( "<" ) )
					typeName = "const TypeOf<$typeName>().type";
				stringBuilder.write( "\t\t\t'${field.name}': $typeName" );
				if ( fields.last != field )
					stringBuilder.writeln( "," );
				else
					stringBuilder.writeln( "" );
			}

			stringBuilder.writeln( "\t\t} );" );
		}

		stringBuilder.write( "\t}" );
		return stringBuilder.toString( );
	}

	Iterable<_Field> _getAllTypeFields( ClassElement type )
	sync*
	{
		bool isObject( InterfaceType type )
		=> type == null || type.isObject || type.displayName == "Object";

		yield* type.fields.map( ( field )
								{
									return new _Field( )
										..name = field.name
										..type = field.type;
								} );
		if ( !isObject( type.supertype ) )
		{
			for ( var currentType = type.supertype; !isObject( currentType ); currentType = currentType.element.supertype )
			{
				var genericParameters = <TypeParameterElement, InterfaceType>{};
				if ( currentType.typeArguments.length > 0 )
				{
					for ( var generic in currentType.typeArguments )
					{
						genericParameters[currentType.element.typeParameters[currentType.typeArguments.indexOf( generic )]] = generic;
					}
				}

				for ( var field in currentType.element.fields )
				{
					var type = field.type;
					if ( type is TypeParameterType )
						type = genericParameters[type.element];

					if ( type is InterfaceTypeImpl )
						type = type;

					yield new _Field( )
						..name = field.name
						..type = type;
				}
			}
		}
	}

	String _generateEnums( )
	{
		var stringBuilder = new StringBuffer( );
		stringBuilder.write( '''\tstatic void _registerEnums()
	{\n''' );

		for ( var type in _typesToMap.where( ( type )
											 => type.isEnum ) )
		{
			var importedTypeName = _libraryImportAliases[type.library] + "." + type.displayName;
			stringBuilder.writeln( "\t\tNoMirrorsMapStore.registerEnum( $importedTypeName, $importedTypeName.values );" );
		}

		stringBuilder.write( "\t}" );
		return stringBuilder.toString( );
	}

	String _generateClassBottom( )
	{
		return '''}''';
	}

	List<String> _uniqifyList( List<String> list )
	{
		var result = new List<String>( );

		for ( var element in list )
			if ( !result.contains( element ) )
				result.add( element );

		return result;
	}

	String _getActualTypeText( InterfaceType type )
	{
		var typeName = type.name;
		if ( _libraryImportAliases.containsKey( type.element.library ) )
			typeName = _libraryImportAliases[type.element.library] + "." + typeName;

		if ( type.typeArguments.length > 0 )
			typeName += "<${type.typeArguments.map( _getActualTypeText ).join( "," )}>";

		return typeName;
	}
}

class _Field
{
	String name;
	InterfaceType type;
}