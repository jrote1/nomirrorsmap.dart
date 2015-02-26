part of nomirrorsmap.conversion_objects;

class ListObjectData extends BaseObjectData
{

	bool get isNativeType
	=> true;

	List<BaseObjectData> values;
}