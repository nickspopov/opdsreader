//
//  MediaType+Extension.swift
//  opdsreader
//
//  Created by Николай Попов on 15.01.2023.
//

import Foundation
import ReadiumOPDS
import R2Shared

extension MediaType {
    public static let djvu = MediaType("application/djvu", name: "DJVU", fileExtension: "djvu")!
    public static let djvuZip = MediaType("application/djvu+zip", name: "DJVU ZIP", fileExtension: "djvu")!
}
