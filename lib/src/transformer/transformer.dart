library nomirrorsmap.transformer;

import 'package:barback/barback.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:code_transformers/resolver.dart';
import 'package:nomirrorsmap/nomirrorsmap.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import 'dart:async';
import 'dart:math';

part 'map_generator_transformer.dart';
part 'map_generator.dart';