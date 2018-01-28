/**
 * Copyright Jan Vojáček 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation;
import KituraTemplateEngine;


public struct KituraMiniHandlebarsOptions: RenderingOptions {
    
    /// Constructor
    public init() {}
}

public class KituraMiniHandlebars: TemplateEngine {
    
    public let fileExtension: String = "html";
    
    public init () {}
    
    /// Public method to generate HTML.
    ///
    /// - Parameters:
    ///   - filePath: The path of the template file.
    ///   - context: A set of variables in the form of a Dictionary of Key/Value pairs.
    /// - Returns: String containing a HTML.
    /// - Throws: Template reading error.
    public func render (filePath: String, context: [String: Any]) throws -> String {
        return try render(filePath: filePath, context: context, options: KituraMiniHandlebarsOptions())
    }
    
    /// Public method to generate HTML.
    ///
    /// - Parameters:
    ///   - filePath: The path of the template file.
    ///   - context: A set of variables in the form of a Dictionary of Key/Value pairs.
    ///   - options: KituraMiniHandlebarsOptions. *Note:* no options available at the time.
    /// - Returns: String containing a HTML.
    /// - Throws: Template reading error.
    public func render (filePath: String, context: [String: Any], options: KituraMiniHandlebarsOptions) throws -> String {
        
        let html: String = try String(contentsOf: URL(fileURLWithPath: filePath), encoding: .utf8);
        
        return KituraMiniHandlebars.render(from: html, context: context);
    }
    
    /// Public static method to generate HTML.
    ///
    /// - Parameters:
    ///   - from: String from which to generate HTML.
    ///   - context: A set of variables in the form of a Dictionary of Key/Value pairs.
    /// - Returns: String containing a HTML.
    public static func render (from: String, context: [String: Any]) -> String {
        
        if from.isEmpty {
            return from;
        }
        
        var rendered: String = from;
        var commands: Array<String> = KituraMiniHandlebars.getAllCommands(from: from);
        
        // process commands
        while (commands.count > 0) {
            
            var processed: Bool = false;
            let command: String = commands.first!;
            let commandWithoutTags: String = command.filter({ (char) in
                return char != "{" && char != "}" && char != " ";
            });
            
            // conditional command
            if !processed && commandWithoutTags.hasPrefix("#if") {
                
                let range = commandWithoutTags.index(commandWithoutTags.startIndex, offsetBy: 3)...;
                let contextCommand: String = String(commandWithoutTags[range]);
                let endCommandOffset: Int = KituraMiniHandlebars.getConditionalEndCommandOffset(commands: commands);
                
                rendered = KituraMiniHandlebars.processConditionalCommand(
                    command: contextCommand,
                    render: rendered,
                    value: Bool(String(describing: context[contextCommand] != nil ? context[contextCommand]! : false)),
                    offset: endCommandOffset
                );
                
                let indexOfEnd: Int? = KituraMiniHandlebars.getIndexOfConditionalEnd(commands: commands, offset: endCommandOffset);
                
                if indexOfEnd != nil {
                    commands.remove(at: indexOfEnd!);
                }
                
                processed = true;
            }
            
            // default
            if !processed {
                
                rendered = KituraMiniHandlebars.processDefaultCommand(
                    command: command, render: rendered, value: context[commandWithoutTags]);
                
                processed = true;
            }
            
            commands.removeFirst();
        }
        
        return rendered;
    }
    
    /// Returns the exact position of a desired end tag of a conditional command in the array of commands offseted by an offset specified.
    ///
    /// - Parameters:
    ///   - commands: Array of commands.
    ///   - offset: Offset of a desired conditional ending tag to be found.
    /// - Returns: Index of desired tag.
    private static func getIndexOfConditionalEnd (commands: Array<String>, offset: Int) -> Int? {
        
        var endIndexIterations: Int = -1;
        
        let indexOfEnd = commands.index(where: { (command) -> Bool in
            
            if command.range(of: "/if") != nil {
                
                endIndexIterations += 1;
                
                if endIndexIterations == offset {
                    return true;
                }
            }
            
            return false;
        });
        
        return indexOfEnd;
    }
    
    /// Returns offset of a right ending tag of an conditional command currently being processed (on the first place in the 'commands' parameter).
    ///
    /// - Parameter commands: Array of commands.
    /// - Returns: Offset of a right end tag of the first processed conditional command..
    private static func getConditionalEndCommandOffset (commands: Array<String>) -> Int {
        
        var commandsToProcess: Array<String> = commands;
        commandsToProcess.removeFirst();
        
        var offset: Int = 0;
        var start: Int = 0;
        var end: Int = 0;
        
        for command in commandsToProcess {
            
            if command.range(of: "#if") != nil {
                start += 1;
                continue;
            }
            
            if command.range(of: "/if") != nil {
                
                if start == end {
                    return offset;
                }
                
                end += 1;
                offset += 1;
            }
        }
        
        return offset;
    }
    
    /// Processes only conditional commands. Takes offset of a ending tag as a parameter to skip any nested conditional commands.
    ///
    /// - Parameters:
    ///   - command: Command to be processed.
    ///   - render: Template string.
    ///   - value: Value to be used.
    ///   - offset: Offset for ending tag.
    /// - Returns: Modified template.
    private static func processConditionalCommand (command: String, render: String, value: Bool?, offset: Int) -> String {
        
        var toRender: String = render;
        let shouldSectionBeDisplayed = value != nil ? value! : false;
        
        do {
            
            let wholeTextRange: NSRange = NSRange(toRender.startIndex..., in: toRender);
            
            let startRegex: NSRegularExpression = try NSRegularExpression(pattern: "\\{\\{#if.*\(command).*\\}\\}");
            let startRange: NSRange = startRegex.rangeOfFirstMatch(in: toRender, range: wholeTextRange);
            
            // important: crucial condition, might cause engine to crash if not present
            if startRange.lowerBound == NSNotFound { // check whether range could be found
                return toRender;
            }
            
            let fromStartRangeTextRange: NSRange =
                NSRange(toRender.index(toRender.startIndex, offsetBy: Int(startRange.upperBound))..., in: toRender);
            
            let endRegex: NSRegularExpression = try NSRegularExpression(pattern: "\\{\\{/if.*\\}\\}");
            let endRangeMatches: [NSTextCheckingResult] = endRegex.matches(in: toRender, range: fromStartRangeTextRange);
            let endRange: NSRange = endRangeMatches[offset].range;
            
            if shouldSectionBeDisplayed {
                toRender.removeSubrange(Range(endRange, in: toRender)!);
                toRender.removeSubrange(Range(startRange, in: toRender)!);
            } else {
                toRender.removeSubrange(Range(NSRange(startRange.lowerBound...endRange.upperBound), in: toRender)!);
            }
            
        } catch {
            return render;
        }
        
        return toRender;
    }
    
    /// Processed all remaining command including the ones that contains variables. Deletes all that could not be processed from the template.
    ///
    /// - Parameters:
    ///   - command: Command to be processed.
    ///   - render: Template string.
    ///   - value: Value to be used.
    /// - Returns: Modified template.
    private static func processDefaultCommand (command: String, render: String, value: Any?) -> String {
        
        var toRender: String = render;
        let replaceWith: String = value != nil ? "\(value!)" : "";
        let range: Range<String.Index>? = toRender.range(of: command);
        
        if range == nil {
            return toRender;
        }
        
        toRender.replaceSubrange(range!, with: replaceWith);
        
        return toRender;
    }
    
    /// Iterates over a template and finds all valid commands of the KituraMiniHandlebars.
    ///
    /// - Parameter from: String of an template.
    /// - Returns: All KituraMiniHandlebars commands to be found in the string.
    private static func getAllCommands (from: String) -> Array<String> {
        
        let characters: Array<Character> = Array(from);
        var indexes: (start: Array<Int>, end: Array<Int>) = (start: Array<Int>(), end: Array<Int>());
        var commandRanges: Array<(Int, Int)> = Array<(Int, Int)>();
        var commands: Array<String> = Array<String>();
        
        for (index, char) in characters.enumerated() {
            
            if char == "{" && characters[index + 1] == "{" {
                indexes.start.append(index);
                continue;
            }
            
            if char == "}" && characters[index + 1] == "}" {
                indexes.end.append(index);
            }
        }
        
        for (a, b) in indexes.start.enumerated() {
            
            guard a < indexes.end.count else {
                break;
            }
            
            commandRanges.append((b, indexes.end[a]));
        }
        
        for (start, end) in commandRanges {
            
            let endIndex: Int = end + 1;
            
            guard endIndex < characters.count else {
                break;
            }
            
            commands.append(String(characters[Range(start...(end + 1))]));
        }
        
        return commands;
    }
}