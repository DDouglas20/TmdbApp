//
//  MovieDetailsView.swift
//  TmdbApp
//
//  Created by DeQuan Douglas on 7/3/25.
//

import SwiftUI
import Kingfisher

struct MovieDetailsView: View {
    @Environment(\.darkModeColor) private var color
    @StateObject var viewModel: MovieDetailsViewModel
    @State var showDirectorPage: Bool = false
    
    var body: some View {
        ScrollView { // Account for device orientation / smaller screens
            VStack(alignment: .leading, spacing: 16) {
                // First view is the image view or the youtube view
                getCorrectMediaView()
                    .frame(height: 300)
                // Show overview
                CategoryView(
                    titleString: "Description: ",
                    subString: viewModel.movieDescription
                )
                Divider()
                // Show rating
                CategoryView(
                    titleString: "Rating: ",
                    subString: viewModel.movieCert,
                    needsHStack: true
                )
                Divider()
                // Show Date created
                CategoryView(
                    titleString: "Release Date: ",
                    subString: viewModel.releaseDate,
                    needsHStack: true
                )
                Divider()
                
                // Show genres
                CategoryView(
                    titleString: "Genres: ",
                    subString: viewModel.movieCategories
                )
                Divider()
                // Show Duration
                CategoryView(
                    titleString: "Duration: ",
                    subString: viewModel.duration,
                    needsHStack: true
                )
                Divider()
                // Show director + jobs
                VStack(alignment: .leading, spacing: 16) {
                    CategoryView(
                        titleString: "Director: ",
                        subString: viewModel.director.capitalized,
                        needsHStack: true,
                        needsUnderline: true,
                        tapGesture: {
                            viewModel.validateDirectorUrl()
                        }
                    )
                    Text(viewModel.directorJobs)
                        .foregroundStyle(color)
                        .font(.system(size: 13))
                }
                Divider()
                if viewModel.productionData.count > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Production Companies: ")
                            .foregroundStyle(color)
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                        ScrollView(.horizontal) {
                            HStack {
                                let prodData = viewModel.productionData
                                ForEach(0..<prodData.count, id: \.self) { index in
                                    VStack(spacing: 4) {
                                        Text("\(prodData[index].name):")
                                            .foregroundStyle(color)
                                            .font(.system(size: 15))
                                        KFImage(prodData[index].logoUrl)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .background(.white)
                                            .clipShape(Circle())
                                    }
                                    if index != prodData.count - 1 {
                                        Divider()
                                    }
                                }
                            }
                        }
                        .scrollDisabled(viewModel.productionData.count < 4)
                    }
                }
                Spacer() // Align everything to the top
            }
            .padding()
            .navigationTitle(viewModel.movieTitle)
            .navigationBarTitleDisplayMode(.automatic)
        }
        .fullScreenCover(isPresented: $viewModel.showDirPage) {
            if let url = viewModel.directorUrl {
                SFSafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .alert("Error", isPresented: $viewModel.showAlert, actions: {}, message: {
            Text("Could not open web page. Please try again later.")
        })
    }
    
    @ViewBuilder
    private func getCorrectMediaView() -> some View {
        Group {
            if let ytId = viewModel.youtubeId {
                YoutubeView(videoId: ytId)
                    .clipShape(RoundedRectangle(cornerRadius: 4.0))
            } else if let landscapeUrl = viewModel.landscapePath {
                KFImage(landscapeUrl)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 4.0))
            }
        }
        .shadow(color: color.opacity(0.3), radius: 6.0, x: 0, y: 0)
    }
}

private struct CategoryView: View {
    @Environment(\.darkModeColor) private var color
    let titleString: String
    let subString: String
    var needsHStack: Bool = false
    var needsUnderline: Bool = false
    var tapGesture: (() -> Void)? = nil
    var body: some View {
        if needsHStack {
            HStack(spacing: 2) {
                Text(titleString)
                    .foregroundStyle(color)
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                Text(subString)
                    .foregroundStyle(color)
                    .font(.system(size: 15))
                    .underline(needsUnderline)
                    .onTapGesture {
                        if let tapGesture {
                            tapGesture()
                        }
                    }
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text(titleString)
                    .foregroundStyle(color)
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                Text(subString)
                    .foregroundStyle(color)
                    .font(.system(size: 15))
                    .underline(needsUnderline)
                    .onTapGesture {
                        if let tapGesture {
                            tapGesture()
                        }
                    }
            }
        }
    }
}

#Preview {
    MovieDetailsView(viewModel: .init(movieObject: MovieData()))
}
