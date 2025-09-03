//
//  VideoPlayerViewModel.swift
//  VideoPlayerDemo
//
//  Created by Claudio Villanueva on 31-08-25.
//

import AVKit
import Foundation
import Combine

class VideoPlayerViewModel: NSObject, ObservableObject {

    @Published var showProgressView = true
    @Published var player: AVPlayer?
    @Published var downloadButtonText: String = "Download"
    @Published var downloadStatus: DownloadStatus = .notDownloaded
    @Published var downloadProgress: Int = 0
    @Published var downloadProgressUI: CGFloat = 0.0
    @Published var showErrorAlert: Bool = false
    @Published var errorAlertTitle = ""
    @Published var errorAlertMessage = ""

    var networkManager: any NetworkManager
    var cancellables = Set<AnyCancellable>()
    var video: VideosListElement?

    init(networkManager: any NetworkManager) {
        self.networkManager = networkManager
        super.init()
        subscribeDownloadProgressPublisher()
        subscribeDownloadsErrorPublisher()
    }

    /// To update the UI when a video is downloaded
    func subscribeDownloadProgressPublisher() {
        networkManager.downloadProgressPublisher.sink(receiveValue: { [weak self] value in
            self?.downloadProgress = Int((value[self?.video?.id ?? ""] ?? 0.0) * 100.0)
            self?.downloadProgressUI = CGFloat(150.0 * (value[self?.video?.id ?? ""] ?? 0.0))

            if self?.downloadProgress == 100 {
                self?.downloadStatus = .downloaded
                self?.downloadProgress = 0
                self?.downloadProgressUI = 0.0
            }
        })
        .store(in: &cancellables)
    }

    /// To get download errors and handle the UI
    func subscribeDownloadsErrorPublisher() {
        networkManager.errorPublisher.sink(receiveValue: { [weak self] value in
            Task { @MainActor in
                self?.downloadStatus = .notDownloaded
                self?.errorAlertTitle = "The video could not be downloaded"
                self?.errorAlertMessage = value[ErrorPublisherKey.downloadTaskError.rawValue] ?? ""
                self?.showErrorAlert = true
            }
        })
        .store(in: &cancellables)
    }

    func setVideo(video: VideosListElement) {
        self.video = video
        checkDownloadedVideo()

        switch downloadStatus {
        case .notDownloaded, .downloading:
            // Play the video consuming the file from the remote server
            self.player = AVPlayer(url:  URL(string: video.videoURL)!)
        case .downloaded:
            // Play the video with a locally downloaded file
            self.player = AVPlayer(url:  URL(string: getLocalVideoPath())!)
        }

        self.player?.allowsExternalPlayback = false
        setPlayerStatusObserver()
    }

    /// To observe status changes in the player
    private func setPlayerStatusObserver() {
        guard let player = player else { return }

        player.currentItem?.addObserver(
            self,
            forKeyPath: #keyPath(AVPlayerItem.status),
            options: [.old, .new],
            context: nil
        )
    }

    func pauseVideo() {
        player?.pause()
    }

    /// Asks the network manager to download a video
    func downloadVideo() {
        // URL example: http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4
        networkManager.startDownload(video: video)
        downloadStatus = .downloading
    }

    /// Deletes the downloaded video
    func deleteDownloadedVideo() {
        guard let validFileURL = URL(string: video?.videoURL ?? "") else {  return }
        let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = directoryPath.appendingPathComponent(validFileURL.lastPathComponent).path
        if FileManager.default.fileExists(atPath: filePath){
            do {
                try FileManager.default.removeItem(atPath: filePath)
                downloadStatus = .notDownloaded
            } catch {
                Task { @MainActor in
                    downloadStatus = .notDownloaded
                    errorAlertTitle = "The video could not be deleted"
                    errorAlertMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }

    /// To show the apropiate button and set the player with a local or remote video
    private func checkDownloadedVideo() {
        guard let validFileURL = URL(string: video?.videoURL ?? "") else {  return }
        let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if FileManager.default.fileExists(atPath: directoryPath.appendingPathComponent(validFileURL.lastPathComponent).path){
            downloadStatus = .downloaded
        }
    }

    /// Returns the local video path to set the player
    private func getLocalVideoPath() -> String {
        guard let validFileURL = URL(string: video?.videoURL ?? "") else {  return "" }
        let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = directoryPath.appendingPathComponent(validFileURL.lastPathComponent).path
        return "file://\(filePath)"
    }

    /// To check the status of the video player and handle the preogress view
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            switch status {
            case .readyToPlay:
                showProgressView = false
                player?.play()
            case .failed:
                showProgressView = false
                errorAlertTitle = "Error"
                errorAlertMessage = "The video could not be played, please check your network access."
                showErrorAlert = true
            case .unknown:
                errorAlertTitle = "Error"
                errorAlertMessage = "An unknown error happened."
                showErrorAlert = true
            @unknown default:
                errorAlertTitle = "Error"
                errorAlertMessage = "A fatal error happened."
                showErrorAlert = true
            }
        }
    }
}

enum DownloadStatus {
    case notDownloaded
    case downloading
    case downloaded
}
