library nomirrorsmap.generated_maps;

import 'tests.dart';
import 'type_to_type_objects.dart' as objects;
import 'package:nomirrorsmap/src/shared/shared.dart';


//Transformer has to generate this
class NoMirrorsMapGeneratedMaps{
	static List load(){
		return [
			new ClassGeneratedMap(objects.BaseDto,"nomirrorsmap.type_to_type_objects.BaseDto", () => null, {}, true),
			new ClassGeneratedMap(objects.ConcreteWithNoMapEntity,"nomirrorsmap.type_to_type_objects.ConcreteWithNoMapEntity", () => new objects.ConcreteWithNoMapEntity(), {
				'id': new GeneratedPropertyMap( int, (obj) => obj.id, (obj, value) => obj.id = value ),
				'name': new GeneratedPropertyMap( String, (obj) => obj.name, (obj, value) => obj.name = value )
			}),
			new ClassGeneratedMap(objects.ConcreteEntity,"nomirrorsmap.type_to_type_objects.ConcreteEntity", () => new objects.ConcreteEntity(), {
				'id': new GeneratedPropertyMap( int, (obj) => obj.id, (obj, value) => obj.id = value ),
				'name': new GeneratedPropertyMap( String, (obj) => obj.name, (obj, value) => obj.name = value )
			}),
			new ClassGeneratedMap(objects.ConcreteDto,"nomirrorsmap.type_to_type_objects.ConcreteDto", () => new objects.ConcreteDto(), {
				'id': new GeneratedPropertyMap( int, (obj) => obj.id, (obj, value) => obj.id = value ),
				'name': new GeneratedPropertyMap( String, (obj) => obj.name, (obj, value) => obj.name = value )
			}),
			new ClassGeneratedMap(objects.InheritedDto,"nomirrorsmap.type_to_type_objects.InheritedDto", () => new objects.InheritedDto(), {
				'extraProperty': new GeneratedPropertyMap( int, (obj) => obj.extraProperty, (obj, value) => obj.extraProperty = value ),
				'stringProperty': new GeneratedPropertyMap( String, (obj) => obj.stringProperty, (obj, value) => obj.stringProperty = value ),
				'intProperty': new GeneratedPropertyMap( int, (obj) => obj.intProperty, (obj, value) => obj.intProperty = value ),
				'dateTimeProperty': new GeneratedPropertyMap( DateTime, (obj) => obj.dateTimeProperty, (obj, value) => obj.dateTimeProperty = value ),
				'doubleProperty': new GeneratedPropertyMap( double, (obj) => obj.doubleProperty, (obj, value) => obj.doubleProperty = value ),
				'boolProperty': new GeneratedPropertyMap( bool, (obj) => obj.boolProperty, (obj, value) => obj.boolProperty = value ),
				'numProperty': new GeneratedPropertyMap( num, (obj) => obj.numProperty, (obj, value) => obj.numProperty = value )
			}),
			new ClassGeneratedMap(objects.InheritedEntity,"nomirrorsmap.type_to_type_objects.InheritedEntity", () => new objects.InheritedEntity(), {
				'extraProperty': new GeneratedPropertyMap( int, (obj) => obj.extraProperty, (obj, value) => obj.extraProperty = value ),
				'stringProperty': new GeneratedPropertyMap( String, (obj) => obj.stringProperty, (obj, value) => obj.stringProperty = value ),
				'intProperty': new GeneratedPropertyMap( int, (obj) => obj.intProperty, (obj, value) => obj.intProperty = value ),
				'dateTimeProperty': new GeneratedPropertyMap( DateTime, (obj) => obj.dateTimeProperty, (obj, value) => obj.dateTimeProperty = value ),
				'doubleProperty': new GeneratedPropertyMap( double, (obj) => obj.doubleProperty, (obj, value) => obj.doubleProperty = value ),
				'boolProperty': new GeneratedPropertyMap( bool, (obj) => obj.boolProperty, (obj, value) => obj.boolProperty = value ),
				'numProperty': new GeneratedPropertyMap( num, (obj) => obj.numProperty, (obj, value) => obj.numProperty = value )
			}),
			new ListGeneratedMap(const TypeOf<objects.CustomList<objects.TestDto>>().type, objects.TestDto, () => new objects.CustomList<objects.TestDto>()),
			new ClassGeneratedMap(objects.CustomListEntity,"nomirrorsmap.type_to_type_objects.CustomListEntity", () => new objects.CustomListEntity(), {
				'list': new GeneratedPropertyMap( const TypeOf<objects.CustomList<objects.TestEntity>>().type, (obj) => obj.list, (obj, value) => obj.list = value )
			}),
			new ClassGeneratedMap(objects.CustomListDto,"nomirrorsmap.type_to_type_objects.CustomListDto", () => new objects.CustomListDto(), {
				'list': new GeneratedPropertyMap( const TypeOf<objects.CustomList<objects.TestDto>>().type, (obj) => obj.list, (obj, value) => obj.list = value )
			}),
			new ListGeneratedMap(const TypeOf<List<objects.TestDto>>().type, objects.TestDto, () => new List<objects.TestDto>()),
			new ClassGeneratedMap(objects.NonPrimitiveListEntity,"nomirrorsmap.type_to_type_objects.NonPrimitiveListEntity", () => new objects.NonPrimitiveListEntity(), {
				'list': new GeneratedPropertyMap( const TypeOf<List<objects.TestEntity>>().type, (obj) => obj.list, (obj, value) => obj.list = value )
			}),
			new ClassGeneratedMap(objects.NonPrimitiveListDto,"nomirrorsmap.type_to_type_objects.NonPrimitiveListDto", () => new objects.NonPrimitiveListDto(), {
				'list': new GeneratedPropertyMap( const TypeOf<List<objects.TestDto>>().type, (obj) => obj.list, (obj, value) => obj.list = value )
			}),
			new ClassGeneratedMap(objects.ListEntity,"nomirrorsmap.type_to_type_objects.ListEntity", () => new objects.ListEntity(), {
				'list': new GeneratedPropertyMap( const TypeOf<List<String>>().type, (obj) => obj.list, (obj, value) => obj.list = value )
			}),
			new ClassGeneratedMap(objects.ListDto,"nomirrorsmap.type_to_type_objects.ListDto", () => new objects.ListDto(), {
				'list': new GeneratedPropertyMap( const TypeOf<List<String>>().type, (obj) => obj.list, (obj, value) => obj.list = value )
			}),
			new ClassGeneratedMap(objects.TestEntity2,"nomirrorsmap.type_to_type_objects.TestEntity2", () => new objects.TestEntity2(), {
				'test': new GeneratedPropertyMap( objects.TestEntity, (obj) => obj.test, (obj, value) => obj.test = value )
			}),
			new ClassGeneratedMap(objects.TestDto2,"nomirrorsmap.type_to_type_objects.TestDto2", () => new objects.TestDto2(), {
				'test': new GeneratedPropertyMap( objects.TestDto, (obj) => obj.test, (obj, value) => obj.test = value )
			}),
			new ClassGeneratedMap(objects.TestDto,"nomirrorsmap.type_to_type_objects.TestDto", () => new objects.TestDto(), {
				'stringProperty': new GeneratedPropertyMap( String, (obj) => obj.stringProperty, (obj, value) => obj.stringProperty = value ),
				'intProperty': new GeneratedPropertyMap( int, (obj) => obj.intProperty, (obj, value) => obj.intProperty = value ),
				'dateTimeProperty': new GeneratedPropertyMap( DateTime, (obj) => obj.dateTimeProperty, (obj, value) => obj.dateTimeProperty = value ),
				'doubleProperty': new GeneratedPropertyMap( double, (obj) => obj.doubleProperty, (obj, value) => obj.doubleProperty = value ),
				'boolProperty': new GeneratedPropertyMap( bool, (obj) => obj.boolProperty, (obj, value) => obj.boolProperty = value ),
				'numProperty': new GeneratedPropertyMap( num, (obj) => obj.numProperty, (obj, value) => obj.numProperty = value )
			}),
			new ClassGeneratedMap(objects.TestEntity,"nomirrorsmap.type_to_type_objects.TestEntity", () => new objects.TestEntity(), {
				'stringProperty': new GeneratedPropertyMap( String, (obj) => obj.stringProperty, (obj, value) => obj.stringProperty = value ),
				'intProperty': new GeneratedPropertyMap( int, (obj) => obj.intProperty, (obj, value) => obj.intProperty = value ),
				'dateTimeProperty': new GeneratedPropertyMap( DateTime, (obj) => obj.dateTimeProperty, (obj, value) => obj.dateTimeProperty = value ),
				'doubleProperty': new GeneratedPropertyMap( double, (obj) => obj.doubleProperty, (obj, value) => obj.doubleProperty = value ),
				'boolProperty': new GeneratedPropertyMap( bool, (obj) => obj.boolProperty, (obj, value) => obj.boolProperty = value ),
				'numProperty': new GeneratedPropertyMap( num, (obj) => obj.numProperty, (obj, value) => obj.numProperty = value )
			}),
			new ClassGeneratedMap(InheritedClass,"nomirrorsmap.tests.InheritedClass", () => new InheritedClass(), {
				'data': new GeneratedPropertyMap( const TypeOf<List<TheAbstractClass>>().type, (obj) => obj.data, (obj, value) => obj.data = value )
			}),
			new ClassGeneratedMap(NewtonSoftTest,"nomirrorsmap.tests.NewtonSoftTest", () => new NewtonSoftTest(), {
				'age': new GeneratedPropertyMap( int, (obj) => obj.age, (obj, value) => obj.age = value ),
				'gender': new GeneratedPropertyMap( String, (obj) => obj.gender, (obj, value) => obj.gender = value )
			}),
			new ClassGeneratedMap(CustomConverterTest,"nomirrorsmap.tests.CustomConverterTest", () => new CustomConverterTest(), {
				'id': new GeneratedPropertyMap( int, (obj) => obj.id, (obj, value) => obj.id = value ),
				'value': new GeneratedPropertyMap( String, (obj) => obj.value, (obj, value) => obj.value = value )
			}),
			new EnumGeneratedMap( TestEnum, TestEnum.values ),
			new ClassGeneratedMap(User,"nomirrorsmap.tests.User", () => new User(), {
				'id': new GeneratedPropertyMap( int, (obj) => obj.id, (obj, value) => obj.id = value ),
				'firstName': new GeneratedPropertyMap( String, (obj) => obj.firstName, (obj, value) => obj.firstName = value ),
				'lastName': new GeneratedPropertyMap( String, (obj) => obj.lastName, (obj, value) => obj.lastName = value ),
				'emailAddress': new GeneratedPropertyMap( String, (obj) => obj.emailAddress, (obj, value) => obj.emailAddress = value ),
				'mobilePhone': new GeneratedPropertyMap( String, (obj) => obj.mobilePhone, (obj, value) => obj.mobilePhone = value ),
				'umpire': new GeneratedPropertyMap( bool, (obj) => obj.umpire, (obj, value) => obj.umpire = value ),
				'teamUsers': new GeneratedPropertyMap( const TypeOf<List<TeamMember>>().type, (obj) => obj.teamUsers, (obj, value) => obj.teamUsers = value ),
				'securityRole': new GeneratedPropertyMap( SecurityRole, (obj) => obj.securityRole, (obj, value) => obj.securityRole = value ),
			}),
			new ClassGeneratedMap(TeamMember,"nomirrorsmap.tests.TeamMember", () => new TeamMember(), {
				'role': new GeneratedPropertyMap( Role, (obj) => obj.role, (obj, value) => obj.role = value ),
				'user': new GeneratedPropertyMap( User, (obj) => obj.user, (obj, value) => obj.user = value )
			}),
			new ClassGeneratedMap(Role,"nomirrorsmap.tests.Role", () => new Role(), {
				'id': new GeneratedPropertyMap( int, (obj) => obj.id, (obj, value) => obj.id = value ),
				'name': new GeneratedPropertyMap( String, (obj) => obj.name, (obj, value) => obj.name = value )
			}),
			new ClassGeneratedMap(AssociationLevel,"nomirrorsmap.tests.AssociationLevel", () => new AssociationLevel(), {
				'id': new GeneratedPropertyMap( int, (obj) => obj.id, (obj, value) => obj.id = value ),
				'value': new GeneratedPropertyMap( String, (obj) => obj.value, (obj, value) => obj.value = value )
			}),
			new ListGeneratedMap(const TypeOf<List<TeamMember>>().type, TeamMember, () => new List<TeamMember>()),
			new ListGeneratedMap(const TypeOf<List<String>>().type, String, () => new List<String>()),
			new ListGeneratedMap(const TypeOf<List<Person>>().type, Person, () => new List<Person>()),
			new ClassGeneratedMap(TypeWithNoProperties,"nomirrorsmap.tests.TypeWithNoProperties", () => new TypeWithNoProperties(), {}),
			new ListGeneratedMap(const TypeOf<List<TypeWithNoProperties>>().type, TypeWithNoProperties, () => new List<TypeWithNoProperties>()),
			new ListGeneratedMap(const TypeOf<List<SimpleTypeUsingDollarRef>>().type, SimpleTypeUsingDollarRef, () => new List<SimpleTypeUsingDollarRef>()),
			new ClassGeneratedMap(SimpleTypeUsingDollarRef,"nomirrorsmap.tests.SimpleTypeUsingDollarRef", () => new SimpleTypeUsingDollarRef(), {
				'name': new GeneratedPropertyMap( String, (obj) => obj.name, (obj, value) => obj.name = value ),
				'people': new GeneratedPropertyMap( const TypeOf<List<SimpleTypeUsingDollarRef>>().type, (obj) => obj.people, (obj, value) => obj.people = value )
			}),
			new ClassGeneratedMap(ClassWithDouble,"nomirrorsmap.tests.ClassWithDouble", () => new ClassWithDouble(), {
				'val': new GeneratedPropertyMap( double, (obj) => obj.val, (obj, value) => obj.val = value )
			}),
			new ClassGeneratedMap(NoTypeTestPropertyClass,"nomirrorsmap.tests.NoTypeTestPropertyClass", () => new NoTypeTestPropertyClass(), {
				'id': new GeneratedPropertyMap( int, (obj) => obj.id, (obj, value) => obj.id = value ),
				'name': new GeneratedPropertyMap(String, (obj) => obj.name, (obj, value) => obj.name = value )
			}),
			new ClassGeneratedMap(NoTypeTestClass,"nomirrorsmap.tests.NoTypeTestClass", () => new NoTypeTestClass(), {
				'id': new GeneratedPropertyMap( int, (obj) => obj.id, (obj, value) => obj.id = value ),
				'firstName': new GeneratedPropertyMap(String, (obj) => obj.firstName, (obj, value) => obj.firstName = value ),
				'testProperty': new GeneratedPropertyMap( NoTypeTestPropertyClass, (obj) => obj.testProperty, (obj, value) => obj.testProperty = value )
			}),
			new ListGeneratedMap(const TypeOf<CustomList<String>>().type, String, () => new CustomList<String>()),
			new ClassGeneratedMap(TestObjectWithCustomList,"nomirrorsmap.tests.TestObjectWithCustomList", () => new TestObjectWithCustomList(), {
				'customList': new GeneratedPropertyMap( const TypeOf<CustomList<String>>().type, (obj) => obj.customList, (obj, value) => obj.customList = value )
			}),
			new ClassGeneratedMap(CustomConverterParentTest,"nomirrorsmap.tests.CustomConverterParentTest", () => new CustomConverterParentTest(), {
				'testProperty': new GeneratedPropertyMap( CustomConverterTest, (obj) => obj.testProperty, (obj, value) => obj.testProperty = value )
			}),
			new ClassGeneratedMap(Person,"nomirrorsmap.tests.Person", () => new Person(), {
				'id': new GeneratedPropertyMap( int, (obj) => obj.id, (obj, value) => obj.id = value ),
				'parents': new GeneratedPropertyMap( const TypeOf<List<Person>>().type, (obj) => obj.parents, (obj, value) => obj.parents = value ),
				'children': new GeneratedPropertyMap( const TypeOf<List<Person>>().type, (obj) => obj.children, (obj, value) => obj.children = value )
			}),
			new ClassGeneratedMap(SecurityRole,"nomirrorsmap.tests.SecurityRole", () => new SecurityRole(), {
				'id': new GeneratedPropertyMap( int, (obj) => obj.id, (obj, value) => obj.id = value ),
				'name': new GeneratedPropertyMap( String, (obj) => obj.name, (obj, value) => obj.name = value ),
				'description': new GeneratedPropertyMap( String, (obj) => obj.description, (obj, value) => obj.description = value ),
				'associationLevel': new GeneratedPropertyMap( AssociationLevel, (obj) => obj.associationLevel, (obj, value) => obj.associationLevel = value )
			}),
			new ClassGeneratedMap(ClassWithDateTime,"nomirrorsmap.tests.User", () => new ClassWithDateTime(), {
				'time': new GeneratedPropertyMap( DateTime, (obj) => obj.time, (obj, value) => obj.time = value )
			})
		];
	}
}

