import XCTest
@testable import Kitura_MiniHandlebars

class Kitura_MiniHandlebarsTests: XCTestCase {
    
    func testRenderVariablesTest () {
        
        let testString: String = """
            <a href="{{link}}">{{name}}</a>
        """;
        
        let testContext: [String: Any] = [
            "link": "https://www.apple.com",
            "name": "Apple's website."
        ];
        
        let testResult: String = KituraMiniHandlebars.render(from: testString, context: testContext);
        
        let res_a: Range<String.Index>? = testResult.range(of: "\(testContext["link"]!)");
        let res_b: Range<String.Index>? = testResult.range(of: "\(testContext["name"]!)");
        
        XCTAssertNotNil(res_a);
        XCTAssertNotNil(res_b);
    }
    
    func testRenderVariableNotRendered () {
        
        let testString: String = """
        <div>
            <p>{{name}}</p>
        </div>
        """;
        
        let testContext: [String: Any] = [:];
        
        let testResult: String = KituraMiniHandlebars.render(from: testString, context: testContext);
        
        let res: Range<String.Index>? = testResult.range(of: "{{name}}");
        
        XCTAssertNil(res);
    }
    
    func testRenderConditionals () {
        
        let testString: String = """
        <div>
            {{#if visible}}
                <p>{{author}}</p>
            {{/if}}
            {{#if nonVisible}}
                <p>{{author2}}</p>
            {{/if}}
        </div>
        """;
        
        let testContext: [String: Any] = [
            "visible": true,
            "author": "H. Murakami",
            "nonVisible": false,
            "author2": "J.R.R. Tolkien"
        ];
        
        let testResult: String = KituraMiniHandlebars.render(from: testString, context: testContext);
        
        let res_a: Range<String.Index>? = testResult.range(of: "H. Murakami");
        let res_b: Range<String.Index>? = testResult.range(of: "J.R.R. Tolkien");
        
        XCTAssertNotNil(res_a);
        XCTAssertNil(res_b);
    }
    
    func testRenderConditionalsNesting () {
        
        let testString: String = """
        <div>
            {{#if visible}}
                <p>{{a1}}</p>
                {{#if nestedVisible}}
                    <p>{{a2}}</p>
                {{/if}}
                {{#if nestedNonVisible}}
                    <p>{{a3}}</p>
                {{/if}}
            {{/if}}
        </div>
        """;
        
        let testContext: [String: Any] = [
            "visible": true,
            "nestedVisible": true,
            "nestedNonVisible": false,
            "a1": "Playstation 3",
            "a2": "Xbox 360",
            "a3": "Xbox One"
        ];
        
        let testResult: String = KituraMiniHandlebars.render(from: testString, context: testContext);
        
        let res_a: Range<String.Index>? = testResult.range(of: "Playstation 3");
        let res_b: Range<String.Index>? = testResult.range(of: "Xbox 360");
        let res_c: Range<String.Index>? = testResult.range(of: "Xbox One");
     
        XCTAssertNotNil(res_a);
        XCTAssertNotNil(res_b);
        XCTAssertNil(res_c);
    }


    static var allTests = [
        ("testRenderVariablesTest", testRenderVariablesTest),
        ("testRenderVariableNotRendered", testRenderVariableNotRendered),
        ("testRenderConditionals", testRenderConditionals),
        ("testRenderConditionalsNesting", testRenderConditionalsNesting)
    ]
}
