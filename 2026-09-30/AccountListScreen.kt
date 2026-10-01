package com.example.jetpackcomposedemos

//
// AccountListScreen_Starter.kt
// Module 12 — Android UI Development
// Lab Exercise: PNC Mobile — Accounts List Screen (Jetpack Compose)
//
// SCENARIO
// Build the accounts list screen for PNC Mobile Android — the final screen
// for Module 12. This exercise pulls together state (Block 1), navigation
// (Block 3), LazyColumn (Block 4), accessibility (Block 6), and animation
// (Block 7).
//
// REQUIREMENTS
// 1. Build AccountListScreen using LazyColumn and Material 3 components.
// 2. Each row shows account name, masked account number, and balance.
// 3. Tapping a row calls onAccountClick(accountId) — wiring this to actual
//    Navigation Compose is assumed to happen in a NavHost elsewhere (not
//    part of this file).
// 4. Every row must be fully readable by TalkBack as ONE combined element,
//    not three separate announcements.
// 5. Add an AnimatedVisibility confirmation banner that appears briefly
//    after a simulated refresh (a button that toggles a "Refreshed!"
//    message is sufficient to demonstrate this).
//
// The Account model below is complete. Implement the two TODOs.
//

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AccountBalance
import androidx.compose.material.icons.outlined.CreditCard
import androidx.compose.material.icons.outlined.Savings
import androidx.compose.ui.Alignment
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector

// MARK: - Model (complete — no changes needed)




data class Account(
    val id: String,
    val name: String,
    val maskedNumber: String,
    val balance: Double
)

val sampleAccounts = listOf(
    Account("a1", "Everyday Checking", "\u2022\u2022\u2022\u2022 4471", 4281.16),
    Account("a2", "High Yield Savings", "\u2022\u2022\u2022\u2022 9902", 18340.50),
    Account("a3", "Rewards Credit Card", "\u2022\u2022\u2022\u2022 2216", -612.44)
)


// Card for each type of account
enum class AccountType {
    CHECKING,
    SAVINGS,
    CREDIT
}

data class AccountStyle(
    val label: String,
    val icon: ImageVector,
    val containerColor: Color,
    val contentColor: Color
)

val Account.type: AccountType
    get() = when {
        name.contains("Credit", ignoreCase = true) -> AccountType.CREDIT
        name.contains("Savings", ignoreCase = true) -> AccountType.SAVINGS
        else -> AccountType.CHECKING
    }


@Composable
fun AccountType.style(): AccountStyle = when (this) {
    AccountType.CHECKING -> AccountStyle(
        label = "Checking",
        icon = Icons.Outlined.AccountBalance,
        containerColor = MaterialTheme.colorScheme.primaryContainer,
        contentColor = MaterialTheme.colorScheme.onPrimaryContainer
    )
    AccountType.SAVINGS -> AccountStyle(
        label = "Savings",
        icon = Icons.Outlined.Savings,
        containerColor = MaterialTheme.colorScheme.secondaryContainer,
        contentColor = MaterialTheme.colorScheme.onSecondaryContainer
    )
    AccountType.CREDIT -> AccountStyle(
        label = "Credit",
        icon = Icons.Outlined.CreditCard,
        containerColor = MaterialTheme.colorScheme.tertiaryContainer,
        contentColor = MaterialTheme.colorScheme.onTertiaryContainer
    )
}


// MARK: - TODO 1: AccountListScreen

@Composable
fun AccountListScreen(
    accounts: List<Account>,
    onAccountClick: (String) -> Unit
) {
    // TODO: Show a "Refresh" button. When tapped, set a boolean state to
    // true, then use AnimatedVisibility to show a "Refreshed!" confirmation
    // banner (fadeIn/fadeOut) above the list.
    //
    // Below the banner, use a LazyColumn with items(accounts, key = { it.id })
    // to render an AccountRow for each account.
    var isRefreshing by remember {
        mutableStateOf(false)
    }
    Column (
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ){
        Button(
            onClick = { isRefreshing = true }
        ) {
            Text("Refresh")
        }
        AnimatedVisibility(
            visible = isRefreshing,
            enter = fadeIn(),
            exit = fadeOut()
        ) {
            Text(
                text = "Refreshed!",
                style = MaterialTheme.typography.bodyMedium,
                modifier = Modifier.padding(16.dp)
            )
        }
        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ){
            items (
                items = accounts,
                key = {account -> account.id}
            )  { account ->
                AccountRow(
                    account = account,
                    onClick = { onAccountClick(account.id) }
                )
            }
        }
    }
}


// MARK: - TODO 2: AccountRow

@Composable
fun AccountRow(
    account: Account,
    onClick: () -> Unit
) {
    // TODO: Lay out account.name, account.maskedNumber, and account.balance
    // in a Row/Column combination. Use MaterialTheme.typography styles only
    // — no hard-coded font sizes. Add
    // Modifier.semantics(mergeDescendants = true) {} and a single,
    // readable contentDescription for the whole row.
    val style = account.type.style()
    Card(
        onClick = onClick,
        modifier = Modifier
            .fillMaxWidth()
            .semantics(mergeDescendants = true) {
                contentDescription =
                    "${style.label} account, " +
                            "${account.name}, " +
                            "ending ${account.maskedNumber.takeLast(4)}," +
                            " balance: $${"%.2f".format(account.balance)}"
            },
        colors = CardDefaults.cardColors(
            containerColor = style.containerColor,
            contentColor = style.contentColor
        ),
        shape = MaterialTheme.shapes.medium
    ) {
        Row(
            modifier = Modifier
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            Icon(
                imageVector = style.icon,
                contentDescription = null
            )
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = account.name,
                    style = MaterialTheme.typography.titleSmall
                )
                Text(
                    text = "${style.label} ${account.maskedNumber}",
                    style = MaterialTheme.typography.bodyMedium
                )
            }
            Text(
                text = "$${"%.2f".format(account.balance)}",
                style = MaterialTheme.typography.titleMedium
            )
        }
    }
}


