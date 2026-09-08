//
//  Products.swift
//  SwiftUIDemo
//
//  Created by John Hernandez on 9/8/26.
//

import SwiftUI

@Observable

class Product: Identifiable {
    
    var id: Int
    var name: String
    var productNumber: String
    var color: String
    var listPrice: Double
    
    init(id: Int, name: String, productNumber: String, color: String, listPrice: Double) {
        self.id = id
        self.name = name
        self.productNumber = productNumber
        self.color = color
        self.listPrice = listPrice
    }
}
