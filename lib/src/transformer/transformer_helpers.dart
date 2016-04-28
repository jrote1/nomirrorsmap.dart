part of nomirrorsmap.transformer;

class TransformerHelpers {
  static String sanitizePathToUsableImport(String path) {
    return path.replaceAll("/", "_").replaceAll(".", "_").replaceAll(":", "_");
  }

  static String sanitizePathToUsableClassName(String path) {
    var importName = sanitizePathToUsableImport(path);
    return importName
        .split("_")
        .map((str) => str[0].toUpperCase() + str.substring(1))
        .join();
  }

  static List uniquifyList(List list) {
    var result = [];

    for (var element in list)
      if (!result.contains(element)) result.add(element);

    return result;
  }
}
