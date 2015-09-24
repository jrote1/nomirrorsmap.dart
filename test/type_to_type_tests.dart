part of nomirrorsmap.tests;

class TypeToTypeTests {
  static dynamic map(dynamic obj, Type type, [Map<Type, Type> typeMaps = null]) {
    return new NoMirrorsMap().convert(obj, new ClassConverter(), new ClassConverter(), [new TypeToTypeManipulator(type, typeMaps)]);
  }

  static void run() {
    group('AutoMapper', () {
      test('Mapping from one type to another with only primitive properties correctly copies string property over', () {
        var dateTime = new DateTime.now();
        var testEntity = new objects.TestEntity()
          ..stringProperty = "test"
          ..intProperty = 1
          ..dateTimeProperty = dateTime
          ..doubleProperty = 1.1
          ..boolProperty = true
          ..numProperty = 1;

        objects.TestDto testDto = map(testEntity, objects.TestDto);

        expect(testDto.stringProperty, "test");
        expect(testDto.intProperty, 1);
        expect(testDto.dateTimeProperty, dateTime);
        expect(testDto.doubleProperty, 1.1);
        expect(testDto.boolProperty, true);
        expect(testDto.numProperty, 1);
      });

      test('Mapping from one type to another with a non primitive property correctly maps the non primitive properties', () {
        var testEntity = new objects.TestEntity()..stringProperty = "test";
        var testEntity2 = new objects.TestEntity2()..test = testEntity;

        objects.TestDto2 testDto = map(testEntity2, objects.TestDto2);

        expect("test", testDto.test.stringProperty);
      });

      test('Mapping an object with a list of primitive types maps correctly', () {
        var listEntity = new objects.ListEntity()..list = ["Hello", "World"];

        var result = map(listEntity, objects.ListDto);

        expect(result.list, isNotNull);
        expect(result.list, new isInstanceOf<List<String>>());
        expect(result.list[0], "Hello");
      });

      test('Mapping an object with a list of non primitive types maps correctly', () {
        var nonPrimitiveListEntity = new objects.NonPrimitiveListEntity()
          ..list = [new objects.TestEntity()..stringProperty = "Hello", new objects.TestEntity()..stringProperty = "World"];

        var result = map(nonPrimitiveListEntity, objects.NonPrimitiveListDto);
        expect(result.list[0], new isInstanceOf<objects.TestDto>());
        expect(result.list[0].stringProperty, "Hello");
      });

      test('Mapping from one inherited type to another with only primitive properties correctly copies base and extended properties', () {
        var dateTime = new DateTime.now();
        var testEntity = new objects.InheritedEntity()
          ..stringProperty = "test"
          ..intProperty = 1
          ..dateTimeProperty = dateTime
          ..doubleProperty = 1.1
          ..boolProperty = true
          ..numProperty = 1
          ..extraProperty = 1;

        objects.InheritedDto testDto = map(testEntity, objects.InheritedDto);

        expect(testDto.stringProperty, "test");
        expect(testDto.intProperty, 1);
        expect(testDto.dateTimeProperty, dateTime);
        expect(testDto.doubleProperty, 1.1);
        expect(testDto.boolProperty, true);
        expect(testDto.numProperty, 1);
        expect(testDto.extraProperty, 1);
      });

      test('Mapping from a specific type to a list of works when a type mapping has been declared', () {
        var concreteEntity = new objects.ConcreteEntity();

        var testDto = map(concreteEntity, objects.BaseDto, {objects.ConcreteEntity: objects.ConcreteDto});

        expect(testDto, new isInstanceOf<objects.ConcreteDto>());
      });

      test('Mapping from a specific type to an abstract type throws use exception if no map exists', () {
        var concreteEntity = new objects.ConcreteWithNoMapEntity();

        try {
          map(concreteEntity, objects.BaseDto);
          throw "Should throw exception about map";
        } catch (ex) {
          expect(
              ex,
              contains(
                  "Are you missing a type map from \"class ${(objects.ConcreteWithNoMapEntity).toString( )}\" to \"abstract class ${(objects.BaseDto).toString( )}\""));
        }
      });
    });
  }
}
