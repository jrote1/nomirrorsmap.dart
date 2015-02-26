library nomirrorsmap.tests;

import 'package:unittest/unittest.dart';
import 'dart:io' as io;
import 'dart:mirrors';
import 'dart:convert';

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
			var json = new io.File.fromUri( new Uri.file( "test_json/reversed_hashcode_json.json" ) ).readAsStringSync( );

			var result = new NoMirrorsMap( ).convert( json, new JsonConverter( ), new ClassConverter( ) ) as Person;

			expect(result.id, 1);
			expect(result.children, isNotNull);
			expect(result.parents, isNotNull);
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

	} );
}

class ClassConverterInstance
{
	dynamic instance;
	bool filled;
}

class ClassConverter implements Converter
{
	List<String> seenHashCodes = [];

	BaseObjectData toBaseObjectData( dynamic value )
	{
		if ( _isPrimitive( value ) )
			return new NativeObjectData( )
				..objectType = reflect( value ).type.reflectedType
				..value = value;
		if ( value is List )
		{
			return new ListObjectData( )
				..objectType = reflect( value ).type.reflectedType
				..values = value.map( ( v )
									  => toBaseObjectData( v ) ).toList( );
		}

		if ( seenHashCodes.contains( value.hashCode.toString( ) ) )
			return new ClassObjectData( )
				..objectType = reflect( value ).type.reflectedType
				..hashcode = value.hashCode.toString( )
				..properties = {
			};
		seenHashCodes.add( value.hashCode.toString( ) );

		var properties = {
		};
		for ( var property in _getPublicReadWriteProperties( reflect( value ).type ) )
		{
			properties[MirrorSystem.getName( property.simpleName )] = toBaseObjectData( reflect( value ).getField( property.simpleName ).reflectee );
		}

		return new ClassObjectData( )
			..objectType = reflect( value ).type.reflectedType
			..hashcode = value.hashCode.toString( )
			..properties = properties;
	}

	bool _isPrimitive( v )
	=> v is num || v is bool || v is String;

	Map<String, ClassConverterInstance> instances = {
	};

	dynamic fromBaseObjectData( BaseObjectData baseObjectData )
	{
		if ( baseObjectData is ClassObjectData )
		{
			ClassConverterInstance classConverterInstance;
			var instanceMirror = reflectClass( baseObjectData.objectType ).newInstance( new Symbol( "" ), [] );
			if ( instances.containsKey( baseObjectData.hashcode ) )
				classConverterInstance = instances[baseObjectData.hashcode];
			else
				classConverterInstance = instances[baseObjectData.hashcode] = new ClassConverterInstance( )
					..filled = false
					..instance = instanceMirror.reflectee;

			if(!classConverterInstance.filled && baseObjectData.properties.length > 0)
			{
				instanceMirror = reflect(classConverterInstance.instance);
				for ( var property in _getPublicReadWriteProperties( reflectClass( baseObjectData.objectType ) ) )
				{
					if ( baseObjectData.properties.containsKey( MirrorSystem.getName( property.simpleName ) ) )
					{
						instanceMirror.setField( property.simpleName, fromBaseObjectData( baseObjectData.properties[MirrorSystem.getName( property.simpleName )] ) );
					}
				}
				classConverterInstance.filled = true;
			}
			return classConverterInstance.instance;
		}
		if ( baseObjectData is ListObjectData )
			return baseObjectData.values.map( ( v )
											  => fromBaseObjectData( v ) ).toList( );
		return (baseObjectData as NativeObjectData).value;
	}

	static ClassMirror _objectMirror = reflectClass( Object );
	static Map<ClassMirror, List<DeclarationMirror>> _publicReadWriteProperties = {
	};

	List<DeclarationMirror> _getPublicReadWriteProperties( ClassMirror classMirror )
	{
		var properties = _publicReadWriteProperties[classMirror];
		if ( properties == null )
		{
			properties = <DeclarationMirror> [];
			if ( classMirror != _objectMirror )
			{
				properties.addAll( _getPublicReadWriteProperties( classMirror.superclass ) );
				classMirror.declarations.forEach( ( k, v )
												  {
													  if ( _isPublicField( v ) )
													  {
														  properties.add( v );
													  } else if ( _isPublicGetter( v ) && _hasSetter( classMirror, v ) )
													  {
														  properties.add( v );
													  }
												  } );
			}
		}
		return _publicReadWriteProperties[classMirror] = properties;
	}

	bool _hasSetter( ClassMirror cls, MethodMirror getter )
	{
		var mirror = cls.declarations[_setterName( getter.simpleName )];
		return mirror is MethodMirror && mirror.isSetter;
	}

	// https://code.google.com/p/dart/issues/detail?id=10029
	Symbol _setterName( Symbol getter )
	=>
	new Symbol( '${MirrorSystem.getName( getter )}=' );

	bool _isPublicField( DeclarationMirror v )
	=>
	v is VariableMirror && !v.isStatic && !v.isPrivate && !v.isFinal;

	bool _isPublicGetter( DeclarationMirror v )
	=>
	(v is MethodMirror && !v.isStatic && !v.isPrivate && v.isGetter);
}

class

JsonConverter implements Converter
{

	BaseObjectData toBaseObjectData( dynamic value )
	{
		if ( !(value is String) )
			throw new Exception( "value is not a String" );
		var json = JSON.decode( value );
		return _jsonToBaseObjectData( json );
	}

	BaseObjectData _jsonToBaseObjectData( dynamic json )
	{
		if ( json is Map )
		{
			Map<String, BaseObjectData> properties = {
			};
			(json as Map).forEach( ( key, value )
								   {
									   properties[key] = _jsonToBaseObjectData( value );
								   } );
			return new ClassObjectData( )
				..hashcode = (json as Map)["\$hashcode"]
				..objectType = _getClassMirrorByName( json["\$type"] ).reflectedType
				..properties = properties;
		} else if ( json is List )
			return new ListObjectData( )
				..objectType = List
				..values = json.map( ( o )
									 => _jsonToBaseObjectData( o ) ).toList( );
		return new NativeObjectData( )
			..objectType = reflect( json ).type.reflectedType
			..value = json;
	}

	ClassMirror _getClassMirrorByName( String className )
	{
		if ( className == null )
		{
			return null;
		}

		var index = className.lastIndexOf( '.' );
		var libraryName = '';
		var name = className;
		if ( index > 0 )
		{
			libraryName = className.substring( 0, index );
			name = className.substring( index + 1 );
		}

		LibraryMirror library;
		if ( libraryName.isEmpty )
		{
			library = currentMirrorSystem( ).isolate.rootLibrary;
		} else
		{
			library = currentMirrorSystem( ).findLibrary( new Symbol( libraryName ) );
		}

		if ( library == null )
		{
			return null;
		}

		return library.declarations[new Symbol( name )];
	}

	dynamic fromBaseObjectData( BaseObjectData baseObjectData )
	{
		return JSON.encode( _fromBaseObjectData( baseObjectData ) );
	}

	dynamic _fromBaseObjectData( BaseObjectData baseObjectData )
	{
		if ( baseObjectData is ClassObjectData )
		{
			var result = {
			};
			result["\$type"] = MirrorSystem.getName( reflectClass( baseObjectData.objectType ).qualifiedName );
			result["\$hashcode"] = baseObjectData.hashcode;
			baseObjectData.properties.forEach( ( name, value )
											   {
												   result[name] = _fromBaseObjectData( value );
											   } );
			return result;
		}
		if ( baseObjectData is ListObjectData )
		{
			return baseObjectData.values.map( ( v )
											  => _fromBaseObjectData( v ) ).toList( );
		}
		return (baseObjectData as NativeObjectData).value;
	}
}

class ClassObjectData extends BaseObjectData
{
	bool get isNativeType
	=> false;

	String hashcode;

	Map<String, BaseObjectData> properties;
}

class NativeObjectData extends BaseObjectData
{

	bool get isNativeType
	=> true;

	dynamic value;
}

class ListObjectData extends BaseObjectData
{

	bool get isNativeType
	=> true;

	List<BaseObjectData> values;
}

class BaseObjectData
{
	Type objectType;

	bool get isNativeType
	=> false;
}

abstract class Converter
{
	BaseObjectData toBaseObjectData( dynamic value );

	dynamic fromBaseObjectData( BaseObjectData baseObjectData );
}

class NoMirrorsMap
{
	dynamic convert( dynamic value, Converter sourceConverter, Converter destinationConverter )
	{
		var convertedSource = sourceConverter.toBaseObjectData( value );
		return destinationConverter.fromBaseObjectData( convertedSource );
	}


}

class Person
{
	int id;
	List<Person> parents;
	List<Person> children;
}