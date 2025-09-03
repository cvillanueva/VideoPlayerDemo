//
//  VideoPlayerViewModelTests.swift
//  VideoPlayerDemoTests
//
//  Created by Claudio Villanueva on 02-09-25.
//

import Testing
@testable import VideoPlayerDemo

struct VideoPlayerViewModelTests {

    @Test func showErrorAlert() async throws {
        let viewModel = VideoPlayerViewModel(networkManager: MockNetworkManagerWithError())

        viewModel.downloadVideo()

        try await Task.sleep(for: .milliseconds(1500))

        #expect(viewModel.showErrorAlert == true)
        #expect(viewModel.errorAlertTitle == "The video could not be downloaded")
        #expect(viewModel.errorAlertMessage == "Download mock error")
    }


    @Test func setVideo() async throws {

        let viewModel = VideoPlayerViewModel(networkManager: MockNetworkManager())
        viewModel.setVideo(video: VideosListElement.mock())

        #expect(viewModel.video?.id == "1")
        #expect(viewModel.video?.title == "Mock video 1")
    }
}
