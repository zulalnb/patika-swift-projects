//
//  PhotosResponse.swift
//  FlickrApp
//
//  Created by Zülal Nebin on 3.10.2026.
//

import Foundation

struct PhotosResponse: Codable {
    let total: Int
    let totalHits: Int
    let hits: [Photo]
}
