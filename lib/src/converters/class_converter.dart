part of nomirrorsmap.converters;

class CustomClassConverter<TActualType, TConvertedType>
{
	Function _fromFunc;

	set from( TConvertedType func( TActualType val ) )
	{
		_fromFunc = func;
	}

	Function get from
	=> _fromFunc;

	Function _toFunc;

	set to( TActualType func( TConvertedType val ) )
	{
		_toFunc = func;
	}

	Function get to
	=> _toFunc;
}

class ClassConverter implements Converter
{
	Type startType;

	ClassConverter( {this.startType} );

	static Map<Type, CustomClassConverter> converters = {
	};

	List<String> seenHashCodes = [];

	BaseObjectData toBaseObjectData( dynamic value )
	{
		var valueType = reflect( value ).type.reflectedType;
		if ( converters.containsKey( valueType ) )
			value = converters[valueType].from( value );

		if ( _isPrimitive( value ) )
			return new NativeObjectData( )
				..objectType = valueType
				..value = value;
		if ( value is List )
		{
			return new ListObjectData( )
				..objectType = valueType
				..values = value.map( ( v )
									  => toBaseObjectData( v ) ).toList( );
		}

		if ( seenHashCodes.contains( value.hashCode.toString( ) ) )
			return new ClassObjectData( )
				..objectType = valueType
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
			..objectType = valueType
			..previousHashCode = value.hashCode.toString( )
			..properties = properties;
	}

	bool _isPrimitive( v )
	=> v is num || v is bool || v is String || v == null;

	Map<String, ClassConverterInstance> instances = {
	};

	dynamic fromBaseObjectData( BaseObjectData baseObjectData )
	{
		return _fromBaseObjectData( baseObjectData, baseObjectData.objectType == null ? startType : baseObjectData.objectType );
	}

	dynamic _fromBaseObjectData( BaseObjectData baseObjectData, Type type )
	{
		if ( baseObjectData is ClassObjectData )
		{
			ClassConverterInstance classConverterInstance;
			var instanceMirror = reflectClass( type ).newInstance( new Symbol( "" ), [] );
			if ( baseObjectData.previousHashCode != null && instances.containsKey( baseObjectData.previousHashCode ) )
				classConverterInstance = instances[baseObjectData.previousHashCode];
			else
			{
				classConverterInstance = new ClassConverterInstance( )
					..filled = false
					..instance = instanceMirror.reflectee;

				if(baseObjectData.previousHashCode != null)
					instances[baseObjectData.previousHashCode] = classConverterInstance;
			}
			if ( !classConverterInstance.filled && baseObjectData.properties.length > 0 )
			{
				instanceMirror = reflect( classConverterInstance.instance );
				for ( var property in _getPublicReadWriteProperties( reflectClass( type ) ) )
				{
					if ( baseObjectData.properties.containsKey( MirrorSystem.getName( property.simpleName ) ) )
					{
						var propertyObjectData = baseObjectData.properties[MirrorSystem.getName( property.simpleName )];
						var propertyType = propertyObjectData.objectType == null ? property.type.reflectedType : propertyObjectData.objectType;
						var value = _fromBaseObjectData( propertyObjectData, propertyType );
						if ( converters.containsKey( propertyType ) )
							value = converters[propertyType].to( value );
						if ( value is List )
						{
							var list = reflectClass( propertyType ).newInstance( new Symbol( "" ), [] ).reflectee;
							list.addAll( value );
							value = list;
						}
						instanceMirror.setField( property.simpleName, value );
					}
				}
				classConverterInstance.filled = true;
			}
			return classConverterInstance.instance;
		}
		if ( baseObjectData is ListObjectData )
		{
			var listType = reflectType( type ).typeArguments[0].reflectedType;

			return baseObjectData.values.map( ( v )
											  => _fromBaseObjectData( v, v.objectType == null ? listType : v.objectType ) ).toList( );
		}
		return (baseObjectData as NativeObjectData).value;
	}

	static ClassMirror _objectMirror = reflectClass( Object );
	static Map<ClassMirror, List<DeclarationMirror>> _publicReadWriteProperties = {
	};

	List<VariableMirror> _getPublicReadWriteProperties( ClassMirror classMirror )
	{
		var properties = _publicReadWriteProperties[classMirror];
		if ( properties == null )
		{
			properties = <VariableMirror> [];
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