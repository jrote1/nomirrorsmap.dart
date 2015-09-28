## NoMirrorsMap [![Build Status](https://travis-ci.org/jrote1/nomirrorsmap.dart.svg)](https://travis-ci.org/jrote1/nomirrorsmap.dart) [![Coverage Status](https://coveralls.io/repos/jrote1/nomirrorsmap.dart/badge.svg?branch=master&service=github)](https://coveralls.io/github/jrote1/nomirrorsmap.dart?branch=master)
### Information
NoMirrorsMap allows you to map objects in one format to objects in another format.  For example, you can use it to serialise and deserialise native dart objects to and from Json, or to map an object of one type to an object of another type with the same property names.

NoMirrorsMap does this without using Mirrors (hence the name...).  It uses a transformer to create a map file for all the objects that you may need to map, and uses that map file at runtime to avoid the use of Mirrors and to significantly improve the mapping performance.

### Usage

Before you can use NoMirrorsMap, you need to add a transformer entry to your pubspec.yaml file and you need to tell NoMirrorsMap which types you are going to be mapping so the transformer knows which types it needs to generate mapping data for.  You can do this in two ways:

1. You can decorate any types that need to be mapped with the `@Mappable()` attribute.
2. You can add an entry for a library under the transformer declaration in your pubspec.yaml file, which will cause NoMirrorsMap to generate mapping data for ALL the types in that library.

NoMirrorsMap works via a two step process; first the object to be mapped from one format to another is mapped into an intermediate format, and then that intermediate format is mapped to the final target format.  While the object is in its intermediate format, you have the opportunity to manipulate the object.  In the current codebase, NoMirrorsMap contains manipulators which can change the casing of properties to PascalCase, or to camelCase, or to change the target type.

When you call the `convert` method, you supply the object to be mapped, the converter to convert the object to the intermediate format, the converter to convert the intermediate format to the final format, and an optional list of manipulators to modify the intermediate format before it is run through the target format converter.

So for example, to convert an object to Json, you would do this:

```
var json = new NoMirrorsMap().convert(objectToMap, new ClassConverter(), new JsonConverter());
```

To convert an object to Json, changing the casing of the properties to PascalCase in the process, you would do this:

```
var json = new NoMirrorsMap().convert(objectToMap, new ClassConverter(), new JsonConverter(), [ new PascalCaseManipulator() ]);
```

Other manipulators include:
- PascalCaseManipulator
- CamelCaseManipulator
- TypeToTypeManipulator

We recommend creating static methods for doing common mappings.  For example you might create the following static methods for encoding and decoding json:

```
class Json {
	static String encode( dynamic obj ) {
    	return new NoMirrorsMap().convert( obj, new ClassConverter(), new JsonConverter() );
    }

    static String decode( string json, Type type ) {
    	return new NoMirrorsMap().convert( json, new JsonConverter(), new ClassConverter( startType: type ) );
    }
}
```

NoMirrorsMap has a few converters within the codebase by default, but you can easily write your own if you need to map to or from any other formats you may need (XML, CSV etc).  Feel free to submit these in a pull request!

#### Basic Example Using The `@Mappable()` Attribute
pubspec.yaml
```
dependencies:
	nomirrorsmap: any
transformers:
	- nomirrorsmap
```
main.dart
```dart
import 'package:nomirrorsmap/nomirrorsmap.dart';

main(){
	var obj = new EncodableObject()..id = 1;
	var json = new NoMirrorsMap().convert(obj, new ClassConverter(), new JsonConverter());
}

@Mappable()
class EncodableObject {
	int id;
}
```
#### Basic Example Using Library Declaration in pubspec.yaml


pubspec.yaml
```
dependencies:
	nomirrorsmap: any
transformers:
	- nomirrorsmap:
		library_names:
        	- "my_library"
```
main.dart
```dart
import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'my_library.dart';

main(){
	var obj1 = new FirstEncodableObject()..id = 1;
    var obj2 = new SecondEncodableObject()..id = 2;

    var mapper = new NoMirrorsMap();
	var json1 = mapper.convert(obj1, new ClassConverter(), new JsonConverter());
    var json2 = mapper.convert(obj2, new ClassConverter(), new JsonConverter());

}
```
my_library.dart
```
library my_library;

class FirstEncodableObject {
	int id;
}

class SecondEncodableObject {
	int id;
}
```
