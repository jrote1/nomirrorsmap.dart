library nomirrorsmap;

export 'src/converters/converters.dart';

import 'src/converters/converters.dart';

class NoMirrorsMap
{
	dynamic convert( dynamic value, Converter sourceConverter, Converter destinationConverter )
	{
		var convertedSource = sourceConverter.toBaseObjectData( value );
		return destinationConverter.fromBaseObjectData( convertedSource );
	}
}