//
//  SettingView.swift
//  QuoteHub
//
//  Created by 이융의 on 2023/09/09.
//

import SwiftUI

struct SettingView: View {
    
    @State private var showLogoutActionSheet: Bool = false
    @State private var showDeleteUserActionSheet: Bool = false
    @EnvironmentObject var userAuthManager: UserAuthenticationManager
    @EnvironmentObject var userViewModel: UserViewModel

    @State private var isLoading = false
    @State private var navigateToUserProfile = false
    
    private let introURL: String = "https://obtainable-postage-df4.notion.site/c4e2df8b16e643bfa05d61cadd238ba2?pvs=4"
    private let termsURL: String = "https://obtainable-postage-df4.notion.site/31236e89fe8942858a7b5a06f458e2ba?pvs=4"
    private let privacyURL: String = "https://obtainable-postage-df4.notion.site/6f8d432d3e5e417b9fa72d1121ec4011?pvs=4"
    private let supportURL: String = "https://docs.google.com/forms/d/e/1FAIpQLSd8Ljo-F7h92bBBy1z_gqHkWQaLWd3yqKogf60mnev7CnrIuw/viewform"
    @State private var isPresentIntroWebView = false
    @State private var isPresentTermsWebView = false
    @State private var isPresentPrivacyWebView = false
    @State private var isPresentSupportWebView = false

    var body: some View {
        
        if isLoading {
            ProgressView()
        }
        
        NavigationLink(destination: UserProfileView()
            .environmentObject(userViewModel)
            .onAppear {
                self.isLoading = false
            }, isActive: $navigateToUserProfile) {
            EmptyView()
        }

        
        List {
            Section(header: Text("내 정보")) {
                Button(action: {
                    self.isLoading = true
                    // 잠시 후에 navigateToUserProfile을 true로 설정하여 이동을 트리거
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.navigateToUserProfile = true
                    }
                }) {
                    HStack {
                        Image(systemName: "person.circle")
                        Text("내 프로필 수정")
                    }
                }
                
                NavigationLink(destination: BlockedListView()) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.xmark")
                        Text("차단 목록")
                    }
                }
                NavigationLink(destination: ReportListView()) {
                    HStack {
                        Image(systemName: "exclamationmark.bubble")
                        Text("신고 목록")
                    }
                }
            }
            
            Section(header: Text("지원")) {
                
                Button(action: {
                    isPresentIntroWebView = true
                }) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("서비스 소개 및 이용방법")
                    }
                }
                .fullScreenCover(isPresented: $isPresentIntroWebView) {
                    if let url = URL(string: introURL) {
                        WebView(url: url)
                            .ignoresSafeArea()
                    } else {
                        Text("Invalid URL")
                    }
                }
                
                Button(action: {
                    isPresentTermsWebView = true
                }) {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("서비스 이용약관")
                    }
                }
                .fullScreenCover(isPresented: $isPresentTermsWebView) {
                    if let url = URL(string: termsURL) {
                        WebView(url: url)
                            .ignoresSafeArea()
                    } else {
                        Text("Invalid URL")
                    }
                }

                Button(action: {
                    isPresentPrivacyWebView = true
                }) {
                    HStack {
                        Image(systemName: "shield.lefthalf.filled")
                        Text("개인정보 처리방침")
                            .fontWeight(.semibold)
                    }
                }
                .fullScreenCover(isPresented: $isPresentPrivacyWebView) {
                    if let url = URL(string: privacyURL) {
                        WebView(url: url)
                            .ignoresSafeArea()
                    } else {
                        Text("Invalid URL")
                    }
                }
                
                Button(action: {
                    isPresentSupportWebView = true
                }) {
                    HStack {
                        Image(systemName: "message")
                        Text("문의하기")
                    }
                }
                .fullScreenCover(isPresented: $isPresentSupportWebView) {
                    if let url = URL(string: supportURL) {
                        WebView(url: url)
                            .ignoresSafeArea()
                    } else {
                        Text("Invalid URL")
                    }
                }
                
                
                
                NavigationLink(destination: DeveloperInfoView()) {
                    HStack {
                        Image(systemName: "hammer.circle")
                        Text("개발자 정보")
                    }
                }
                
                NavigationLink(destination: VersionInfoView()) {
                    HStack {
                        Image(systemName: "number.circle")
                        Text("버전 정보")
                    }
                }
            }
            
            Section(header: Text("계정 관리")) {

                Button(action: {
                    showLogoutActionSheet = true
                }) {
                    HStack {
                        Image(systemName: "power")
                        Text("로그아웃")
                    }
                }
                .actionSheet(isPresented: $showLogoutActionSheet) {
                    ActionSheet(title: Text("로그아웃"), message: Text("정말로 로그아웃 하시겠습니까?"), buttons: [
                        .destructive(Text("로그아웃")) {
                            Task {
                                await userAuthManager.logout()
                            }
                        },
                        .cancel()
                    ])
                }
                
                Button(action: {
                    showDeleteUserActionSheet = true
                }) {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("회원탈퇴")
                            .foregroundColor(.red)
                    }
                }
                .actionSheet(isPresented: $showDeleteUserActionSheet) {
                    ActionSheet(title: Text("회원 탈퇴"), message: Text("회원 탈퇴를 진행하면 모든 개인 데이터와 정보가 영구적으로 삭제됩니다. 이 작업은 되돌릴 수 없습니다. 정말로 계속하시겠습니까?"), buttons: [
                        .destructive(Text("회원 탈퇴")) {
                            Task {
//                                await userAuthManager.revokeAccount() // bool
                            }
                        },
                        .cancel()
                    ])
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("설정")
    }
}
