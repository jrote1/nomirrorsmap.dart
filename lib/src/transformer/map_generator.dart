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

		var typeHelper = new TypeHelper(libraryImportNames);

		var resolvers = [new ListGenerator(_resolver, typeHelper),
		new EnumGenerator(typeHelper),
		new ClassGenerator(typeHelper)];

		do
		{
			for ( dynamic element in typesToRun.toList( ) )
			{
				if ( _isNotDartCoreType(element) && !seenTypes.contains( element ) && !(element.type.element is TypeParameterElementImpl) )
				{
					if(resolvers.any((r) => r.isApplicable(element))){
						typesToRun.addAll(resolvers.firstWhere((r) => r.isApplicable(element)).process(element, mapFileContent));
					}
				}
				seenTypes.add( element );
			}
		}
		while ( typesToRun.where( ( t ) => !seenTypes.contains( t ) ).length > 0 );

		mapFileContent.write( '''];
  }
}''' );

		return mapFileContent.toString( );
	}

	bool _isNotDartCoreType(dynamic element){
		return !(element.type.element.library.name.startsWith( 'dart.core' ) && _isPrimitiveTypeName( element.type.name ));
	}

	bool _isPrimitiveTypeName( String name )
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