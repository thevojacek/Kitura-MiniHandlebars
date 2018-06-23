# Kitura-MiniHandlebars

A Templating engine for Kitura that uses Handlebars-like syntaxed templates.

## Changelog
### 1.2.x
**Kitura 2.4 support added.**

Fixed bug where the engine could crash when command was placed as a last item in a template file.

## Summary

`Kitura-MiniHandlebars` enables Kitura servers to serve HTML content generated from Handlebars-like templates `(.html files as of now)`.

**Note:** This is not an implementation of Handlebars for Kitura web server by IBM. It only uses similar (mostly same) syntax, but does not aim to implement whole handlebars functionality, but only it's portions. See `"Usage"` for more info about whats supported.

## Installation

Install using SPM (Swfit Package Manager).

## Usage

### Variables rendering

You can render almost any variable into the template.

```html
    <p>{{text}}</p>
```

### Conditional rendering (#if)

You can use conditional rendering and even use nested tags to compose complex templates.
**Notice:** Make sure that you use only variables of evaluatable `Bool` type, anything else will be evaluated as false and therefore the block will not be rendered.

```html
    {{#if visible}}

        <p>This is rendered.</p>

        {{#if nonVisible}}
            <p>This is not rendered.</p>
        {{/if}}

    {{/if}}
```

### Loop rendering (#each command)

You can use each ```{{#each list}}{{/each}}``` to render repetitevely from an array. The rendered contextual property must be of a type ```Array<[String:Any]>```.
**Notice:** If a rendered property is not an array, whole block will be deleted.

```swift
let context: [String: Any] = [
    "articles": [
        [ "title": "Some title", "text": "Any text...", "views": 324 ],
        [ "title": "Some title 2", "text": "Any text...", "views": 98 ]
    ]
];
```

```html
<div>
{{#each articles}}
    <!-- This code will be repeated twice and rendered -->
    <article>
        <h3>{{title}}</h3>
        <p>{{text}}</p>
        <span>Views: {{views}}</span>
    </article>
{{/each}}
</div>
```


### Usage examples

```html
<div>

    <p>{{paragraph}}</p>

    <a href="{{link}}">{{linkName}}</a>

    {{#if visible}}

        <div>This should be displayed!</div>

        {{#if nonVisible}}
            <div>This is not rendered.</div>
        {{/if}}

    {{/if}}
</div>
```

```swift
import Kitura_MiniHandlebars;

// Create a new router
let router = Router();

// Add KituraMiniHandlebars as a TemplatingEngine
router.add(templateEngine: KituraMiniHandlebars());

// Handle HTTP GET requests
router.get("/docs") { _, response, next in

    let context: [String: Any] = [
        "paragraph": "Some text.",
        "link": "https://www.ibm.com/us-en/",
        "linkName": "IBM's website.",
        "visible": true,
        "nonVisible": false
    ];

    try response.render("index.html", context: [String:Any]());
    response.status(.OK);
    next();
}

// Static rendering
router.get("/something") { _, response, next in

    let context: [String: Any] = [:];
    // you can also load an template from a file manually
    let template: String = """
        <div></div>
    """;

    let html: String = KituraMiniHandlebars.render(from: template, context: context);

    try response.send(template).status(.OK);
    next();
}
```

## License
Copyright 2018 Jan Vojáček

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Full license text is available in LICENSE.txt attached to this library.
