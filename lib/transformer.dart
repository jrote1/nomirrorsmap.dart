import 'package:barback/barback.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:code_transformers/resolver.dart';
import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import 'dart:async';
import 'dart:math';

class MainTransformer implements TransformerGroup
{
	final Iterable<Iterable> phases;

	MainTransformer( )
	: phases = _createPhases( );

	MainTransformer.asPlugin( ): phases = _createPhases( );

	static _createPhases( )
	{
		var resolvers = new Resolvers( dartSdkDirectory );
		return [[new MapGeneratorTransformer( resolvers )]];
	}
}

class MapGeneratorTransformer extends Transformer with ResolverTransformer
{
	MapGeneratorTransformer( Resolvers resolvers )
	{
		this.resolvers = resolvers;
	}

	Future<bool> shouldApplyResolver( Asset asset )
	=> new Future.value( true );

	void applyResolver( Transform transform, Resolver resolver )
	{
		if ( resolver.getType( "nomirrorsmap.MapType" ) != null )
		{
			var id = transform.primaryInput.id;
			var outputPath = path.url.join( path.url.dirname( id.path ), "${path.url.basenameWithoutExtension( id.path )}_nomirrorsmap_generated_maps.dart" );
			var generatedAssetId = new AssetId( id.package, outputPath );

			var mapFile = (new MapGenerator( resolver )
				..addTypes( resolver.libraries
							.expand( ( lib )
									 => lib.units )
							.expand( ( compilationUnit )
									 => compilationUnit.types ).toList( ) ))
			.buildMapFile( generatedAssetId );


			transform.addOutput(
				new Asset.fromString( generatedAssetId, mapFile ) );

			_editMain( transform, resolver );
		}
	}

	void _editMain( Transform transform, Resolver resolver )
	{
		AssetId id = transform.primaryInput.id;
		var lib = resolver.getLibrary( id );
		var unit = lib.definingCompilationUnit.node;
		var transaction = resolver.createTextEditTransaction( lib );

		var imports = unit.directives.where( ( d )
											 => d is ImportDirective );
		transaction.edit( imports.last.end, imports.last.end, '\nimport '
		"'${path.url.basenameWithoutExtension( id.path )}"
		"_nomirrorsmap_generated_maps.dart' show NoMirrorsMapGeneratedMaps;\n"
		"import 'package:nomirrorsmap/src/shared/shared.dart' as nomirrorsmap;\n" );

		FunctionExpression main = unit.declarations.where( ( d )
														   =>
														   d is FunctionDeclaration && d.name.toString( ) == 'main' )
		.first.functionExpression;
		var body = main.body;
		if ( body is BlockFunctionBody )
		{
			var location = body.beginToken.end;
			transaction.edit( location, location, '\n  nomirrorsmap.GeneratedMapProvider.addMaps(NoMirrorsMapGeneratedMaps.load());' );
		} else if ( body is ExpressionFunctionBody )
		{
			transaction.edit( body.beginToken.offset, body.endToken.end,
							  "{\n  nomirrorsmap.GeneratedMapProvider.addMaps(NoMirrorsMapGeneratedMaps.load());\n"
							  "  return ${body.expression};\n}" );
		}
		// EmptyFunctionBody can only appear as abstract methods and constructors.

		var printer = transaction.commit( );
		var url = id.path.startsWith( 'lib/' ) ?
		'package:${id.package}/${id.path.substring( 4 )}' : id.path;
		printer.build( url );
		transform.addOutput( new Asset.fromString( id, printer.text ) );
	}
}

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
		_typesToGenerate.addAll( _uniqueClassElements(
			types.where( _shouldBeMapped )
			.where( ( e )
					=> e is ClassElement ).toList( ) ) );

	}

	List<ClassElement> _uniqueClassElements( List<ClassElement> elements )
	{
		List<ClassElement> result = [];
		for ( var element in elements )
		{
			if ( !result.contains( element ) )
				result.add( element );
		}
		return result;
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

	String _getTypeStringWithTypeOf( Element type, Map<LibraryElement, String> libraryImportNames )
	{
		var result = _getTypeString( type, libraryImportNames );
		if ( result.contains( "<" ) )
		{
			return "const nomirrorsmap.TypeOf<$result>().type";
		}
		return result;
	}

	void _addClassMap( ClassElement type, StringBuffer mapFileContent, Map<LibraryElement, String> libraryImportNames, List<Element> noticedTypes )
	{
		mapFileContent.write( "new nomirrorsmap.ClassGeneratedMap(${_getTypeStringWithTypeOf(type, libraryImportNames)},\"${_getFullTypeName(type.type)}\", () => new ${_getTypeString(type, libraryImportNames)}(), {\n" );

		var currentElement = type;
		do {
			for (var field in currentElement.fields) {
				noticedTypes.add(field);
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
		return name == "String" || name == "int";
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