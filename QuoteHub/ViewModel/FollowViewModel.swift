//
//  FollowViewModel.swift
//  QuoteHub
//
//  Created by 이융의 on 11/15/23.
//

import Foundation

class FollowViewModel: ObservableObject {
    @Published var followers = [User]()
    @Published var following = [User]()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isLastPage = false
    @Published var isBlocked: Bool = false

    
    @Published var followersCount: Int = 0
    @Published var followingCount: Int = 0

    private var currentPage = 1
    private let pageSize = 10
    private var service = FollowService()
    @Published var isFollowing: Bool = false
    private var userId: String?

    init(userId: String? = nil) {
        self.userId = userId
    }
    
    func setUserId(_ newUserId: String?) {
        userId = newUserId
        // 필요한 추가 로직, 예를 들어 userId 변경에 따른 데이터 로드 등
    }
    
    func resetLoadingState() {
        currentPage = 1
        followers.removeAll()
        following.removeAll()
        isLoading = false
        isLastPage = false
    }

    
    func updateFollowStatus(userId: String) {
        service.checkFollowStatus(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let followStatus):
                    self.isFollowing = followStatus.isFollowing
                    self.isBlocked = followStatus.isBlocked
                case .failure(let error):
                    print("Error checking follow status: \(error)")
                }
            }
        }
    }
    
    // 팔로워 및 팔로잉 수를 로드하는 메서드
    func loadFollowCounts() {
        guard let userId = self.userId else { return }

        service.getFollowCounts(userId: userId) { [weak self] result in
            switch result {
            case .success(let followCountResponse):
                DispatchQueue.main.async {
                    self?.followersCount = followCountResponse.followersCount
                    self?.followingCount = followCountResponse.followingCount
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func updateFollowCounts(for userId: String) {
        service.getFollowCounts(userId: userId) { [weak self] result in
            switch result {
            case .success(let followCountResponse):
                DispatchQueue.main.async {
                    self?.followersCount = followCountResponse.followersCount
                    self?.followingCount = followCountResponse.followingCount
                }
            case .failure(let error):
                print("Error updating follow counts: \(error)")
            }
        }
    }

    // 팔로우
    func followUser(userId: String) {
        isLoading = true
        print("Attempting to follow user: \(userId)")
        service.followUser(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    print("Follow response: \(response)")
                    if response.success {
                        self?.isFollowing = true
                        self?.updateFollowCounts(for: userId)
                        self?.following.append(response.data)
                    } else {
                        self?.errorMessage = response.error
                    }
                case .failure(let error):
                    if let afError = error.asAFError, afError.isResponseValidationError, afError.responseCode == 400 {
                        // 특정 에러 코드에 대한 사용자 친화적인 메시지 설정
                        self?.errorMessage = "자기 자신은 팔로우 할 수 없습니다."
                    } else {
                        // 일반 에러 메시지 설정
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    // 언팔로우
    func unfollowUser(userId: String) {
        isLoading = true
        print("Attempting to unfollow user: \(userId)")
        service.unfolllowUser(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let response):
                    print("Unfollow response: \(response)")
                    if response.success {
                        self?.isFollowing = false
                        self?.updateFollowCounts(for: userId)
                        self?.following.removeAll { $0._id == userId }
                    } else {
                        self?.errorMessage = response.error
                    }
                case .failure(let error):
                    print("Unfollow error: \(error)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // 팔로워 목록 로드
    func loadFollowers(userId: String) {
        guard !isLoading && !isLastPage else {
            print("로딩 중이거나 마지막 페이지입니다.")
            return
        }
        
        isLoading = true
        
        print("팔로워 로드 시작: userId = \(userId), currentPage = \(currentPage)")
        service.getFollowers(userId: userId, page: currentPage, pageSize: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("팔로워 로드 성공: \(response.data.count) 명")

                    self?.followers.append(contentsOf: response.data)
                    self?.isLastPage = response.currentPage >= response.totalPages
                    
                    self?.currentPage += 1
                    self?.isLoading = false
                case .failure(let error):
                    print("Error loading Followers List: \(error)")
                }
            }
        }
    }

    // 팔로잉 목록 로드
    func loadFollowing(userId: String) {
        guard !isLoading && !isLastPage else {
            print("로딩 중이거나 마지막 페이지입니다.")
            return
        }
        
        print("팔로잉 로드 시작: userId = \(userId), currentPage = \(currentPage)")
        isLoading = true

        service.getFollowing(userId: userId, page: currentPage, pageSize: pageSize) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print("팔로잉 로드 성공: \(response.data.count) 명")
                    self?.following.append(contentsOf: response.data)
                    self?.isLastPage = response.currentPage >= response.totalPages
                    self?.currentPage += 1
                    self?.isLoading = false
                case .failure(let error):
                    print("Error loading Following List: \(error)")
                }
            }
        }
    }
    
    func FollowersloadMoreIfNeeded(currentItem item: User?) {
        guard let item = item, let userId = self.userId else {
            print("필요한 정보가 없습니다.")
            return
        }

        print("더 많은 팔로워 로드가 필요할 수도 있습니다: currentItem = \(String(describing: item))")
        if item == followers.last {
            loadFollowers(userId: userId)
        }
    }
    
    func FollowingsloadMoreIfNeeded(currentItem item: User?) {
        guard let item = item, let userId = self.userId else {
            print("필요한 정보가 없습니다.")
            return
        }

        print("더 많은 팔로잉 로드가 필요할 수도 있습니다: currentItem = \(String(describing: item))")
        if item == following.last {
            loadFollowing(userId: userId)
        }
    }

    // 친구 차단 혹은 차단 해제

}

extension FollowViewModel {

    // Update follow status (block or unblock a friend)
    func updateFollowStatus(forUserId userId: String, withStatus status: Follow.Status, completion: @escaping (Bool, String?) -> Void) {
        service.updateFollowStatus(userId: userId, status: status.rawValue) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // Handle the success case, update UI or model as needed
                    completion(true, nil)
                case .failure(let error):
                    // Handle the error, maybe update the UI to show the error message
                    self.errorMessage = error.localizedDescription
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
}
