//
//  TextConstants.swift
//  Your Presentation
//
//  Created by a mystic on 12/25/23.
//

import Foundation

struct TextConstants {
    static let introEmojis = ["🎙️", "💡", "🌎", "💭", "💬", "🪄"]
    static let introTexts = [
        "Your Presentation",
        "I know you have great ideas.",
        "And I'm sure your ideas will change the world.",
        "But ideas that exist only in imagination are meaningless.",
        "Ideas are meaningful only when they are communicated well to people.",
        "If you want to convey your ideas to people more clearly, tap the button below."
    ]
    
    static let voiceAndFaceText = """
    When giving a presentation, both your voice and nonverbal communication are important.
    In this chapter we analyze your 🎙️voice, 🙂face and 👀eyes. (Tap the button in the top right for details)
    Lastly, it is important to write and practice a script before you begin your presentation.
    Write your script, choose the parts you think are important, and present it as if it were real.
    When you're ready, tap the button below.
    """
    
    static let postureText = """
    This chapter analyzes your presentation posture in terms of nonverbal aspects. (Tap the button in the top right for details)
    The analysis consists of two steps.
    1. Ready: Check your posture at the start of your presentation. If your posture is appropriate, count down 5 seconds and then move on to the next stage, the rehearsal stage.
    2. Rehearsal: You rehearse as if you were giving an actual presentation.
    Before you start your presentation, think about how you would like to pose during your presentation.
    When you're ready, tap the button below.
    """
    
    static let finishText = "I hope your ideas change the world."
    
    static let descriptionApp = "Your Presentation is an app that helps users give better presentations."
    
    static let descriptionVoiceAndFace = """
    Analyze 🎙️ voice, 🙂 facial expression, 👀 eyes.
    🎙️: Analyzes the volume of the user's voice to determine whether the user's voice is trembling. Additionally, it analyzes how well the script pronounced by the user matches the script entered.
    🙂: Recognizes facial expressions and analyzes expressions that appear too often.
    👀: By analyzing eye movements and blinking, we analyze how much eye movement or eye blinking occurs when giving a presentation.
    """
    
    static let descriptionVoiceAndFaceNotice = """
    * The script cannot be empty and cannot contain unpronounceable characters such as emojis.
    """
    
    static let descriptionPosture = """
    Focusing on the body, analyze ✋ hands and 🦶 feet.
    ✋: Hand positions are recorded to analyze how much the user moves their hands while presenting. Additionally, it recognizes whether the position of the user's hand is below the designated position.
    🦶: Recognizes the positions of the feet and shoulders and checks whether the user's feet are shoulder width apart. It also analyzes how much users move their feet while presenting. Additionally, it recognizes whether the user is crossing their legs.
    """
    
    static let descriptionPostureNotice = """
    * Correct presentation posture: Spread your legs about shoulder width and place your hands below your shoulders. And it is good to use your hands by moving them appropriately.
    ** Considering users who play alone, the game automatically moves to the feedback screen after 35 seconds. If you completed your presentation before then, tap the Finish button.
    """
}
