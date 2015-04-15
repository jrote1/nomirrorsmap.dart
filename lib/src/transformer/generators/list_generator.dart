part of nomirrorsmap.generators;

class ListGenerator implements Generator{
  final DartType _listType;
  final TypeHelper _typeHelper;

  ListGenerator(Resolver resolver, this._typeHelper) : _listType = resolver.getType( "dart.core.List" ).type;

  @override
  bool isApplicable(dynamic element) => _listType == element.type.element.type || element.type.isSubtypeOf( _listType );

  @override
  List<Element> process(dynamic element, StringBuffer fileContent) {
    fileContent.write( "new nomirrorsmap.ListGeneratedMap(" );
    fileContent.write( " ${_typeHelper.getTypeString( element )},");
    fileContent.write( " ${_typeHelper.getTypeString( element.type.typeArguments.first.element )},");
    fileContent.write( " ${_typeHelper.getInstantiationFunc( element )} ),\n" );
    return [];
  }
}