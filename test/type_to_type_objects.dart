library nomirrorsmap.type_to_type_objects;

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

class SourceType {
  int intProperty;
  String stringProperty;
}

class DestType {
  int intProperty;
}
