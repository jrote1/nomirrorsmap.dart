import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import 'dart:async';
import 'dart:math';

class MainTransformer implements TransformerGroup{
  final Iterable<Iterable> phases;
  
  MainTransformer()
        : phases = _createPhases();

  MainTransformer.asPlugin(): phases = _createPhases();
  
  static _createPhases(){
    var resolvers = new Resolvers(dartSdkDirectory);
      return [[new MapGeneratorTransformer(resolvers)]];
  }
}

class MapGeneratorTransformer extends Transformer with ResolverTransformer
{
	MapGeneratorTransformer(Resolvers resolvers){
		this.resolvers = resolvers;
	}

	Future<bool> shouldApplyResolver( Asset asset ) => new Future.value(true);

	void applyResolver( Transform transform, Resolver resolver )
	{
		var mapFile = (new MapGenerator( resolver )
			..addTypes( resolver.libraries
						.expand((lib) => lib.units)
						.expand((compilationUnit) => compilationUnit.types).toList() ))
			.buildMapFile();
		
		var id = transform.primaryInput.id;
    var outputPath = path.url.join(path.url.dirname(id.path), "nomirrorsmap_generated_maps.dart");
    print(outputPath);
    var generatedAssetId = new AssetId(id.package, outputPath);

		transform.addOutput(
			new Asset.fromString(generatedAssetId, mapFile));
	}

	void _editMain(){
	  
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
	  types.addAll(types
        .where( ( e )
                    => e is ClassElement )
                 .expand((ClassElement e)=>e.fields.map((f)=>f.type.element)).where( ( e )
                     => e is ClassElement ).toList());
	  _typesToGenerate.addAll( _uniqueClassElements( 
                 types.where( _shouldBeMapped )
                 .where((e) => !_getFullTypeName(e.type).startsWith("dart.core."))
                 .where( ( e )
                             => e is ClassElement ).toList() ) );

	}
	
	List<ClassElement> _uniqueClassElements(List<ClassElement> elements){
	  List<ClassElement> result = [];
	  for(var element in elements){
	    if(!result.contains(element))
	      result.add(element);
	  }
	  return result;
	}
	
	String _getPropertyType(InterfaceType type, Map<LibraryElement, String> libraryImportNames){
	  if(libraryImportNames.containsKey(type.element.library))
	     return "${libraryImportNames[type.element.library]}.${type.displayName}";
	  return type.displayName;
	}

	void _addType( List<Element> seenTypes, ClassElement type, StringBuffer mapFileContent, Map<LibraryElement,String> libraryImportNames, List<DartType> noticedTypes )
	{
		seenTypes.add( type );
		mapFileContent.write( "new ClassGeneratedMap(${libraryImportNames[type.library]}.${type.displayName},\"${_getFullTypeName( type.type )}\", () => new ${libraryImportNames[type.library]}.${type.displayName}(), {\n" );
		for ( var field in type.fields )
		{
			noticedTypes.add( field.type );
			mapFileContent.write( "'${field.displayName}': new GeneratedPropertyMap( ${_getPropertyType(field.type, libraryImportNames)}, (obj) => obj.${field.displayName}, (obj, value) => obj.${field.displayName} = value ),\n" );
		}
		mapFileContent.write( "}),\n" );
	}

	String buildMapFile(){
		var mapFileContent = new StringBuffer();

		var libraryImportNames = _getLibraryImportNames();
		_appendLibraryImports(libraryImportNames, mapFileContent);

		mapFileContent.write("\n");

		mapFileContent.write('''class NoMirrorsMapGeneratedMaps{
  static List load(){
    return [\n''');
		List<Element> seenTypes = [];
		List<InterfaceType> noticedTypes = [];

		for(ClassElement type in _typesToGenerate){
		  if(type.type.element.type == _resolver.getType( "dart.core.List" ).type || type.type.isAssignableTo(_resolver.getType( "dart.core.List" ).type)){
		    mapFileContent.write("new ListGeneratedMap(const TypeOf<${_getListType(type.type)}>().type, String, () => new ${_getListType(type.type)}()),");
		  }else if(type.isEnum){
		    mapFileContent.write("new EnumGeneratedMap( ${libraryImportNames[type.library]}.${type.displayName}, ${libraryImportNames[type.library]}.${type.displayName}.values ),\n");
		  }else{
		    _addType( seenTypes, type, mapFileContent, libraryImportNames, noticedTypes );
		  }
		}

		for(InterfaceType type in noticedTypes.toList()){
		  if(type.element.type == _resolver.getType( "dart.core.List" ).type || type.isAssignableTo(_resolver.getType( "dart.core.List" ).type)){
		    mapFileContent.write("new ListGeneratedMap(const TypeOf<${_getListType(type)}>().type, String, () => new ${_getListType(type)}()),");
		  }
		}

		mapFileContent.write('''];
  }
}''');
		
		return mapFileContent.toString();
	}
	
	String _getListType(InterfaceType type){
	  return "${type.name}<${type.typeArguments.first.name}>";
	}

	String _getFullTypeName(InterfaceType element){
		if(element.element.library.displayName == "")
			return element.displayName;
		return "${element.element.library.displayName}.${element.displayName}";
	}

	void _appendLibraryImports( Map<LibraryElement, String> libraryImportNames, StringBuffer mapFileContent )
	{
		libraryImportNames.forEach((library, importName){
			var importPath = _resolver.getImportUri( library );
			mapFileContent.write( 'import "$importPath" as $importName;\n' );
		});
	}

	Map<LibraryElement, String> _getLibraryImportNames(){
		List<LibraryElement> uniqueLibraries = [];
		_typesToGenerate.map((e) => e.library).forEach((e){
			if(!uniqueLibraries.contains(e))
				uniqueLibraries.add(e);
		});

		Map<LibraryElement, String> libraryImportNames = {};
		uniqueLibraries.forEach((l){
			libraryImportNames[l] = _randomString( l.displayName.length + 3 );
		});
		return libraryImportNames;
	}

	String _randomString(int length) {
		const List<String> characters = const ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];

		var rand = new Random();
		var stringBuffer = new StringBuffer();
		for(var i = 0; i < length; i++){
			stringBuffer.write(characters[rand.nextInt(25)]);
		}

		return stringBuffer.toString();
	}

	bool _shouldBeMapped( ClassElement element )
	{
	  if(element.isEnum)
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
}