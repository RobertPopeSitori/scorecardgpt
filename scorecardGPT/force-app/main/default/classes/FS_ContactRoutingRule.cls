/**
 * @author Christopher Mudd from fusionSpan
 * @date 06/17/19
 *
 * @description handles updating a Contact if they terminate their association with an Account with
 * an Organizational Membership
 */

global without sharing class FS_ContactRoutingRule extends Framework.Domain {

    private static final String ACCOUNT_STRING = 'Account';
    private static final String ACTIVE_STRING = 'Active';

    public FS_ContactRoutingRule(List<Contact> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_ContactRoutingRule(sObjectList);
        }
    }

    global override void beforeUpdate(Map<Id, SObject> existingRecords) {
        Framework.Log.push(FS_ContactRoutingRule.class.getName(), 'beforeUpdate');
        List<Contact> contactsToProcess = (List<Contact>) records;
        Map<Id, Contact> oldContactsMap = (Map<Id, Contact>) existingRecords;
        Map<Id, Id> accountIdsByContactIds = new Map<Id, Id>();
        List<Contact> contactsToUpdate = new List<Contact>();

        Map<Id, Contact> contactsById = new Map<Id, Contact>();

        System.debug('updating contacts: ' + contactsToProcess);

        for (Contact contactToUpdate : contactsToProcess) {
            if (String.isBlank(contactToUpdate.AccountId) &&
                    !String.isBlank(oldContactsMap.get(contactToUpdate.Id).AccountId)) {

                contactToUpdate.FS_Receives_Org_Member_Benefits__c = false;
                contactsToUpdate.add(contactToUpdate);

            } else if (!String.isBlank(contactToUpdate.AccountId) &&
                    !String.isBlank(oldContactsMap.get(contactToUpdate.Id).AccountId) &&
                    contactToUpdate.AccountId != oldContactsMap.get(contactToUpdate.Id).AccountId) {

                accountIdsByContactIds.put(contactToUpdate.Id, contactToUpdate.AccountId);
                contactsById.put(contactToUpdate.Id, contactToUpdate);

            } else if (!String.isBlank(contactToUpdate.AccountId) &&
                    String.isBlank(oldContactsMap.get(contactToUpdate.Id).AccountId)) {

                accountIdsByContactIds.put(contactToUpdate.Id, contactToUpdate.AccountId);
                contactsById.put(contactToUpdate.Id, contactToUpdate);

            }
        }

        if (accountIdsByContactIds != null && !accountIdsByContactIds.isEmpty()) {
            List<Id> accountIds = new List<Id>(accountIdsByContactIds.values());
            Map<Id, OrderApi__Subscription__c> subsByAccountIds = FS_Utils.getSubsByAccountIds(accountIds);
            for (Id contactId : accountIdsByContactIds.keySet()) {
                OrderApi__Subscription__c subToProcess = subsByAccountIds.get(accountIdsByContactIds.get(contactId));
                Contact contactToUpdate = contactsById.get(contactId);
                if (subToProcess != null && subToProcess.OrderApi__Entity__c == ACCOUNT_STRING &&
                        subToProcess.OrderApi__Status__c == ACTIVE_STRING) {
                    contactToUpdate.FS_Receives_Org_Member_Benefits__c = true;
                    contactsToUpdate.add(contactToUpdate);
                } else {
                    contactToUpdate.FS_Receives_Org_Member_Benefits__c = false;
                    contactsToUpdate.add(contactToUpdate);
                }
            }
        }


//        Database.update(contactsToUpdate, false);
        Framework.Log.pop();
    }
}