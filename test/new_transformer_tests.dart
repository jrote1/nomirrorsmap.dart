import 'dart:io' as io;

import 'package:unittest/unittest.dart';
import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'package:nomirrorsmap/src/conversion_objects/conversion_objects.dart';
import 'package:nomirrorsmap/src/shared/shared.dart';
import 'package:nomirrorsmap/src/transformer/transformer.dart';
import 'dart:collection';
import 'package:code_transformers/tests.dart' as codeTransformerTests;

import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/tests.dart';
import 'package:code_transformers/src/dart_sdk.dart';

import 'dart:async';

import 'type_to_type_objects.dart' as objects;
import 'package:code_transformers/src/test_harness.dart';
import 'dart:io';

String MAP_LIBRARY = '''
		library nomirrorsmap;

		class Mappable{
			const Mappable();
		}
	''';

main( )
{
	var resolvers = new Resolvers( dartSdkDirectory );

	var phases = [
		[new MapGeneratorTransformer( resolvers )]
	];

	group( "Main Modification", ( )
	=> MainModificationTransformerTests.run( phases ) );

	test( "With empty type generates mappings", ( )
	{
		return applyTransformers( phases, inputs: {
			'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
			'testProject|web/main.dart': '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class TestClass
{

}'''
		}, results: {
			'testProject|web/test_project_mappings.dart': '''library TestProject.Mappings;
			
import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'main.dart' as web_main_dart;

class TestProjectMappings
{
	static void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	static void _registerAccessors()
	{
	}

	static void _registerClasses()
	{
		NoMirrorsMapStore.registerClass( "TestClass", web_main_dart.TestClass, const TypeOf<List<web_main_dart.TestClass>>().type, () => new web_main_dart.TestClass(), {
		} );
	}

	static void _registerEnums()
	{
	}
}'''
		} );
	} );

	test( "With type with properties of native types generates mappings", ( )
	{
		return applyTransformers( phases, inputs: {
			'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
			'testProject|web/main.dart': '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class TestClass
{
	String stringVal;
	int intVal;
}'''
		}, results: {
			'testProject|web/test_project_mappings.dart': '''library TestProject.Mappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'main.dart' as web_main_dart;

class TestProjectMappings
{
	static void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	static void _registerAccessors()
	{
		NoMirrorsMapStore.registerAccessor( "stringVal", ( object, value ) => object.stringVal = value, (object) => object.stringVal );
		NoMirrorsMapStore.registerAccessor( "intVal", ( object, value ) => object.intVal = value, (object) => object.intVal );
	}

	static void _registerClasses()
	{
		NoMirrorsMapStore.registerClass( "TestClass", web_main_dart.TestClass, const TypeOf<List<web_main_dart.TestClass>>().type, () => new web_main_dart.TestClass(), {
			'stringVal': String,
			'intVal': int
		} );
	}

	static void _registerEnums()
	{
	}
}'''
		} );
	} );

	test( "With type with properties of seen types", ( )
	{
		return applyTransformers( phases, inputs: {
			'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
			'testProject|web/main.dart': '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class TestClass
{
	TestClass testClass;
}'''
		}, results: {
			'testProject|web/test_project_mappings.dart': '''library TestProject.Mappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'main.dart' as web_main_dart;

class TestProjectMappings
{
	static void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	static void _registerAccessors()
	{
		NoMirrorsMapStore.registerAccessor( "testClass", ( object, value ) => object.testClass = value, (object) => object.testClass );
	}

	static void _registerClasses()
	{
		NoMirrorsMapStore.registerClass( "TestClass", web_main_dart.TestClass, const TypeOf<List<web_main_dart.TestClass>>().type, () => new web_main_dart.TestClass(), {
			'testClass': web_main_dart.TestClass
		} );
	}

	static void _registerEnums()
	{
	}
}'''
		} );
	} );

	test( "With type in different package", ( )
	{
		return applyTransformers( phases, inputs: {
			'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
			'testProject1|lib/testProject1.dart': '''import 'package:nomirrorsmap/nomirrorsmap.dart';

@Mappable()
class TestClass
{
	TestClass testClass;
}''',
			'testProject|web/main.dart': '''import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'package:testProject1/testProject1.dart';

main(){}
'''
		}, results: {
			'testProject|web/test_project_mappings.dart': '''library TestProject.Mappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'package:testProject1/testProject1.dart' as lib_testProject1_dart;

class TestProjectMappings
{
	static void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	static void _registerAccessors()
	{
		NoMirrorsMapStore.registerAccessor( "testClass", ( object, value ) => object.testClass = value, (object) => object.testClass );
	}

	static void _registerClasses()
	{
		NoMirrorsMapStore.registerClass( "TestClass", lib_testProject1_dart.TestClass, const TypeOf<List<lib_testProject1_dart.TestClass>>().type, () => new lib_testProject1_dart.TestClass(), {
			'testClass': lib_testProject1_dart.TestClass
		} );
	}

	static void _registerEnums()
	{
	}
}'''
		} );
	} );

	test( "With type that is enum", ( )
	{
		return applyTransformers( phases, inputs: {
			'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
			'testProject|web/main.dart': '''import 'package:nomirrorsmap/nomirrorsmap.dart';

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
			'testProject|web/test_project_mappings.dart': '''library TestProject.Mappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'main.dart' as web_main_dart;

class TestProjectMappings
{
	static void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	static void _registerAccessors()
	{
	}

	static void _registerClasses()
	{
	}

	static void _registerEnums()
	{
		NoMirrorsMapStore.registerEnum( web_main_dart.MyEnum, web_main_dart.MyEnum.values );
	}
}'''
		} );
	} );

	test( "With type that has base types", ( )
	{
		return applyTransformers( phases, inputs: {
			'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
			'testProject|web/main.dart': '''import 'package:nomirrorsmap/nomirrorsmap.dart';

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
			'testProject|web/test_project_mappings.dart': '''library TestProject.Mappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'main.dart' as web_main_dart;

class TestProjectMappings
{
	static void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	static void _registerAccessors()
	{
		NoMirrorsMapStore.registerAccessor( "intVal", ( object, value ) => object.intVal = value, (object) => object.intVal );
		NoMirrorsMapStore.registerAccessor( "stringVal", ( object, value ) => object.stringVal = value, (object) => object.stringVal );
		NoMirrorsMapStore.registerAccessor( "dateTimeVal", ( object, value ) => object.dateTimeVal = value, (object) => object.dateTimeVal );
	}

	static void _registerClasses()
	{
		NoMirrorsMapStore.registerClass( "Type1", web_main_dart.Type1, const TypeOf<List<web_main_dart.Type1>>().type, () => new web_main_dart.Type1(), {
			'intVal': int,
			'stringVal': String,
			'dateTimeVal': DateTime
		} );
	}

	static void _registerEnums()
	{
	}
}'''
		} );
	} );

	test( "With type that has GenericBaseType", ( )
	{
		return applyTransformers( phases, inputs: {
			'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
			'testProject|web/main.dart': '''import 'package:nomirrorsmap/nomirrorsmap.dart';

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
			'testProject|web/test_project_mappings.dart': '''library TestProject.Mappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'main.dart' as web_main_dart;

class TestProjectMappings
{
	static void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	static void _registerAccessors()
	{
		NoMirrorsMapStore.registerAccessor( "intVal", ( object, value ) => object.intVal = value, (object) => object.intVal );
		NoMirrorsMapStore.registerAccessor( "tVal", ( object, value ) => object.tVal = value, (object) => object.tVal );
	}

	static void _registerClasses()
	{
		NoMirrorsMapStore.registerClass( "Type1", web_main_dart.Type1, const TypeOf<List<web_main_dart.Type1>>().type, () => new web_main_dart.Type1(), {
			'intVal': int,
			'tVal': web_main_dart.Type3
		} );
	}

	static void _registerEnums()
	{
	}
}'''
		} );
	} );

	test( "With type that has List", ( )
	{
		return applyTransformers( phases, inputs: {
			'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
			'testProject|web/main.dart': '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class Type1
{
	List<Type1> values;
}
'''
		}, results: {
			'testProject|web/test_project_mappings.dart': '''library TestProject.Mappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'main.dart' as web_main_dart;

class TestProjectMappings
{
	static void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	static void _registerAccessors()
	{
		NoMirrorsMapStore.registerAccessor( "values", ( object, value ) => object.values = value, (object) => object.values );
	}

	static void _registerClasses()
	{
		NoMirrorsMapStore.registerClass( "Type1", web_main_dart.Type1, const TypeOf<List<web_main_dart.Type1>>().type, () => new web_main_dart.Type1(), {
			'values': const TypeOf<List<web_main_dart.Type1>>().type
		} );
	}

	static void _registerEnums()
	{
	}
}'''
		} );
	} );
}

class MainModificationTransformerTests
{
	static const String defaultMappingsFile = '''library TestProject.Mappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';

class TestProjectMappings
{
	static void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	static void _registerAccessors()
	{
	}

	static void _registerClasses()
	{
	}

	static void _registerEnums()
	{
	}
}''';

	static void run( List<List<Transformer>> phases )
	{
		test( "With no types and no imports generates mappings and modifys main method", ( )
		{
			return applyTransformers( phases, inputs: {
				'testProject|web/main.dart': '''main(){}'''
			}, results: {
				'testProject|web/main.dart': '''import "test_project_mappings.dart" as TestProjectMappings;
main(){
	TestProjectMappings.TestProjectMappings.register();
}''',
				'testProject|web/test_project_mappings.dart': defaultMappingsFile
			} );
		} );

		test( "With no types and has imports generates mappings and modifys main method", ( )
		{
			return applyTransformers( phases, inputs: {
				'testProject|web/main.dart': '''import 'dart:io';

main(){}'''
			}, results: {
				'testProject|web/main.dart': '''import 'dart:io';
import "test_project_mappings.dart" as TestProjectMappings;

main(){
	TestProjectMappings.TestProjectMappings.register();
}''',
				'testProject|web/test_project_mappings.dart': defaultMappingsFile
			} );
		} );

		test( "With no types and no imports and library directive generates mappings and modifys main method", ( )
		{
			return applyTransformers( phases, inputs: {
				'testProject|web/main.dart': '''library TestProject;

main(){}'''
			}, results: {
				'testProject|web/main.dart': '''library TestProject;

import "test_project_mappings.dart" as TestProjectMappings;

main(){
	TestProjectMappings.TestProjectMappings.register();
}''',
				'testProject|web/test_project_mappings.dart': defaultMappingsFile
			} );
		} );

		test( "With no types and no imports and main is expression directive generates mappings and modifys main method", ( )
		{
			return applyTransformers( phases, inputs: {
				'testProject|web/main.dart': '''library TestProject;

main() => 1;'''
			}, results: {
				'testProject|web/main.dart': '''library TestProject;

import "test_project_mappings.dart" as TestProjectMappings;

main() {
	TestProjectMappings.TestProjectMappings.register();
	return 1;
}''',
				'testProject|web/test_project_mappings.dart': defaultMappingsFile
			} );
		} );
	}
}