part of nomirrorsmap.transformer;

class TransformerOptions {
  static const LIBRARY_NAMES_PARAM = "library_names";

  final List<String> libraryNames;

  TransformerOptions.initialize(this.libraryNames);

  factory TransformerOptions(BarbackSettings settings) {
    return new TransformerOptions.initialize(
        _readLibraryList(settings.configuration, LIBRARY_NAMES_PARAM));
  }

  static List<String> _readLibraryList(Map config, String paramName) {
    var value = config[paramName];
    if (value == null) return null;
    var files = [];
    bool error = false;
    if (value is List) {
      files = value;
      error = value.any((e) => e is! String);
    } else if (value is String) {
      files = [value];
      error = false;
    } else {
      error = true;
    }
    if (error) {
      print('Invalid value for "$paramName" in the nomirrorsmap transformer.');
    }
    return files;
  }
}
