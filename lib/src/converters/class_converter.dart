part of nomirrorsmap.converters;

class NoMirrorsMapStore
{
	static List<_PropertyMapping> _propertyMappings = [];
	static List<_ClassMapping> _classMappings = [];
	static Map<Type,List> _enumMappings = {};

	static void registerAccessor( String propertyName, void setter( dynamic object, dynamic value ), dynamic getter( dynamic object ) )
	{
		_propertyMappings.add( new _PropertyMapping( )
								   ..getter = getter
								   ..setter = setter
								   ..propertyName = propertyName );
	}

	static Map<Type, _ClassMapping> _classMappingsByType = {};

	static _ClassMapping getClassGeneratedMap( Type type )
	{
		var classMapping = _classMappingsByType[type];
		if ( classMapping == null )
		{
			if ( _classMappings.any( ( m )
									 => m.type == type ) )
				return _classMappingsByType[type] = _classMappings.firstWhere( ( m )
																			   => m.type == type );
			else
			{
				throw "Can't find map for type '${type.toString( )}' is it missing the @Mappable() annotation ";
			}
		}
		return classMapping;
	}

	static Map<Type, _ClassMapping> _classMappingsByListType = {};

	static _ClassMapping getClassGeneratedMapByListType( Type type )
	{
		var classMapping = _classMappingsByListType[type];
		if ( classMapping == null )
		{
			if ( !type.toString( ).contains( "<" ) )
				return null;
			if ( _classMappings.any( ( m )
									 => m.listType == type ) )
				return _classMappingsByListType[type] = _classMappings.firstWhere( ( m )
																				   => m.listType == type );
			throw "Can't find map for type '${type.toString( )}' is it missing the @Mappable() annotation ";
		}
		return classMapping;
	}

	static _ClassMapping getClassGeneratedMapByQualifiedName( String qualifiedName )
	{
		if ( _classMappings.any( ( m )
								 => m.fullName == qualifiedName ) )
			return _classMappings.firstWhere( ( m )
											  => m.fullName == qualifiedName );
		throw "Can't find map for type '$qualifiedName' is it missing the @Map() annotation ";
	}

	static void registerClass( String fullName, Type type, Type listType, dynamic instantiate( ), Map<String, Type> properties )
	{
		var classProperties = [];
		properties.forEach( ( k, v )
							{
								classProperties.add( new _ClassProperty( )
														 ..type = v
														 ..property = _propertyMappings.firstWhere( ( p )
																									=> p.propertyName == k ) );
							} );

		_classMappings.add( new _ClassMapping( )
								..type = type
								..listType = listType
								..fullName = fullName
								..instantiate = instantiate
								..properties = classProperties );
	}

	static void registerEnum( Type type, List values )
	{
		_enumMappings[type] = values;
	}

	static Function getPropertySetter( String name )
	{
		return _propertyMappings
			.firstWhere( ( property )
						 => property.propertyName == name )
			.setter;
	}

	static bool containsEnumGeneratedMap( Type type )
	{
		return _enumMappings.containsKey( type );
	}

	static getEnumGeneratedMap( Type type )
	{
		return _enumMappings[type];
	}

	static Function getPropertyGetter( String name )
	{
		return _propertyMappings
			.firstWhere( ( property )
						 => property.propertyName == name )
			.getter;
	}
}

class _ClassMapping
{
	String fullName;
	Type type;
	Type listType;
	Function instantiate;
	List<_ClassProperty> properties;
}

class _ClassProperty
{
	Type type;
	_PropertyMapping property;
}

class _PropertyMapping
{
	String propertyName;
	Function setter;
	Function getter;
}

class _EnumMapping
{
	Type type;
	List values;
}

class ClassConverter
	implements Converter
{
	Type startType;

	ClassConverter( {this.startType} );

	static Map<Type, CustomClassConverter> converters = {
	};

	Set<int> seenHashCodes = new Set<int>( );

	BaseObjectData toBaseObjectData( Object value )
	{
		if ( value is List )
		{
			return new ListObjectData( )
				..values = value.map( ( v )
									  => toBaseObjectData( v ) ).toList( );
		}

		var valueType = value.runtimeType;
		//if ( converters.containsKey( valueType ) )
		//	value = converters[valueType].from( value );

		if ( _isPrimitive( value ) )
			return new NativeObjectData( )
				..objectType = valueType
				..value = value;

		if ( _isEnum( value ) )
		{
			return new NativeObjectData( )
				..objectType = int
				..value = (value as dynamic).index;
		}

		var hashCode = value.hashCode;
		if ( seenHashCodes.contains( hashCode ) )
			return new ClassObjectData( )
				..objectType = valueType
				..previousHashCode = hashCode.toString( )
				..properties = {
				};
		seenHashCodes.add( hashCode );

		var generatedMap = NoMirrorsMapStore.getClassGeneratedMap( valueType );

		var properties = {
		};

		//Faster than foreach loop
		for ( var i = 0; i < generatedMap.properties.length; i++ )
		{
			var property = generatedMap.properties[i];
			var getter = property.property.getter;
			properties[property.property.propertyName] = toBaseObjectData( getter( value ) );
		}

		return new ClassObjectData( )
			..objectType = valueType
			..previousHashCode = value.hashCode.toString( )
			..properties = properties;
	}

	bool _isEnum( dynamic value )
	{
		//Not safe
		return _isTypeEnum( value.runtimeType );
	}

	bool _isPrimitive( v )
	=> v is num || v is bool || v is String || v == null || v is DateTime;

	Map<String, ClassConverterInstance> instances = new Map<String, ClassConverterInstance>( );

	dynamic fromBaseObjectData( BaseObjectData baseObjectData )
	{
		return _fromBaseObjectData( baseObjectData, baseObjectData.objectType == null ? startType : baseObjectData.objectType );
	}

	dynamic _fromBaseObjectData( BaseObjectData baseObjectData, Type type )
	{
		if ( baseObjectData is ClassObjectData )
		{
			var generatedMap = NoMirrorsMapStore.getClassGeneratedMap( type );
			var instance = generatedMap.instantiate( );


			ClassConverterInstance classConverterInstance;
			if ( baseObjectData.previousHashCode != null && instances.containsKey( baseObjectData.previousHashCode ) )
				classConverterInstance = instances[baseObjectData.previousHashCode];
			else
			{
				classConverterInstance = new ClassConverterInstance( )
					..filled = false
					..instance = instance;

				if ( baseObjectData.previousHashCode != null )
					instances[baseObjectData.previousHashCode] = classConverterInstance;
			}
			if ( !classConverterInstance.filled && baseObjectData.properties.length > 0 )
			{
				for ( var property in generatedMap.properties )
				{
					if ( baseObjectData.properties.containsKey( property.property.propertyName ) )
					{
						var setter = property.property.setter;

						var propertyObjectData = baseObjectData.properties[property.property.propertyName];
						var propertyType = propertyObjectData.objectType == null
							? property.type
							: propertyObjectData.objectType;
						var value = _fromBaseObjectData( propertyObjectData, propertyType );
						if ( converters.containsKey( propertyType ) )
							value = converters[propertyType].to( value );
						if ( value is List )
						{
							var list = [];
							list.addAll( value );
							value = list;
						}
						setter( classConverterInstance.instance, value );
					}
				}
				classConverterInstance.filled = true;
			}
			return classConverterInstance.instance;
		}
		if ( baseObjectData is ListObjectData )
		{
			var classMap = NoMirrorsMapStore
				.getClassGeneratedMapByListType( type );

			var listType = classMap == null ? Object : classMap.type;

			return baseObjectData.values.map( ( v )
											  => _fromBaseObjectData( v, v.objectType == null ? listType : v.objectType ) ).toList( );
		}
		var nativeObjectValue = (baseObjectData as NativeObjectData).value;

		if ( type == DateTime )
		{
			if ( nativeObjectValue is DateTime )
				return nativeObjectValue;
			return DateTime.parse( nativeObjectValue );
		}
		if ( _isTypeEnum( type ) )
		{
			return NoMirrorsMapStore
				.getEnumGeneratedMap( type )
				.values[nativeObjectValue];
		}

		if ( type == double && nativeObjectValue != null )
		{
			return double.parse( nativeObjectValue.toString( ) );
		}


		return nativeObjectValue;
	}

	bool _isTypeEnum( Type type )
	{
		return NoMirrorsMapStore.containsEnumGeneratedMap( type );
	}
}