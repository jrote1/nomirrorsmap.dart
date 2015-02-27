part of nomirrorsmap.manipulators;

abstract class BaseClassIteratorDataManipulator implements BaseObjectDataManipulator
{

	void manipulate( BaseObjectData baseObjectData )
	{
		if ( baseObjectData is ClassObjectData )
		{
			ClassObjectData classObjectData = baseObjectData;

			var newProperties = {
			};

			classObjectData.properties.forEach( ( k, v )
												{
													newProperties[manipulatePropertyName( k )] = v;
													manipulate( v );
												} );

			classObjectData.properties = newProperties;
		}
	}

	String manipulatePropertyName( String propertyName );
}