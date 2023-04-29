/**
 * @author Christopher Mudd from fusionSpan
 * @date 06/17/19
 *
 * @description handles updating a Contact if they purchase a product w/ item class = Professional Membership or if
 * their associated Account purchases a product w/ item class = Organizational Membership
 *
 */

global without sharing class FS_SubscriptionRoutingRule extends Framework.Domain {

    private static final String CONTACT_STRING = 'Contact';
    private static final String ACCOUNT_STRING = 'Account';
    private static final String ACTIVE_STRING = 'Active';


    public FS_SubscriptionRoutingRule(List<OrderApi__Subscription__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_SubscriptionRoutingRule(sObjectList);
        }
    }

    global override void afterInsert() {
        Framework.Log.push(FS_SubscriptionRoutingRule.class.getName(), 'afterInsert');
        System.debug('===== sub rr beginning');
        List<OrderApi__Subscription__c> subsToProcess = (List<OrderApi__Subscription__c>) records;
        List<Contact> contactsToUpdate = updateContactsFromSubs(subsToProcess);
        Database.update(contactsToUpdate, true);
        updateAccountsFromSubs(subsToProcess);
        Framework.Log.pop();
    }

    global override void afterUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_SubscriptionRoutingRule.class.getName(), 'afterUpdate');
        System.debug('===== sub rr beginning');
        List<OrderApi__Subscription__c> subsToProcess = (List<OrderApi__Subscription__c>) records;
        List<Contact> contactsToUpdate = updateContactsFromSubs(subsToProcess);
        Database.update(contactsToUpdate, true);
        updateAccountsFromSubs(subsToProcess);
        Framework.Log.pop();
    }


    private void updateAccountsFromSubs(List<OrderApi__Subscription__c> subsToProcess) {

        Map<Id, Account> accountsToUpdate = FS_Utils.getAccountsByIdsFromSubs(subsToProcess);
        Map<Id, List<OrderApi__Subscription__c>> accountsToUpdateNew = new Map<Id, List<OrderApi__Subscription__c>>();
        List<OrderApi__Subscription__c> profMemSubs = FS_Utils.getProfMemSubs(subsToProcess);
        for (OrderApi__Subscription__c sub : profMemSubs) {
            List<OrderApi__Subscription__c> subscriptions =new List<OrderApi__Subscription__c>();
            subscriptions.add(sub);
            accountsToUpdateNew.put(sub.OrderApi__Account__c, subscriptions);
        }

        update accountsToUpdate.values();
    }


    // determine if updating is necessary based on subscription item/item class and update accordingly
    private List<Contact> updateContactsFromSubs(List<OrderApi__Subscription__c> subsToProcess) {
//        Map<Id, OrderApi__Item_Class__c> itemClassesByIds = FS_Utils.getItemClassNames(subsToProcess);

        System.debug('===== sub routing rule beginning');

        List<OrderApi__Subscription__c> profMemSubs = FS_Utils.getProfMemSubs(subsToProcess);
        List<OrderApi__Subscription__c> orgMemSubs = FS_Utils.getOrgMemSubs(subsToProcess);

        system.debug('count::::'+orgMemSubs.size());
        Map<Id, Contact> contactsToUpdate = FS_Utils.getContactsByIdsFromSubs(profMemSubs);

        Map<Id, List<Contact>> contactsByAccountId = FS_Utils.getContactsByIdsFromAccountSubs(orgMemSubs);
        updateContactsFromOrgMems(contactsToUpdate, orgMemSubs, contactsByAccountId);
        System.debug('qwe 5');

        updateContactsFromProfMems(contactsToUpdate, profMemSubs);

        System.debug('qwe 6');
        return contactsToUpdate.values();
    }


    // update professional member non-date fields
    // all date fields are assigned on the term routing rule, as terms are created after subscriptions and
    // thereby may not exist at the time of subscription routing rule's execution
    private void updateContactsFromProfMems(Map<Id, Contact> contactsToUpdate,
            List<OrderApi__Subscription__c> profMemSubs) {
//        List<Contact> updatedContacts = new List<Contact>();
        for (OrderApi__Subscription__c sub : profMemSubs) {
            Contact contactToUpdate = contactsToUpdate.get(sub.OrderApi__Contact__c);
            if (sub.OrderApi__Entity__c == CONTACT_STRING && sub.OrderApi__Status__c == ACTIVE_STRING) {
                contactToUpdate.FS_Professional_Membership__c = true;
            } else {
                contactToUpdate.FS_Professional_Membership__c = false;
            }
//            updatedContacts.add(contactToUpdate);
        }
//        return updatedContacts;
    }

    // update receives org member benefits field
    private void updateContactsFromOrgMems(Map<Id, Contact> contactsToUpdate,
            List<OrderApi__Subscription__c> orgMemSubs,
            Map<Id, List<Contact>> contactsByAccountId) {
//        List<Contact> updatedContacts = new List<Contact>();
        System.debug('qwe 1');
        for (OrderApi__Subscription__c sub : orgMemSubs) {
            System.debug('qwe 2');
            if (contactsByAccountId.get(sub.OrderApi__Account__c) != null) {
                system.debug('account inside if::::::');
                for (Contact contactToUpdate : contactsByAccountId.get(sub.OrderApi__Account__c)) {
                    System.debug('qwe 3');
                    if (contactsToUpdate.get(contactToUpdate.Id) != null) {
                        contactToUpdate = contactsToUpdate.get(contactToUpdate.Id);
                    }
                    if (sub.OrderApi__Entity__c == ACCOUNT_STRING && sub.OrderApi__Status__c == ACTIVE_STRING) {
                        contactToUpdate.FS_Receives_Org_Member_Benefits__c = true;
                    } else {
                        contactToUpdate.FS_Receives_Org_Member_Benefits__c = false;
                    }
                    contactsToUpdate.put(contactToUpdate.Id, contactToUpdate);
                }
            }
//            updatedContacts.add(contactToUpdate);
        }
        System.debug('qwe 4');
//        return updatedContacts;
    }

}