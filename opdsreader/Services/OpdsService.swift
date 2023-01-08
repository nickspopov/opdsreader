//
//  OpdsService.swift
//  opdsreader
//
//  Created by Николай Попов on 02.01.2023.
//

import Foundation
import ReadiumOPDS
import R2Shared

struct Book: Identifiable, Equatable {
    var id = UUID()
    var title: String
    var author: String?
    var image: URL?
    var description: String?
    var link: URL?
    var allLinks: [URL]?
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
    
    static public func getAllLinks(links: [Link]) -> [URL]? {
        var _links: [URL] = []
        
        links.forEach {
            if let _link = URL(string: $0.href) {
                _links.append(_link)
            }
        }
        
        return _links
    }
    
    static public func getAuthor(authors: [Contributor]?) -> String {
        var authorsString = ""
        
        if let _authors = authors {
            _authors.forEach { _author in
                authorsString = authorsString + _author.name + " "
            }
        }
        
        return authorsString
    }
    
    func searchByTitle(searchQuery: String, pageNumber: Int = 0, completion: @escaping ([Book]?, NSError?) -> Void) {
        
        if let _searchQuery =  searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            
            let requestLink = "http://flibusta.net/opds/opensearch?searchType=books" + "&pageNumber=" + String(pageNumber) + "&searchTerm=" + _searchQuery
            
            OPDS1Parser.parseURL(url: URL(string: requestLink)!) { parseData, error in
                if(error != nil) {
                    completion(nil, NSError())
                }
                if(parseData != nil) {
                    let bookArray = parseData?.feed?.publications.map {
                        Book(
                            title: $0.metadata.title.trimmingCharacters(in: .whitespacesAndNewlines),
                            author: OpdsService.getAuthor(authors: $0.metadata.authors),
                            image: ($0.images.first != nil) ? URL(string: $0.images[0].href) : nil,
                            description: $0.metadata.description ?? "No description",
                            link: OpdsService.getDownloadLink(links: $0.links),
                            allLinks: OpdsService.getAllLinks(links: $0.links)
                        )
                    } ?? []
                    completion(bookArray, nil)
                }
            }
        } else {
            completion(nil, NSError())
        }

    }
}
