////
////  FollowListView.swift
////  QuoteHub
////
////  Created by 이융의 on 11/16/23.
////
//
//import SwiftUI
//
//// MARK: - Follow List Type
//
//enum FollowListType: String, CaseIterable {
//    case followers = "팔로워"
//    case following = "팔로잉"
//    
//    var title: String {
//        switch self {
//        case .followers:
//            return "팔로워 목록"
//        case .following:
//            return "팔로잉 목록"
//        }
//    }
//    
//    var emptyMessage: String {
//        switch self {
//        case .followers:
//            return "아직 팔로워가 없어요"
//        case .following:
//            return "아직 팔로잉한 사람이 없어요"
//        }
//    }
//    
//    var emptyDescription: String {
//        switch self {
//        case .followers:
//            return "다른 사용자들과 소통해보세요!"
//        case .following:
//            return "관심 있는 사용자를 팔로우해보세요!"
//        }
//    }
//}
//
//// MARK: - Follow List View
//
//struct FollowListView: View {
//    let userId: String?
//    let type: FollowListType
//    
//    @EnvironmentObject private var followViewModel: FollowViewModel
//    
//    /// 현재 타입에 따른 사용자 목록
//    private var currentUsers: [User] {
//        switch type {
//        case .followers:
//            return followViewModel.followers
//        case .following:
//            return followViewModel.following
//        }
//    }
//    
//    var body: some View {
//        ZStack {
//            GradientBackground()
//            
//            ScrollView(showsIndicators: false) {
//                LazyVStack(spacing: 16) {
//                    if currentUsers.isEmpty && !followViewModel.isLoading {
//                        emptyStateView
//                            .padding(.top, 60)
//                    } else {
//                        ForEach(currentUsers, id: \.id) { user in
//                            NavigationLink(
//                                destination: LibraryView(otherUser: user)
//                            ) {
//                                UserRow(user: user)
//                            }
//                            .buttonStyle(CardButtonStyle())
//                            .onAppear {
//                                followViewModel.loadMoreIfNeeded(currentItem: user, type: type)
//                            }
//                        }
//                        
//                        // 더 로딩할 데이터가 있을 때 로딩 인디케이터
//                        if !followViewModel.isLastPage && !currentUsers.isEmpty {
//                            loadingMoreView
//                        }
//                    }
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 20)
//                .padding(.bottom, 100)
//            }
//        }
//        .navigationTitle(type.title)
//        .navigationBarTitleDisplayMode(.inline)
//        .progressOverlay(viewModel: followViewModel, animationName: "progressLottie", opacity: true)
//        .refreshable {
//            await refreshContent()
//        }
//        .onAppear {
//            setupContent()
//        }
//    }
//    
//    // MARK: - UI Components
//    
//    private var emptyStateView: some View {
//        VStack(spacing: 24) {
//            Image(systemName: type == .followers ? "person.2.fill" : "person.badge.plus.fill")
//                .font(.system(size: 50))
//                .foregroundColor(.secondaryText.opacity(0.6))
//            
//            VStack(spacing: 8) {
//                Text(type.emptyMessage)
//                    .font(.scoreDream(.bold, size: .title3))
//                    .foregroundColor(.primaryText)
//                
//                Text(type.emptyDescription)
//                    .font(.scoreDream(.medium, size: .subheadline))
//                    .foregroundColor(.secondaryText)
//                    .multilineTextAlignment(.center)
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 60)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(.ultraThinMaterial)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(Color.antiqueGold.opacity(0.2), lineWidth: 1)
//                )
//        )
//        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
//    }
//    
//    private var loadingMoreView: some View {
//        HStack(spacing: 12) {
//            ProgressView()
//                .scaleEffect(0.8)
//                .tint(.brownLeather)
//            
//            Text("더 불러오는 중...")
//                .font(.scoreDream(.regular, size: .subheadline))
//                .foregroundColor(.secondaryText)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 20)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(.ultraThinMaterial)
//        )
//        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
//    }
//    
//    // MARK: - Methods
//    
//    private func setupContent() {
//        guard let userId = userId else { return }
//        
//        followViewModel.resetLoadingState()
//        
//        switch type {
//        case .followers:
//            followViewModel.loadFollowers(userId: userId)
//        case .following:
//            followViewModel.loadFollowing(userId: userId)
//        }
//    }
//    
//    private func refreshContent() async {
//        setupContent()
//    }
//}
//
//// MARK: - User Card Component
//
//struct UserRow: View {
//    let user: User
//    
//    var body: some View {
//        
//        HStack(spacing: 16) {
//            // 프로필 이미지
//            ProfileImage(profileImageURL: user.profileImage, size: 60)
//            // 사용자 정보
//            userInfoView
//            
//            Spacer()
//            
//            // 화살표 아이콘
//            Image(systemName: "chevron.right")
//                .font(.caption.weight(.medium))
//                .foregroundColor(.secondaryText.opacity(0.6))
//        }
//        .padding(20)
//        .backgroundCard(cornerRadius: 20)
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
//    }
//    
//    // MARK: - User Card Components
//    
//    private var userInfoView: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text(user.nickname)
//                .font(.scoreDream(.bold, size: .body))
//                .foregroundColor(.primaryText)
//                .lineLimit(1)
//                .truncationMode(.tail)
//            
//            Text(user.statusMessage ?? "상태메시지가 없습니다")
//                .font(.scoreDream(.medium, size: .subheadline))
//                .foregroundColor(.secondaryText)
//                .lineLimit(2)
//                .multilineTextAlignment(.leading)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//    }
//}
