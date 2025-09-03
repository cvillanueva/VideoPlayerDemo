//
//  VideoPlayerView.swift
//  VideoPlayerDemo
//
//  Created by Claudio Villanueva on 31-08-25.
//

import AVKit
import SwiftUI

struct VideoPlayerView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: VideoPlayerViewModel
    @State var showFullscreen = false
    var video: VideosListElement

    init(video: VideosListElement, viewModel: VideoPlayerViewModel) {
        self.video = video
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                videoView
                    .frame(height: 240)
                if viewModel.showProgressView {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.large)
                        .tint(CustomColor.videoCardTitle)
                }
            }
            ScrollView(showsIndicators: false) {
                HStack {
                    Text("\(video.views) views")
                        .font(.callout)
                        .foregroundColor(.gray)

                    Spacer()

                    Text(video.uploadTime)
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))


                HStack {
                    Spacer()

                    Text(video.subscriber)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 16)
                .padding(.top, 16)

                HStack {
                    HStack {
                        Image(systemName: "person")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                        Text(video.author)
                            .multilineTextAlignment(.leading)
                            .padding()
                    }
                    Spacer()

                    // Show a button or view depending on the download status
                    switch viewModel.downloadStatus {
                    case .notDownloaded:
                        downloadButton
                    case .downloading:
                        downloadProgressView
                    case .downloaded:
                        deleteDownloadButton
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing, 16)
                Text(video.description)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .padding()
            }
            Spacer()
        }
        .fullScreenCover(isPresented: $showFullscreen) {
            ZStack {
                videoView
                fullScreenButtonLayerView
            }
            .background(.black)
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            backButton
            title
        }
        .onAppear {
            viewModel.setVideo(video: video)
        }
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(
                title: Text(viewModel.errorAlertTitle),
                message: Text(viewModel.errorAlertMessage),
                dismissButton: .default(Text("Ok"))
            )
        }
    }

    @ViewBuilder
    private var videoView: some View {
        VideoPlayer(player: viewModel.player) {
            if !showFullscreen {
                fullScreenButtonLayerView
            }
        }
    }

    @ViewBuilder
    private var fullScreenButtonLayerView: some View {
        VStack {
            HStack {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .padding(16)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .onTapGesture {
                        showFullscreen.toggle()
                    }
                Spacer()
            }
            Spacer()
        }
    }

    @ToolbarContentBuilder
    var backButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.pauseVideo()
                self.dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .tint(.black)
            }
        }
    }

    @ToolbarContentBuilder
    private var title: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            HStack {
                Text(video.title)
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private var downloadButton: some View {
        Button {
            viewModel.downloadVideo()
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 16, height: 16)
                    .tint(.black)
                    .padding()

                Text(viewModel.downloadButtonText)
                    .multilineTextAlignment(.leading)
                    .tint(.black)
                    .padding(.trailing, 16)
            }
            .frame(maxWidth: 150)
            .background(CustomColor.videoCardTitle)
            .cornerRadius(8)
        }
    }

    @ViewBuilder
    private var downloadProgressView: some View {
        HStack {
            ZStack {
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.gray).fill(Color.orange)
                        .frame(width: viewModel.downloadProgressUI, height: 40)
                    Rectangle()
                        .fill(Color.gray).fill(Color.gray)
                        .frame(width: (150 - viewModel.downloadProgressUI), height: 40)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                Text("\(viewModel.downloadProgress)% downloaded")
                    .font(.footnote)
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .frame(height: 40)
        .frame(maxWidth: 150)
        .cornerRadius(8)
    }

    @ViewBuilder
    private var deleteDownloadButton: some View {
        Button {
            viewModel.deleteDownloadedVideo()
        } label: {
            HStack(spacing: 0) {

                Text("Delete video")
                    .font(.footnote)
                    .tint(.white)
                    .padding()

                Image(systemName: "delete.left")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 12, height: 12)
                    .tint(.white)
                    .padding(.trailing, 16)
            }
            .frame(height: 40)
            .frame(maxWidth: 150)
            .background(.red)
            .cornerRadius(8)
        }
    }

}

#Preview {
    VideoPlayerView(
        video: VideosListElement.mock(),
        viewModel: VideoPlayerViewModel(networkManager: MockNetworkManager())
    )
}
