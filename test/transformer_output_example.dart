class NoMirrorsMapStore
{
	static void registerAccessor( String propertyName, void setter( dynamic object, dynamic value ), dynamic getter( dynamic object ) )
	{

	}

	static void registerClass( String fullName, Type type, dynamic instantiate(), Map<String, Type> properties ){

	}

	static void registerEnum( Type type, List values ){

	}
}

class Team
{

}

enum Teams
{
	One
}



class LiveScoringMappings
{
	void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	void _registerAccessors( )
	{
		NoMirrorsMapStore.registerAccessor( "id", ( object, value ) => object.id = value, (object) => object.id );
		NoMirrorsMapStore.registerAccessor( "name", ( object, value ) => object.name = value, (object) => object.name );
		NoMirrorsMapStore.registerAccessor( "date", ( object, value ) => object.date = value, (object) => object.date );
		NoMirrorsMapStore.registerAccessor( "type", ( object, value ) => object.type = value, (object) => object.type );
	}

	void _registerClasses()
	{
		NoMirrorsMapStore.registerClass( "LiveScoring.Entites.Team", Team, () => new Team(), const {
			"id": int,
			"name": String
		} );
	}

	void _registerEnums()
	{
		NoMirrorsMapStore.registerEnum( Teams, Teams.values );
	}
}