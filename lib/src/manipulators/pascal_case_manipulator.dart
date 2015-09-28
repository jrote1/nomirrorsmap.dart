part of nomirrorsmap.manipulators;

class PascalCaseManipulator extends BaseClassIteratorDataManipulator {
  String manipulatePropertyName(String propertyName) =>
      propertyName[0].toUpperCase() + propertyName.substring(1);
}
