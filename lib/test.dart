library nomirrormap.maps.livescoring.entitis;

import 'package:LiveScoring/entities/entities.dart';

import 'package:library/nomirrorsmaps.dart' as library;

class ClientInformationMap implements ObjectMap<ClientInformation>
{
	Type get type
	=> SecurityRole;

	String get typeString
	=> "LiveScoring.entities.ClientInformation";

	ClientInformation createInstance( )
	=> new ClientInformation( );

	Map<String, dynamic> encode( MapEngine mapEngine, ClientInformation obj )
	{
		return {
			"authenticatedUserId": obj.authenticatedUserId,
			"umpire": obj.umpire,
			"teamOrganiser": obj.teamOrganiser,
			"securityRole": mapEngine.encode( obj.securityRole )
		};
	}

	void decode( ClientInformation instance, MapEngine mapEngine, Map<String, dynamic> values )
	{
		instance.authenticatedUserId = values["authenticatedUserId"];
		instance.umpire = values["umpire"];
		instance.teamOrganiser = values["teamOrganiser"];
		instance.securityRole = mapEngine.decode( values["securityRole"], SecurityRole );
	}
}

class Initializer
{
	void add( )
	{
		MapEngine.maps.addAll( [new ClientInformationMap( )] );
		library.Initializer.add( );
	}
}


class MapEngine
{
	static List<ObjectMap> maps = [];
}

abstract class ObjectMap<T>
{
	Type get type;

	String get typeString;

	T createInstance( )

	Map<String, dynamic> encode( MapEngine mapEngine, T obj );

	void decode( T instance, MapEngine mapEngine, Map<String, dynamic> values );
}