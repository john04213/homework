//
//  ProductDetails.swift
//  SwiftUIDemo
//
//  Created by John Hernandez on 9/8/26.
//

import SwiftUI

struct ProductDetails: View {
    
    var product: Product
    var body: some View {
        List {
            LabeledContent("ID", value: "\(product.id)")
            LabeledContent("Name", value: product.name)
            LabeledContent("Product Number", value: product.productNumber)
            LabeledContent("Color", value: product.color)
            LabeledContent("List Price", value: product.listPrice, format: .currency(code:"USD"))
        }
        
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
