////
////  BookStoryDetailView.swift
////  QuoteHub
////
////  Created by 이융의 on 2023/09/12.
////
//
//import SwiftUI
//
///// 북스토리 상세 뷰. isMyStory가 true인 경우, 내 북스토리 뷰 (삭제, 수정 가능)
///// isMyStory가 false 인 경우, 상대방 스토리 뷰 (차단/신고 가능)
//
//struct BookStoryDetailView: View {
//    
//    // MARK: - PROPERTIES
//    let story: BookStory
//    let isMyStory: Bool
//    
//    // view model
//    @EnvironmentObject private var userAuthManager: UserAuthenticationManager
//    
//    @Environment(BlockReportViewModel.self) private var blockReportViewModel
//    @State private var detailViewModel = BookStoryDetailViewModel()
//    
//    @State private var commentViewModel: BookStoryCommentsViewModel
//    
//    // 북스토리 삭제 시 뒤로가기
//    @Environment(\.dismiss) var dismiss
//    
//    init(story: BookStory, isMyStory: Bool = false) {
//        self.story = story
//        self.isMyStory = isMyStory
//        self._commentViewModel = State(wrappedValue: BookStoryCommentsViewModel(bookStoryId: story.id))
//    }
//    
//    // MARK: - BODY
//    
//    var body: some View {
//        Group {
//            // 여기서 분기처리 (북스토리 잘 불러와졌을 때(mainContent), 차단된 사용자일때, 못불러왔을 때
//            if let currentStory = detailViewModel.story {
//                mainContent(currentStory)
//            } else if detailViewModel.isLoading == false {
//                ContentUnavailableView("북스토리를 찾을 수 없습니다", systemImage: "book.closed.fill")
//            }
//        }
//        .backgroundGradient()
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationTitle("북스토리")
//        .toolbar {
//            toolBarItems
//        }
//        // 북스토리 수정, 차단 액션 시트
//        .confirmationDialog(Text(""), isPresented: $detailViewModel.showActionSheet) { actionSheetView
//        }
//        .alert("알림", isPresented: $detailViewModel.showAlert) {
//            Button(role: .cancel) {} label: { Text("확인") }
//        } message: { Text(detailViewModel.alertMessage) }
//        // 댓글창
//        .sheet(isPresented: $detailViewModel.isCommentSheetExpanded) {
//            CommentView()
//                .presentationDetents([.medium, .large])
//                .presentationDragIndicator(.visible)
//        }
//        
//        // 북스토 신고하기 창
//        .sheet(isPresented: $detailViewModel.showReportSheet) {
//            ReportSheetView(
//                targetId: story.id,
//                reportType: .bookstory
//            )
//            .presentationDetents([.medium, .large])
//            .presentationDragIndicator(.visible)
//
//        }
//        .refreshable {
//            await withTaskGroup(of: Void.self) { group in
//                group.addTask {
//                    await detailViewModel.loadStoryDetail(storyId: story.id)
//                }
//                group.addTask {
//                    await commentViewModel.loadCommentCount()
//                }
//            }
//        }
//        // 뷰가 나타날 때마다 서버로부터 최신 북스토리 가져오기
//        .task {
//            await withTaskGroup(of: Void.self) { group in
//                group.addTask {
//                    await detailViewModel.loadStoryDetail(storyId: story.id)
//                }
//                group.addTask {
//                    await commentViewModel.loadCommentCount()
//                }
//            }
//        }
//        .progressOverlay(viewModel: detailViewModel, opacity: false)
//        .environmentObject(detailViewModel)
//        .environmentObject(commentViewModel)
//    }
//    
//    // MARK: - VIEW COMPONENTS
//    
//    @ViewBuilder
//    private func mainContent(_ currentStory: BookStory) -> some View {
//        ScrollView {
//            LazyVStack {
//                if detailViewModel.isCarouselView {
//                    CarouselStoryQuotesDisplayView(story: currentStory)
//                } else {
//                    ListStoryQuotesDisplayView(story: currentStory)
//                }
//                spacer(height: 20)
//                CommonStoryDisplayView(story: currentStory, isMyStory: isMyStory)
//            }
//        }
//    }
//    
//    @ViewBuilder
//    private var actionSheetView: some View {
//        if isMyStory {
//            // 내 스토리라면 편집, 삭제 시트를
//            NavigationLink {
//                StoryQuotesRecordView(book: story.bookId, storyId: story.id)
//            } label: {
//                Text("수정하기")
//            }
//            
//            Button("삭제하기", role: .destructive) {
////                Task {
////                    let isSuccess = await storiesViewModel.deleteBookStory(storyID: story.id)
////                    if isSuccess { dismiss() }
////                    else { detailViewModel.showAlertWith(message: "북스토리를 삭제하지 못했습니다.") }
////                }
//            }
//            
//            Button("취소", role: .cancel) { }
//            
//        } else {
//            // 친구 스토리라면 차단, 신고 시트를
//            Button("차단하기") {
//                Task { await blockUser() }
//            }
//            Button("신고하기") {
//                detailViewModel.toggleReportSheet()
//            }
//            Button("취소", role: .cancel) { }
//        }
//    }
//    
//    private var toolBarItems: some ToolbarContent {
//        Group {
//            ToolbarItem(placement: .primaryAction) {
//                HStack {
//                    Button {
//                        detailViewModel.toggleViewMode()
//                    } label: {
//                        Image(systemName:
//                                detailViewModel.isCarouselView ? "square.3.layers.3d.down.backward" : "list.bullet.below.rectangle")
//                        .scaleEffect(x: 1, y: detailViewModel.isCarouselView ? 1 : -1)
//                    }
//                    if userAuthManager.isUserAuthenticated {
//                        Button {
//                            detailViewModel.toggleCommentSheet()
//                        } label: {
//                            Image(systemName: "bubble.right")
//                        }
//                        Button {
//                            detailViewModel.showActionSheetView()
//                        } label: {
//                            Image(systemName: "ellipsis")
//                        }
//                    }
//                }
//            }
//        }
//    }
//    private func blockUser() async {
//        let isSuccess = await blockReportViewModel.blockUser(story.userId.id)
//        let alertMessage = isSuccess ? blockReportViewModel.successMessage : blockReportViewModel.errorMessage
//        detailViewModel.showAlertWith(message: alertMessage ?? "")
//    }
//}
