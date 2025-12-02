//
//  NetworkManager.swift
//  VideoPlayerDemo
//
//  Created by Claudio Villanueva on 30-08-25.
//

import Combine
import Foundation

protocol NetworkManager: ObservableObject {
    var downloadProgressPublisher: PassthroughSubject<[String: Double], Never> { get }
    var errorPublisher: PassthroughSubject<[String: String], Never> { get }

    func get<T: Decodable>(endpoint: Endpoint) async throws -> Result<T?>
    func startDownload(video: VideosListElement?)
}

class NetworkManagerImpl: NSObject, ObservableObject, NetworkManager, URLSessionDownloadDelegate {

    @Published var downloadTaskSession : URLSessionDownloadTask!
    private let urlCache: URLCache
    var progress: Double = 0
    var downloadProgress: [String: Double] = ["": 0.0]
    var downloadProgressPublisher = PassthroughSubject<[String: Double], Never>()
    var errorPublisher = PassthroughSubject<[String: String], Never>()
    var downloadingVideo: VideosListElement?


    init(urlCache: URLCache = .shared) {
        self.urlCache = urlCache
    }

    /// Generic function to consume a JSON from a given endpoint
    func get<T>(endpoint: Endpoint) async throws -> Result<T?> where T : Decodable {
        guard let url = URL(string: endpoint.rawValue) else { return Result(httpStatusCode: 999, data: nil) }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else { return Result(httpStatusCode: 999, data: nil) }

        switch httpResponse.statusCode {
        case 100..<200:
            return Result(httpStatusCode: httpResponse.statusCode, data: nil)

        case 200..<300:
            storeCachedResponse(urlRequest: URLRequest(url: url), data: data, response: response)
            let decodedData = try? JSONDecoder().decode(T.self, from: data)
            return Result(httpStatusCode: httpResponse.statusCode, data: decodedData)

        case 300..<600:
            return Result(httpStatusCode: httpResponse.statusCode, data: nil)

        default:
            return Result(httpStatusCode: 999, data: nil)
        }
    }

    /// Stores a cache in order to be able of use the app oflline
    func storeCachedResponse(urlRequest: URLRequest, data: Data, response: URLResponse) {
        let cachedResponse = CachedURLResponse(response: response, data: data)
        urlCache.storeCachedResponse(cachedResponse, for: urlRequest)
    }

    func startDownload(video: VideosListElement?) {
        downloadingVideo = video
        let urlString = downloadingVideo?.videoURL

        guard let validFileURL = URL(string: urlString ?? "") else { return }

        // We don't want to download the file if it already exists.
        let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if !FileManager.default.fileExists(atPath: directoryPath.appendingPathComponent(validFileURL.lastPathComponent).path) {
            self.progress = 0
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            downloadTaskSession = session.downloadTask(with: validFileURL)
            downloadTaskSession.resume()
        }
    }
}

/// To handle urlsession events
extension NetworkManagerImpl {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let fileURL = downloadTask.originalRequest?.url else { return }

        let directoryPath   = FileManager.default.urls(for : .documentDirectory, in  : .userDomainMask)[0]
        let destinationURL = directoryPath.appendingPathComponent(fileURL.lastPathComponent)

        // If the file exists, it is deleted. This should never happen, but just in case.
        try? FileManager.default.removeItem(at: destinationURL)

        do {
            // Copying temp file to directory
            try FileManager.default.moveItem(at: location, to: destinationURL)
        } catch {
            // To display an error if moving the downloaded file fails
            let downloadTaskError: [String: String] = [ErrorPublisherKey.downloadTaskError.rawValue: error.localizedDescription]
            self.errorPublisher.send(downloadTaskError)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            if let error = error {
                // Handle client-side errors
                let downloadTaskError: [String: String] = [ErrorPublisherKey.downloadTaskError.rawValue: error.localizedDescription]
                self.errorPublisher.send(downloadTaskError)
            } else if let httpResponse = task.response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                // Handle server-side errors
                let downloadTaskError: [String: String] = [ErrorPublisherKey.downloadTaskError.rawValue: "Server error \(httpResponse.statusCode)"]
                self.errorPublisher.send(downloadTaskError)
            }
        }

    nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        Task {
            await MainActor.run {
                // Updating the video player screen UI
                progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
                downloadProgress[downloadingVideo?.id ?? ""] = progress
                downloadProgressPublisher.send(downloadProgress)
            }
        }
    }
}

/// Intented to running tests and show SwiftUI previews
final class MockNetworkManager: NetworkManager {
    var downloadProgressPublisher = PassthroughSubject<[String: Double], Never>()
    var errorPublisher = PassthroughSubject<[String: String], Never>()

    func get<T>(endpoint: Endpoint) async -> Result<T?> where T : Decodable {
        switch endpoint {
        case .videosList:
            return Result(httpStatusCode: 200, data: VideosList.mock() as? T)
        }
    }

    func startDownload(video: VideosListElement?) {}
}

/// To run test with error cases
final class MockNetworkManagerWithError: NetworkManager {
    var downloadProgressPublisher = PassthroughSubject<[String: Double], Never>()
    var errorPublisher = PassthroughSubject<[String: String], Never>()

    func get<T>(endpoint: Endpoint) async -> Result<T?> where T : Decodable {
        switch endpoint {
        case .videosList:
            return Result(httpStatusCode: 404, data: nil)
        }
    }

    func startDownload(video: VideosListElement?) {
        let downloadTaskError: [String: String] = [ErrorPublisherKey.downloadTaskError.rawValue: "Download mock error"]
        self.errorPublisher.send(downloadTaskError)
    }
}

enum ErrorPublisherKey: String {
    case downloadTaskError = "downloadTaskError"
}

enum Endpoint: String {
    case videosList = "https://raw.githubusercontent.com/cvillanueva/VideoPlayerDemo/refs/heads/main/videos.json"
}

struct Result<T: Decodable> {
    let httpStatusCode: Int
    let data: T

    var resultMessage: String {
        switch httpStatusCode {
        case 100..<200:
            return "Informational response"

        case 200..<300:
            return "Success"

        case 300..<400:
            return "Redirected"

        case 400..<500:
            return "Client error"

        case 500..<600:
            return "Server error"

        default:
            return "Undefined error"
        }
    }
}

