//
//  CommonRequest.swift
//  UnsplashPhotoPicker
//
//  Created by Manh Pham on 11/17/20.
//

import Foundation

class CommonRequest: NetworkRequest {

    enum RequestError: Error {
        case invalidJSONResponse

        var localizedDescription: String {
            switch self {
            case .invalidJSONResponse:
                return "Invalid JSON response."
            }
        }
    }

    private(set) var jsonResponse: Any?

    // MARK: - Prepare the request

    var apiURL: String { return "" }
    
    override func prepareURLComponents() -> URLComponents? {
        guard let apiURL = URL(string: self.apiURL) else {
            return nil
        }

        var urlComponents = URLComponents(url: apiURL, resolvingAgainstBaseURL: true)
        urlComponents?.path = endpoint
        return urlComponents
    }

    override func prepareParameters() -> [String: Any]? {
        return nil
    }

    // MARK: - Process the response

    override func processResponseData(_ data: Data?) {
        if let error = error {
            completeWithError(error)
            return
        }

        guard let data = data else { return }

        do {
            jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.init(rawValue: 0))
            processJSONResponse()
        } catch {
            completeWithError(RequestError.invalidJSONResponse)
        }
    }

    func processJSONResponse() {
        if let error = error {
            completeWithError(error)
        } else {
            completeOperation()
        }
    }
}
