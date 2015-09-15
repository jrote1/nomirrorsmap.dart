library nomirrorsmap.tests;

import 'dart:io' as io;

import 'package:unittest/unittest.dart';
import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'package:nomirrorsmap/src/conversion_objects/conversion_objects.dart';
import 'dart:collection';

part 'transformer_tests.dart';

String getFileContent( String fileName )
{
	return new io.File.fromUri( new Uri.file( fileName ) ).readAsStringSync( );
}

main( )
{
	group( "Serialization Tests", ( )
	{
		test( "Can serialize an object that is null", ( )
		{
			var result = new NoMirrorsMap( ).convert( null, new ClassConverter( ), new JsonConverter( ) );
			expect( result, "null" );
		} );

		test( "Can serialize to Pascal case", ( )
		{
			var result = new NoMirrorsMap( ).convert( new Person( )
														  ..id = 1
														  ..children = []
														  ..parents = [], new ClassConverter( ), new JsonConverter( ), [new PascalCaseManipulator( )] );
			expect( result, endsWith( '''"Id":1,"Parents":[],"Children":[]}''' ) );
		} );

		test( "Performance test", (){
			//218
			var list = [];
			for(int i = 0; i < 1000; i++)
					list.add(new Person( )
								 ..id = i
								 ..children = [new Person( )
									 ..id = i
									 ..children = []
									 ..parents = []]
								 ..parents = [new Person( )
									 ..id = i
									 ..children = []
									 ..parents = []]);

			var stopwatch = new Stopwatch()..start();
			new ClassConverter( ).toBaseObjectData( list );
			//var result = new NoMirrorsMap( ).convert( list, , new NewtonSoftJsonConverter( ) );
			stopwatch.stop();
			print("Took: ${stopwatch.elapsedMilliseconds}");
		} );
	} );

	group( "Deserialization Tests", ( )
	{
		test( "Can deserialize null DateTime", ( )
		{
			var json = "null";

			var result = new NoMirrorsMap( ).convert( json, new JsonConverter( ), new ClassConverter( startType: DateTime ) ) as Person;

			expect( result, isNull );
		} );

		test( "Can deserialize simple object structure", ( )
		{
			var json = new io.File.fromUri( new Uri.file( "test/test_json/simple_object.json" ) ).readAsStringSync( );

			var result = new NoMirrorsMap( ).convert( json, new JsonConverter( ), new ClassConverter( ) ) as Person;

			expect( result.id, 1 );
			expect( result.children, isNotNull );
			expect( result.parents, isNotNull );
		} );

		test( "Can deserialize objects with circular references", ( )
		{
			var json = new io.File.fromUri( new Uri.file( "test/test_json/hashcode_test.json" ) ).readAsStringSync( );

			var result = new NoMirrorsMap( ).convert( json, new JsonConverter( ), new ClassConverter( ) ) as Person;

			var parent = result.parents[0];

			expect( parent.children[0].parents[0], parent );
		} );

		test( "Can deserialize objects with circular references, even if properties are seen after reference", ( )
		{
			var json = new io.File.fromUri( new Uri.file( "test/test_json/reversed_hashcode_json.json" ) ).readAsStringSync( );

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

		test( "Can deserialize using CamelCaseManipulator", ( )
		{
			var json = '''{"\$type":"nomirrorsmap.tests.Person","\$hashcode":"511757599","Id":1,"Parents":[],"Children":[]}''';

			Person result = new NoMirrorsMap( ).convert( json, new JsonConverter( ), new ClassConverter( ), [new CamelCaseManipulator( )] );
			expect( result.id, 1 );
		} );

		test( "Can deserialize type that contains a list", ( )
		{
			var json = "{\"id\": 1, \"children\": [{\"id\": 2,\"children\": [], \"parents\": []}], \"parents\": []}";

			Person result = new NoMirrorsMap( ).convert( json, new JsonConverter( ), new ClassConverter( startType: Person ) );

			expect( result.id, 1 );
			expect( result.children.length, 1 );
			expect( result.children[0].id, 2 );
		} );

		test( "Can deserialize type that contains a list", ( )
		{
			var json = new io.File.fromUri( new Uri.file( "test/test_json/list.json" ) ).readAsStringSync( );

			User result = new NoMirrorsMap( ).convert( json, new JsonConverter( ), new ClassConverter( startType: User ), [new CamelCaseManipulator( )] );

			expect( result.id, 2 );
			expect( result.teamUsers[0].role.id, 1 );
		} );

		test( "Can deserialize type that contains a DateTime", ( )
		{
			ClassWithDateTime result = new NoMirrorsMap( ).convert( "{\"time\": \"2055-02-03T15:57:12\"}", new JsonConverter( ), new ClassConverter( startType: ClassWithDateTime ) );

			expect( result.time, new isInstanceOf<DateTime>( ) );
		} );
	} );


	group( "ClassConverter test", ( )
	{

		setUp( ( )
			   {
				   ClassConverter.converters[CustomConverterTest] = new CustomClassConverter<CustomConverterTest, String>( )
					   ..to = (( String val )
				   {
					   var values = val.split( "|" );
					   var result = new CustomConverterTest( )
					   ..id = int.parse( values[0] )
					   ..value = values[1];
				   return result;
			   })
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

		test( "With a json string with no type attributes and a sub property of different type, deserialises correctly", ( )
		{
			var json = new io.File.fromUri( new Uri.file( "test/test_json/no_type_string_objects.json" ) ).readAsStringSync( );
			NoTypeTestClass result = new NoMirrorsMap( ).convert( json, new JsonConverter( ), new ClassConverter( startType: NoTypeTestClass ) );
			expect( result.testProperty.name, "OtherName" );
		} );

		test( "With json with int value and setting double does not explode", ( )
		{
			var objectData = new NativeObjectData( )
				..value = 1;
			var objectd = new ClassObjectData( )
				..objectType = ClassWithDouble
				..properties = {
				"val": objectData
			};

			var classConverter = new ClassConverter( startType: ClassWithDouble );

			var result = classConverter.fromBaseObjectData( objectd );

			expect( result.val, 1.0 );
		} );
	} );

	group( "JsonConverter tests", ( )
	{
		test( "can convert to object using HashCode", ( )
		{
			const String hashcode = "1234";
			const String jsonHashcodeName = "\$ref";

			var data = new ClassObjectData( )
				..properties = {}
				..previousHashCode = hashcode
				..objectType = CustomConverterTest;

			var converter = new JsonConverter( jsonHashcodeName );
			String jsonResult = converter.fromBaseObjectData( data );

			var expected = "\"$jsonHashcodeName\":\"$hashcode\"";
			expect( jsonResult.contains( expected ), true );
		} );

		test( "can convert from json to object using custom HashCode", ( )
		{
			const String hashcode = "1234";
			const String jsonHashcodeName = "\$ref";

			var converter = new JsonConverter( jsonHashcodeName );
			var json = '{ "\$type": "nomirrorsmap.tests.CustomConverterTest",\"$jsonHashcodeName\": \"$hashcode\"}';
			var baseObjectData = converter.toBaseObjectData( json ) as ClassObjectData;

			expect( baseObjectData.previousHashCode, hashcode );
			expect( baseObjectData.properties.containsKey( jsonHashcodeName ), true );
		} );
	} );

	group( "NewtonSoft json test", ( )
	{
		test( "For fromBaseObjectData, When called with two objects with same reference, Then returned json should have \$id in first object and  \$ref in second object", ( )
		{
			var list = new ListObjectData( );
			var klass1 = new ClassObjectData( );
			var klass2 = new ClassObjectData( );

			klass1.objectType = klass2.objectType = NewtonSoftTest;
			klass1.previousHashCode = klass2.previousHashCode = "1";
			klass1.properties = {};
			klass1.properties["age"] = new NativeObjectData( )
				..value = 14;
			klass1.properties["gender"] = new NativeObjectData( )
				..value = "m";

			klass2.properties = {};

			list.values = [klass1, klass2];

			var converter = new NewtonSoftJsonConverter( );
			String json = converter.fromBaseObjectData( list );

			expect( json.contains( getFileContent( "test\\test_json\\newtonsoft_test.json" ) ), true );

		} );

		test( "For toBaseObjectData, When called with two objects with same reference, Then returned objects should restore references", ( )
		{
			var converter = new NewtonSoftJsonConverter( );
			ListObjectData json = converter.toBaseObjectData( getFileContent( "test\\test_json\\newtonsoft_test.json" ) );

			expect( (json.values[0] as ClassObjectData).previousHashCode, "1" );
			expect( (json.values[0] as ClassObjectData).previousHashCode, (json.values[1] as ClassObjectData).previousHashCode );

		} );

		test( "can deserialize using dollar ref property only", ( )
		{
			var converter = new NewtonSoftJsonConverter( );
			var jsonText = getFileContent( "test\\test_json\\convert_using_dollarRef.json" );
			var mapper = new NoMirrorsMap( );
			var result = mapper.convert( jsonText, converter, new ClassConverter( ) );

			expect( result != null, true );
			var simpleType = result as SimpleTypeUsingDollarRef;
			expect( result.name, result.people[1].name );
			expect( result.people[1].name, "Test User" );
		} );

		test( "can serialize object with no properties", ( )
		{
			var json = '''[{"\$id":"994910500","\$type":"nomirrorsmap.tests.TypeWithNoProperties"},{"\$ref":"994910500"}]''';

			var result = new NoMirrorsMap( ).convert( json, new NewtonSoftJsonConverter( ), new ClassConverter( startType: const TypeOf<List<TypeWithNoProperties>>( ).type ) );


		} );

		test( "Can deserialize", ( )
		{
			var converter = new NewtonSoftJsonConverter( );
			var jsonText = getFileContent( "test\\test_json\\abstract_class_and_inheritence.json" );
			BaseObjectData result = converter.toBaseObjectData(jsonText);

			assertClassObjectDataTypeNotNull(result);
		} );

		test( "Can deserialize generic", ()
		{
			var json = '''{ "id": 1 }''';
			var result = new NoMirrorsMap( ).convert( json, new JsonConverter( ), new ClassConverter( startType: const TypeOf<GenericType<int>>( ).type ) ) as GenericType<int>;
			expect( result.id, 1 );
		});

	} );

}

class GenericType<T>
{
	T id;
}



void assertClassObjectDataTypeNotNull(BaseObjectData objectData){
	if(objectData is ClassObjectData){
		var classObjectData = objectData as ClassObjectData;
		if(classObjectData.objectType == null)
		{
			expect( classObjectData.objectType, isNotNull );
		}
		classObjectData.properties.forEach((k,v){
			assertClassObjectDataTypeNotNull(v);
		});
	}else if (objectData is ListObjectData){
		var listObjectData = objectData as ListObjectData;
		listObjectData.values.forEach((v){
			assertClassObjectDataTypeNotNull(v);
		});
	}else{

	}
}

abstract class TheAbstractClass
{
	List<TheAbstractClass> data;
}

class InheritedClass extends TheAbstractClass
{

}

class TypeWithNoProperties
{

}

class SimpleTypeUsingDollarRef
{
	String name;
	List<SimpleTypeUsingDollarRef> people;
}

class NewtonSoftTest
{
	int age;
	String gender;
}

class Person
{
	int id;
	List<Person> parents;
	List<Person> children;
}

class ClassWithDouble
{
	double val;
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

class NoTypeTestClass
{
	int id;
	String firstName;
	NoTypeTestPropertyClass testProperty;
}

class NoTypeTestPropertyClass
{
	int id;
	String name;
}

class User
{
	int id;
	String firstName;
	String lastName;
	String emailAddress;
	String mobilePhone;
	bool umpire;

	List<TeamMember> teamUsers;
	SecurityRole securityRole;
}

class TeamMember
{
	Role role;
	User user;
}

class Role
{
	int id;
	String name;
}

class SecurityRole
{
	int id;
	String name;
	String description;
	AssociationLevel associationLevel;
}

class AssociationLevel
{
	int id;
	String value;
}

class ClassWithDateTime
{
	DateTime time;
}

class TypeOf<T>
{
	Type get type
	=> T;

	const TypeOf( );
}