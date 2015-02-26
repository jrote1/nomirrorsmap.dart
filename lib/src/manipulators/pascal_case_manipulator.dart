part of nomirrorsmap.manipulators;

class PascalCaseManipulator implements BaseObjectDataManipulator{

	void manipulate( BaseObjectData baseObjectData )
	{
		if(baseObjectData is ClassObjectData){
			ClassObjectData classObjectData = baseObjectData;

			var newProperties = {};

			classObjectData.properties.forEach((k,v){
				newProperties[k[0].toUpperCase() + k.substring(1)] = v;
				manipulate(v);
			});

			classObjectData.properties = newProperties;
		}
	}
}