import SwiftUI

@main
struct FoldCaptchaApp: App {
    var body: some Scene {
        WindowGroup {
            ChallengeView(
                viewModel: ChallengeViewModel(
                    hingeService: SimulatorHingeService(),
                    challengeGenerator: ChallengeGenerator(),
                    validator: TrajectoryValidator(),
                    haptics: HapticService()
                )
            )
        }
    }
}
