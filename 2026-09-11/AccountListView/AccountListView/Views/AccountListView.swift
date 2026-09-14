//
//  AccountListView.swift
//  AccountListView
//
//  Created by John Hernandez on 9/13/26.
//

import SwiftUI
struct AccountListView: View {
    let accounts: [Account]

    var body: some View {
        NavigationStack {
            List(accounts) { account in
                NavigationLink(value: account) {
                    AccountRow(account: account)
                }
            }
            .navigationTitle("Accounts")
            .navigationDestination(for: Account.self) { account in
                AccountDetailView(account: account)
            }
        }
    }
}
