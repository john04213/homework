//
//  AccountListViewApp.swift
//  AccountListView
//
//  Created by John Hernandez on 9/13/26.
//

import SwiftUI

@main
struct AccountListViewApp: App {
    var body: some Scene {
        WindowGroup {
            AccountListView(accounts: sampleAccounts)
        }
    }
}
