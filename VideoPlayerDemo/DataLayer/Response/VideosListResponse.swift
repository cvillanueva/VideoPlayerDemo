//
//  VideosListResponse.swift
//  VideoPlayerDemo
//
//  Created by Claudio Villanueva on 30-08-25.
//

import Foundation

// MARK: - VideosListElement
struct VideosListElement: Codable {
    let id, title: String
    let thumbnailURL: String
    let duration, uploadTime, views, author: String
    let videoURL: String
    let description, subscriber: String
    let isLive: Bool

    enum CodingKeys: String, CodingKey {
        case id, title
        case thumbnailURL = "thumbnailUrl"
        case duration, uploadTime, views, author
        case videoURL = "videoUrl"
        case description, subscriber, isLive
    }
}

typealias VideosList = [VideosListElement]

/// For testing and SwiftUI previews
extension VideosList {
    static func mock() -> VideosList {
        [
            .init(
                id: "1",
                title: "Mock video 1",
                thumbnailURL: "https://fake.domain.com/thumbnail_01.jpg",
                duration: "1:23",
                uploadTime: "Jan 1, 2025",
                views: "1,000",
                author: "Fake author 01",
                videoURL: "https://fake.domain.com/video_01.mp4",
                description: "Fake description 01",
                subscriber: "1000 subscribers",
                isLive: true
            ),
            .init(
                id: "2",
                title: "Mock video 2",
                thumbnailURL: "https://fake.domain.com/thumbnail_01.jpg",
                duration: "4:56",
                uploadTime: "Jan 2, 2025",
                views: "2,000",
                author: "Fake author 02",
                videoURL: "https://fake.domain.com/video_02.mp4",
                description: "Fake description 02",
                subscriber: "2000 subscribers",
                isLive: true
            )
        ]
    }
}

/// For testing and SwiftUI previews
extension VideosListElement {
    static func mock() -> Self {
        .init(
            id: "1",
            title: "Mock video 1",
            thumbnailURL: "https://fake.domain.com/thumbnail_01.jpg",
            duration: "1:23",
            uploadTime: "Jan 1, 2025",
            views: "1,000",
            author: "Fake author 01",
            videoURL: "https://fake.domain.com/video_01.mp4",
            description: "Fake description 01",
            subscriber: "1000 subscribers",
            isLive: true
        )
    }
}
