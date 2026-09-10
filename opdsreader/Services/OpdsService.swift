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
    var authorName: String?
    var image: URL?
    var description: String?
    var link: URL?
    var allLinks: [URL]?
}

struct AuthorShort: Identifiable, Equatable {
    var id = UUID()
    var name: String
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
        if let djvuLink = links.first(withMediaType: .djvu) {
            return URL(string: djvuLink.href)
        }
        if let djvuZipLink = links.first(withMediaType: .djvuZip) {
            return URL(string: djvuZipLink.href)
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
    
    /// Default catalog: Standard Ebooks (public domain, OPDS 1.2, OpenSearch on `all?query=`).
    static let catalogBase = "https://standardebooks.org/feeds/opds"
    static let pageSize = 12

    private static func searchURL(query: String, pageNumber: Int) -> URL? {
        guard let q = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return nil }
        return URL(string: "\(catalogBase)/all?query=\(q)&per-page=\(pageSize)&page=\(pageNumber + 1)")
    }

    private static func book(from publication: Publication) -> Book {
        Book(
            title: publication.metadata.title.trimmingCharacters(in: .whitespacesAndNewlines),
            authorName: getAuthor(authors: publication.metadata.authors),
            image: publication.images.first.flatMap { URL(string: $0.href) },
            description: publication.metadata.description ?? "No description",
            link: getDownloadLink(links: publication.links),
            allLinks: getAllLinks(links: publication.links)
        )
    }

    private func fetchBooks(url: URL?, completion: @escaping ([Book]?, NSError?) -> Void) {
        guard let url = url else { completion(nil, NSError()); return }
        OPDS1Parser.parseURL(url: url) { parseData, error in
            if error != nil {
                completion(nil, NSError())
                return
            }
            let books = parseData?.feed?.publications.map(OpdsService.book(from:)) ?? []
            completion(books, nil)
        }
    }

    func searchByTitle(searchQuery: String, pageNumber: Int = 0, completion: @escaping ([Book]?, NSError?) -> Void) {
        fetchBooks(url: OpdsService.searchURL(query: searchQuery, pageNumber: pageNumber), completion: completion)
    }

    /// The catalog has no author navigation feed, so authors are derived from the books matching the query.
    func searchByAuthor(searchQuery: String, pageNumber: Int = 0, completion: @escaping ([AuthorShort]?, NSError?) -> Void) {
        fetchBooks(url: OpdsService.searchURL(query: searchQuery, pageNumber: pageNumber)) { books, error in
            guard let books = books else { completion(nil, error); return }
            var seen = Set<String>()
            let authors: [AuthorShort] = books.compactMap { book in
                guard let name = book.authorName?.trimmingCharacters(in: .whitespaces), !name.isEmpty, !seen.contains(name) else { return nil }
                seen.insert(name)
                return AuthorShort(name: name, link: OpdsService.searchURL(query: name, pageNumber: 0))
            }
            completion(authors, nil)
        }
    }

    func getBooksByAuthor(authorLink: URL, completion: @escaping ([Book]?, NSError?) -> Void) {
        fetchBooks(url: authorLink, completion: completion)
    }
}
