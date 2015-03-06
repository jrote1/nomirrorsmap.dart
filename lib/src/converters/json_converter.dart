part of nomirrorsmap.converters;

class JsonConverter implements Converter
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
				..previousHashCode = (json as Map)["\$hashcode"]
				..objectType = json.containsKey("\$type") ? _getClassMirrorByName( json["\$type"] ).reflectedType : null
				..properties = properties;
		} else if ( json is List )
			return new ListObjectData( )
				..values = json.map( ( o )
									 => _jsonToBaseObjectData( o ) ).toList( );
		return new NativeObjectData( )
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
			result["\$hashcode"] = baseObjectData.previousHashCode;
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