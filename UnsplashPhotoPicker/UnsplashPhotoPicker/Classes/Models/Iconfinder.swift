//
//  Iconfinder.swift
//  UnsplashPhotoPicker
//
//  Created by Manh Pham on 11/17/20.
//

import Foundation

public struct Iconfinder: Codable {
    
    let id: Int
    let type: Type
    let rasters: [Asset]
    let vectors: [Asset]
    enum `Type`: String, Codable {
        case vector
    }
    enum CodingKeys: String, CodingKey {
        case id = "icon_id"
        case type
        case rasters = "raster_sizes"
        case vectors = "vector_sizes"
    }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        type = try container.decode(Type.self, forKey: .type)
        rasters = try container.decode([Asset].self, forKey: .rasters)
        vectors = try container.decode([Asset].self, forKey: .vectors)
    }
    
    struct Asset: Codable {
        let width: Double
        let height: Double
        let formats: [Format]
        enum CodingKeys: String, CodingKey {
            case width = "size_width"
            case height = "size_height"
            case formats
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            width = try container.decode(Double.self, forKey: .width)
            height = try container.decode(Double.self, forKey: .height)
            formats = try container.decode([Format].self, forKey: .formats)
        }
       
    }
    
    struct Format: Codable {
        let downloadURL: String
        let previewURL: String?
        let ext: String
        enum CodingKeys: String, CodingKey {
            case downloadURL = "download_url"
            case previewURL = "preview_url"
            case ext = "format"
        }
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            downloadURL = try container.decode(String.self, forKey: .downloadURL)
            previewURL = try container.decodeIfPresent(String.self, forKey: .previewURL)
            ext = try container.decode(String.self, forKey: .ext)
        }
    }
    
    /*
    curl --request GET \
    --url 'https://api.iconfinder.com/v4/icons/search?query=paint&count=10&offset=0&premium=0&vector=1' \
    --header 'Authorization: Bearer X0vjEUN6KRlxbp2DoUkyHeM0VOmxY91rA6BbU5j3Xu6wDodwS0McmilLPBWDUcJ1'
    */
}

extension Iconfinder {
    private var identifier: String { get { return "\(id)" }}
    private var displayName: String { return "" }
    private var urls: [URLKind: WrapAssetURLBlock] {
        var ret: [URLKind: WrapAssetURLBlock] = [:]
        if let thumb = self.rasters.last, let preview = thumb.formats.first?.previewURL, let previewURL = URL(string: preview) {
            ret[.thumb] = { $0(previewURL) }
        }
        
        if let fmt = self.vectors.first?.formats.first(where: { $0.ext == "svg"}), let downloadURL = URL(string: fmt.downloadURL) {
            
            ret[.regular] = { $0(downloadURL) }
            ret[.full] = { $0(downloadURL) }
            ret[.raw] = { $0(downloadURL) }
        }
        return ret
        
    }
    private var width: Int {
        return Int(self.vectors.first?.width ?? 0)
    }
    private var height: Int {
        return Int(self.vectors.first?.height ?? 0)
    }
    private var headers: [String: String] {
        return ["Authorization": "Bearer \(Configuration.shared.iconfinder.apiKey)"]
    }
    var wrap: WrapAsset<Iconfinder> {
        get {
            return WrapAsset<Iconfinder>(source: self,
                                         identifierKeyPath: \.identifier,
                                         nameKeyPath: \.displayName,
                                         colorKeyPath: nil,
                                         heightKeyPath: \.height,
                                         widthKeyPath: \.width,
                                         urlsKeyPath: \.urls,
                                         trackingKeyPath: nil,
                                         headersKeyPath: \.headers)
        }
    }
}
