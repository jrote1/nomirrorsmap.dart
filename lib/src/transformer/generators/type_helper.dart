part of nomirrorsmap.generators;

class TypeHelper{
  final Map<LibraryElement, String> _libraryImportNames;

  TypeHelper(this._libraryImportNames);

  String getInstantiationFunc(Element element){
    return "() => new ${_getTypeString(element)}()";
  }

  String getTypeString(Element element){
    var result = _getTypeString( element );
    if ( result.contains( "<" ) )
    {
      return "const nomirrorsmap.TypeOf<$result>().type";
    }
    return result;
  }

  String _getTypeString( dynamic element )
  {
    var result = "";
    if ( _libraryImportNames.containsKey( element.type.element.library ) )
      result = "${_libraryImportNames[element.type.element.library]}.${element.type}";
    else
      result = element.type.name;

    if ( element.type is TypeParameterTypeImpl || element.type is DynamicTypeImpl )
    {
      print( "Type parameter found: ${element.type}" );
      return result;
    }
    if ( element.type.typeArguments.length > 0 )
    {
      result += "<";
      result += element.type.typeArguments.map( ( a ) => _getTypeString( a.element ) ).join( "," );
      result += ">";
    }

    return result;

  }

  String getFullTypeName(dynamic element){
    if ( element.type.element.library.displayName == "" )
      return element.displayName;
    return "${element.type.element.library.displayName}.${element.displayName}";
  }
}