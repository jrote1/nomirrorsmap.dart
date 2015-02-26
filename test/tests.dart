library nomirrorsmap.tests;

import 'dart:io' as io;

import 'package:unittest/unittest.dart';
import 'package:nomirrorsmap/nomirrorsmap.dart';

part 'transformer_tests.dart';

main( )
{
	group( "Transformer", ( )
	{
		TransformerTests.run( );
	} );

	group( "Deserialization Tests", ( )
	{
		test( "Can deserialize simple object structure", ( )
		{
			var json = new io.File.fromUri( new Uri.file( "test_json/simple_object.json" ) ).readAsStringSync( );

			var result = new NoMirrorsMap( ).convert( json, new JsonConverter( ), new ClassConverter( ) ) as Person;

			expect( result.id, 1 );
			expect( result.children, isNotNull );
			expect( result.parents, isNotNull );
		} );

		test( "Can deserialize objects with circular references", ( )
		{
			var json = new io.File.fromUri( new Uri.file( "test_json/hashcode_test.json" ) ).readAsStringSync( );

			var result = new NoMirrorsMap( ).convert( json, new JsonConverter( ), new ClassConverter( ) ) as Person;

			var result1 = new NoMirrorsMap( ).convert( result, new ClassConverter( ), new JsonConverter( ) );

			var result2 = new NoMirrorsMap( ).convert( result1, new JsonConverter( ), new ClassConverter( ) ) as Person;

			var parent = result2.parents[0];

			expect( parent.children[0].parents[0], parent );
		} );

		test( "Can deserialize objects with circular references, even if properties are seen after reference", ( )
		{
			var json = new io.File.fromUri( new Uri.file( "test_json/reversed_hashcode_json.json" ) ).readAsStringSync( );

			var result = new NoMirrorsMap( ).convert( json, new JsonConverter( ), new ClassConverter( ) ) as Person;

			var parent = result.parents[0];

			expect( parent, parent.children[0].parents[0] );
			expect( parent.id, 1 );
		} );

		test("Can deserialize objects that do not have \$type",(){

		});
	} );
}

class Person
{
	int id;
	List<Person> parents;
	List<Person> children;
}