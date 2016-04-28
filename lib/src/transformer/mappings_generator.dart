part of nomirrorsmap.transformer;

class MappingsGenerator {
  final Resolver _resolver;
  final AssetId _assetId;
  final bool _formatCode;

  List<Element> _typesToMap = [];
  Map<LibraryElement, String> _libraryImportAliases = {};

  MappingsGenerator(this._resolver, this._assetId, this._formatCode);

  void _addTypes(List<String> libraryNamesToInclude) {
    var libraries = <LibraryElement>[];
    for (var libraryName in libraryNamesToInclude) {
      var library = _resolver.getLibraryByName(libraryName);
      if (library == null)
        print("nomirrorsmap: '$libraryName' was not found so will be ignored");
      else
        libraries.add(library);
    }

    var allTypes = _expandCompilationUnitsWhereShouldBeMapped((compilationUnit) => compilationUnit.enums);

    allTypes.addAll(_expandCompilationUnitsWhereShouldBeMapped((compilationUnit) => compilationUnit.types).where((type) => !type.isAbstract));

    _typesToMap.addAll(_getTypesThatShouldBeMapped(allTypes, libraries));
    _typesToMap.addAll(_getListTypesFromPropertiesThatAreNotAlreadyMapped());

    _generateLibraryAliases();
  }

  List<ClassElement> _expandCompilationUnitsWhereShouldBeMapped(Iterable<ClassElement> expand(CompilationUnitElement unit)) {
    return _resolver.libraries.expand((lib) => lib.units).expand((compilationUnit) => expand(compilationUnit)).toList();
  }

  void _generateLibraryAliases() {
    for (var type in _typesToMap) {
      if (!_libraryImportAliases.containsKey(type.library)) {
        var source = type.library.definingCompilationUnit.source;
        if (source is! DartSourceProxy) {
          var libraryFullPath = source.assetId.path as String;
          var libraryImportAlias = TransformerHelpers.sanitizePathToUsableImport(libraryFullPath);
          _libraryImportAliases[type.library] = libraryImportAlias;
        }
      }
    }
  }

  Iterable<ClassElement> _getTypesThatShouldBeMapped(List<ClassElement> types, List<LibraryElement> libraries) sync* {
    var mappableMetadataType = _resolver.getType("nomirrorsmap.shared.Mappable");
    for (var type in types) {
      if (libraries.contains(type.library)) yield type;
      if (mappableMetadataType != null) {
        var metadata = type.metadata.map((meta) => meta.element).where((element) => element is ConstructorElement).toList();
        if (type.isEnum) metadata = _getEnumMetaData(type);

        for (ConstructorElement meta in metadata) {
          DartType metaType = meta.enclosingElement.type;
          if (metaType.isAssignableTo(mappableMetadataType.type)) {
            if (!type.isEnum && (type.unnamedConstructor == null || (type.unnamedConstructor.parameters.length > 0 && type.unnamedConstructor.parameters.any((p) => !p.parameterKind.isOptional))))
              throw "The type '${type.displayName}' has a @Mappable() annotation but no DefaultConstructor";
            yield type;
          }
        }
      }
    }
  }

  //This is a hack to fix a bug in analyzer don't judge it
  List _getEnumMetaData(ClassElement type) {
    var annotations = type.library.units.expand((u) => u.computeNode().declarations.where((d) => d is EnumDeclaration && d.name.name == type.name)).first.metadata;
    return annotations.map((a) => a.element).where((element) => element is ConstructorElement).toList();
  }

  String generate(String className, List<String> libraryNamesToInclude) {
    if (libraryNamesToInclude == null) libraryNamesToInclude = [];

    _addTypes(libraryNamesToInclude);

    var generators = <_Generator>[new _ClassTopGenerator(_resolver), new _FieldsGenerator(), new _ClassGenerator(), new _EnumsGenerator(), new _ClassBottomGenerator()];

    var parameters = new _GeneratorParameters(className, _assetId, _typesToMap, _libraryImportAliases);

    var code = generators.map((generator) => generator.generate(parameters)).join();
    if (!_formatCode) return code;

    var formatter = new DartFormatter();
    return formatter.format(code);
  }

  bool _typeHasConstructor(ClassElement type) {
    return type.constructors.any((ctor) => ctor.parameters.length == 0) && !type.isAbstract;
  }

  List<ClassElement> _getListTypesFromPropertiesThatAreNotAlreadyMapped() {
    return TransformerHelpers.uniquifyList(_typesToMap
        .where((type) => !type.isEnum)
        .expand((type) => type.fields)
        .where((FieldElement field) => field.type.name == "List")
        .map((field) => field.type)
        .where((InterfaceType type) => type is InterfaceType && type.typeArguments.length > 0)
        .map((type) => type.typeArguments.first.element)
        .where((ClassElement type) => !_typesToMap.contains(type))
        .toList());
  }
}
