//
//  Folder.swift
//  QuoteHub
//
//  Created by 이융의 on 10/30/23.
//

import Foundation

struct Folder: Codable, Identifiable, Equatable {
    var id: String { _id }
    var _id: String
    var userId: User
    
    var name: String
    var description: String
    var folderImageURL: String
    var isPublic: Bool

    var createdAt: String
    var updatedAt: String

    var createdAtDate: String {
        return String(createdAt.prefix(10))
    }
    var updatedAtDate: String {
        return String(updatedAt.prefix(10))
    }
    
    static func ==(lhs: Folder, rhs: Folder) -> Bool {
        return lhs.id == rhs.id
    }
}


struct FolderResponse: Codable {
    var success: Bool
    var data: Folder
    var message: String?
}


struct FolderListResponse: Codable {
    var success: Bool
    var data: [Folder]
    var currentPage: Int
    var totalPages: Int
    var pageSize: Int
    var totalItems: Int
    let message: String?
}
