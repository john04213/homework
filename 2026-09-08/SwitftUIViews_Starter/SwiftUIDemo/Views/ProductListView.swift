//
//  ProductListView.swift
//  SwiftUIDemo
//
//  Created by John Hernandez on 9/8/26.
//

import SwiftUI

struct ProductListView: View {
    
    @State private var products: [Product] = []
    
    var body: some View {
        NavigationStack {
            List(products) { product in
                NavigationLink {
                    ProductDetails(product: product)
                } label: {
                    VStack(alignment: .leading, spacing: 4){
                        Text(product.name)
                            .font(.headline)
                        Text(product.color)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
            }
            .navigationTitle("Products")
            .task{
                products = await loadProducts()
            }
        }
        
    }
    
    func loadProducts() async -> [Product] {
       [
        Product(id: 1, name: "Mountain Lion Stuffed Animal", productNumber: "BK-M76B-42", color: "Red/Orange", listPrice: 45.99),
        Product(id: 2, name: "Brown Bear", productNumber: "BK-M463-45", color: "Brown", listPrice: 35.99),
        Product(id: 3, name: "Polar Bear", productNumber: "BK-M472-12", color: "White", listPrice: 25.99),
        Product(id: 4, name: "Rhino", productNumber: "BK-M438-95", color: "Gray", listPrice: 28.99),
        Product(id: 5, name: "Giraffe", productNumber: "BK-M878-89", color: "Orange", listPrice: 40.99),
        ]
    }
}

#Preview {
    ProductListView()
}

