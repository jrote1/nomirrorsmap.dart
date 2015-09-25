part of nomirrorsmap.converters;

abstract class Converter {
  BaseIntermediateObject toBaseIntermediateObject(dynamic value);

  dynamic fromBaseIntermediateObject(BaseIntermediateObject baseObjectData);
}
