//
//  IconfinderRequest.swift
//  UnsplashPhotoPicker
//
//  Created by Manh Pham on 11/17/20.
//

import Foundation

class IconfinderRequest: CommonRequest {
    override var apiURL: String {
        return Configuration.shared.iconfinder.apiURL
    }
    override func prepareHeaders() -> [String: String]? {
        var headers = [String: String]()
        headers["Authorization"] = "Bearer \(Configuration.shared.iconfinder.apiKey)"
        return headers
    }
}
