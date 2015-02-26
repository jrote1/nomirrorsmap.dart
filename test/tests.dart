library nomirrorsmap.tests;

import 'dart:io' as io;

import 'package:unittest/unittest.dart';
import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'package:nomirrorsmap/src/conversion_objects/conversion_objects.dart';
import 'dart:collection';

part 'transformer_tests.dart';


main( )
{
	group( "Serialization Tests", ( )
	{
		test( "Can serialize an object that is null", ( )
		{
			var result = new NoMirrorsMap( ).convert( null, new ClassConverter( ), new JsonConverter( ) );
			expect( result, "null" );
		} );

		test("Can serialize to Pascal case",(){
			var result = new NoMirrorsMap( ).convert( new Person()..id = 1..children = []..parents = [], new ClassConverter( ), new JsonConverter( ), [new PascalCaseManipulator()] );
			expect( result, endsWith('''"Id":1,"Parents":[],"Children":[]}''') );
		});
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

			var parent = result.parents[0];

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

		test( "Can deserialize objects that do not have \$type", ( )
		{
			var json = "{\"id\": 1, \"children\": [], \"parents\": []}";

			Person result = new NoMirrorsMap( ).convert( json, new JsonConverter( ), new ClassConverter( startType: Person ) );

			expect( result.id, 1 );
			expect( result.children, isNotNull );
			expect( result.parents, isNotNull );
		} );

		test( "Can deserialize null", ( )
		{
			var result = new NoMirrorsMap( ).convert( "null", new JsonConverter( ), new ClassConverter( ) );
			expect( result, null );
		} );

		test("Can deserialize using CamelCaseManipulator",(){
			var json = '''{"\$type":"nomirrorsmap.tests.Person","\$hashcode":"511757599","Id":1,"Parents":[],"Children":[]}''';

			Person result = new NoMirrorsMap( ).convert( json, new JsonConverter( ), new ClassConverter( ), [new CamelCaseManipulator()] );
			expect( result.id, 1 );
		});
	} );


	group( "ClassConverter test", ( )
	{

		setUp( ( )
			   {
				   ClassConverter.converters[CustomConverterTest] = new CustomClassConverter<CustomConverterTest, String>( )
					   ..to = ( String val )
				   {
					   var values = val.split( "|" );
					   var result = new CustomConverterTest( )
						   ..id = int.parse( values[0] )
						   ..value = values[1];
					   return result;
				   }
					   ..from = ( CustomConverterTest val )
				   => "${val.id}|${val.value}";

			   } );
		test( "When a custom converter is specified for a type, the converter is used when converting to baseObject", ( )
		{
			var object = new CustomConverterParentTest( )
				..testProperty = ( new CustomConverterTest( )
				..id = 1
				..value = "Matthew");

			var classConverter = new ClassConverter( );
			ClassObjectData baseObject = classConverter.toBaseObjectData( object );
			NativeObjectData result = baseObject.properties["testProperty"];

			expect( result.value, "1|Matthew" );
		} );

		test( "When a custom converter is specified for a type, the convert is used when converting from baseObject", ( )
		{
			var classObjectData = new ClassObjectData( )
				..properties = {
			};
			classObjectData.properties["testProperty"] = new NativeObjectData( )
				..value = "1|Matthew";
			classObjectData.previousHashCode = "1";
			classObjectData.objectType = CustomConverterParentTest;

			var classConverter = new ClassConverter( );
			CustomConverterParentTest result = classConverter.fromBaseObjectData( classObjectData );

			expect( result.testProperty.value, "Matthew" );
			expect( result.testProperty.id, 1 );

		} );


		test( "When a property is of a type that inherits from list, the conversion from baseObject to object works", ( )
		{
			var classObjectData = new ClassObjectData( )
				..properties = {
			};

			classObjectData.properties["customList"] = new ListObjectData( )
				..values = [ new NativeObjectData( )
				..value = "Hello", new NativeObjectData( )
				..value = "World"];
			classObjectData.previousHashCode = "1";
			classObjectData.objectType = TestObjectWithCustomList;

			var classConverter = new ClassConverter( );
			TestObjectWithCustomList result = classConverter.fromBaseObjectData( classObjectData );

			expect( result.customList[0], "Hello" );
			expect( result.customList[1], "World" );
		} );


	} );

}

class Person
{
	int id;
	List<Person> parents;
	List<Person> children;
}


//{"1|Matthew"}

class CustomConverterParentTest
{
	CustomConverterTest testProperty;
}

class CustomConverterTest
{
	int id;
	String value;
}

class CustomList<E> extends ListBase<E>
{
	var innerList = new List<E>( );

	int get length
	=> innerList.length;

	void set length( int length )
	{
		innerList.length = length;
	}

	void operator []=( int index, E value ) {
		innerList[index] = value;
	}

	E operator []( int index ) => innerList[index];

	// Though not strictly necessary, for performance reasons
	// you should implement add and addAll.

	void add( E value )
	=> innerList.add( value );

	void addAll( Iterable<E> all )
	=> innerList.addAll( all );
}

class TestObjectWithCustomList
{
	CustomList<String> customList = new CustomList<String>( );
}