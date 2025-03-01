//
//  FollowingListView.swift
//  QuoteHub
//
//  Created by 이융의 on 11/16/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct FollowingListView: View {
    let userId: String?
    @EnvironmentObject var followViewModel: FollowViewModel
    @EnvironmentObject var userAuthManager: UserAuthenticationManager


    var body: some View {
        List {
            ForEach(followViewModel.following) { friend in
                NavigationLink(destination: FriendLibraryView(friendId: friend).environmentObject(userAuthManager)) {
                    HStack {
                        if let url = URL(string: friend.profileImage), !friend.profileImage.isEmpty {
                            WebImage(url: URL(string: friend.profileImage))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                                .padding(.trailing, 5)

                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .padding(.trailing, 5)
                        }

                        VStack(alignment: .leading) {
                            if !friend.nickname.isEmpty {
                                Text(friend.nickname)
                                    .font(.headline)
                            } else {
                                Text("닉네임")
                                    .font(.headline)
                            }
                            
                            Text(friend.statusMessage ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }
                        Spacer()
                    }
                }
            }
            if !followViewModel.isLastPage {
                ProgressView()
                    .onAppear {
                        followViewModel.FollowingsloadMoreIfNeeded(currentItem: followViewModel.following.last)
                    }
            }
        }
        .navigationTitle("친구 목록")
        .onAppear {
            followViewModel.resetLoadingState()
            followViewModel.loadFollowing(userId: userId ?? "")
        }
    }
}
