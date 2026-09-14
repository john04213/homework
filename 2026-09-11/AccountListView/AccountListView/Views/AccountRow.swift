//
//  AccountRow.swift
//  AccountListView
//
//  Created by John Hernandez on 9/13/26.
//

import SwiftUI

struct AccountRow: View {
    let account: Account

    var body: some View {
        // TODO: Lay out account.name, account.maskedNumber, and
        // account.balance (currency-formatted) in an HStack/VStack
        // combination. Use Dynamic-Type-aware font styles only — no
        // .font(.system(size:)). Add accessibilityElement(children: .combine)
        // and a single, readable accessibilityLabel for the whole row.
        HStack{
            VStack(alignment: .leading){
                Text("\(account.name)")
                    .font(Font.headline)
                Text("\(account.maskedNumber)")
                    .font(Font.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(account.balance, format: .currency(code: "USD"))
                .font(Font.body)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(account.name), ending \(account.maskedNumber.suffix(4)), balance \(account.balance.formatted(.currency(code: "USD")))")
        
    }
}
