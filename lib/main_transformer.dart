import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:nomirrorsmap/src/transformer/transformer.dart';

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