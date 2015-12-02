library nomirrorsmap.shared;

import 'package:nomirrorsmap/src/conversion_objects/conversion_objects.dart';

class CustomClassConverter<TActualType> {
  Function _fromFunc;

  set from(BaseIntermediateObject func(TActualType val)) {
    _fromFunc = func;
  }

  Function get from => _fromFunc;

  Function _toFunc;

  set to(TActualType func(BaseIntermediateObject val)) {
    _toFunc = func;
  }

  Function get to => _toFunc;
}

class Mappable {
  const Mappable();
}

class TypeOf<T> {
  const TypeOf();

  Type get type => T;
}