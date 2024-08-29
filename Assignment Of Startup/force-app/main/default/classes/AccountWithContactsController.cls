public with sharing class AccountWithContactsController {
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountsWithContacts(Integer recordOffset, Integer recordLimit) {
        return [
            SELECT Id, Name, 
                   (SELECT Id, FirstName, LastName FROM Contacts)
            FROM Account
            ORDER BY Name
            LIMIT :recordLimit
            OFFSET :recordOffset
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Integer getAccountsCount() {
        return [SELECT COUNT() FROM Account];
    }
}
