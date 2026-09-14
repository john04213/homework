//
//  AccountDetailView.swift
//  AccountListView
//
//  Created by John Hernandez on 9/13/26.
//

import SwiftUI

struct AccountDetailView: View {
    let account: Account

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(account.name).font(.largeTitle.bold())
            Text(account.maskedNumber).font(.subheadline).foregroundStyle(.secondary)
            Text(account.balance, format: .currency(code: "USD"))
                .font(.title.monospacedDigit())
            Spacer()
        }
        .padding()
        .navigationTitle(account.name)
    }
}

#Preview {
    AccountListView(accounts: sampleAccounts)
}
