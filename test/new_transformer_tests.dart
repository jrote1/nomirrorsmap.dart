library transformer.tests;

import 'package:test/test.dart';
import 'package:nomirrorsmap/src/transformer/transformer.dart';
import 'package:dart_style/dart_style.dart';

import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/tests.dart';
import 'package:code_transformers/src/dart_sdk.dart';

String MAP_LIBRARY = '''
		library nomirrorsmap;

		class Mappable{
			const Mappable();
		}
	''';

List getPhases([List<String> libraryNames = const []]) {
  var resolvers = new Resolvers(dartSdkDirectory);

  return [
    [
      new MapGeneratorTransformer(
          resolvers, new TransformerOptions.initialize(libraryNames))
    ]
  ];
}

String mappingsClassGenerator(List<String> imports, List<String> propertyMaps,
    List<String> classMaps, List<String> enumMaps) {
  var source = '''library WebMainDartMappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
${imports.join("\n")}

class WebMainDartMappings
{
	static void register( )
	{
		_registerFields( );
		_registerClasses( );
		_registerEnums( );
	}
	static void _registerFields()
	{
		${propertyMaps.map((name)=>'''NoMirrorsMapStore.registerField( "$name", ( object, value ) => object.$name = value, (object) => object.$name );''').join("\n")}
	}
	static void _registerClasses()
	{
		${classMaps.join("\n")}
	}
	static void _registerEnums()
	{
		${enumMaps.join("\n")}
	}
}''';

  return new DartFormatter().format(source);
}

class TransformerTests {
  static void run() {
    test("With empty type generates mappings", () {
      return applyTransformers(getPhases(), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class TestClass
{

}'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'main.dart' as web_main_dart;"
        ], [], [
          '''NoMirrorsMapStore.registerClass( "TestClass", web_main_dart.TestClass, const TypeOf<List<web_main_dart.TestClass>>().type, () => new web_main_dart.TestClass(), {
		} );'''
        ], [])
      });
    });

    test("With type with properties of native types generates mappings", () {
      return applyTransformers(getPhases(), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class TestClass
{
	String stringVal;
	int intVal;
}'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'main.dart' as web_main_dart;"
        ], [
          "stringVal",
          "intVal"
        ], [
          '''NoMirrorsMapStore.registerClass( "TestClass", web_main_dart.TestClass, const TypeOf<List<web_main_dart.TestClass>>().type, () => new web_main_dart.TestClass(), {
			'stringVal': String,
			'intVal': int
		} );'''
        ], [])
      });
    });

    test("With type with properties of seen types", () {
      return applyTransformers(getPhases(), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class TestClass
{
	TestClass testClass;
}'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'main.dart' as web_main_dart;"
        ], [
          "testClass"
        ], [
          '''NoMirrorsMapStore.registerClass( "TestClass", web_main_dart.TestClass, const TypeOf<List<web_main_dart.TestClass>>().type, () => new web_main_dart.TestClass(), {
			'testClass': web_main_dart.TestClass
		} );'''
        ], [])
      });
    });

    test("With type in different package", () {
      return applyTransformers(getPhases(), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:testProject1/testProject1.dart';

        main() {}''',
        'testProject1|lib/testProject1.dart': '''library TestProject1;

          import 'package:nomirrorsmap/nomirrorsmap.dart';

          part 'test_class.dart';''',
        'testProject1|lib/test_class.dart': '''part of TestProject1;

          @Mappable()
          class TestClass
          {
            TestClass testClass;
          }

          @Mappable()
          enum TestEnum {
            One
          }'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'package:testProject1/testProject1.dart' as lib_testProject1_dart;"
        ], [
          "testClass"
        ], [
          '''NoMirrorsMapStore.registerClass( "TestProject1.TestClass", lib_testProject1_dart.TestClass, const TypeOf<List<lib_testProject1_dart.TestClass>>().type, () => new lib_testProject1_dart.TestClass(), {
			'testClass': lib_testProject1_dart.TestClass
		} );'''
        ], [
          "NoMirrorsMapStore.registerEnum( lib_testProject1_dart.TestEnum, lib_testProject1_dart.TestEnum.values );"
        ])
      });
    });

    test("With type that is enum", () {
      return applyTransformers(getPhases(), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
enum MyEnum
{
	EnumValue1,
	EnumValue2,
	EnumValue3,
	EnumValue4
}
'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'main.dart' as web_main_dart;"
        ], [], [], [
          "NoMirrorsMapStore.registerEnum( web_main_dart.MyEnum, web_main_dart.MyEnum.values );"
        ])
      });
    });

    test("With type that has base types", () {
      return applyTransformers(getPhases(), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class Type1 extends Type2
{
	int intVal;
}

class Type2 extends Type3
{
	String stringVal;
}

class Type3
{
	DateTime dateTimeVal;
}
'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'main.dart' as web_main_dart;"
        ], [
          "intVal",
          "stringVal",
          "dateTimeVal"
        ], [
          '''NoMirrorsMapStore.registerClass( "Type1", web_main_dart.Type1, const TypeOf<List<web_main_dart.Type1>>().type, () => new web_main_dart.Type1(), {
			'intVal': int,
			'stringVal': String,
			'dateTimeVal': DateTime
		} );'''
        ], [])
      });
    });

    test("With type that has GenericBaseType", () {
      return applyTransformers(getPhases(), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class Type1 extends Type2<Type3>
{
	int intVal;
}

class Type2<T>
{
	T tVal;
}

class Type3
{
	DateTime dateTimeVal;
}
'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'main.dart' as web_main_dart;"
        ], [
          "intVal",
          "tVal"
        ], [
          '''NoMirrorsMapStore.registerClass( "Type1", web_main_dart.Type1, const TypeOf<List<web_main_dart.Type1>>().type, () => new web_main_dart.Type1(), {
			'intVal': int,
			'tVal': web_main_dart.Type3
		} );'''
        ], [])
      });
    });

    test("With type that has List", () {
      return applyTransformers(getPhases(), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class Type1
{
	List<Type1> values;
}
'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'main.dart' as web_main_dart;"
        ], [
          "values"
        ], [
          '''NoMirrorsMapStore.registerClass( "Type1", web_main_dart.Type1, const TypeOf<List<web_main_dart.Type1>>().type, () => new web_main_dart.Type1(), {
			'values': const TypeOf<List<web_main_dart.Type1>>().type
		} );'''
        ], [])
      });
    });

    test("With library name specified reads all type form that library", () {
      return applyTransformers(getPhases(["TestProject1"]), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'package:testProject1/testProject1.dart';

main(){}
''',
        'testProject1|lib/testProject1.dart': '''library TestProject1;

		class Class1 {}
		class Class2 {}'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'package:testProject1/testProject1.dart' as lib_testProject1_dart;"
        ], [], [
          '''NoMirrorsMapStore.registerClass( "TestProject1.Class1", lib_testProject1_dart.Class1, const TypeOf<List<lib_testProject1_dart.Class1>>().type, () => new lib_testProject1_dart.Class1(), {
		} );''',
          '''NoMirrorsMapStore.registerClass( "TestProject1.Class2", lib_testProject1_dart.Class2, const TypeOf<List<lib_testProject1_dart.Class2>>().type, () => new lib_testProject1_dart.Class2(), {
		} );'''
        ], [])
      });
    });

    test("With type is generic ignores generic part", () {
      return applyTransformers(getPhases(), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'package:testProject1/testProject1.dart';

main(){}

@Mappable()
class Class1<T>
{
	T val;
}

@Mappable()
class Class2
{
	Class1 val;
}
'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'main.dart' as web_main_dart;"
        ], [
          "val"
        ], [
          '''NoMirrorsMapStore.registerClass( "Class1", web_main_dart.Class1, const TypeOf<List<web_main_dart.Class1>>().type, () => new web_main_dart.Class1(), {
			'val': dynamic
		} );''',
          '''NoMirrorsMapStore.registerClass( "Class2", web_main_dart.Class2, const TypeOf<List<web_main_dart.Class2>>().type, () => new web_main_dart.Class2(), {
			'val': web_main_dart.Class1
		} );'''
        ], [])
      });
    });

    test("Picks up lists from properties", () {
      return applyTransformers(getPhases(), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'package:testProject1/testProject1.dart';

main(){}

@Mappable()
class Class1
{
	List<String> val;
	List<String> val2;
}
'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'main.dart' as web_main_dart;"
        ], [
          "val",
          "val2"
        ], [
          '''NoMirrorsMapStore.registerClass( "Class1", web_main_dart.Class1, const TypeOf<List<web_main_dart.Class1>>().type, () => new web_main_dart.Class1(), {
			'val': const TypeOf<List<String>>().type,
			'val2': const TypeOf<List<String>>().type
		} );''',
          '''NoMirrorsMapStore.registerClass( "dart.core.String", String, const TypeOf<List<String>>().type, null, {
		} );'''
        ], [])
      });
    });

    test("Does not add constructor for abstract type", () {
      return applyTransformers(getPhases(), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class ClassWithListOfAbstract
{
	List<Class1> val;
}

abstract class Class1
{

}
'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'main.dart' as web_main_dart;"
        ], [
          "val"
        ], [
          '''NoMirrorsMapStore.registerClass( "ClassWithListOfAbstract", web_main_dart.ClassWithListOfAbstract, const TypeOf<List<web_main_dart.ClassWithListOfAbstract>>().type, () => new web_main_dart.ClassWithListOfAbstract(), {
			'val': const TypeOf<List<web_main_dart.Class1>>().type
		} );''',
          '''NoMirrorsMapStore.registerClass( "Class1", web_main_dart.Class1, const TypeOf<List<web_main_dart.Class1>>().type, null, {
		} );'''
        ], [])
      });
    });

    test("Does not property map where does not have set/get", () {
      return applyTransformers(getPhases(), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class ClassWithOnlyGetOrSet
{
	int get prop1 => 1;

	set prop2 (int val){

	}
}
'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'main.dart' as web_main_dart;"
        ], [], [
          '''NoMirrorsMapStore.registerClass( "ClassWithOnlyGetOrSet", web_main_dart.ClassWithOnlyGetOrSet, const TypeOf<List<web_main_dart.ClassWithOnlyGetOrSet>>().type, () => new web_main_dart.ClassWithOnlyGetOrSet(), {} );'''
        ], [])
      });
    });

    test("Does not property map where is not public", () {
      return applyTransformers(getPhases(), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class ClassWithOnlyGetOrSet
{
	int _prop;
}
'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'main.dart' as web_main_dart;"
        ], [], [
          '''NoMirrorsMapStore.registerClass( "ClassWithOnlyGetOrSet", web_main_dart.ClassWithOnlyGetOrSet, const TypeOf<List<web_main_dart.ClassWithOnlyGetOrSet>>().type, () => new web_main_dart.ClassWithOnlyGetOrSet(), {} );'''
        ], [])
      });
    });

    test("Generates constuctor for ClassWithPositionalArguments", () {
      return applyTransformers(getPhases(), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class ClassWithPositionalArguments
{
	ClassWithPositionalArguments([int val = 0]);
}
'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'main.dart' as web_main_dart;"
        ], [], [
          '''NoMirrorsMapStore.registerClass( "ClassWithPositionalArguments", web_main_dart.ClassWithPositionalArguments, const TypeOf<List<web_main_dart.ClassWithPositionalArguments>>().type, () => new web_main_dart.ClassWithPositionalArguments(), {} );'''
        ], [])
      });
    });

    test("Does not property map for DateTime", () {
      return applyTransformers(getPhases(), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class ClassWithDateTime
{
	List<DateTime> val;
}
'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'main.dart' as web_main_dart;"
        ], [
          "val"
        ], [
          '''NoMirrorsMapStore.registerClass( "ClassWithDateTime", web_main_dart.ClassWithDateTime, const TypeOf<List<web_main_dart.ClassWithDateTime>>().type, () => new web_main_dart.ClassWithDateTime(), {
                  'val': const TypeOf<List<DateTime>>().type
                } );''',
          '''NoMirrorsMapStore.registerClass( "dart.core.DateTime", DateTime, const TypeOf<List<DateTime>>().type, null, {} );'''
        ], [])
      });
    });

    test("Type has with generates correct map", () {
      return applyTransformers(getPhases(), inputs: {
        'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
        'testProject|web/main.dart':
            '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class ClassWithWith with BaseClass
{

}

class BaseClass
{
    int id;
}
'''
      }, results: {
        'testProject|web/web_main_dart_mappings.dart': mappingsClassGenerator([
          "import 'main.dart' as web_main_dart;"
        ], [
          "id"
        ], [
          '''NoMirrorsMapStore.registerClass( "ClassWithWith", web_main_dart.ClassWithWith, const TypeOf<List<web_main_dart.ClassWithWith>>().type, () => new web_main_dart.ClassWithWith(), {
                  'id': int
                } );'''
        ], [])
      });
    });
  }
}

class MainModificationTransformerTests {
  static String defaultMappingsFile = mappingsClassGenerator([], [], [], []);

  static void run(List<List<Transformer>> phases) {
    test(
        "With no types and no imports generates mappings and modifys main method",
        () {
      return applyTransformers(phases, inputs: {
        'testProject|web/main.dart': '''main(){}'''
      }, results: {
        'testProject|web/main.dart':
            '''import "web_main_dart_mappings.dart" as WebMainDartMappings;
main(){
	WebMainDartMappings.WebMainDartMappings.register();
}''',
        'testProject|web/web_main_dart_mappings.dart': defaultMappingsFile
      });
    });

    test(
        "With no types and has imports generates mappings and modifys main method",
        () {
      return applyTransformers(phases, inputs: {
        'testProject|web/main.dart': '''import 'dart:io';

main(){}'''
      }, results: {
        'testProject|web/main.dart': '''import 'dart:io';
import "web_main_dart_mappings.dart" as WebMainDartMappings;

main(){
	WebMainDartMappings.WebMainDartMappings.register();
}''',
        'testProject|web/web_main_dart_mappings.dart': defaultMappingsFile
      });
    });

    test(
        "With no types and no imports and library directive generates mappings and modifys main method",
        () {
      return applyTransformers(phases, inputs: {
        'testProject|web/main.dart': '''library TestProject;

main(){}'''
      }, results: {
        'testProject|web/main.dart': '''library TestProject;

import "web_main_dart_mappings.dart" as WebMainDartMappings;

main(){
	WebMainDartMappings.WebMainDartMappings.register();
}''',
        'testProject|web/web_main_dart_mappings.dart': defaultMappingsFile
      });
    });

    test(
        "With no types and no imports and main is expression directive generates mappings and modifys main method",
        () {
      return applyTransformers(phases, inputs: {
        'testProject|web/main.dart': '''library TestProject;

main() => 1;'''
      }, results: {
        'testProject|web/main.dart': '''library TestProject;

import "web_main_dart_mappings.dart" as WebMainDartMappings;

main() {
	WebMainDartMappings.WebMainDartMappings.register();
	return 1;
}''',
        'testProject|web/web_main_dart_mappings.dart': defaultMappingsFile
      });
    });

    test("Whe using nomirrorsmap_mirrors import it gets removed", () {
      return applyTransformers(phases, inputs: {
        'nomirrrorsmap|lib/nomirrorsmap_mirrors.dart':
            'library nomirrorsmap.mirrors;',
        'testProject|web/main.dart': '''library TestProject;

import 'package:nomirrorsmap/nomirrorsmap_mirrors.dart';

main() => 1;'''
      }, results: {
        'testProject|web/main.dart': '''library TestProject;


import "web_main_dart_mappings.dart" as WebMainDartMappings;

main() {
	WebMainDartMappings.WebMainDartMappings.register();
	return 1;
}''',
        'testProject|web/web_main_dart_mappings.dart': defaultMappingsFile
      });
    });

    test("Whe using nomirrorsmap_mirrors useMirrors gets removed", () {
      return applyTransformers(phases, inputs: {
        'nomirrrorsmap|lib/nomirrorsmap_mirrors.dart':
            'library nomirrorsmap.mirrors;'
            ''
            'void useMirrors(){}',
        'testProject|web/main.dart': '''library TestProject;

import 'package:nomirrorsmap/nomirrorsmap_mirrors.dart' as nomirrorsmapmirrors;

main(){
    nomirrorsmapmirrors.useMirrors();
}'''
      }, results: {
        'testProject|web/main.dart': '''library TestProject;


import "web_main_dart_mappings.dart" as WebMainDartMappings;

main(){
	WebMainDartMappings.WebMainDartMappings.register();


}''',
        'testProject|web/web_main_dart_mappings.dart': defaultMappingsFile
      });
    });
  }
}
