import 'package:barback/barback.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:code_transformers/resolver.dart';
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
	  var id = transform.primaryInput.id;
        var outputPath = path.url.join(path.url.dirname(id.path), "${path.url.basenameWithoutExtension(id.path)}_nomirrorsmap_generated_maps.dart");
        var generatedAssetId = new AssetId(id.package, outputPath);
	  
		var mapFile = (new MapGenerator( resolver )
			..addTypes( resolver.libraries
						.expand((lib) => lib.units)
						.expand((compilationUnit) => compilationUnit.types).toList() ))
			.buildMapFile(generatedAssetId);
		
		

		transform.addOutput(
			new Asset.fromString(generatedAssetId, mapFile));
		
		_editMain(transform, resolver);
	}

	void _editMain(Transform transform, Resolver resolver){
	  AssetId id = transform.primaryInput.id;
        var lib = resolver.getLibrary(id);
        var unit = lib.definingCompilationUnit.node;
        var transaction = resolver.createTextEditTransaction(lib);

        var imports = unit.directives.where((d) => d is ImportDirective);
        transaction.edit(imports.last.end, imports.last.end, '\nimport '
            "'${path.url.basenameWithoutExtension(id.path)}"
            "_nomirrorsmap_generated_maps.dart' show NoMirrorsMapGeneratedMaps;\n"
            "import 'package:nomirrorsmap/src/shared/shared.dart' as nomirrorsmap;\n");

        FunctionExpression main = unit.declarations.where((d) =>
            d is FunctionDeclaration && d.name.toString() == 'main')
            .first.functionExpression;
        var body = main.body;
        if (body is BlockFunctionBody) {
          var location = body.beginToken.end;
          transaction.edit(location, location, '\n  nomirrorsmap.GeneratedMapProvider.addMaps(NoMirrorsMapGeneratedMaps.load());');
        } else if (body is ExpressionFunctionBody) {
          transaction.edit(body.beginToken.offset, body.endToken.end,
              "{\n  nomirrorsmap.GeneratedMapProvider.addMaps(NoMirrorsMapGeneratedMaps.load());\n"
              "  return ${body.expression};\n}");
        } // EmptyFunctionBody can only appear as abstract methods and constructors.

        var printer = transaction.commit();
        var url = id.path.startsWith('lib/') ?
            'package:${id.package}/${id.path.substring(4)}' : id.path;
        printer.build(url);
        transform.addOutput(new Asset.fromString(id, printer.text));
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
		mapFileContent.write( "new nomirrorsmap.ClassGeneratedMap(${libraryImportNames[type.library]}.${type.displayName},\"${_getFullTypeName( type.type )}\", () => new ${libraryImportNames[type.library]}.${type.displayName}(), {\n" );
		for ( var field in type.fields )
		{
			noticedTypes.add( field.type );
			mapFileContent.write( "'${field.displayName}': new nomirrorsmap.GeneratedPropertyMap( ${_getPropertyType(field.type, libraryImportNames)}, (obj) => obj.${field.displayName}, (obj, value) => obj.${field.displayName} = value ),\n" );
		}
		mapFileContent.write( "}),\n" );
	}

	String buildMapFile(AssetId assetId){
		var mapFileContent = new StringBuffer();

		_appendHeader(mapFileContent, assetId);
		
		var libraryImportNames = _getLibraryImportNames();
		_appendLibraryImports(libraryImportNames, mapFileContent, assetId);

		mapFileContent.write("\n");

		mapFileContent.write('''class NoMirrorsMapGeneratedMaps{
  static List load(){
    return [\n''');
		List<Element> seenTypes = [];
		List<InterfaceType> noticedTypes = [];

		for(ClassElement type in _typesToGenerate){
		  if(type.type.element.type == _resolver.getType( "dart.core.List" ).type || type.type.isAssignableTo(_resolver.getType( "dart.core.List" ).type)){
		    mapFileContent.write("new nomirrorsmap.ListGeneratedMap(const TypeOf<${_getListType(type.type)}>().type, String, () => new ${_getListType(type.type)}()),");
		  }else if(type.isEnum){
		    mapFileContent.write("new nomirrorsmap.EnumGeneratedMap( ${libraryImportNames[type.library]}.${type.displayName}, ${libraryImportNames[type.library]}.${type.displayName}.values ),\n");
		  }else{
		    _addType( seenTypes, type, mapFileContent, libraryImportNames, noticedTypes );
		  }
		}

		List<InterfaceType> seenNoticedTypes = [];
		for(InterfaceType type in noticedTypes.toList()){
		  if(!seenNoticedTypes.contains(type))
		  {
		    seenNoticedTypes.add(type);
		    if(type.element.type == _resolver.getType( "dart.core.List" ).type || type.isAssignableTo(_resolver.getType( "dart.core.List" ).type)){
		      mapFileContent.write("new nomirrorsmap.ListGeneratedMap(const TypeOf<${_getListType(type)}>().type, String, () => new ${_getListType(type)}()),");
		    }
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

	void _appendLibraryImports( Map<LibraryElement, String> libraryImportNames, StringBuffer mapFileContent, AssetId assetId )
	{
		libraryImportNames.forEach((library, importName){
			var importPath = _resolver.getImportUri( library, from: assetId );
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
	
	void _appendHeader(StringBuffer stringBuffer, AssetId assetId){
	  stringBuffer.write("library ${path.url.basenameWithoutExtension(assetId.path)}_nomirrorsmap_generated_maps;\n\n");
	  stringBuffer.write("import 'package:nomirrorsmap/src/shared/shared.dart' as nomirrorsmap;\n");
	}
}