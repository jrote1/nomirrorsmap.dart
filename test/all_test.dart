library nomirrorsmap.tests;

import 'dart:io';
import 'package:test/test.dart';
import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'package:nomirrorsmap/nomirrorsmap_mirrors.dart';
import 'package:nomirrorsmap/src/conversion_objects/conversion_objects.dart';
import 'package:nomirrorsmap/src/shared/shared.dart';

import 'test_mappings.dart' as test_mappings;

import 'type_to_type_objects.dart' as objects;
import 'test_objects.dart';
import 'new_transformer_tests.dart';
import 'package:reflective/reflective.dart';

part 'type_to_type_tests.dart';

main() async {
  test_mappings.TestProjectMappings.register();

  group("Type to Type", () => TypeToTypeTests.run());
  group("Transformer Main Modification",
      () => MainModificationTransformerTests.run(getPhases()));
  group("Transformer", () => TransformerTests.run());

  var noMirrorsMapInstances = {
    'Mirrors Based': () {
      useMirrors();
    },
    'Mappings Based': () {}
  };

  for (var noMirrorsMapFuncKey in noMirrorsMapInstances.keys) {
    var noMirrorsMap = new NoMirrorsMap();
    var doThingsFunction = noMirrorsMapInstances[noMirrorsMapFuncKey];
    group("${noMirrorsMapFuncKey} tests", () {
      setUp(() {
        doThingsFunction();
      });

      group("Serialization Tests", () {
        test("Can serialize an object that is null", () {
          var result = noMirrorsMap.convert(
              null, new ClassConverter(), new JsonConverter());
          expect(result, "null");
        });

        test("Can serialize with tab", () {
          var previousJson = noMirrorsMap.convert(
              new NoTypeTestPropertyClass()
                ..id = 1
                ..name = "\t",
              new ClassConverter(),
              new JsonConverter());
          print(previousJson);
          var result = noMirrorsMap.convert(
              new NoTypeTestPropertyClass()
                ..id = 1
                ..name = previousJson,
              new ClassConverter(),
              new JsonConverter());

          expect(result, endsWith('''"name\\":\\"\\\\t\\"}"}'''));
        });

        test("Can serialize to Pascal case", () {
          var result = noMirrorsMap.convert(
              new Person()
                ..id = 1
                ..children = []
                ..parents = [],
              new ClassConverter(),
              new JsonConverter(),
              [new PascalCaseManipulator()]);
          expect(result, endsWith('''"Id":1,"Parents":[],"Children":[]}'''));
        });

        test("Performance test", () {
          //218
          var list = [];
          for (int i = 0; i < 1000; i++)
            list.add(new Person()
              ..id = i
              ..children = [
                new Person()
                  ..id = i
                  ..children = []
                  ..parents = []
              ]
              ..parents = [
                new Person()
                  ..id = i
                  ..children = []
                  ..parents = []
              ]);

          var stopwatch = new Stopwatch()..start();
          noMirrorsMap.convert(
              list, new ClassConverter(), new NewtonSoftJsonConverter());
          stopwatch.stop();
          print("Took: ${stopwatch.elapsedMilliseconds}");
        });

        test("Generic test", () {
          var person = new PersonGeneric()..val = new Person();
          var json = noMirrorsMap.convert(
              person, new ClassConverter(), new NewtonSoftJsonConverter());
          noMirrorsMap.convert(json, new NewtonSoftJsonConverter(),
              new ClassConverter(startType: PersonGeneric));
        });

        test("Can deserialize to object", () {
          ClassConverter.converters[
              Duration] = new CustomClassConverter<Duration>()
            ..to = ((ClassIntermediateObject input) {
              return new Duration(
                  minutes:
                      (input.properties["minutes"] as NativeIntermediateObject)
                          .value,
                  seconds:
                      (input.properties["seconds"] as NativeIntermediateObject)
                          .value);
            })
            ..from = ((Duration duration) {
              return new ClassIntermediateObject()
                ..objectType = null
                ..previousHashCode = duration.hashCode.toString()
                ..properties = {
                  "minutes": new NativeIntermediateObject()
                    ..value = duration.inMinutes
                    ..objectType = int,
                  "seconds": new NativeIntermediateObject()
                    ..value = duration.inSeconds % 60
                    ..objectType = int
                };
            });

          var json = r'''{ "duration": {"minutes":15, "seconds":10} }''';
          var result = noMirrorsMap.convert(json, new JsonConverter(),
                  new ClassConverter(startType: TypeWithDuration))
              as TypeWithDuration;
          noMirrorsMap.convert(
              result, new ClassConverter(), new JsonConverter());

          expect(result.duration.inMinutes, 15);
          expect(result.duration.inSeconds, 15 * 60 + 10);
        });
      });

      group("Deserialization Tests", () {
        test("Can deserialize null DateTime", () {
          var json = "null";

          var result = noMirrorsMap.convert(json, new JsonConverter(),
              new ClassConverter(startType: DateTime)) as Person;

          expect(result, isNull);
        });

        test("Can deserialize simple object structure", () {
          var json = r'''{
  "$type": "nomirrorsmap.test_objects.Person",
  "$hashcode": "547833245",
  "id": 1,
  "parents": [],
  "children": []
}''';

          var result = noMirrorsMap.convert(
              json, new JsonConverter(), new ClassConverter()) as Person;

          expect(result.id, 1);
          expect(result.children, isNotNull);
          expect(result.parents, isNotNull);
        });

        test("Can deserialize objects with circular references", () {
          var json = r'''{
  "$type": "nomirrorsmap.test_objects.Person",
  "$hashcode": "547833245",
  "id": 3,
  "parents": [{
    "$type": "nomirrorsmap.test_objects.Person",
    "$hashcode": "48854486",
    "id": 1,
    "parents": [],
    "children": [{
      "$type": "nomirrorsmap.test_objects.Person",
      "$hashcode": "48854487",
      "id": 2,
      "parents": [{
        "$type": "nomirrorsmap.test_objects.Person",
        "$hashcode": "48854486"
      }],
      "children": []
    }]
  }],
  "children": []
}''';

          var result = noMirrorsMap.convert(
              json, new JsonConverter(), new ClassConverter()) as Person;

          var parent = result.parents[0];

          expect(parent.children[0].parents[0], parent);
        });

        test(
            "Can deserialize objects with circular references, even if properties are seen after reference",
            () {
          var json = r'''{
  "$type": "nomirrorsmap.test_objects.Person",
  "$hashcode": "547833245",
  "id": 3,
  "parents": [{
    "$type": "nomirrorsmap.test_objects.Person",
    "$hashcode": "48854486",
    "parents": [],
    "children": [{
      "$type": "nomirrorsmap.test_objects.Person",
      "$hashcode": "48854487",
      "id": 2,
      "parents": [{
        "$type": "nomirrorsmap.test_objects.Person",
        "$hashcode": "48854486",
        "id": 1
      }],
      "children": []
    }]
  }],
  "children": []
}''';

          var result = noMirrorsMap.convert(
              json, new JsonConverter(), new ClassConverter()) as Person;

          var parent = result.parents[0];

          expect(parent, parent.children[0].parents[0]);
          expect(parent.id, 1);
        });

        test("Can deserialize objects that do not have \$type", () {
          var json = "{\"id\": 1, \"children\": [], \"parents\": []}";

          Person result = noMirrorsMap.convert(
              json, new JsonConverter(), new ClassConverter(startType: Person));

          expect(result.id, 1);
          expect(result.children, isNotNull);
          expect(result.parents, isNotNull);
        });

        test("Can deserialize null", () {
          var result = noMirrorsMap.convert(
              "null", new JsonConverter(), new ClassConverter());
          expect(result, null);
        });

        test("Can deserialize using CamelCaseManipulator", () {
          var json =
              '''{"\$type":"nomirrorsmap.test_objects.Person","\$hashcode":"511757599","Id":1,"Parents":[],"Children":[]}''';

          Person result = noMirrorsMap.convert(json, new JsonConverter(),
              new ClassConverter(), [new CamelCaseManipulator()]);
          expect(result.id, 1);
        });

        test("Can deserialize type that contains a list", () {
          var json =
              "{\"id\": 1, \"children\": [{\"id\": 2,\"children\": [], \"parents\": []}], \"parents\": []}";

          Person result = noMirrorsMap.convert(
              json, new JsonConverter(), new ClassConverter(startType: Person));

          expect(result.id, 1);
          expect(result.children.length, 1);
          expect(result.children[0].id, 2);
        });

        test("Can deserialize type that contains a list", () {
          var json = r'''{
  "odata.metadata": "http://localhost/odata/$metadata#Users/@Element",
  "Id": 2,
  "FirstName": "No",
  "LastName": "Mirrors",
  "EmailAddress": "fsgpoidhnfoglb@example.com",
  "MobilePhone": "65406834354356",
  "Umpire": false,
  "TeamUsers": [
    {
      "Id": 6665,
      "Role": {
        "Id": 1,
        "Name": "Organiser"
      }
    },
    {
      "Id": 6677,
      "Role": {
        "Id": 1,
        "Name": "Organiser"
      }
    },
    {
      "Id": 6680,
      "Role": {
        "Id": 1,
        "Name": "Organiser"
      }
    }
  ],
  "SecurityRole": {
    "Id": 1,
    "Name": "Administrator",
    "Description": "Top level security.  Can perform all actions within the system",
    "AssociationLevel": {
      "Id": 1,
      "Value": "Top"
    }
  }
}''';

          User result = noMirrorsMap.convert(
              json,
              new JsonConverter(),
              new ClassConverter(startType: User),
              [new CamelCaseManipulator()]);

          expect(result.id, 2);
          expect(result.teamUsers[0].role.id, 1);
        });

        test("Can deserialize type that contains a DateTime", () {
          ClassWithDateTime result = noMirrorsMap.convert(
              "{\"time\": \"2055-02-03T15:57:12\"}",
              new JsonConverter(),
              new ClassConverter(startType: ClassWithDateTime));

          expect(result.time, new isInstanceOf<DateTime>());
        });
      });

      group("ClassConverter test", () {
        setUp(() {
          ClassConverter.converters[CustomConverterTest] =
              new CustomClassConverter<CustomConverterTest>()
                ..to = ((NativeIntermediateObject val) {
                  var values = val.value.split("|");
                  var result = new CustomConverterTest()
                    ..id = int.parse(values[0])
                    ..value = values[1];
                  return result;
                })
                ..from =
                    (CustomConverterTest val) => (new NativeIntermediateObject()
                      ..value = "${val.id}|${val.value}"
                      ..objectType = String);
        });
        test(
            "When a custom converter is specified for a type, the converter is used when converting to baseObject",
            () {
          var object = new CustomConverterParentTest()
            ..testProperty = (new CustomConverterTest()
              ..id = 1
              ..value = "Matthew");

          var classConverter = new ClassConverter();
          ClassIntermediateObject baseObject =
              classConverter.toBaseIntermediateObject(object);
          var result = baseObject.properties["testProperty"];

          expect(result.value, "1|Matthew");
        });

        test(
            "When a custom converter is specified for a type, the convert is used when converting from baseObject",
            () {
          var classObjectData = new ClassIntermediateObject()..properties = {};
          classObjectData.properties["testProperty"] =
              new NativeIntermediateObject()..value = "1|Matthew";
          classObjectData.previousHashCode = "1";
          classObjectData.objectType = CustomConverterParentTest;

          var classConverter = new ClassConverter();
          CustomConverterParentTest result =
              classConverter.fromBaseIntermediateObject(classObjectData);

          expect(result.testProperty.value, "Matthew");
          expect(result.testProperty.id, 1);
        });

        test(
            "With a json string with no type attributes and a sub property of different type, deserialises correctly",
            () {
          var json = r'''{
  "id": 1,
  "firstName": "Matthew",
  "testProperty": {
    "id": 2,
    "name": "OtherName"
  }
}''';
          NoTypeTestClass result = noMirrorsMap.convert(
              json,
              new JsonConverter(),
              new ClassConverter(startType: NoTypeTestClass));
          expect(result.testProperty.name, "OtherName");
        });

        test("With json with int value and setting double does not explode",
            () {
          var objectData = new NativeIntermediateObject()..value = 1;
          var objectd = new ClassIntermediateObject()
            ..objectType = ClassWithDouble
            ..properties = {"val": objectData};

          var classConverter = new ClassConverter(startType: ClassWithDouble);

          var result = classConverter.fromBaseIntermediateObject(objectd);

          expect(result.val, 1.0);
        });
      });

      group("JsonConverter tests", () {
        test("can convert to object using HashCode", () {
          const String hashcode = "1234";
          const String jsonHashcodeName = "\$ref";

          var data = new ClassIntermediateObject()
            ..properties = {}
            ..previousHashCode = hashcode
            ..objectType = CustomConverterTest;

          var converter = new JsonConverter(hashcodeName: jsonHashcodeName);
          String jsonResult = converter.fromBaseIntermediateObject(data);

          var expected = "\"$jsonHashcodeName\":\"$hashcode\"";
          expect(jsonResult, contains(expected));
        });

        test("can convert from json to object using custom HashCode", () {
          const String hashcode = "1234";
          const String jsonHashcodeName = "\$ref";

          var converter = new JsonConverter(hashcodeName: jsonHashcodeName);
          var json =
              '{ "\$type": "nomirrorsmap.test_objects.CustomConverterTest",\"$jsonHashcodeName\": \"$hashcode\"}';
          var baseObjectData = converter.toBaseIntermediateObject(json)
              as ClassIntermediateObject;

          expect(baseObjectData.previousHashCode, hashcode);
          expect(baseObjectData.properties.containsKey(jsonHashcodeName), true);
        });

        test("can convert datetime to json", () {
          var nativeIntermediateObject = new NativeIntermediateObject()
            ..objectType = DateTime
            ..value = new DateTime(2015, 9, 29, 10, 11);
          var converter = new JsonConverter();
          var json =
              converter.fromBaseIntermediateObject(nativeIntermediateObject);
          expect(json, '"${nativeIntermediateObject.value.toString( )}"');
        });

        test("can convert int in json to enum value", () {
          var result = noMirrorsMap.convert("0", new JsonConverter(),
              new ClassConverter(startType: TestEnum));
          expect(result, TestEnum.One);
        });

        test("Can serialise without including metadata", () {
          var result = noMirrorsMap.convert(
              new Person()
                ..id = 1
                ..children = []
                ..parents = [],
              new ClassConverter(),
              new JsonConverter(includeMetadata: false));
          expect(result, '''{"id":1,"parents":[],"children":[]}''');
        });
      });

      group("NewtonSoft json test", () {
        test(
            "For fromBaseObjectData, When called with two objects with same reference, Then returned json should have \$id in first object and  \$ref in second object",
            () {
          var list = new ListIntermediateObject();
          var klass1 = new ClassIntermediateObject();
          var klass2 = new ClassIntermediateObject();

          klass1.objectType = klass2.objectType = NewtonSoftTest;
          klass1.previousHashCode = klass2.previousHashCode = "1";
          klass1.properties = {};
          klass1.properties["age"] = new NativeIntermediateObject()..value = 14;
          klass1.properties["gender"] = new NativeIntermediateObject()
            ..value = "m";

          klass2.properties = {};

          list.values = [klass1, klass2];

          var converter = new NewtonSoftJsonConverter();
          String json = converter.fromBaseIntermediateObject(list);

          expect(
              json,
              contains(
                  r'''[{"$id":"1","$type":"nomirrorsmap.test_objects.NewtonSoftTest","age":14,"gender":"m"},{"$ref":"1"}]'''));
        });

        test(
            "For toBaseObjectData, When called with two objects with same reference, Then returned objects should restore references",
            () {
          var converter = new NewtonSoftJsonConverter();
          ListIntermediateObject json = converter.toBaseIntermediateObject(
              r'''[{"$id":"1","$type":"nomirrorsmap.test_objects.NewtonSoftTest","age":14,"gender":"m"},{"$ref":"1"}]''');

          expect((json.values[0] as ClassIntermediateObject).previousHashCode,
              "1");
          expect((json.values[0] as ClassIntermediateObject).previousHashCode,
              (json.values[1] as ClassIntermediateObject).previousHashCode);
        });

        test("can deserialize using dollar ref property only", () {
          var converter = new NewtonSoftJsonConverter();
          var jsonText = r'''{
  "$id": "1",
  "$type": "nomirrorsmap.test_objects.SimpleTypeUsingDollarRef",
  "name": "Test User",
  "people": [{
    "$id": "2",
    "$type": "nomirrorsmap.test_objects.SimpleTypeUsingDollarRef",
    "name": "Another Test User",
    "people": []
  },
    {
      "$ref": "1"
    }
  ]
}''';
          var mapper = noMirrorsMap;
          var result =
              mapper.convert(jsonText, converter, new ClassConverter());

          expect(result != null, true);
          result as SimpleTypeUsingDollarRef;
          expect(result.name, result.people[1].name);
          expect(result.people[1].name, "Test User");
        });

        test("can deserialize object with no properties", () {
          var json =
              '''[{"\$id":"994910500","\$type":"nomirrorsmap.test_objects.TypeWithNoProperties"},{"\$ref":"994910500"}]''';

          noMirrorsMap.convert(
              json,
              new NewtonSoftJsonConverter(),
              new ClassConverter(
                  startType: const TypeOf<List<TypeWithNoProperties>>().type));
        });

        test("Can deserialize", () {
          var converter = new NewtonSoftJsonConverter();
          var jsonText = r'''{
  "$id": "1",
  "$type": "nomirrorsmap.test_objects.InheritedClass",
  "data": [
    {
      "$ref": "1"
    }
  ]
}''';
          BaseIntermediateObject result =
              converter.toBaseIntermediateObject(jsonText);

          assertClassObjectDataTypeNotNull(result);
        });

        test("Can deserialize when using standard NewtonSoft type information",
            () {
          var converter = new NewtonSoftJsonConverter();
          var jsonText = r'''{
  "$id": "1",
  "$type": "nomirrorsmap.test_objects.InheritedClass, The.Assembly.Name",
  "data": [
    {
      "$ref": "1"
    }
  ]
}''';
          BaseIntermediateObject result =
              converter.toBaseIntermediateObject(jsonText);

          assertClassObjectDataTypeNotNull(result);
        });

        test("Can deserialize generic", () {
          var json = '''{ "id": 1 }''';
          var result = noMirrorsMap.convert(
                  json,
                  new JsonConverter(),
                  new ClassConverter(
                      startType: const TypeOf<GenericType>().type))
              as GenericType<int>;
          expect(result.id, 1);
        });

        test("Can serialise without including metadata", () {
          var result = noMirrorsMap.convert(
              new Person()
                ..id = 1
                ..children = []
                ..parents = [],
              new ClassConverter(),
              new NewtonSoftJsonConverter(includeMetadata: false));
          expect(result, '''{"id":1,"parents":[],"children":[]}''');
        });
      });
    });
  }
}

void assertClassObjectDataTypeNotNull(BaseIntermediateObject objectData) {
  if (objectData is ClassIntermediateObject) {
    var classObjectData = objectData;
    if (classObjectData.objectType == null) {
      expect(classObjectData.objectType, isNotNull);
    }
    classObjectData.properties.forEach((k, v) {
      assertClassObjectDataTypeNotNull(v);
    });
  } else if (objectData is ListIntermediateObject) {
    var listObjectData = objectData;
    listObjectData.values.forEach((v) {
      assertClassObjectDataTypeNotNull(v);
    });
  } else {}
}
