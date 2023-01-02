//
//  OpdsService.swift
//  opdsreader
//
//  Created by Николай Попов on 02.01.2023.
//

import Foundation
import ReadiumOPDS
import R2Shared

struct Book {
    var title: String
    var image: URL?
    var description: String
    var link: URL?
}

class OpdsService {
    static public var shared = OpdsService()
    
    static public func getDownloadLink(links: [Link]) -> URL? {
        if let epubLink = links.first(withMediaType: .epub) {
            return URL(string: (epubLink.href))
        }
        if let zipLink = links.first(withMediaType: .zip) {
            return URL(string: zipLink.href)
        }
        return nil
    }
    
    func searchByTitle(searchQuery: String, completion: @escaping ([Book]?, NSError?) -> Void) {
        
        if let _searchQuery =  searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            
            let requestLink = "http://flibusta.net/opds/opensearch?searchType=books&pageNumber=0&searchTerm=" + _searchQuery
            
            OPDS1Parser.parseURL(url: URL(string: requestLink)!) { parseData, error in
                if(error != nil) {
                    completion(nil, NSError())
                }
                if(parseData != nil) {
                    let bookArray = parseData?.feed?.publications.map {
                        Book(title: $0.metadata.title, image: nil, description: $0.metadata.description ?? "No description", link: OpdsService.getDownloadLink(links: $0.links))
                    } ?? []
                    completion(bookArray, nil)
                }
            }
        } else {
            completion(nil, NSError())
        }

    }
}
