//
//  NaturalLanguageSamplerTests.swift
//  NaturalLanguageSamplerTests
//
//  Created by Daiki Matsudate on 2018/06/08.
//

import XCTest
import NaturalLanguage
@testable import NaturalLanguageSampler

fileprivate let text = """
Lorem ipsum dolor sit amet, has atqui numquam qualisque id, mei et tantas posidonium, eu habeo forensibus definitiones sed. Deserunt interesset reprehendunt ne per, nonumy ornatus antiopam ei mea. Sapientem constituto neglegentur an pro, oratio equidem pro cu. Salutatus comprehensam eu qui, aperiam volutpat scripserit per ut. At per scribentur accommodare, ea eam viderer definitiones.

Ut iudico scaevola mnesarchum sit, usu ipsum deserunt ne. Et nibh intellegat per, stet verterem ex eam, cum ad laudem vocent. Velit soluta sed cu, cu duo semper inermis graecis. Ex labores evertitur sed.

No modus reque semper nam, affert quodsi in per. Vim eu unum delenit, eum eu option iuvaret aliquid. Te qui albucius offendit definitionem, usu putant detraxit reformidans te, in mei delectus volutpat. Has natum aliquid principes id, ad est eruditi mnesarchum.

An audire volutpat pro, vel no wisi audiam nostrum. Quo vocent insolens an, mollis disputando liberavisse an sea. Cetero intellegam ius id, in sint habeo dolores vis, stet malorum eripuit ei eos. In usu modus corrumpit persequeris, atqui apeirian consequuntur nam ne, mutat dictas eos et.

Audire omnesque mei at, et vide maluisset similique has. Cu unum instructior nec, lucilius perfecto explicari sea at, lorem dolor munere quo ex. Eos ei paulo congue fabellas, vel cu reque putant expetendis, eum id clita facilisi. Mei euismod legendos an, et option pertinax mel. Eu usu solum latine deseruisse, quando recusabo in vis, eum ea saperet cotidieque. Mutat dolores democritum ut sit.
"""

class TokenizeTests: XCTestCase {
    func testTokenizeTextToWord() {
        let tokenizer = NLTokenizer(unit: .word)
        let tokens = tokenizer.tokens(text: text)
        XCTAssert(text[tokens.first!] == "Lorem")
        XCTAssert(text[tokens[1]] == "ipsum")
        XCTAssert(text[tokens[2]] == "dolor")
        XCTAssert(text[tokens.last!] == "sit")
    }

    func testTokenizeTextToSentence() {
        let tokenizer = NLTokenizer(unit: .sentence)
        let tokens = tokenizer.tokens(text: text)
        XCTAssert(text[tokens.first!] == "Lorem ipsum dolor sit amet, has atqui numquam qualisque id, mei et tantas posidonium, eu habeo forensibus definitiones sed. ") // need separator
        XCTAssert(text[tokens.last!] == "Mutat dolores democritum ut sit.")
    }

    func testTokenizeTextToParagraph() {
        let tokenizer = NLTokenizer(unit: .paragraph)
        let tokens = tokenizer.tokens(text: text)
        XCTAssert(text[tokens.first!] == "Lorem ipsum dolor sit amet, has atqui numquam qualisque id, mei et tantas posidonium, eu habeo forensibus definitiones sed. Deserunt interesset reprehendunt ne per, nonumy ornatus antiopam ei mea. Sapientem constituto neglegentur an pro, oratio equidem pro cu. Salutatus comprehensam eu qui, aperiam volutpat scripserit per ut. At per scribentur accommodare, ea eam viderer definitiones.\n") // only one new line...
    }

    func testTokenizeTextToDocument() {
        let tokenizer = NLTokenizer(unit: .document)
        let tokens = tokenizer.tokens(text: text)
        XCTAssert(text[tokens.first!] == text) // When we need to use this unit?
    }
}

class LanguageRecognizerTests: XCTestCase {
    func testTextLanguageIsEnglish() {
        let recognizer = NLLanguageRecognizer(text: text)
        XCTAssert(recognizer.dominantLanguage! == .english)
    }
    let japaneseText = "やっていき"

    func testTextLanguageIsJapanese() {
        let recognizer = NLLanguageRecognizer(text: japaneseText)
        XCTAssert(recognizer.dominantLanguage! == .japanese)
    }

    func testEnglishTextLanguageIsFrenchWithFrenchHigherHints() {
        let recognizer = NLLanguageRecognizer(text: text)
        recognizer.languageHints = [.french: 0.2, .english: 0.00001]
        XCTAssert(recognizer.dominantLanguage! == .french) // French
    }

    /// In spite of higher hint for French than English, the dominant language is detected to English
    func testEnglishTextLanguageIsEnglishWithFrenchHigherHints() {
        let recognizer = NLLanguageRecognizer(text: text)
        recognizer.languageHints = [.french: 0.2, .english: 0.1]
        XCTAssert(recognizer.dominantLanguage! == .english) // English
    }

    /// Japanese text is detected as Japanese regardless of specifying english for hints.
    func testJapaneseTextLanguageIsJapaneseWithEngishHints() {
        let recognizer = NLLanguageRecognizer(text: "やっていき")
        recognizer.languageHints = [.english: 0.1]
        XCTAssert(recognizer.dominantLanguage! == .japanese)
    }

    func testTextHypothesesContainEnglishAndPortuguese() {
        let recognizer = NLLanguageRecognizer(text: text)
        let hyphotheses = recognizer.languageHypotheses(withMaximum: 2)
        print(hyphotheses) // [pt: 0.32105109095573425, en: 0.4647941291332245]
        XCTAssert(hyphotheses.keys.contains(.english))    // 0.4647941291332245
        XCTAssert(hyphotheses.keys.contains(.portuguese)) // 0.32105109095573425
    }
}

class LinguisticTagsTests: XCTestCase {
    let text = "I can not go San Jose this year due to not have my ticket."
    let textContainsConstractions = "I can't go San Jose this year due to not have my ticket."

    func testPrintTags() {
        let schemes: [NLTagScheme] = [.language, .lemma, .lexicalClass, .nameTypeOrLexicalClass, .nameType, .tokenType, .script]
        let tagger = NLTagger(tagSchemes: schemes)

        // '.joinContractions' is only available in NaturalLanguage framework to treat contraction as a token.
        // If not specified this, `can't` will be treated as `ca` and `n't`
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinContractions]

        schemes.forEach({
            print("---- \($0.rawValue) ----")
            tagger.tagging(text: text, unit: .word, scheme: $0, options: options)
        })
    }

    func testPrintNSLinguisticTaggerTags() {
        let schemes: [NSLinguisticTagScheme] = [.language, .lemma, .lexicalClass, .nameTypeOrLexicalClass, .nameType, .tokenType, .script]
        let tagger = NSLinguisticTagger(tagSchemes: schemes)
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]

        schemes.forEach({
            print("---- \($0.rawValue) ----")
            tagger.tagging(text: text, unit: .word, scheme: $0, options: options)
        })
    }

    func testTagEqualEnglish() {
        let tagger = NLTagger(tagSchemes: [.language])
        let tags = tagger.tags(text: text, unit: .word, scheme: .language, options: [.omitPunctuation, .omitWhitespace, .joinContractions])
        XCTAssertEqual(tags.first!.0, (NLTag("en"))) // I: en
        XCTAssertEqual(tags[1].0, (NLTag("en"))) // can't: en
        XCTAssertEqual(tags.last!.0, (NLTag("en"))) // age: en
    }

    func testNLTagIsEqualToNSLinguisticTag() {
        let tSchemes: [NLTagScheme] = [.language, .lemma, .lexicalClass, .nameTypeOrLexicalClass, .nameType, .tokenType, .script]
        let lSchemes: [NSLinguisticTagScheme] = [.language, .lemma, .lexicalClass, .nameTypeOrLexicalClass, .nameType, .tokenType, .script]
        let tTagger = NLTagger(tagSchemes: tSchemes)
        let lTagger = NSLinguisticTagger(tagSchemes: lSchemes)

        zip(tSchemes, lSchemes).forEach { (tScheme, lScheme) in
            print("---- \(tScheme.rawValue) ----")
            XCTAssertEqual(tScheme.rawValue, lScheme.rawValue)

            let tags  = tTagger.tags(text: text, unit: .word, scheme: tScheme, options: [.omitPunctuation, .omitWhitespace])
            let lTags = lTagger.tags(text: text, unit: .word, scheme: lScheme, options: [.omitPunctuation, .omitWhitespace])
            zip(tags, lTags).forEach({ (tTag, lTag) in
                print(tTag.0.rawValue, lTag.0.rawValue, tTag.0.rawValue == lTag.0.rawValue)
                XCTAssertEqual(tTag.0.rawValue, lTag.0.rawValue)
                XCTAssertEqual(text[tTag.1], text[Range(lTag.1, in: text)!])
            })
        }
    }
}
