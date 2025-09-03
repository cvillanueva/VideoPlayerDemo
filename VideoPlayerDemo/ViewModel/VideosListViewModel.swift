//
//  VideosListViewModel.swift
//  VideoPlayerDemo
//
//  Created by Claudio Villanueva on 31-08-25.
//

import Foundation

public class VideosListViewModel: ObservableObject {
    var networkManager: any NetworkManager
    var loadingState: LoadingState = .notLoaded

    @Published var videosList: VideosList = []
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage = ""

    init(networkManager: any NetworkManager = NetworkManagerImpl()) {
        self.networkManager = networkManager
    }

    /// Retrieving yhe videos list
    func getVideosList() async {
        do {
            let result: Result<VideosList?> = try await networkManager.get(endpoint: .videosList)

            if result.httpStatusCode == 200 {
                guard let videosList = result.data else { return }

                await MainActor.run {
                    self.videosList = videosList
                    loadingState = .loaded
                }
            } else {
                await showErrorAlert(message: result.resultMessage)
            }
        } catch {
            await showErrorAlert(message: error.localizedDescription)
        }
    }

    /// Shows an alert in case of error
    func showErrorAlert(message: String) async {
        await MainActor.run {
            showErrorAlert.toggle()
            loadingState = .failed
            errorMessage = message
        }
    }
}

enum LoadingState {
    case loaded
    case notLoaded
    case failed
}
