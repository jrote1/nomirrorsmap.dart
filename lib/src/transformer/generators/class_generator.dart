part of nomirrorsmap.generators;

class ClassGenerator implements Generator{
  final TypeHelper _typeHelper;

  ClassGenerator(this._typeHelper);

  @override
  bool isApplicable(element) => !(element is FieldElementImpl) && element is ClassElement && !element.isAbstract;


  //Should return noticed types
  @override
  List<Element> process(element, StringBuffer fileContent) {
    var seenTypes = [];

    fileContent.write( "new nomirrorsmap.ClassGeneratedMap( ${_typeHelper.getTypeString(element)}, \"${_typeHelper.getFullTypeName(element)}\", ${_typeHelper.getInstantiationFunc(element)}, {\n" );

    var currentElement = element;
    do {
      for (var field in currentElement.fields) {
        seenTypes.add(field);
        fileContent.write("'${field.displayName}': new nomirrorsmap.GeneratedPropertyMap( ${_typeHelper.getTypeString(field)}, (obj) => obj.${field.displayName}, (obj, value) => obj.${field.displayName} = value ),\n");
      }
      currentElement = currentElement.supertype.element;
    }
    while(currentElement != null && !currentElement.library.name.startsWith("dart.core"));
    fileContent.write( "}),\n" );

    return seenTypes;
  }
}