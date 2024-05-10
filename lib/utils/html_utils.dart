import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

List<String> splitHtmlTopLevelScrollableParts(String htmlContent) {
  Document document = parse(htmlContent);
  List<String> parts = [];
  StringBuffer currentPart = StringBuffer();

  // Flag to track if we're currently adding content to a non-table part
  bool isInTable = false;

  // Iterate through the top-level nodes in the parsed HTML
  for (var node in document.body!.nodes) {
    // Check if the current node is a top-level <table>
    if ((node.nodeType == Node.ELEMENT_NODE &&
            (node as Element).localName == 'table') ||
        (node.nodeType == Node.ELEMENT_NODE &&
            (node as Element).localName == 'pre')) {
      if (currentPart.isNotEmpty) {
        // If there's accumulated content before this table, add it as a part
        parts.add(currentPart.toString());
        currentPart.clear();
      }
      isInTable = true;
      // Add the outerHtml of the table to the parts
      parts.add(node.outerHtml);
    } else {
      if (isInTable) {
        // If we just finished a table, add the accumulated content as a part
        if (currentPart.isNotEmpty) {
          parts.add(currentPart.toString());
          currentPart.clear();
        }
        isInTable = false;
      }
      // Accumulate content, either leading up to a table or after a table

      // ...
      if (node.nodeType == Node.ELEMENT_NODE) {
        currentPart.write((node as Element).outerHtml);
      } else {
        currentPart.write((node.text?.trim()) ?? '');
      }
    }
  }

  // If there's remaining content after the last table, add it as a part
  if (currentPart.isNotEmpty) {
    parts.add(currentPart.toString());
  }

  return parts;
}
