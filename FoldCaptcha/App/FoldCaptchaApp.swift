import SwiftUI

@main
struct FoldCaptchaApp: App {
    var body: some Scene {
        WindowGroup {
            ChallengeView(
                viewModel: ChallengeViewModel(
                    challengeGenerator: ChallengeGenerator(),
                    validator: TrajectoryValidator(),
                    haptics: HapticService()
                )
            )
        }
    }
}
