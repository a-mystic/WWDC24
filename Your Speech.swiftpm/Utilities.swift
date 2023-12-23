//
//  Utilities.swift
//  Your Speech
//
//  Created by a mystic on 11/29/23.
//

import Foundation
import NaturalLanguage

func similarity(_ input: String, and compare: String) {
    if let sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english) {
        let input = """
Hello! I'm ChatGPT, an AI language model created by OpenAI. I'm here to assist you with any questions or information you may need. Let's chat and explore the world of knowledge together!
"""
        let compare = "hello! i'm mystic, an AI image model created by korea. I'm here to assist you with any questions or information you may need. Let's chat and explore the world of knowledge together!"
        let distance = sentenceEmbedding.distance(between: input, and: compare)
        print(distance.description)
    }
}

