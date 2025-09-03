//
//  VideosListView.swift
//  VideoPlayerDemo
//
//  Created by Claudio Villanueva on 31-08-25.
//

import SwiftUI

struct VideosListView: View {

    var networkManager: any NetworkManager = NetworkManagerImpl()
    @ObservedObject var viewModel: VideosListViewModel

    init(networkManager: any NetworkManager) {
        self.networkManager = networkManager
        self.viewModel = VideosListViewModel(networkManager: networkManager)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.loadingState == .notLoaded {
                    ProgressView()
                        .controlSize(.large)
                }
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.videosList, id: \.id) { video in
                            NavigationLink {
                                VideoPlayerView(
                                    video: video,
                                    viewModel: VideoPlayerViewModel(networkManager: NetworkManagerImpl())
                                )
                            } label: {
                                VideoCardView(
                                    title: video.title,
                                    date: video.uploadTime,
                                    duration: video.duration,
                                    views: video.views
                                )
                            }
                        }
                    }
                    .padding()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    title
                }
            }
            .background(CustomColor.viewBackground)
        }
        .task {
            await viewModel.getVideosList()
        }
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(
                title: Text("Error retrieving videos"),
                message: Text(viewModel.errorMessage),
                dismissButton: .cancel()
            )
        }
    }

    @ToolbarContentBuilder
    private var title: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack {
                Image(systemName: "movieclapper")
                Text("Videos List")
                    .font(.headline)
            }
        }
    }
}

#Preview {
    VideosListView(networkManager: MockNetworkManager())
}
