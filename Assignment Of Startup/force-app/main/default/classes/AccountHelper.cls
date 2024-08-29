public class AccountHelper {
    public static void updateAccountTotalAmount(Set<Id> accountIds) {
        if (accountIds.isEmpty()) {
            return;
        }

        // Query to aggregate Opportunity amounts by AccountId
        Map<Id, Decimal> accountToTotalAmount = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT AccountId, SUM(Amount) totalAmount
            FROM Opportunity
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            accountToTotalAmount.put((Id)ar.get('AccountId'), (Decimal)ar.get('totalAmount'));
        }

        // Prepare a list of Accounts to update
        List<Account> accountsToUpdate = new List<Account>();
        for (Id accountId : accountIds) {
            Account acc = new Account(Id = accountId);
            acc.TotalAmount__c = accountToTotalAmount.get(accountId) != null ? accountToTotalAmount.get(accountId) : 0;
            accountsToUpdate.add(acc);
        }

        // Update Accounts
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}
