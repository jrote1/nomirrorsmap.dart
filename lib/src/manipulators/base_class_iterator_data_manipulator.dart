part of nomirrorsmap.manipulators;

abstract class BaseClassIteratorDataManipulator implements BaseObjectDataManipulator {
  void manipulate(BaseIntermediateObject baseObjectData) {
    if (baseObjectData is ClassIntermediateObject) {
      ClassIntermediateObject classObjectData = baseObjectData;

      var newProperties = {};

      classObjectData.properties.forEach((k, v) {
        newProperties[manipulatePropertyName(k)] = v;
        manipulate(v);
      });

      classObjectData.properties = newProperties;
    }
    if (baseObjectData is ListIntermediateObject) {
      for (var value in baseObjectData.values) {
        manipulate(value);
      }
    }
  }

  String manipulatePropertyName(String propertyName) => propertyName;
}
