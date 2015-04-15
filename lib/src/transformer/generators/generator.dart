part of nomirrorsmap.generators;

abstract class Generator{
  bool isApplicable(dynamic element);
  List<Element> process(dynamic element, StringBuffer fileContent);
}