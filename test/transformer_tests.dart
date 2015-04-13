part of nomirrorsmap.tests;


class TransformerTests
{
	static String MAP_LIBRARY = '''
		library nomirrorsmap;

		class MapType{
			const MapType();
		}
	''';

	static void run( )
	{
		var resolvers = new Resolvers(dartSdkDirectory);

		var phases = [
			[new MapGeneratorTransformer( resolvers)]
		];

		test("Test",(){
			return applyTransformers( phases, inputs: {
				'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
				'a|web/main.dart': 'import "package:a/car.dart"; main() {}',
				'a|lib/car.dart': '''
                import 'package:nomirrorsmap/nomirrorsmap.dart';
                import 'package:b/b.dart';
                @MapType()
                class Car {
                	int id;
                	String name;
                	List<String> values;
                  Engine engine;
                  CarSize carSize;
                }
                @MapType()
                enum CarSize{
                  One
                }
                ''',
         'b|lib/b.dart': '''
          library b;

          import 'package:nomirrorsmap/nomirrorsmap.dart';
          @MapType()
          class Engine {
              int size;
          }
          '''
			}, results: {} );
		});
	}
}