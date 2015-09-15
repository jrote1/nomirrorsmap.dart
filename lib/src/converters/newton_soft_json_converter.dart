part of nomirrorsmap.converters;

class NewtonSoftJsonConverter extends JsonConverter
{
	HashMap<String,Type> fromJsonHashCodesAndTypes = new HashMap<String,Type>(equals: (a,b) => a == b);
	HashSet<String> toJsonSeenHashcodes = new HashSet<String>(equals: (a,b) => a == b);

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
		else
		{
			if
			( !json.containsKey( "\$type" ) && fromJsonHashCodesAndTypes.containsKey( json["\$ref"] ) )
				objectType =fromJsonHashCodesAndTypes[json["\$ref"]];
		}

		return objectType;
	}

	@override
	void afterCreatingClassObjectData(ClassObjectData classObjectData)
	{
		if (!fromJsonHashCodesAndTypes.containsKey(classObjectData.previousHashCode) && classObjectData.objectType != null)
			fromJsonHashCodesAndTypes[classObjectData.previousHashCode] = classObjectData.objectType;
	}

}