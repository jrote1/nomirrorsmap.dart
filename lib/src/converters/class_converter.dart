part of nomirrorsmap.converters;



class ClassConverter implements Converter
{
	Type startType;

	ClassConverter( {this.startType} );

	static Map<Type, CustomClassConverter> converters = {
	};

	List<String> seenHashCodes = [];

	BaseObjectData toBaseObjectData( dynamic value )
	{
		var valueType = value.runtimeType;
		if ( converters.containsKey( valueType ) )
			value = converters[valueType].from( value );

		if ( _isPrimitive( value ) )
			return new NativeObjectData( )
				..objectType = valueType
				..value = value;
		if(_isEnum( value )){
			return new NativeObjectData( )
				..objectType = int
				..value = value.index;
		}

		if ( value is List )
		{
			return new ListObjectData( )
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

		var generatedMap = GeneratedMapProvider.getClassGeneratedMap( (value as Object).runtimeType );

		var properties = {
		};

		generatedMap.properties.forEach((name, propertyMap){
			properties[name] = toBaseObjectData( propertyMap.getValue( value ) );
		});

		return new ClassObjectData( )
			..objectType = valueType
			..previousHashCode = value.hashCode.toString( )
			..properties = properties;
	}

	bool _isEnum( dynamic value )
	{
		//Not safe
		return _isTypeEnum(value.runtimeType);
	}

	bool _isPrimitive( v )	=> v is num || v is bool || v is String || v == null || v is DateTime;

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
			var generatedMap = GeneratedMapProvider.getClassGeneratedMap(type);
			var instance = generatedMap.initialize();


			ClassConverterInstance classConverterInstance;
			if ( baseObjectData.previousHashCode != null && instances.containsKey( baseObjectData.previousHashCode ) )
				classConverterInstance = instances[baseObjectData.previousHashCode];
			else
			{
				classConverterInstance = new ClassConverterInstance( )
					..filled = false
					..instance = instance;

				if(baseObjectData.previousHashCode != null)
					instances[baseObjectData.previousHashCode] = classConverterInstance;
			}
			if ( !classConverterInstance.filled && baseObjectData.properties.length > 0 )
			{
				generatedMap.properties.forEach((name, propertyMap){
					if ( baseObjectData.properties.containsKey( name ) )
					{
						var propertyObjectData = baseObjectData.properties[name];
						var propertyType = propertyObjectData.objectType == null ? propertyMap.type : propertyObjectData.objectType;
						var value = _fromBaseObjectData( propertyObjectData, propertyType );
						if ( converters.containsKey( propertyType ) )
							value = converters[propertyType].to( value );
						if ( value is List )
						{
							var list = GeneratedMapProvider.getListGeneratedMap( propertyType ).initialize();
							list.addAll( value );
							value = list;
						}
						propertyMap.setValue( classConverterInstance.instance, value );
					}
				});
				classConverterInstance.filled = true;
			}
			return classConverterInstance.instance;
		}
		if ( baseObjectData is ListObjectData )
		{
			var listType = GeneratedMapProvider.getListGeneratedMap(type).innerType;

			return baseObjectData.values.map( ( v )
											  => _fromBaseObjectData( v, v.objectType == null ? listType : v.objectType ) ).toList( );
		}
		var nativeObjectValue = (baseObjectData as NativeObjectData).value;

		if( type == DateTime){
			if(nativeObjectValue is DateTime)
				return nativeObjectValue;
			return DateTime.parse( nativeObjectValue );
		}
		if(_isTypeEnum(type)){
			return GeneratedMapProvider.getEnumGeneratedMap(type).values[nativeObjectValue];
		}
		
		if (type == double && nativeObjectValue != null)
		{
			return double.parse(  nativeObjectValue.toString());
		}


		return nativeObjectValue;
	}

	bool _isTypeEnum( Type type )
	{
		return GeneratedMapProvider.containsEnumGeneratedMap(type);
	}
}