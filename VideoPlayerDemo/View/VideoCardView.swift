//
//  VideoCardView.swift
//  VideoPlayerDemo
//
//  Created by Claudio Villanueva on 31-08-25.
//

import SwiftUI

struct VideoCardView: View {
    var title: String
    var date: String
    var duration: String
    var views: String

    let gradientEndRadius: CGFloat = 200
    let gradientStartRadius: CGFloat = 0

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(title)
                        .foregroundColor(CustomColor.videoCardTitle)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text(date)
                        .foregroundColor(Color.white)
                        .font(.callout)
                }

                HStack {
                    Image(systemName: "clock")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 15, height: 15)
                        .foregroundColor(Color.white)

                    Text(duration)
                        .foregroundColor(Color.white)
                        .font(.callout)
                    Spacer()
                    Image(systemName: "eye")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 10, height: 10)
                        .foregroundColor(Color.white)
                    Text(views)
                        .foregroundColor(Color.white)
                        .font(.callout)
                }

            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RadialGradient(
                gradient: Gradient(
                    colors: [
                        CustomColor.gradientInnerColor,
                        CustomColor.gradientOuterColor
                    ]
                ),
                center: .bottom,
                startRadius: gradientStartRadius,
                endRadius: gradientEndRadius
            )
        )
        .background(CustomColor.gradientOuterColor)
        .cornerRadius(16)
    }
}

#Preview {
    VStack {
        VideoCardView(
            title: "The title",
            date: "Jan 1, 2020",
            duration: "1:56",
            views: "95,624"
        )
        .padding()

        VideoCardView(
            title: "This is a long title to show at least two lines",
            date: "Jan 1, 2020",
            duration: "1:56",
            views: "95,624"
        )
        .padding()

        VideoCardView(
            title: "This is a really long title to see how the card scales with more than two lines",
            date: "Jan 1, 2020",
            duration: "1:56",
            views: "95,624"
        )
        .padding()

        Spacer()
    }
    .background(CustomColor.viewBackground)
    .frame(maxHeight: .infinity)
}
