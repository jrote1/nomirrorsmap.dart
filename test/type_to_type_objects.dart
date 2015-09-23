library nomirrorsmap.type_to_type_objects;

import 'dart:collection';

class TestEntity {
  String stringProperty;
  int intProperty;
  DateTime dateTimeProperty;
  double doubleProperty;
  bool boolProperty;
  num numProperty;
}

class TestDto {
  String stringProperty;
  int intProperty;
  DateTime dateTimeProperty;
  double doubleProperty;
  bool boolProperty;
  num numProperty;
}

class TestEntity2 {
  TestEntity test;
}

class TestDto2 {
  TestDto test;
}

class ListEntity {
  List<String> list;
}

class ListDto {
  List<String> list;
}

class NonPrimitiveListEntity {
  List<TestEntity> list;
}

class NonPrimitiveListDto {
  List<TestDto> list;
}

class CustomListEntity {
  CustomList<TestEntity> list;
}

class CustomListDto {
  CustomList<TestDto> list;
}

class CustomList<E> extends ListBase<E> {
  var innerList = new List<E>();

  int get length => innerList.length;

  void set length(int length) {
    innerList.length = length;
  }

  void operator []=(int index, E value) {
    innerList[index] = value;
  }

  E operator [](int index) => innerList[index];

  // Though not strictly necessary, for performance reasons
  // you should implement add and addAll.

  void add(E value) => innerList.add(value);

  void addAll(Iterable<E> all) => innerList.addAll(all);
}

class InheritedDto extends TestDto {
  int extraProperty;
}

class InheritedEntity extends TestEntity {
  int extraProperty;
}

abstract class BaseEntity {
  int id;
  String name;
}

abstract class BaseDto {
  int id;
  String name;
}

class ConcreteEntity extends BaseEntity {}

class ConcreteDto extends BaseDto {}

class ConcreteWithNoMapEntity extends BaseEntity {}
