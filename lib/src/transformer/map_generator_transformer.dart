part of nomirrorsmap.transformer;

class TransformerOptions
{
	static const LIBRARY_NAMES_PARAM = "library_names";

	final List<String> libraryNames;

	TransformerOptions.initialize( this.libraryNames );

	factory TransformerOptions( BarbackSettings settings ) {
		return new TransformerOptions.initialize( _readFileList( settings.configuration, LIBRARY_NAMES_PARAM ) );
	}

	static List<String> _readFileList( Map config, String paramName )
	{
		var value = config[paramName];
		if ( value == null ) return null;
		var files = [];
		bool error = false;
		if ( value is List )
		{
			files = value;
			error = value.any( ( e )
							   => e is! String );
		} else if ( value is String )
		{
			files = [value];
			error = false;
		} else
		{
			error = true;
		}
		if ( error )
		{
			print( 'Invalid value for "$paramName" in the Angular 2 transformer.' );
		}
		return files;
	}
}

class MapGeneratorTransformer extends Transformer
	with ResolverTransformer
{
	final TransformerOptions _options;

	MapGeneratorTransformer( Resolvers resolvers, this._options )
	{
		this.resolvers = resolvers;
	}

	void applyResolver( Transform transform, Resolver resolver )
	{
		var id = transform.primaryInput.id;

		var regex = new RegExp( "(?=[A-Z])" );
		var mappingsFileName = "${id.package.split( regex ).join( "_" ).toLowerCase( )}_mappings.dart";
		var outputPath = path.url.join( path.url.dirname( id.path ), mappingsFileName );
		var generatedAssetId = new AssetId( id.package, outputPath );

		_transformEntryFile( transform, resolver, mappingsFileName );

		var mappingsFile = new MappingsGenerator( resolver, id )
			.generate( _options.libraryNames );

		transform.addOutput(
			new Asset.fromString( generatedAssetId, mappingsFile ) );
	}

	void _transformEntryFile( Transform transform, Resolver resolver, String mappingsFileName )
	{
		AssetId id = transform.primaryInput.id;
		var lib = resolver.getLibrary( id );
		var unit = lib.definingCompilationUnit.node;
		var transaction = resolver.createTextEditTransaction( lib );

		var importParameters = _getImportParameters( unit );

		var mappingsClassName = _getMappingsClassName( mappingsFileName );
		transaction.edit(
			importParameters.startPoint,
			importParameters.startPoint,
			'${importParameters.importStart}import "$mappingsFileName" as $mappingsClassName;' + (importParameters.startPoint == 0 ? "\n" : "") );

		FunctionExpression main = unit.declarations
			.where( ( d )
					=>
					d is FunctionDeclaration && d.name.toString( ) == 'main' )
			.first
			.functionExpression;
		var body = main.body;
		if ( body is BlockFunctionBody )
		{
			var location = body.beginToken.end;
			transaction.edit( location, location, '\n\t$mappingsClassName.$mappingsClassName.register();\n' );
		}
		else if ( body is ExpressionFunctionBody )
		{
			transaction.edit( body.beginToken.offset, body.endToken.end,
								  "{\n\t$mappingsClassName.$mappingsClassName.register();\n"
									  "\treturn ${body.expression};\n}" );
		}

		var printer = transaction.commit( );
		printer.build( id.path );
		transform.addOutput( new Asset.fromString( id, printer.text ) );
	}

	String _getMappingsClassName( String mappingsFileName )
	{
		return mappingsFileName
			.replaceAll( ".dart", "" )
			.split( "_" )
			.map( ( str )
				  => str[0].toUpperCase( ) + str.substring( 1 ) )
			.join( );
	}

	EntryPointImportParameters _getImportParameters( dynamic unit )
	{
		List<Directive> imports = unit.directives.where( ( d )
														 => d is ImportDirective ).toList( );

		var result = new EntryPointImportParameters( )
			..startPoint = 0
			..importStart = "";

		if ( imports.length > 0 )
		{
			result.importStart = "\n";
			result.startPoint = imports.last.end;
		}
		else
		{
			List<Directive> libraries = unit.directives.where( ( d )
															   => d is LibraryDirective ).toList( );
			if ( libraries.length > 0 )
			{
				result.importStart = "\n\n";
				result.startPoint = libraries.last.end;
			}
		}
		return result;
	}
}

class EntryPointImportParameters
{
	int startPoint;
	String importStart;
}