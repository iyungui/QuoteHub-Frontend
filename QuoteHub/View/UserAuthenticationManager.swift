//
//  UserAuthenticationManager.swift
//  QuoteHub
//
//  Created by 이융의 on 10/23/23.
//

import Foundation
import Alamofire

class UserAuthenticationManager: ObservableObject {
    @Published var isUserAuthenticated: Bool = KeyChain.read(key: "JWTAccessToken") != nil
    @Published var isOnboardingComplete: Bool = false
    @Published var showingLoginView: Bool = false
    
    // MARK: -  로그아웃 함수
    static let shared = UserAuthenticationManager()

    func logout(completion: @escaping (Result<Bool, Error>) -> Void) {
        if KeyChain.read(key: "JWTAccessToken") != nil {
            DispatchQueue.main.async {
                KeyChain.delete(key: "JWTAccessToken")
                KeyChain.delete(key: "JWTRefreshToken")
                self.isUserAuthenticated = false
            }

            completion(.success(true))
        } else {
            completion(.failure(NSError(domain: "LogoutError", code: 500, userInfo: [NSLocalizedDescriptionKey: "No token to delete"])))
        }
    }
    
    // MARK: - 회원 탈퇴
    
    func revokeUser(completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = APIEndpoint.revokeTokenURL
        
        guard let token = KeyChain.read(key: "JWTAccessToken") else {
            completion(.failure(NSError(domain: "UserService", code: -2, userInfo: [NSLocalizedDescriptionKey: "No Authorization Token Found"])))
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]

        AF.request(url, method: .post, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any], let success = json["success"] as? Bool, success {
                    if KeyChain.read(key: "JWTAccessToken") != nil {
                        KeyChain.delete(key: "JWTAccessToken")
                        KeyChain.delete(key: "JWTRefreshToken")
                        self.isUserAuthenticated = false
                    }
                    
                    completion(.success(true))
                } else {
                    let error = NSError(domain: "RevokeError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to revoke user data and token"])
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    // MARK: -  auto-login
    
    func validateToken() {
        let accessToken = KeyChain.read(key: "JWTAccessToken")
        let refreshToken = KeyChain.read(key: "JWTRefreshToken")
        
        guard let accessToken = accessToken, let refreshToken = refreshToken else {
            isUserAuthenticated = false
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "x-refresh-token": refreshToken
        ]
        
        let url = APIEndpoint.validateTokenURL
        
        AF.request(url, method: .post, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                if let json = value as? [String: Any], let valid = json["valid"] as? Bool {
                    if valid {
                        self.isUserAuthenticated = true
                    } else if let newAccessToken = json["newAccessToken"] as? String {
                        KeyChain.create(key: "JWTAccessToken", token: newAccessToken)
                        self.isUserAuthenticated = true
                    } else {
                        self.isUserAuthenticated = false
                    }
                }
            case .failure:
                self.isUserAuthenticated = false
            }
        }
    }
    
    func renewAccessToken(completion: @escaping (Bool) -> Void) {
        guard let token = KeyChain.read(key: "JWTRefreshToken") else {
            completion(false)
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        let renewTokenURL = APIEndpoint.JWTRefreshURL

        AF.request(renewTokenURL, method: .post, headers: headers)
            .responseDecodable(of: AccessTokenResponse.self) { response in
                switch response.result {
                case .success(let tokenResponse):
                    KeyChain.create(key: "JWTAccessToken", token: tokenResponse.accessToken)
                    completion(true)
                case .failure:
                    print("refresh token 만료, 로그인 필요")
                    completion(false)
                }
            }
    }

    struct AccessTokenResponse: Codable {
        let accessToken: String
    }
}