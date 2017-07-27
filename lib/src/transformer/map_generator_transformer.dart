part of nomirrorsmap.transformer;

class MapGeneratorTransformer extends Transformer with ResolverTransformer {
  final TransformerOptions _options;

  MapGeneratorTransformer(Resolvers resolvers, this._options) {
    this.resolvers = resolvers;
  }

  void applyResolver(Transform transform, Resolver resolver) {
    var id = transform.primaryInput.id;

    var filePrefix = TransformerHelpers.sanitizePathToUsableImport(id.path);
    var mappingsClassName =
        TransformerHelpers.sanitizePathToUsableClassName(id.path) + "Mappings";

    var mappingsFileName = "${filePrefix}_mappings.dart";
    var outputPath = path.url.join(path.url.dirname(id.path), mappingsFileName);
    var generatedAssetId = new AssetId(id.package, outputPath);

    if(!_transformEntryFile(
        transform, resolver, mappingsFileName, mappingsClassName))
      return;

    var mappingsFile = new MappingsGenerator(resolver, id, _options.formatCode)
        .generate(mappingsClassName, _options.libraryNames);

    transform.addOutput(new Asset.fromString(generatedAssetId, mappingsFile));
  }

  bool _transformEntryFile(Transform transform, Resolver resolver,
      String mappingsFileName, String mappingsClassName) {
    AssetId id = transform.primaryInput.id;
    var lib = resolver.getLibrary(id);
    var unit = lib.definingCompilationUnit.computeNode();

    if(unit.declarations
        .where((d) => d is FunctionDeclaration && d.name.toString() == 'main').toList().length == 0)
      return false;


    var transaction = resolver.createTextEditTransaction(lib);

    var importParameters = _getImportParameters(unit);

    for (var directive in unit.directives) {
      if (directive is ImportDirective &&
          directive.uri.stringValue ==
              'package:nomirrorsmap/nomirrorsmap_mirrors.dart') {
        transaction.edit(directive.beginToken.offset, directive.end, '');
      }
    }

    transaction.edit(
        importParameters.startPoint,
        importParameters.startPoint,
        '${importParameters.importStart}import "$mappingsFileName" as $mappingsClassName;' +
            (importParameters.startPoint == 0 ? "\n" : ""));

    FunctionExpression main = unit.declarations
        .where((d) => d is FunctionDeclaration && d.name.toString() == 'main')
        .first
        .functionExpression;
    var body = main.body;

    if (body is BlockFunctionBody) {
      Iterable<MethodInvocation> methodInvocations = body.block.statements
          .where((statement) =>
              statement is ExpressionStatement &&
              statement.expression is MethodInvocation)
          .map((statement) => statement.expression);
      if (methodInvocations
          .any((method) => method.methodName.toString() == "useMirrors")) {
        var methodInvocation = methodInvocations.firstWhere(
            (method) => method.methodName.toString() == "useMirrors");
        transaction.edit(
            methodInvocation.beginToken.offset, methodInvocation.end + 1, '');
      }
    }
    if (body is BlockFunctionBody) {
      var location = body.beginToken.end;
      transaction.edit(location, location,
          '\n\t$mappingsClassName.$mappingsClassName.register();\n');
    } else if (body is ExpressionFunctionBody) {
      transaction.edit(
          body.beginToken.offset,
          body.endToken.end,
          "{\n\t$mappingsClassName.$mappingsClassName.register();\n"
          "\treturn ${body.expression};\n}");
    }

    var printer = transaction.commit();
    printer.build(id.path);
    transform.addOutput(new Asset.fromString(id, printer.text));

    return true;
  }

  _EntryPointImportParameters _getImportParameters(dynamic unit) {
    List<Directive> imports =
        unit.directives.where((d) => d is ImportDirective).toList();

    var result = new _EntryPointImportParameters()
      ..startPoint = 0
      ..importStart = "";

    if (imports.length > 0) {
      result.importStart = "\n";
      result.startPoint = imports.last.end;
    } else {
      List<Directive> libraries =
          unit.directives.where((d) => d is LibraryDirective).toList();
      if (libraries.length > 0) {
        result.importStart = "\n\n";
        result.startPoint = libraries.last.end;
      }
    }
    return result;
  }
}

class _EntryPointImportParameters {
  int startPoint;
  String importStart;
}
