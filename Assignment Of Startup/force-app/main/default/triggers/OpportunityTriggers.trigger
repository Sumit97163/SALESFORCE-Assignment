trigger OpportunityTriggers on Opportunity (after insert, after update, after delete) {
    // Set to collect Account Ids
    Set<Id> accountIds = new Set<Id>();

    // Add Account Ids from Opportunities to the set
    if (Trigger.isInsert || Trigger.isUpdate) {
        for (Opportunity opp : Trigger.new) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
    }
    if (Trigger.isDelete) {
        for (Opportunity opp : Trigger.old) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
    }

    // Call the helper class method to update Account TotalAmount
    AccountHelper.updateAccountTotalAmount(accountIds);
}
