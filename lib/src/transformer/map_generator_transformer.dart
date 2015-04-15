part of nomirrorsmap.transformer;

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

