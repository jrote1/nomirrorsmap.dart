part of nomirrorsmap.parsers;

class JsonParser implements Converter
{

	Map<String, dynamic> parse( dynamic value )	=> JSON.decode( value );

	dynamic deparse( Map<String, dynamic> values ) => JSON.encode( values );

}