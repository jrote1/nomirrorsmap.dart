library TestProject.Mappings;

import 'package:nomirrorsmap/src/converters/converters.dart';
import 'main.dart' as web_main_dart;

class TestProjectMappings {
  static void register() {
    _registerAccessors();
    _registerClasses();
    _registerEnums();
  }

  static void _registerAccessors() {
    NoMirrorsMapStore.registerAccessor("data", (object, value) => object.data = value, (object) => object.data);
    NoMirrorsMapStore.registerAccessor("name", (object, value) => object.name = value, (object) => object.name);
    NoMirrorsMapStore.registerAccessor("people", (object, value) => object.people = value, (object) => object.people);
    NoMirrorsMapStore.registerAccessor("age", (object, value) => object.age = value, (object) => object.age);
    NoMirrorsMapStore.registerAccessor("gender", (object, value) => object.gender = value, (object) => object.gender);
    NoMirrorsMapStore.registerAccessor("id", (object, value) => object.id = value, (object) => object.id);
    NoMirrorsMapStore.registerAccessor("parents", (object, value) => object.parents = value, (object) => object.parents);
    NoMirrorsMapStore.registerAccessor("children", (object, value) => object.children = value, (object) => object.children);
    NoMirrorsMapStore.registerAccessor("val", (object, value) => object.val = value, (object) => object.val);
    NoMirrorsMapStore.registerAccessor("testProperty", (object, value) => object.testProperty = value, (object) => object.testProperty);
    NoMirrorsMapStore.registerAccessor("value", (object, value) => object.value = value, (object) => object.value);
    NoMirrorsMapStore.registerAccessor("customList", (object, value) => object.customList = value, (object) => object.customList);
    NoMirrorsMapStore.registerAccessor("firstName", (object, value) => object.firstName = value, (object) => object.firstName);
    NoMirrorsMapStore.registerAccessor("lastName", (object, value) => object.lastName = value, (object) => object.lastName);
    NoMirrorsMapStore.registerAccessor("emailAddress", (object, value) => object.emailAddress = value, (object) => object.emailAddress);
    NoMirrorsMapStore.registerAccessor("mobilePhone", (object, value) => object.mobilePhone = value, (object) => object.mobilePhone);
    NoMirrorsMapStore.registerAccessor("umpire", (object, value) => object.umpire = value, (object) => object.umpire);
    NoMirrorsMapStore.registerAccessor("teamUsers", (object, value) => object.teamUsers = value, (object) => object.teamUsers);
    NoMirrorsMapStore.registerAccessor("securityRole", (object, value) => object.securityRole = value, (object) => object.securityRole);
    NoMirrorsMapStore.registerAccessor("role", (object, value) => object.role = value, (object) => object.role);
    NoMirrorsMapStore.registerAccessor("user", (object, value) => object.user = value, (object) => object.user);
    NoMirrorsMapStore.registerAccessor("description", (object, value) => object.description = value, (object) => object.description);
    NoMirrorsMapStore.registerAccessor("associationLevel", (object, value) => object.associationLevel = value, (object) => object.associationLevel);
    NoMirrorsMapStore.registerAccessor("time", (object, value) => object.time = value, (object) => object.time);
  }

  static void _registerClasses() {
    NoMirrorsMapStore.registerClass("InheritedClass", web_main_dart.InheritedClass, () => new web_main_dart.InheritedClass(), const {'data': List});
    NoMirrorsMapStore.registerClass(
        "TypeWithNoProperties", web_main_dart.TypeWithNoProperties, () => new web_main_dart.TypeWithNoProperties(), const {});
    NoMirrorsMapStore.registerClass("SimpleTypeUsingDollarRef", web_main_dart.SimpleTypeUsingDollarRef,
        () => new web_main_dart.SimpleTypeUsingDollarRef(), const {'name': String, 'people': List});
    NoMirrorsMapStore.registerClass(
        "NewtonSoftTest", web_main_dart.NewtonSoftTest, () => new web_main_dart.NewtonSoftTest(), const {'age': int, 'gender': String});
    NoMirrorsMapStore.registerClass(
        "Person", web_main_dart.Person, () => new web_main_dart.Person(), const {'id': int, 'parents': List, 'children': List});
    NoMirrorsMapStore.registerClass(
        "ClassWithDouble", web_main_dart.ClassWithDouble, () => new web_main_dart.ClassWithDouble(), const {'val': double});
    NoMirrorsMapStore.registerClass("CustomConverterParentTest", web_main_dart.CustomConverterParentTest,
        () => new web_main_dart.CustomConverterParentTest(), const {'testProperty': web_main_dart.CustomConverterTest});
    NoMirrorsMapStore.registerClass(
        "CustomConverterTest", web_main_dart.CustomConverterTest, () => new web_main_dart.CustomConverterTest(), const {'id': int, 'value': String});
    NoMirrorsMapStore.registerClass("TestObjectWithCustomList", web_main_dart.TestObjectWithCustomList,
        () => new web_main_dart.TestObjectWithCustomList(), const {'customList': web_main_dart.CustomList});
    NoMirrorsMapStore.registerClass("NoTypeTestClass", web_main_dart.NoTypeTestClass, () => new web_main_dart.NoTypeTestClass(),
        const {'id': int, 'firstName': String, 'testProperty': web_main_dart.NoTypeTestPropertyClass});
    NoMirrorsMapStore.registerClass("NoTypeTestPropertyClass", web_main_dart.NoTypeTestPropertyClass,
        () => new web_main_dart.NoTypeTestPropertyClass(), const {'id': int, 'name': String});
    NoMirrorsMapStore.registerClass("User", web_main_dart.User, () => new web_main_dart.User(), const {
      'id': int,
      'firstName': String,
      'lastName': String,
      'emailAddress': String,
      'mobilePhone': String,
      'umpire': bool,
      'teamUsers': List,
      'securityRole': web_main_dart.SecurityRole
    });
    NoMirrorsMapStore.registerClass(
        "TeamMember", web_main_dart.TeamMember, () => new web_main_dart.TeamMember(), const {'role': web_main_dart.Role, 'user': web_main_dart.User});
    NoMirrorsMapStore.registerClass("Role", web_main_dart.Role, () => new web_main_dart.Role(), const {'id': int, 'name': String});
    NoMirrorsMapStore.registerClass("SecurityRole", web_main_dart.SecurityRole, () => new web_main_dart.SecurityRole(),
        const {'id': int, 'name': String, 'description': String, 'associationLevel': web_main_dart.AssociationLevel});
    NoMirrorsMapStore.registerClass(
        "AssociationLevel", web_main_dart.AssociationLevel, () => new web_main_dart.AssociationLevel(), const {'id': int, 'value': String});
    NoMirrorsMapStore.registerClass(
        "ClassWithDateTime", web_main_dart.ClassWithDateTime, () => new web_main_dart.ClassWithDateTime(), const {'time': DateTime});
  }

  static void _registerEnums() {
    NoMirrorsMapStore.registerEnum(web_main_dart.TestEnum, web_main_dart.TestEnum.values);
  }
}
