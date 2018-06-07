//
//  LinguisticTagger.swift
//  NaturalLanguageSampler
//
//  Created by Daiki Matsudate on 2018/06/06.
//

import Foundation

/// This is old tagger api released on iOS 11. To compare Natural Language Framework, wrapping same interface as new one.
public extension NSLinguisticTagger {

    public convenience init(tagSchemes: [NSLinguisticTagScheme]) {
        self.init(tagSchemes: tagSchemes, options: 0)
    }

    public func tags(text: String, unit: NSLinguisticTaggerUnit, scheme: NSLinguisticTagScheme, options: NSLinguisticTagger.Options = []) -> [(NSLinguisticTag, NSRange)] {
        string = text
        let range = NSRange(location: 0, length: text.count)
        var tokenRanges: NSArray?
        let tags: [NSLinguisticTag] = self.tags(in: range, unit: unit, scheme: scheme, options: options, tokenRanges: &tokenRanges)
        return tags.indices.compactMap {
            guard let range = tokenRanges?[$0] as? NSRange, tags[$0] != "" else { return nil }
            return (tags[$0], range)
        }
    }

    public func tagging(text: String, unit: NSLinguisticTaggerUnit, scheme: NSLinguisticTagScheme, options: NSLinguisticTagger.Options = []) {
        string = text
        let range = NSRange(location: 0, length: text.count)
        enumerateTags(in: range, unit: unit, scheme: scheme, options: options) { (tag, tokenRange, stop) in
            if let tag = tag, let range = Range(tokenRange, in: text) {
                print("\(text[range]): \(tag.rawValue)")
            }
        }
    }
}
