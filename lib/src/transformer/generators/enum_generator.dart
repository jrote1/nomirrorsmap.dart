part of nomirrorsmap.generators;

class EnumGenerator implements Generator{
  final TypeHelper _typeHelper;

  EnumGenerator(this._typeHelper);

  @override
  bool isApplicable(element) => element.type.element.isEnum;

  @override
  List<Element> process(element, StringBuffer fileContent) {
    fileContent.write( "new nomirrorsmap.EnumGeneratedMap( ");
    fileContent.write( "${_typeHelper.getTypeString( element )}, ");
    fileContent.write( "${_typeHelper.getTypeString( element )}.values ),\n" );
    return [];
  }
}