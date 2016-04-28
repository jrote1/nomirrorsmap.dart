part of nomirrorsmap.transformer;

class TransformerOptions {
  static const LIBRARY_NAMES_PARAM = "library_names";
  static const FORMAT_CODE_NAMES_PARAM = "format_code";

  final List<String> libraryNames;
  final bool formatCode;

  TransformerOptions.initialize(this.libraryNames, this.formatCode);

  factory TransformerOptions(BarbackSettings settings) {
    return new TransformerOptions.initialize(_readLibraryList(settings.configuration, LIBRARY_NAMES_PARAM), _readBool(settings.configuration, FORMAT_CODE_NAMES_PARAM, defaultValue: true));
  }

  static bool _readBool(Map config, String paramName, {bool defaultValue}) {
    return config.containsKey(paramName) ? config[paramName] != false : defaultValue;
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
