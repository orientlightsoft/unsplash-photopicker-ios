//
//  UnsplashPagedRequest.swift
//  Unsplash
//
//  Created by Olivier Collet on 2017-09-28.
//  Copyright © 2017 Unsplash. All rights reserved.
//

import Foundation

class UnsplashPagedRequest: CommonPagedRequest {
    // MARK: - Prepare the request
    override var apiURL: String {
        return Configuration.shared.unsplash.apiURL
    }
    override func prepareHeaders() -> [String: String]? {
        var headers = [String: String]()
        headers["Authorization"] = "Client-ID \(Configuration.shared.unsplash.accessKey)"
        return headers
    }
    
    override func prepareParameters() -> [String: Any]? {
        var parameters = super.prepareParameters() ?? [String: Any]()
        parameters["page"] = cursor.page
        parameters["per_page"] = cursor.perPage

        if let cursorParameters = cursor.parameters {
            for (key, value) in cursorParameters {
                parameters[key] = value
            }
        }

        return parameters
    }
}
