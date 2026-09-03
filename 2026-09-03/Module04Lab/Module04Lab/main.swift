
//  Created by John Hernandez on 9/3/26.

import Foundation

enum TransactionType: String, CaseIterable, Codable {
    case credit
    case debit
    case transfer
    case fee
    
    var isExpense: Bool {
        switch self {
        case .debit, .fee: return true
        default: return false
        }
    }
}

enum TransactionStatus:String, Codable {
    case pending
    case completed
    case failed
    case cancelled
    
    var isTerminal: Bool{
        switch self {
        case .completed, .failed, .cancelled: return true
        case .pending: return false
        }
    }
}
struct Transaction: Identifiable, Codable, Equatable, Hashable, Summarizable {
    let id: String = UUID().uuidString
    let date: Date
    let amount: Double
    var description: String
    let type: TransactionType
    var status: TransactionStatus = .completed
    var category: String? = nil
    var merchantName: String? = nil
    
    var formattedAmount: String {
        return "\(type.isExpense ? "-" : "+")$\(String(format: "%.2f", abs(amount)))"
    }
    
    var formattedDate:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    var resolvedCategory: String {
        return category ?? "Uncategorized"
    }
    
    init(date: Date, amount: Double, description: String, type: TransactionType, status: TransactionStatus = .completed, category: String? = nil, merchantName: String? = nil) {
        self.date = date
        self.amount = amount
        self.description = description
        self.type = type
        self.status = status
        self.category = category
        self.merchantName = merchantName
    }
    
    var summary: String {
        return "\(formattedDate) - \(formattedAmount) - \(resolvedCategory)"
    }
}

class BankAccount: Identifiable, AccountOperations, Summarizable {
    var id: String
    var accountNumber: String
    var accountType: String
    var nickname: String?
    var balance: Double
    var availableBalance: Double
    let currency: String
    let isActive: Bool
    var transactions: [Transaction]
    
    var displayName: String {
        return nickname ?? accountType.capitalized
    }
    
    var maskedAccountNumber: String {
        return "****\(accountNumber.suffix(4))"
    }
    var formattedBalance: String {
        return String(format: "$%.2f", balance)
    }
    
    var recentTransactions: [Transaction] {
        return Array(transactions.sorted(by: { $0.date > $1.date }).prefix(5))
    }
    
    var pendingCount: Int {
        transactions.filter{ $0.status == .pending}.count
    }
    
    init(id: String, accountNumber: String, accountType: String, nickname: String? = nil, initialBalance: Double, currency: String = "USD", isActive: Bool = true) {
        self.id = id
        self.accountNumber = accountNumber
        self.accountType = accountType
        self.nickname = nickname
        self.balance = initialBalance
        self.availableBalance = initialBalance
        self.currency = currency
        self.isActive = isActive
        self.transactions = []
    }
    
    
    func addTransaction(_ transaction: Transaction){
        transactions.append(transaction)
        if transaction.type.isExpense{
            balance -= transaction.amount
            
        } else {
            balance += transaction.amount
        }
        availableBalance = balance
    }
    
    func deposit(amount: Double) throws {
        guard amount > 0 else {
            throw AccountOperationsError.invalidAmount
        }
        guard isActive else {
            throw AccountOperationsError.accountInactive
        }
        balance += amount
        availableBalance += amount
    }
    func withdraw (amount: Double) throws {
        guard amount > 0 else {
            throw AccountOperationsError.invalidAmount
        }
        guard isActive else {
            throw AccountOperationsError.accountInactive
        }
        guard availableBalance >= amount else{ throw AccountOperationsError.insufficientFunds(available: availableBalance, required: amount)}
        balance -= amount
        availableBalance -= amount
    }
    
    func transfer(amount: Double, to destination: BankAccount) throws {
        guard destination !== self else {
            throw AccountOperationsError.transferToSameAccount
        }
        try withdraw(amount: amount)
        try destination.deposit(amount: amount)
    }
    
    var summary: String {
        "\(accountType.capitalized) \(maskedAccountNumber) (\(currency)): \(formattedBalance)"
    }
}


protocol Summarizable {
    var summary: String { get }
}

extension Summarizable {
    func printSummary() {
        print(summary)
    }
}

 protocol AccountOperations {
    func deposit(amount: Double) throws
    func withdraw(amount: Double) throws
    func transfer(amount: Double, to destination: BankAccount) throws
}

enum AccountOperationsError: Error, LocalizedError {
    case invalidAmount
    case insufficientFunds(available: Double, required: Double)
    case accountInactive
    case transferToSameAccount
    case dailyLimitExceeded(limit: Double)
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Invalid amount. Please reenter amount"
        case .insufficientFunds(available: let available, required: let required):
            return "Insufficient funds. Available: \(available), required: \(required)"
        case .accountInactive:
            return "Account is inactive. Please contact bank"
        case .transferToSameAccount:
            return "Cannot transfer to same account"
        case .dailyLimitExceeded(limit: let limit):
            return "Daily limit exceeded. Limit: \(limit)"
        }
    }
}

protocol AnalyticsProvider {
    var totalCredits: Double { get }
    var totalDebits: Double { get }
    var netFlow: Double { get }
    var largestTransaction: Transaction? { get }
    func monthlyTotal(month: Int, year: Int) -> Double
    func transactionsByCategory() -> [String: [Transaction]]
}

struct AccountAnalytics: AnalyticsProvider {
    let transactions: [Transaction]
    var totalCredits: Double {
        return transactions.filter { !$0.type.isExpense }.reduce(0) { $0 + $1.amount }
    }
    var totalDebits: Double {
        return transactions.filter {$0.type.isExpense}.reduce(0) { $0 + $1.amount }
    }
    var netFlow: Double {
        return totalCredits - totalDebits
    }
    var largestTransaction: Transaction? {
        return transactions.max(by: { $0.amount < $1.amount })
    }
    func monthlyTotal(month: Int, year: Int) -> Double {
        return transactions.filter {$0.type.isExpense}.filter {
            let comps = Calendar.current.dateComponents([.month, .year], from: $0.date)
            return comps.month == month && comps.year == year
        }.reduce (0) { $0 + $1.amount }
    }
    func transactionsByCategory() -> [String: [Transaction]] {
        return Dictionary(grouping: transactions, by: \.resolvedCategory)
    }
    
}


func reportResults<T: Summarizable>(_ items: [T], title: String) {
    print("===\(title)===")
    print("\(items.count) items")
    for item in items {
        item.printSummary()
    }
    print("===\(title)===")
}



func runlabDemo() {
    let checking = BankAccount(id:"chk-1", accountNumber: "12345676543", accountType: "CHECKING", initialBalance: 3500)
    let savings = BankAccount(id:"sav-1", accountNumber: "333444555666", accountType: "SAVINGS", initialBalance: 12000)
    
    checking.addTransaction(Transaction(date: Date(),amount: 1000, description: "Gas", type: .debit))
    print(checking.formattedBalance)
    
    checking.addTransaction(Transaction(date: Date(),amount: 100, description: "Groceries", type: .debit))
    print(checking.formattedBalance)
    
    checking.addTransaction(Transaction(date: Date(),amount: 1000, description: "Salary", type: .credit))
    print(checking.formattedBalance)
    
    checking.addTransaction(Transaction(date: Date(),amount: 1000, description: "Move to savings", type: .transfer))
    print(checking.formattedBalance)
    
    checking.addTransaction(Transaction(date: Date(),amount: 600, description: "rent", type: .fee))
    print(checking.formattedBalance)
    
    
    do {
        try checking.withdraw(amount: 10000)
    } catch {
        print(error.localizedDescription)
    }
    
    do {
        try checking.deposit(amount: -1000)
    } catch {
        print(error.localizedDescription)
    }
    
    do {
        try checking.transfer(amount: 1000, to: checking)
    } catch {
        print(error.localizedDescription)
    }

    
    let analytics = AccountAnalytics(transactions: checking.transactions)
    print("Total credits: \(analytics.totalCredits)")
    print("Total debits: \(analytics.totalDebits)")
    print("Total netflow: \(analytics.netFlow)")
    if let largestTransaction = analytics.largestTransaction {
        print("\(largestTransaction.description): \(largestTransaction.amount)")
    }
    for(category, list) in analytics.transactionsByCategory() {
        print("\(category): \(list.count)")
    }
           
           reportResults(checking.transactions, title: "Checking transactions")
           reportResults([checking, savings], title: "All accounts")
           
           let original = checking.transactions[0]
           var copy = original
           copy.description = "Updated"
           print(original.description, copy.description)
           
           let alias = checking
          try? alias.deposit(amount: 1000)
          print(checking.formattedBalance)
          print(alias.formattedBalance)
}

runlabDemo()

