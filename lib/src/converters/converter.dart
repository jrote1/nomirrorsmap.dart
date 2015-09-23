part of nomirrorsmap.converters;

abstract class Converter {
  BaseObjectData toBaseObjectData(dynamic value);

  dynamic fromBaseObjectData(BaseObjectData baseObjectData);
}
