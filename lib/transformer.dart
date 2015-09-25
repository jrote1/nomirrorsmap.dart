import 'package:barback/barback.dart';
import 'package:nomirrorsmap/src/transformer/transformer.dart';
import 'package:code_transformers/resolver.dart';

class MainTransformer extends TransformerGroup {
  MainTransformer._(phases) : super(phases) {}

  factory MainTransformer(TransformerOptions options) {
    var resolvers = new Resolvers(dartSdkDirectory);

    var phases = [
      [new MapGeneratorTransformer(resolvers, options)]
    ];

    return new MainTransformer._(phases);
  }

  factory MainTransformer.asPlugin(BarbackSettings settings) {
    return new MainTransformer(new TransformerOptions(settings));
  }
}
