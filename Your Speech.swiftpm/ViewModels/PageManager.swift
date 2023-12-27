//
//  File.swift
//  
//
//  Created by a mystic on 11/29/23.
//

import Foundation

class PageManager: ObservableObject {
    @Published var currentPage: Int? = 0
    
    func addPage() {
        if let currentPage = currentPage, currentPage < 5 {
            self.currentPage = currentPage + 1
        }
    }
    
    func minusPage() {
        if let currentPage = currentPage, currentPage > 0 {
            self.currentPage = currentPage - 1
        }
    }
}
