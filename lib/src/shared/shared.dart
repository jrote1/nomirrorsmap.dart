library nomirrorsmap.shared;

class EnumGeneratedMap<T> extends GeneratedMap
{
	EnumGeneratedMap(Type type, this.values){
		this.type = type;
	}

	List<dynamic> values;
}

class ClassGeneratedMap extends InstanceGeneratedMap
{
	ClassGeneratedMap(Type type, this.qualifiedName, dynamic initialize(), this.properties, [bool isAbstract = false]){
		this.type = type;
		this.initialize = initialize;
		this.isAbstract = isAbstract;
	}

	String qualifiedName;
	Map<String, GeneratedPropertyMap> properties;
}

class ListGeneratedMap extends InstanceGeneratedMap
{
	ListGeneratedMap(Type type, this.innerType, dynamic initialize(), [bool isAbstract = false]){
		this.type = type;
		this.initialize = initialize;
		this.isAbstract = isAbstract;
	}

	Type innerType;
}

abstract class InstanceGeneratedMap extends GeneratedMap{
	bool isAbstract;

	//initialize()
	Function initialize;
}

abstract class GeneratedMap{
	Type type;
}

class GeneratedPropertyMap{
	GeneratedPropertyMap( this.type, dynamic getValue( dynamic obj ), void setValue( dynamic obj, dynamic value ) ){
		this.getValue = getValue;
		this.setValue = setValue;
	}

	Type type;

	//getValue( Object obj );
	Function getValue;

	//setValue( Object obj, Object value );
	Function setValue;
}

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

class GeneratedMapProvider1{
	static List<GeneratedMap> _maps = [];

	static ClassGeneratedMap getClassGeneratedMap(Type type){
		if(_maps.where((m) => m is ClassGeneratedMap).any((m) => m.type == type))
			return _maps.where((m) => m is ClassGeneratedMap).firstWhere((m) => m.type == type );
		throw "Can't find map for type '${type.toString()}' is it missing the @Map() annotation ";
	}

	static ClassGeneratedMap getClassGeneratedMapByQualifiedName( String qualifiedName )
	{
		if(_maps.where((m) => m is ClassGeneratedMap).any((m) => m.qualifiedName == qualifiedName ))
			return _maps.where((m) => m is ClassGeneratedMap).firstWhere((m) => m.qualifiedName == qualifiedName);
		throw "Can't find map for type '$qualifiedName' is it missing the @Map() annotation ";
	}

	static ListGeneratedMap getListGeneratedMap(Type type){
		if(_maps.where((m) => m is ListGeneratedMap).any((m) => m.type == type))
			return _maps.where((m) => m is ListGeneratedMap).firstWhere((m) => m.type == type);
		throw "Can't find map for type '${type.toString()}' is it missing the @Map() annotation ";
	}

	static EnumGeneratedMap getEnumGeneratedMap(Type type){
		if(_maps.where((m) => m is EnumGeneratedMap).any((m) => m.type == type))
			return _maps.where((m) => m is EnumGeneratedMap).firstWhere((m) => m.type == type);
		throw "Can't find map for type '${type.toString()}' is it missing the @Map() annotation ";
	}

	static bool containsEnumGeneratedMap(Type type){
		return _maps.where((m) => m is EnumGeneratedMap).any((m) => m.type == type);
	}

	static void addMaps( List<GeneratedMap> maps )
	{
		_maps.addAll(maps);
	}
}