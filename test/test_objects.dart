library nomirrorsmap.test_objects;

import 'package:nomirrorsmap/nomirrorsmap.dart';

@Mappable()
enum TestEnum { One, Two }

abstract class TheAbstractClass {
  List<TheAbstractClass> data;
}

@Mappable()
class InheritedClass extends TheAbstractClass {}

@Mappable()
class TypeWithNoProperties {}

@Mappable()
class SimpleTypeUsingDollarRef {
  String name;
  List<SimpleTypeUsingDollarRef> people;
}

@Mappable()
class NewtonSoftTest {
  int age;
  String gender;
}

@Mappable()
class Person {
  int id;
  List<Person> parents;
  List<Person> children;
}

@Mappable()
class ClassWithDouble {
  double val;
}

//{"1|Matthew"}

@Mappable()
class CustomConverterParentTest {
  CustomConverterTest testProperty;
}

@Mappable()
class CustomConverterTest {
  int id;
  String value;
}

@Mappable()
class NoTypeTestClass {
  int id;
  String firstName;
  NoTypeTestPropertyClass testProperty;
}

@Mappable()
class NoTypeTestPropertyClass {
  int id;
  String name;
}

@Mappable()
class User {
  int id;
  String firstName;
  String lastName;
  String emailAddress;
  String mobilePhone;
  bool umpire;

  List<TeamMember> teamUsers;
  SecurityRole securityRole;
}

@Mappable()
class TeamMember {
  Role role;
  User user;
}

@Mappable()
class Role {
  int id;
  String name;
}

@Mappable()
class SecurityRole {
  int id;
  String name;
  String description;
  AssociationLevel associationLevel;
}

@Mappable()
class AssociationLevel {
  int id;
  String value;
}

@Mappable()
class ClassWithDateTime {
  DateTime time;
}

@Mappable()
class GenericBase<T> {
  T val;
}

@Mappable()
class PersonGeneric extends GenericBase<Person> {}

class TypeWithDuration {
  Duration duration;
}

class GenericType<T> {
  T id;
}
