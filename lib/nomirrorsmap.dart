library nomirrorsmap;

export 'src/converters/converters.dart';
export 'src/manipulators/manipulators.dart';
export 'src/shared/shared.dart';

import 'src/converters/converters.dart';
import 'src/manipulators/manipulators.dart';

class NoMirrorsMap {
  NoMirrorsMap() {
    TypeInformationRetrieverLocator.setInstance(new NoMirrorsMapStore());
  }

  dynamic convert(dynamic value, Converter sourceConverter, Converter destinationConverter,
      [List<BaseObjectDataManipulator> manipulators]) {
    var convertedSource = sourceConverter.toBaseIntermediateObject(value);
    if (manipulators != null) manipulators.forEach((m) => m.manipulate(convertedSource));
    return destinationConverter.fromBaseIntermediateObject(convertedSource);
  }
}
