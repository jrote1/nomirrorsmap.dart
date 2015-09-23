part of nomirrorsmap.transformer;

class MappingsGenerator {
  final Resolver _resolver;
  final AssetId _assetId;

  List<Element> _typesToMap = [];
  Map<LibraryElement, String> _libraryImportAliases = {};

  MappingsGenerator(this._resolver, this._assetId);

  void _addTypes(List<String> libraryNamesToInclude) {
    var allEnums = _expandCompilationUnitsWhereShouldBeMapped((compilationUnit) => compilationUnit.enums);
    _typesToMap.addAll(allEnums);

    var allTypes = _expandCompilationUnitsWhereShouldBeMapped((compilationUnit) => compilationUnit.types).where((type) => !type.isAbstract);
    _typesToMap.addAll(allTypes);

    for (var libraryName in libraryNamesToInclude) {
      var library = _resolver.getLibraryByName(libraryName);
      if (library == null) print("nomirrorsmap: '$libraryName' was not found so will be ignored");
      else {
        _typesToMap.addAll(library.units.expand((unit) => unit.enums.where((enumeration) => enumeration.isPublic)));
        _typesToMap.addAll(library.units.expand((unit) => unit.types.where((type) => type.isPublic && !type.isAbstract)));
      }
    }
    _typesToMap.addAll( _getListTypesFromPropertiesThatAreNotAlreadyMapped( ) );

    _generateLibraryAliases();
  }

  List<ClassElement> _expandCompilationUnitsWhereShouldBeMapped(Iterable<ClassElement> expand(CompilationUnitElement unit)) {
    return _resolver.libraries.expand((lib) => lib.units).expand((compilationUnit) => expand(compilationUnit)).where(_shouldBeMapped).toList();
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

  bool _shouldBeMapped(ClassElement type) {
    var mappableMetadataType = _resolver.getType("nomirrorsmap.Mappable");
    if (mappableMetadataType == null) return false;

    var metadata = type.metadata.map((meta) => meta.element).where((element) => element is ConstructorElement);

    for (ConstructorElement meta in metadata) {
      DartType metaType = meta.enclosingElement.type;
      if (metaType.isAssignableTo(mappableMetadataType.type)) {
        if (!type.isEnum &&
            (type.unnamedConstructor == null ||
                type.unnamedConstructor.parameters.length >
                    0)) throw "The type '${type.displayName}' has a @Mappable() annotation but no DefaultConstructor";
        return true;
      }
    }
    return false;
  }

  String generate(String className, List<String> libraryNamesToInclude) {
    _addTypes(libraryNamesToInclude);

    var generators = <_Generator>[
      new ClassTopGenerator(_resolver),
      new PropertiesGenerator(),
      new ClassGenerator(),
      new EnumsGenerator(),
      new ClassBottomGenerator()
    ];

    var parameters = new _GeneratorParameters(className, _assetId, _typesToMap, _libraryImportAliases);

    var formatter = new DartFormatter();
    return formatter.format(generators.map((generator) => generator.generate(parameters)).join());
  }

  bool _typeHasConstructor(ClassElement type) {
    return type.constructors.any((ctor) => ctor.parameters.length == 0) && !type.isAbstract;
  }

  List<ClassElement> _getListTypesFromPropertiesThatAreNotAlreadyMapped() {
    return _typesToMap
        .where((type) => !type.isEnum)
        .expand((type) => type.fields)
        .where((FieldElement field) => field.type.name == #List)
        .map((field) => field.type)
        .where((InterfaceType type) => type is InterfaceType && type.typeArguments.length > 0)
        .map((type) => type.typeArguments.first.element)
        .where((ClassElement type) => !_typesToMap.contains(type))
        .toList();
  }
}
