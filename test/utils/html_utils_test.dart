import 'package:flutter_ai_chatbot/utils/html_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

void main() {
  test(
      'splitHtmlByTopLevelTables should split HTML content by top-level tables',
      () {
    // Arrange
    String htmlContent = '''
      <p>Some text</p>
      <table>
        <tr>
          <td>Table 1</td>
        </tr>
      </table>
      <p>Some text</p>
      <table>
        <tr>
          <td>Table 2</td>
        </tr>
      </table>
      <p>Some text</p>
      <pre>
        <code class="language-json">{
          "name": "Rajani Kanth",
          "age": 120,
          "city": "Erragadda"
        }
        </code>
      </pre>
      <p>Some text</p>
    ''';

    // Act
    List<String> result = splitHtmlTopLevelScrollableParts(htmlContent);

    // Assert
    expect(result.length, 7);

    expect(
      (parse(result[0]).body!.nodes[0] as Element).outerHtml,
      (parse('''
      <p>Some text</p>''').body!.nodes[0] as Element).outerHtml,
    );

    expect(
      (parse(result[1]).body!.nodes[0] as Element).outerHtml,
      (parse('''
      <table>
        <tr>
          <td>Table 1</td>
        </tr>
      </table>''').body!.nodes[0] as Element).outerHtml,
    );

    expect(
      (parse(result[2]).body!.nodes[0] as Element).outerHtml,
      (parse('''
      <p>Some text</p>''').body!.nodes[0] as Element).outerHtml,
    );

    expect(
      (parse(result[3]).body!.nodes[0] as Element).outerHtml,
      (parse('''
      <table>
        <tr>
          <td>Table 2</td>
        </tr>
      </table>''').body!.nodes[0] as Element).outerHtml,
    );

    expect(
      (parse(result[4]).body!.nodes[0] as Element).outerHtml,
      (parse('''
      <p>Some text</p>''').body!.nodes[0] as Element).outerHtml,
    );

    expect(
      (parse(result[5]).body!.nodes[0] as Element).outerHtml,
      (parse('''
      <pre>
        <code class="language-json">{
          "name": "Rajani Kanth",
          "age": 120,
          "city": "Erragadda"
        }
        </code>
      </pre>''').body!.nodes[0] as Element).outerHtml,
    );

    expect(
      (parse(result[6]).body!.nodes[0] as Element).outerHtml,
      (parse('''
      <p>Some text</p>''').body!.nodes[0] as Element).outerHtml,
    );
  });
}
