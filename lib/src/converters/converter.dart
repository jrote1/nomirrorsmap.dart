part of nomirrorsmap.parsers;

abstract class Converter{
	Map<String, dynamic> parse(dynamic value);
	dynamic deparse(Map<String, dynamic> values);
}