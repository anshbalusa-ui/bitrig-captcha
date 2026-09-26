import SwiftUI

@main
struct FoldCaptchaApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                viewModel: ChallengeViewModel(
                    challengeGenerator: ChallengeGenerator(),
                    validator: TrajectoryValidator(),
                    haptics: HapticService()
                )
            )
        }
    }
}
