part of nomirrorsmap.converters;

class JsonConverter
	implements Converter
{
	String _hashcodeName;

	JsonConverter( [String hashcodeName = "\$hashcode"] )
	{
		_hashcodeName = hashcodeName;
	}

	BaseObjectData toBaseObjectData( dynamic value )
	{
		if ( !(value is String) )
			throw new Exception( "value is not a String" );
		var json = JSON.decode( value );
		return _jsonToBaseObjectData( json );
	}

	String getPreviousHashcode( Map json )
	=> json[_hashcodeName];

	Type findObjectType( dynamic json )
	{
		return json.containsKey( "\$type" ) ? NoMirrorsMapStore
			.getClassGeneratedMapByQualifiedName( json["\$type"] )
			.type : null;
	}

	void afterCreatingClassObjectData( ClassObjectData classObjectData )
	{
	}

	BaseObjectData _jsonToBaseObjectData( dynamic json )
	{
		if ( json is Map )
		{
			var classObjectData = new ClassObjectData( );
			classObjectData.previousHashCode = getPreviousHashcode( json );
			classObjectData.objectType = findObjectType( json );

			afterCreatingClassObjectData( classObjectData );
			Map<String, BaseObjectData> properties = {
			};
			(json as Map).forEach( ( key, value )
								   {
									   properties[key] = _jsonToBaseObjectData( value );
								   } );


			classObjectData.properties = properties;

			return classObjectData;
		} else if ( json is List )
			return new ListObjectData( )
				..values = json.map( ( o )
									 => _jsonToBaseObjectData( o ) ).toList( );
		return new NativeObjectData( )
			..value = json;
	}

	dynamic fromBaseObjectData( BaseObjectData baseObjectData )
	{
		var stringBuffer = new StringBuffer();
		_fromBaseObjectData( baseObjectData, stringBuffer );
		return stringBuffer.toString();
	}

	void setMetaData( Map result, String hashcode, ClassObjectData classObjectData )
	{
		result[_hashcodeName] = hashcode;
		setTypeFromObjectType( result, classObjectData );
	}

	void setTypeFromObjectType( Map json, ClassObjectData classObjectData )
	{
		json["\$type"] = NoMirrorsMapStore
			.getClassGeneratedMap( classObjectData.objectType )
			.fullName;
	}

	void _fromBaseObjectData( BaseObjectData baseObjectData, StringBuffer stringBuffer )
	{
		if ( baseObjectData is ClassObjectData )
		{
			stringBuffer.write( "{" );

			stringBuffer.write( "\"$_hashcodeName:\"$hashCode\"," );
			stringBuffer.write( "\"\$type:\"${NoMirrorsMapStore
					.getClassGeneratedMap( baseObjectData.objectType )
					.fullName}\"," );

			for ( var key in baseObjectData.properties.keys )
			{
				stringBuffer.write( "\"$key:" );
				_fromBaseObjectData( baseObjectData.properties[key], stringBuffer );
				if ( baseObjectData.properties.keys.last != key )
					stringBuffer.write( "," );
			}

			baseObjectData.properties.forEach( ( name, value )
											   {

											   } );
		}
		if ( baseObjectData is ListObjectData )
		{
			stringBuffer.write( "[" );
			for ( var i = 0; i < baseObjectData.values.length; i++ )
			{
				var value = baseObjectData.values[i];
				_fromBaseObjectData( value, stringBuffer );
				if ( i != (baseObjectData.values.length - 1) )
					stringBuffer.write( "," );
			}
			stringBuffer.write( "]" );
		}

		if ( baseObjectData is NativeObjectData )
		{
			if ( baseObjectData.value is String )
				stringBuffer.write( "\"" + baseObjectData.value.replaceAll( "\"", '\\"' ) + "\"" );
			else
				stringBuffer.write( baseObjectData.value );
		}
		/*
		if ( baseObjectData is ClassObjectData )
		{
			var result = {
			};
			setMetaData( result, baseObjectData.previousHashCode, baseObjectData );
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
		*/
	}
}

