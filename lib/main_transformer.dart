import 'package:barback/barback.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:code_transformers/resolver.dart';
import 'package:nomirrorsmap/src/transformer/transformer.dart';
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