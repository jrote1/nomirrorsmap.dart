part of nomirrorsmap.transformer;

class _GeneratorParameters {
  final String mappingsClassName;
  final AssetId assetId;
  final UnmodifiableListView<Element> typesToMap;
  final UnmodifiableMapView<LibraryElement, String> libraryImportAliases;

  _GeneratorParameters(
      this.mappingsClassName,
      this.assetId,
      List<Element> typesToMap,
      Map<LibraryElement, String> libraryImportAliases)
      : this.typesToMap = new UnmodifiableListView<Element>(typesToMap),
        this.libraryImportAliases =
            new UnmodifiableMapView<LibraryElement, String>(
                libraryImportAliases);
}
