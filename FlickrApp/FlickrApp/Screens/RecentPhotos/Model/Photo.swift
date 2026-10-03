//
//  Photo.swift
//  FlickrApp
//
//  Created by Zülal Nebin on 3.10.2026.
//

import Foundation

struct Photo: Codable {
    let id: Int
    let pageURL: String
    let type: String
    let tags: String

    let previewURL: String
    let previewWidth: Int
    let previewHeight: Int

    let webformatURL: String
    let webformatWidth: Int
    let webformatHeight: Int

    let largeImageURL: String
    let fullHDURL: String?
    let imageURL: String?

    let imageWidth: Int
    let imageHeight: Int
    let imageSize: Int

    let views: Int
    let downloads: Int
    let collections: Int
    let likes: Int
    let comments: Int

    let user_id: Int
    let user: String
    let userImageURL: String
    let userURL: String

    let noAiTraining: Bool
    let isAiGenerated: Bool
    let isGRated: Bool
    let isLowQuality: Bool

    let name: String
}

extension Photo {
    var avatarURL: String {
        userImageURL.isEmpty
            ? "https://www.flickr.com/images/buddyicon.gif"
            : userImageURL
    }
}
