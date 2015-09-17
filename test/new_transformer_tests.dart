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

import 'nomirrorsmap_generated_maps.dart';
import 'type_to_type_objects.dart' as objects;

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
		[new NewMapGeneratorTransformer( resolvers )]
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
			'testProject|web/test_project_mappings.dart': '''import 'package:nomirrorsmap/src/transformer.dart';
import 'main.dart' as web_main_dart;

class TestProjectMappings
{
	void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	void _registerAccessors()
	{
	}

	void _registerClasses()
	{
		NoMirrorsMapStore.registerClass( "TestClass", web_main_dart.TestClass, () => new web_main_dart.TestClass(), const {
		} );
	}

	void _registerEnums()
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
			'testProject|web/test_project_mappings.dart': '''import 'package:nomirrorsmap/src/transformer.dart';
import 'main.dart' as web_main_dart;

class TestProjectMappings
{
	void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	void _registerAccessors()
	{
		NoMirrorsMapStore.registerAccessor( "stringVal", ( object, value ) => object.stringVal = value, (object) => object.stringVal );
		NoMirrorsMapStore.registerAccessor( "intVal", ( object, value ) => object.intVal = value, (object) => object.intVal );
	}

	void _registerClasses()
	{
		NoMirrorsMapStore.registerClass( "TestClass", web_main_dart.TestClass, () => new web_main_dart.TestClass(), const {
			'stringVal': String,
			'intVal': int
		} );
	}

	void _registerEnums()
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
			'testProject|web/test_project_mappings.dart': '''import 'package:nomirrorsmap/src/transformer.dart';
import 'main.dart' as web_main_dart;

class TestProjectMappings
{
	void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	void _registerAccessors()
	{
		NoMirrorsMapStore.registerAccessor( "testClass", ( object, value ) => object.testClass = value, (object) => object.testClass );
	}

	void _registerClasses()
	{
		NoMirrorsMapStore.registerClass( "TestClass", web_main_dart.TestClass, () => new web_main_dart.TestClass(), const {
			'testClass': web_main_dart.TestClass
		} );
	}

	void _registerEnums()
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
			'testProject|web/test_project_mappings.dart': '''import 'package:nomirrorsmap/src/transformer.dart';
import 'package:testProject1/testProject1.dart' as lib_testProject1_dart;

class TestProjectMappings
{
	void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	void _registerAccessors()
	{
		NoMirrorsMapStore.registerAccessor( "testClass", ( object, value ) => object.testClass = value, (object) => object.testClass );
	}

	void _registerClasses()
	{
		NoMirrorsMapStore.registerClass( "TestClass", lib_testProject1_dart.TestClass, () => new lib_testProject1_dart.TestClass(), const {
			'testClass': lib_testProject1_dart.TestClass
		} );
	}

	void _registerEnums()
	{
	}
}'''
		} );
	} );
}

class MainModificationTransformerTests
{
	static const String defaultMappingsFile = '''import 'package:nomirrorsmap/src/transformer.dart';

class TestProjectMappings
{
	void register( )
	{
		_registerAccessors( );
		_registerClasses( );
		_registerEnums( );
	}

	void _registerAccessors()
	{
	}

	void _registerClasses()
	{
	}

	void _registerEnums()
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