//
//  AuthEndpoints.swift
//  QuoteHub
//
//  Created by 이융의 on 5/26/25.
//

import Foundation

enum AuthEndpoints: EndpointProtocol {
    case appleLogin
    case renewToken
    case validateAndRenewToken
    case revokeAccount
    case checkNickname(nickname: String)
    case changeNickname
    case generateNickname
    
    var path: String {
        switch self {
        case .appleLogin:
            return "/auth/apple/callback"
        case .renewToken:
            return "/auth/renew-token"
        case .validateAndRenewToken:
            return "/auth/validate-token"
        case .revokeAccount:
            return "/auth/revoke"
        case .checkNickname(let nickname):
            return "/auth/check-nickname?nickname=\(nickname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        case .changeNickname:
            return "/auth/change-nickname"
        case .generateNickname:
            return "/auth/generate-nickname"

        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .checkNickname, .generateNickname: return .GET
        case .changeNickname: return .PUT
        default: return .POST
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case .revokeAccount, .changeNickname: return true
        default: return false
        }
    }
}
