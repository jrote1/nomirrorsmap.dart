import 'dart:async';

import 'package:barback/barback.dart';

class ClassTransformer extends Transform {
  ClassTransformer.asPlugin();

  String get allowedExtensions => ".dart";

  Future apply(Transform transform) async {
    String fileContent = await transform.primaryInput.readAsString();


  var id = transform.primaryInput.id;
      String newContent = copyright + content;
      transform.addOutput(new Asset.fromString(id, newContent));
  }
}