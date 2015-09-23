part of nomirrorsmap.manipulators;

class CamelCaseManipulator extends BaseClassIteratorDataManipulator {
  String manipulatePropertyName(String propertyName) => propertyName[0].toLowerCase() + propertyName.substring(1);
}
