//
//  VideosListViewModelTests.swift
//  VideoPlayerDemoTests
//
//  Created by Claudio Villanueva on 01-09-25.
//

import Testing
@testable import VideoPlayerDemo

struct VideosListViewModelTests {

    @Test func getVideosList() async throws {
        let viewModel = VideosListViewModel(networkManager: MockNetworkManager())

        await viewModel.getVideosList()

        guard case .loaded = viewModel.loadingState else {
            Issue.record("Videos not loaded.")
            return
        }

        #expect(viewModel.loadingState == .loaded)
        #expect(viewModel.videosList.count == VideosList.mock().count)
    }

    @Test func showErrorAlert() async throws {
        let viewModel = VideosListViewModel(networkManager: MockNetworkManagerWithError())

        await viewModel.getVideosList()

        #expect(viewModel.loadingState == .failed)
        #expect(viewModel.showErrorAlert == true)
    }

}
