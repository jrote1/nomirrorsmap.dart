part of nomirrorsmap.converters;

abstract class TypeInformationRetriever {
  ClassMapping getClassGeneratedMap(Type type);
  ClassMapping getClassGeneratedMapWithNoCheck(Type type);
  ClassMapping getClassGeneratedMapByListType(Type type);
  ClassMapping getClassGeneratedMapByQualifiedName(String qualifiedName);
  bool containsEnumGeneratedMap(Type type);
  List getEnumGeneratedMap(Type type);
}

class TypeInformationRetrieverLocator {
  static TypeInformationRetriever _instance;

  static setInstance(TypeInformationRetriever instance) {
    _instance = instance;
  }

  static TypeInformationRetriever get instance => _instance;
}
