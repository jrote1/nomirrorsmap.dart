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

List getPhases( [List<String> libraryNames = const []] )
{
	var resolvers = new Resolvers( dartSdkDirectory );

	return [
		[new MapGeneratorTransformer( resolvers, new TransformerOptions.initialize( libraryNames ) )]
	];
}

main( )
{
	group( "Main Modification", ( )
	=> MainModificationTransformerTests.run( getPhases( ) ) );

	test( "With empty type generates mappings", ( )
	{
		return applyTransformers( getPhases( ), inputs: {
			'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
			'testProject|web/main.dart': '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class TestClass
{

}'''
		}, results: {
			'testProject|web/web_main_dart_mappings.dart': '''library WebMainDartMappings;
			
import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'main.dart' as web_main_dart;

class WebMainDartMappings
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
		return applyTransformers( getPhases( ), inputs: {
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
			'testProject|web/web_main_dart_mappings.dart': '''library WebMainDartMappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'main.dart' as web_main_dart;

class WebMainDartMappings
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
		return applyTransformers( getPhases( ), inputs: {
			'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
			'testProject|web/main.dart': '''import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){}

@Mappable()
class TestClass
{
	TestClass testClass;
}'''
		}, results: {
			'testProject|web/web_main_dart_mappings.dart': '''library WebMainDartMappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'main.dart' as web_main_dart;

class WebMainDartMappings
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
		return applyTransformers( getPhases( ), inputs: {
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
			'testProject|web/web_main_dart_mappings.dart': '''library WebMainDartMappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'package:testProject1/testProject1.dart' as lib_testProject1_dart;

class WebMainDartMappings
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
		return applyTransformers( getPhases( ), inputs: {
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
			'testProject|web/web_main_dart_mappings.dart': '''library WebMainDartMappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'main.dart' as web_main_dart;

class WebMainDartMappings
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
		return applyTransformers( getPhases( ), inputs: {
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
			'testProject|web/web_main_dart_mappings.dart': '''library WebMainDartMappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'main.dart' as web_main_dart;

class WebMainDartMappings
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
		return applyTransformers( getPhases( ), inputs: {
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
			'testProject|web/web_main_dart_mappings.dart': '''library WebMainDartMappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'main.dart' as web_main_dart;

class WebMainDartMappings
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
		return applyTransformers( getPhases( ), inputs: {
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
			'testProject|web/web_main_dart_mappings.dart': '''library WebMainDartMappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'main.dart' as web_main_dart;

class WebMainDartMappings
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

	test( "With library name specified reads all type form that library", ( )
	{
		return applyTransformers( getPhases( ["TestProject1"] ), inputs: {
			'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
			'testProject|web/main.dart': '''import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'package:testProject1/testProject1.dart';

main(){}
''',
			'testProject1|lib/testProject1.dart': '''library TestProject1;

		class Class1 {}
		class Class2 {}'''
		}, results: {
			'testProject|web/web_main_dart_mappings.dart': '''library WebMainDartMappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'package:testProject1/testProject1.dart' as lib_testProject1_dart;

class WebMainDartMappings
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
		NoMirrorsMapStore.registerClass( "TestProject1.Class1", lib_testProject1_dart.Class1, const TypeOf<List<lib_testProject1_dart.Class1>>().type, () => new lib_testProject1_dart.Class1(), {
		} );
		NoMirrorsMapStore.registerClass( "TestProject1.Class2", lib_testProject1_dart.Class2, const TypeOf<List<lib_testProject1_dart.Class2>>().type, () => new lib_testProject1_dart.Class2(), {
		} );
	}

	static void _registerEnums()
	{
	}
}'''
		} );
	} );

	test( "With type is generic ignores generic part", ( )
	{
		return applyTransformers( getPhases( ), inputs: {
			'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
			'testProject|web/main.dart': '''import 'package:nomirrorsmap/nomirrorsmap.dart';
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
			'testProject|web/web_main_dart_mappings.dart': '''library WebMainDartMappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'main.dart' as web_main_dart;

class WebMainDartMappings
{
	static void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	static void _registerAccessors()
	{
		NoMirrorsMapStore.registerAccessor( "val", ( object, value ) => object.val = value, (object) => object.val );
	}

	static void _registerClasses()
	{
		NoMirrorsMapStore.registerClass( "Class1", web_main_dart.Class1, const TypeOf<List<web_main_dart.Class1>>().type, () => new web_main_dart.Class1(), {
			'val': dynamic
		} );
		NoMirrorsMapStore.registerClass( "Class2", web_main_dart.Class2, const TypeOf<List<web_main_dart.Class2>>().type, () => new web_main_dart.Class2(), {
			'val': web_main_dart.Class1
		} );
	}

	static void _registerEnums()
	{
	}
}'''
		} );
	} );

	test( "Picks up lists from properties", ( )
	{
		return applyTransformers( getPhases( ), inputs: {
			'nomirrorsmap|lib/nomirrorsmap.dart': MAP_LIBRARY,
			'testProject|web/main.dart': '''import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'package:testProject1/testProject1.dart';

main(){}

@Mappable()
class Class1
{
	List<String> val;
}
'''
		}, results: {
			'testProject|web/web_main_dart_mappings.dart': '''library WebMainDartMappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'main.dart' as web_main_dart;

class WebMainDartMappings
{
	static void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	static void _registerAccessors()
	{
		NoMirrorsMapStore.registerAccessor( "val", ( object, value ) => object.val = value, (object) => object.val );
	}

	static void _registerClasses()
	{
		NoMirrorsMapStore.registerClass( "Class1", web_main_dart.Class1, const TypeOf<List<web_main_dart.Class1>>().type, () => new web_main_dart.Class1(), {
			'val': const TypeOf<List<String>>().type
		} );
		NoMirrorsMapStore.registerClass( "dart.core.String", String, const TypeOf<List<String>>().type, null, {
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
	static const String defaultMappingsFile = '''library WebMainDartMappings;

import 'package:nomirrorsmap/nomirrorsmap.dart';

class WebMainDartMappings
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
				'testProject|web/main.dart': '''import "web_main_dart_mappings.dart" as WebMainDartMappings;
main(){
	WebMainDartMappings.WebMainDartMappings.register();
}''',
				'testProject|web/web_main_dart_mappings.dart': defaultMappingsFile
			} );
		} );

		test( "With no types and has imports generates mappings and modifys main method", ( )
		{
			return applyTransformers( phases, inputs: {
				'testProject|web/main.dart': '''import 'dart:io';

main(){}'''
			}, results: {
				'testProject|web/main.dart': '''import 'dart:io';
import "web_main_dart_mappings.dart" as WebMainDartMappings;

main(){
	WebMainDartMappings.WebMainDartMappings.register();
}''',
				'testProject|web/web_main_dart_mappings.dart': defaultMappingsFile
			} );
		} );

		test( "With no types and no imports and library directive generates mappings and modifys main method", ( )
		{
			return applyTransformers( phases, inputs: {
				'testProject|web/main.dart': '''library TestProject;

main(){}'''
			}, results: {
				'testProject|web/main.dart': '''library TestProject;

import "web_main_dart_mappings.dart" as WebMainDartMappings;

main(){
	WebMainDartMappings.WebMainDartMappings.register();
}''',
				'testProject|web/web_main_dart_mappings.dart': defaultMappingsFile
			} );
		} );

		test( "With no types and no imports and main is expression directive generates mappings and modifys main method", ( )
		{
			return applyTransformers( phases, inputs: {
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
			} );
		} );
	}
}