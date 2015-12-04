library nomirrorsmap.transformer;

import 'package:barback/barback.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:code_transformers/resolver.dart';
import 'package:path/path.dart' as path;
import 'dart:collection';
import 'package:dart_style/dart_style.dart';

part 'map_generator_transformer.dart';
part 'transformer_options.dart';

part 'mappings_generator.dart';
part 'transformer_helpers.dart';

part 'generators/class_bottom_generator.dart';
part 'generators/class_generator.dart';
part 'generators/class_top_generator.dart';
part 'generators/enums_generator.dart';
part 'generators/field.dart';
part 'generators/generator.dart';
part 'generators/generator_parameters.dart';
part 'generators/properties_generator.dart';
part 'generators/type_information_retriever.dart';
