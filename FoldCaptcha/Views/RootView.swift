import SwiftUI

struct RootView: View {
    enum Screen {
        case landing
        case challenge
    }

    @StateObject private var viewModel: ChallengeViewModel
    @State private var screen: Screen = .landing

    init(
        viewModel: ChallengeViewModel
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel
        )
    }

    var body: some View {
        Group {
            switch screen {
            case .landing:
                LandingView(
                    viewModel: viewModel
                ) {
                    beginChallenge()
                }

            case .challenge:
                ChallengeView(
                    viewModel: viewModel
                )
            }
        }
        .trackDuoHinge { reading in
            viewModel.receiveHingeReading(
                reading
            )
        }
        .task {
            viewModel.prepare()
        }
        .animation(
            .easeInOut(duration: 0.35),
            value: screen
        )
    }

    private func beginChallenge() {
        viewModel.restart()
        screen = .challenge
    }
}
