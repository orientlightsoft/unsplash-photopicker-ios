//
//  UnsplashRequest.swift
//  Unsplash
//
//  Created by Olivier Collet on 2017-07-26.
//  Copyright © 2017 Unsplash. All rights reserved.
//

import Foundation

class UnsplashRequest: CommonRequest {
    override var apiURL: String {
        return Configuration.shared.unsplash.apiURL
    }
    override func prepareHeaders() -> [String: String]? {
        var headers = [String: String]()
        headers["Authorization"] = "Client-ID \(Configuration.shared.unsplash.accessKey)"
        return headers
    }
}
