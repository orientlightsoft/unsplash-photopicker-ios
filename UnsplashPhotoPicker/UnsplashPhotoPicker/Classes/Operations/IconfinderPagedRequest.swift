//
//  IconfinderPagedRequest.swift
//  UnsplashPhotoPicker
//
//  Created by Manh Pham on 11/17/20.
//

import Foundation

class IconfinderPagedRequest: CommonPagedRequest {
    // MARK: - Prepare the request
    override var apiURL: String {
        return Configuration.shared.iconfinder.apiURL
    }
    override func prepareHeaders() -> [String: String]? {
        var headers = [String: String]()
        headers["Authorization"] = "Bearer \(Configuration.shared.iconfinder.apiKey)"
        return headers
    }
    
    override func prepareParameters() -> [String: Any]? {
        var parameters = super.prepareParameters() ?? [String: Any]()
        parameters["offset"] = (cursor.page - 1) * cursor.perPage
        parameters["count"] = cursor.perPage

        if let cursorParameters = cursor.parameters {
            for (key, value) in cursorParameters {
                parameters[key] = value
            }
        }

        return parameters
    }
}
