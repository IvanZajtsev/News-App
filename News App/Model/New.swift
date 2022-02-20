//
//  New.swift
//  News App
//
//  Created by Иван Зайцев on 05.02.2022.
//

import Foundation

struct News: Codable {
    let articles: [Article]
    
}

struct Article: Codable {
    let title: String
    let description: String
    var url: String
//    var urlToImage: String?
    
    
    
     init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "No data :/"
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? "No data :/"
        url = try container.decodeIfPresent(String.self, forKey: .url) ?? ""
        
      }
}
