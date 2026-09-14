//
//  Account.swift
//  AccountListView
//
//  Created by John Hernandez on 9/13/26.
//
import SwiftUI

struct Account: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let maskedNumber: String
    let balance: Decimal
}
