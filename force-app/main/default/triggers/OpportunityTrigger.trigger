/*Opportunity trigger should do the following:
* 1. Validate that the amount is greater than 5000.
* 2. Prevent the deletion of a closed won opportunity for a banking account.
* 3. Set the primary contact on the opportunity to the contact with the title of CEO.
*/



/*
    * Question 5
    * Opportunity Trigger
    * When an opportunity is updated validate that the amount is greater than 5000.
    * Error Message: 'Opportunity amount must be greater than 5000'
    * Trigger should only fire on update.
    */

trigger OpportunityTrigger on Opportunity (before insert, before update, before delete) {

if (trigger.isUpdate) {
    for (Opportunity oppy : Trigger.new) {
        if (oppy.Amount < 5000) {
            oppy.addError('Opportunity amount must be greater than 5000')   ;
        }
    }
}
/*
     * Question 6
	 * Opportunity Trigger
	 * When an opportunity is deleted prevent the deletion of a closed won opportunity if the account industry is 'Banking'.
	 * Error Message: 'Cannot delete closed opportunity for a banking account that is won'
	 * Trigger should only fire on delete.
	 */
    if (Trigger.isDelete) {

        // Define a Set to hold the Account Ids
        Set<Id> accountIds = new Set<Id>();
    
        // Define a Map to hold Account data (AccountId -> Account)
        Map<Id, Account> accountMap = new Map<Id, Account>();
    
        // Loop through the Opportunities being deleted to get Account Ids
        for (Opportunity oppyPop : Trigger.old) {
            // Only add Account Ids for 'Closed Won' Opportunities
            if (oppyPop.StageName == 'Closed Won') {
                accountIds.add(oppyPop.AccountId);
            }
        }
    
        // Query the Accounts where Id is in accountIds
        if (accountIds.size() > 0) {
            accountMap = new Map<Id, Account>(
                [SELECT Id, Industry FROM Account WHERE Id IN :accountIds]
            );
        }
    
        // Loop through the Opportunities again to enforce the deletion restriction
        for (Opportunity opp : Trigger.old) {
            if (opp.StageName == 'Closed Won' && accountMap.containsKey(opp.AccountId)) {
                Account acc = accountMap.get(opp.AccountId);
                
                // Check if the Account's Industry is 'Banking'
                if (acc.Industry == 'Banking') {
                    // Prevent deletion and display error message
                    opp.addError('Cannot delete closed opportunity for a banking account that is won');
                }
            }
        }
    }
        /*
    * Question 7
    * Opportunity Trigger
    * When an opportunity is updated set the primary contact on the opportunity 
    * to the contact on the same account with the title of 'CEO'.
    * Trigger should only fire on update.
    */

    if (Trigger.isUpdate) {

        // Collect Account Ids from Opportunities being updated
        Set<Id> accountIds = new Set<Id>();
    
        for (Opportunity opp : Trigger.new) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
    
        // Only query if we have account IDs
        if (!accountIds.isEmpty()) {
            // Query Contacts with Title 'CEO' for the relevant accounts
            Map<Id, Contact> accountToCEOMap = new Map<Id, Contact>();
            for (Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO']) {
                accountToCEOMap.put(con.AccountId, con);
            }
    
            // Loop through opportunities again and assign Primary Contact as CEO
            for (Opportunity opp : Trigger.new) {
                if (accountToCEOMap.containsKey(opp.AccountId)) {
                    opp.Primary_Contact__c = accountToCEOMap.get(opp.AccountId).Id;
                }
            }
        }
    }
}