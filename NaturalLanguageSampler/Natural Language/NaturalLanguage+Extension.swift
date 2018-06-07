//
//  NaturalLanguage.swift
//  NaturalLanguageSampler
//
//  Created by Daiki Matsudate on 2018/06/05.
//

import NaturalLanguage

//MARK: Tokenization
public extension NLTokenizer {
    public func tokens(text: String) -> [Range<String.Index>] {
        string = text
        return tokens(for: text.startIndex..<text.endIndex)
    }

    public func tokenize(text: String) {
        string = text
        enumerateTokens(in: text.startIndex..<text.endIndex) { (tokenRange, attributes) -> Bool in
            print(text[tokenRange])
            return true
        }
    }
}

//MARK: - Language Identification
public extension NLLanguageRecognizer {

    public convenience init(text: String, constraints: [NLLanguage]? = nil) {
        self.init()

        if let constraints = constraints {
            languageConstraints = constraints
        }
        processString(text)
    }
}

//MARK: - Linguistic Tags
public extension NLTagger {

    public func tags(text: String, unit: NLTokenUnit, scheme: NLTagScheme, options: NLTagger.Options = []) -> [(NLTag, Range<String.Index>)] {
        string = text
        return tags(in: text.startIndex..<text.endIndex, unit: unit, scheme: scheme, options: options).compactMap({ (tag, tokenRange) -> (NLTag, Range<String.Index>)? in
            guard let tag = tag else { return nil }
            return (tag, tokenRange)
        })
    }

    public func tagging(text: String, unit: NLTokenUnit, scheme: NLTagScheme, options: NLTagger.Options = []) {
        string = text
        enumerateTags(in: text.startIndex..<text.endIndex, unit: unit, scheme: scheme, options: options) { tag, tokenRange in
            if let tag = tag {
                print("\(text[tokenRange]): \(tag.rawValue)")
            }
            return true
        }
    }
}

