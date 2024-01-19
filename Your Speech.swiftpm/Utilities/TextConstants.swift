//
//  TextConstants.swift
//  Your Speech
//
//  Created by a mystic on 12/25/23.
//

import Foundation

struct TextConstants {
    static let introTexts = [
        "🎙️ Your Speech",
        "💡 I know you have great ideas.",
        "🌎 And I'm sure your ideas will change the world.",
        "💭 But ideas that exist only in imagination are meaningless.",
        "✉️ Ideas are meaningful only when they are well communicated to people.",
        "If you want to convey your idea to people, tap the button below."
    ]
    
    static let voiceAndFaceText = """
    When giving a presentation, not only your voice and voice but also non verbal communication is important.
    In this chapter, we analyze your voice and facial features. (Click the button in the top right for details)
    Lastly, it is important to write and practice a script before you begin your presentation.
    Write a script for your presentation, shorten the parts you think are important, and present it as if it were real.
    When you're ready, tap the button below.
    """
    
    static let postureText = """
    This chapter analyzes your presentation posture in terms of non-verbal aspects. (Click the button in the top right for details)
    The analysis consists of two steps.
    1. ready: Check your posture at the start of your presentation. If your posture is appropriate, count down 5 seconds and then move on to the next stage, the rehearsal stage.
    2. Rehearsal: You rehearse as if you were giving an actual presentation.
    Before you start your presentation, think about how you would like to pose during your presentation.
    When you're ready, tap the button below.
    """
    
    static let finishText = "I hope your ideas reach the world."
    
    static let descriptionApp = "Your Speech is an app that helps users give better presentations."
    
    static let descriptionVoiceAndFace = """
    Analyze 🎙️ voice, 🙂 facial expression, 👀 eyes.
    🎙️: Analyzes the volume of the user's voice to determine whether the user's voice is trembling. Additionally, it analyzes how well the script pronounced by the user matches the script entered.
    🙂: Recognizes facial expressions and analyzes expressions that appear too often.
    👀: By analyzing eye movements and blinking, we analyze how much eye movement or eye blinking occurs when giving a presentation.

    * If you have a stand, it is better to place the iPad on the stand.
    """
    
    static let descriptionPosture = """
    Focusing on the body, analyze ✋ hands and 🦶 foot.
    ✋: Hand positions are recorded to analyze how much the user moves their hands while presenting. It then recognizes whether the user's hand position is below the designated position.
    🦶: Recognizes the position of the foot and shoulders and checks whether the user's foot are as wide as the shoulders. It then analyzes how much the user moves his or her foot while making a presentation. Additionally, it recognizes whether the user is crossing their legs.

    * Correct presentation posture: foot should be spread about shoulder width and hands should be placed below the shoulders. It is best to move your hands appropriately and make gestures.
    ** Considering users who play alone, the game automatically moves to the feedback screen after 35 seconds. If you have completed your presentation before then, just click the Finish button.
    *** If you have a stand, it is better to place your iPad on the stand.
    """
}
