part of nomirrorsmap.converters;

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
				..previousHashCode = value.hashCode.toString( )
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
			..previousHashCode = value.hashCode.toString( )
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
			if ( instances.containsKey( baseObjectData.previousHashCode ) )
				classConverterInstance = instances[baseObjectData.previousHashCode];
			else
				classConverterInstance = instances[baseObjectData.previousHashCode] = new ClassConverterInstance( )
					..filled = false
					..instance = instanceMirror.reflectee;

			if ( !classConverterInstance.filled && baseObjectData.properties.length > 0 )
			{
				instanceMirror = reflect( classConverterInstance.instance );
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