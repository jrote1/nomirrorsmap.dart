part of nomirrorsmap.transformer;

class MapGenerator
{
	Resolver _resolver;
	DartType _mapType;

	MapGenerator( Resolver resolver )
	{
		_resolver = resolver;
		_mapType = resolver.getType( "nomirrorsmap.MapType" ).type;
	}

	List<Element> _typesToGenerate = [];

	void addTypes( List<Element> types )
	{
		_typesToGenerate.addAll( types.where( _shouldBeMapped ).toList( ) );
	}

	String _getFullTypeName( InterfaceType element )
	{
		if ( element.element.library.displayName == "" )
			return element.displayName;
		return "${element.element.library.displayName}.${element.displayName}";
	}

	String _getTypeString( dynamic element, Map<LibraryElement, String> libraryImportNames )
	{
		var result = "";
		if ( libraryImportNames.containsKey( element.type.element.library ) )
			result = "${libraryImportNames[element.type.element.library]}.${element.type}";
		else
			result = element.type.name;

		if ( element.type is TypeParameterTypeImpl || element.type is DynamicTypeImpl )
		{
			print( "Type parameter found: ${element.type}" );
			return result;
		}
		if ( element.type.typeArguments.length > 0 )
		{
			result += "<";
			result += element.type.typeArguments.map( ( a )
													  => _getTypeString( a.element, libraryImportNames ) ).join( "," );
			result += ">";
		}

		return result;

	}

	String _addTypeGetterToLibrary(LibraryElement library, dynamic element, Map<LibraryElement, String> libraryImportNames){
		var node = library.definingCompilationUnit.node;
		var transaction = _resolver.createTextEditTransaction( library );

		transaction.edit(node.endToken.end, node.endToken.end, "\nType get nomirrorsmap_${element.type.name}_type => ${_getTypeStringWithTypeOf(element, libraryImportNames)};");

		transaction.commit();
	}

	String _getTypeStringWithTypeOf( Element type, Map<LibraryElement, String> libraryImportNames )
	{
		var result = _getTypeString( type, libraryImportNames );
		if ( result.contains( "<" ) )
		{
			return "const nomirrorsmap.TypeOf<$result>().type";
		}
		return result;
	}

	void _addClassMap( ClassElement element, StringBuffer mapFileContent, Map<LibraryElement, String> libraryImportNames, List<Element> typeToRun )
	{
		mapFileContent.write( "new nomirrorsmap.ClassGeneratedMap(${_getTypeStringWithTypeOf(element, libraryImportNames)},\"${_getFullTypeName(element.type)}\", () => new ${_getTypeString(element, libraryImportNames)}(), {\n" );

		var currentElement = element;
		do {
			for (var field in currentElement.fields) {
				typeToRun.add(field);
				mapFileContent.write("'${field.displayName}': new nomirrorsmap.GeneratedPropertyMap( ${_getTypeStringWithTypeOf(field, libraryImportNames)}, (obj) => obj.${field.displayName}, (obj, value) => obj.${field.displayName} = value ),\n");
			}
			currentElement = currentElement.supertype.element;
		}
		while(currentElement != null && !currentElement.library.name.startsWith("dart.core"));
		mapFileContent.write( "}),\n" );
	}

	String buildMapFile( AssetId assetId )
	{
		var mapFileContent = new StringBuffer( );

		_appendHeader( mapFileContent, assetId );

		var libraryImportNames = _getLibraryImportNames( assetId );
		_appendLibraryImports( libraryImportNames, mapFileContent, assetId );

		mapFileContent.write( "\n" );

		mapFileContent.write( '''class NoMirrorsMapGeneratedMaps{
  static List load(){
    return [\n''' );
		List<Element> seenTypes = [];
		List<Element> typesToRun = _typesToGenerate.toList( );

		var listType = _resolver.getType( "dart.core.List" ).type;
		do
		{
			for ( dynamic element in typesToRun.toList( ) )
			{
				if ( !(element.type.element.library.name.startsWith( 'dart.core' ) && isPrimitiveTypeName( element.type.name )) && !seenTypes.contains( element ) && !(element.type.element is TypeParameterElementImpl) )
				{
					if ( listType == element.type.element.type || element.type.isSubtypeOf( listType ) )
						mapFileContent.write( "new nomirrorsmap.ListGeneratedMap( ${_getTypeStringWithTypeOf( element, libraryImportNames )}, ${_getTypeStringWithTypeOf( element.type.typeArguments.first.element, libraryImportNames )}, () => new ${_getTypeString( element, libraryImportNames )}() ),\n" );
					else if ( element.type.element.isEnum )
						mapFileContent.write( "new nomirrorsmap.EnumGeneratedMap( ${_getTypeStringWithTypeOf( element, libraryImportNames )}, ${_getTypeStringWithTypeOf( element, libraryImportNames )}.values ),\n" );
					else if ( !(element is FieldElementImpl) && element is ClassElement && !element.isAbstract )
						_addClassMap( element, mapFileContent, libraryImportNames, typesToRun );
				}
				seenTypes.add( element );
			}
		}
		while ( typesToRun.where( ( t )
								  => !seenTypes.contains( t ) ).length > 0 );

		mapFileContent.write( '''];
  }
}''' );

		return mapFileContent.toString( );
	}

	bool isPrimitiveTypeName( String name )
	{
		return name == "String" || name == "int" || name == "double" || name == "num" || name == "bool" || name == "int" ;
	}

	void _appendLibraryImports( Map<LibraryElement, String> libraryImportNames, StringBuffer mapFileContent, AssetId assetId )
	{
		libraryImportNames.forEach( ( library, importName )
									{
										var importPath = _resolver.getImportUri( library, from: assetId );
										mapFileContent.write( 'import "$importPath" as $importName;\n' );
									} );
	}

	Map<LibraryElement, String> _getLibraryImportNames( AssetId assetId )
	{
		List<LibraryElement> uniqueLibraries = [];
		_typesToGenerate.map( ( e )
							  => e.library ).forEach( ( e )
													  {
														  if ( !uniqueLibraries.contains( e ) )
															  uniqueLibraries.add( e );
													  } );

		Map<LibraryElement, String> libraryImportNames = {};
		uniqueLibraries.forEach( ( l )
								 {
									 var importAs = _resolver.getImportUri( l, from: assetId ).toString( ).replaceAll( ".", "_" ).replaceAll( "/", "_" ).replaceAll( "package:", "" );
									 if ( importAs == "" )
										 importAs = l.displayName;
									 libraryImportNames[l] = importAs;
								 } );
		return libraryImportNames;
	}

	bool _shouldBeMapped( ClassElement element )
	{
		if ( element.isEnum )
			return true;
		for ( var meta in element.metadata )
		{
			if ( meta.element is ConstructorElement )
			{
				DartType metaType = meta.element.enclosingElement.type;
				if ( metaType.isAssignableTo( _mapType ) )
				{
					if ( element.unnamedConstructor == null )
						throw "The type '${element.displayName}' has a @Map() annotation but no DefaultConstructor";
					return true;
				}
			}
		}
		return false;
	}

	void _appendHeader( StringBuffer stringBuffer, AssetId assetId )
	{
		stringBuffer.write( "library ${path.url.basenameWithoutExtension( assetId.path )}_nomirrorsmap_generated_maps;\n\n" );
		stringBuffer.write( "import 'package:nomirrorsmap/src/shared/shared.dart' as nomirrorsmap;\n" );
	}
}