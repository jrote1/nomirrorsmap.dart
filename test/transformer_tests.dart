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
				'a|web/main.dart': '''import "package:a/car.dart";
				import 'package:nomirrorsmap/nomirrorsmap.dart';

				@MapType()
                class Car {
                	int id;
                	String name;
                	List<String> values;
                	List<Car> previousVersions;
                	CarType carType;
                }

                enum CarType{
                	Sport,
                	Coupe
                }

				main() {}'''
			}, results: {
				'a|web/main_nomirrorsmap_generated_maps.dart': '''library main_nomirrorsmap_generated_maps_nomirrorsmap_generated_maps;

import \'package:nomirrorsmap/src/shared/shared.dart\' as nomirrorsmap;
import "main.dart" as main_dart;

class NoMirrorsMapGeneratedMaps{
  static List load(){
    return [
new nomirrorsmap.ClassGeneratedMap(main_dart.Car,"Car", () => new main_dart.Car(), {
\'id\': new nomirrorsmap.GeneratedPropertyMap( int, (obj) => obj.id, (obj, value) => obj.id = value ),
\'name\': new nomirrorsmap.GeneratedPropertyMap( String, (obj) => obj.name, (obj, value) => obj.name = value ),
\'values\': new nomirrorsmap.GeneratedPropertyMap( const nomirrorsmap.TypeOf<List<String>>().type, (obj) => obj.values, (obj, value) => obj.values = value ),
\'previousVersions\': new nomirrorsmap.GeneratedPropertyMap( const nomirrorsmap.TypeOf<List<main_dart.Car>>().type, (obj) => obj.previousVersions, (obj, value) => obj.previousVersions = value ),
\'carType\': new nomirrorsmap.GeneratedPropertyMap( main_dart.CarType, (obj) => obj.carType, (obj, value) => obj.carType = value ),
}),
new nomirrorsmap.ListGeneratedMap( const nomirrorsmap.TypeOf<List<String>>().type, String, () => new List<String>() ),
new nomirrorsmap.ListGeneratedMap( const nomirrorsmap.TypeOf<List<main_dart.Car>>().type, main_dart.Car, () => new List<main_dart.Car>() ),
new nomirrorsmap.EnumGeneratedMap( main_dart.CarType, main_dart.CarType.values ),
];
  }
}'''
			} );
		});
	}
}