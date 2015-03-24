part of nomirrorsmap.converters;

class NewtonSoftJsonConverter extends JsonConverter
{
	Map<String,String> fromJsonHashCodesAndTypes = new Map<String,String>();
	List<String> toJsonSeenHashcodes = new List<String>();

	@override
	void setMetaData(Map result, String hashcode, ClassObjectData classObjectData){
		if (toJsonSeenHashcodes.contains(hashcode))
			result["\$ref"] = hashcode;
		else
		{
			toJsonSeenHashcodes.add(hashcode);
			result["\$id"] = hashcode;
			setTypeFromObjectType(result, classObjectData);
		}
	}

	@override
	String getPreviousHashcode(Map json)
	{
		if (json.containsKey("\$ref"))
			return json["\$ref"];

		return json["\$id"];
	}

	@override
	Type findObjectType(dynamic json)
	{
		Type objectType = null;

		if (json.containsKey("\$type"))
			objectType = _getClassMirrorByName( json["\$type"] ).reflectedType;
		else if
		(!json.containsKey("\$type") && fromJsonHashCodesAndTypes.containsKey(json["\$ref"]) )
			objectType = _getClassMirrorByName( fromJsonHashCodesAndTypes[json["\$ref"]] ).reflectedType;

		return objectType;
	}

	@override
	void afterCreatingClassObjectData(ClassObjectData classObjectData)
	{
		if (!fromJsonHashCodesAndTypes.containsKey(classObjectData.previousHashCode) && classObjectData.properties.containsKey("\$type"))
			fromJsonHashCodesAndTypes[classObjectData.previousHashCode] = classObjectData.properties["\$type"].value;
	}

}