/* Account trigger should do the following:
* 1. Set the account type to prospect.
* 2. Copy the shipping address to the billing address.
* 3. Set the account rating to hot.
* 4. Create a contact for each account inserted.  
Question 1
    * Account Trigger
    * When an account is inserted change the account type to 'Prospect' if there is no value in the type field.
    * Trigger should only fire on insert.
Question 2
    * Account Trigger
    * When an account is inserted copy the shipping address to the billing address.
    * BONUS: Check if the shipping fields are empty before copying.
    * Trigger should only fire on insert.
Question 3
    * Account Trigger
	* When an account is inserted set the rating to 'Hot' if the Phone, Website, and Fax ALL have a value.
    * Trigger should only fire on insert.
Question 4
    * Account Trigger
    * When an account is inserted create a contact related to the account with the following default values:
    * LastName = 'DefaultContact'
    * Email = 'default@email.com'
    * Trigger should only fire on insert. 123
*/


trigger AccountTrigger on Account (before insert, after insert) {

    if (Trigger.isInsert) {
        // Before Insert Logic
        if (Trigger.isBefore) {
            for (Account acct : Trigger.new) {
                // Set Account Type to 'Prospect' if not provided
                if (acct.Type == null) {
                    acct.Type = 'Prospect';
                }

                // Copy Shipping Address to Billing Address if Shipping fields are populated
                if (!String.isBlank(acct.ShippingStreet) ||
                    !String.isBlank(acct.ShippingCity) ||
                    !String.isBlank(acct.ShippingState) ||
                    !String.isBlank(acct.ShippingPostalCode) ||
                    !String.isBlank(acct.ShippingCountry)) {
                        acct.BillingStreet = acct.ShippingStreet;
                        acct.BillingCity = acct.ShippingCity;
                        acct.BillingState = acct.ShippingState;
                        acct.BillingPostalCode = acct.ShippingPostalCode;
                        acct.BillingCountry = acct.ShippingCountry;      
                }

                // Set Rating to 'Hot' if Phone, Website, and Fax all have values
                if (String.isNotBlank(acct.Phone) && 
                    String.isNotBlank(acct.Website) && 
                    String.isNotBlank(acct.Fax)) {
                        acct.Rating = 'Hot';
                }        
            }
        }

        // After Insert Logic
        if (Trigger.isAfter) {
            List<Contact> cont = new List<Contact>();

            for (Account acct2 : Trigger.new) {
                if (acct2.Id != null) {
                    // Create a default contact related to the account
                    Contact contact = new Contact();
                    contact.LastName = 'DefaultContact';
                    contact.Email = 'default@email.com';
                    contact.AccountId = acct2.Id;
                    cont.add(contact);
                }
            }

            if (!cont.isEmpty()) {
                insert cont;
            }
        }
    }
}
