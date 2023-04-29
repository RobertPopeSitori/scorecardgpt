trigger RelatedToAccount on Task (before insert,before update){
    
    Set<id> contactIds = new Set<id>();
    for (Task item : Trigger.new) {
        if(item.WhoId != null && String.valueOf(item.WhoId ).startsWith('003')) {
            contactIds.add(item.WhoId);
        } 
    }
    system.debug('ContactId:- '+contactIds);
    List<Contact> listcon = [SELECT id,AccountId 
                             FROM Contact
                             WHERE Id =:contactIds];
    system.debug('listcon:- '+listcon);
    for(task ts:trigger.new){
        for(Contact con:listcon){
            if(ts.Related_to_Account__c == null && ts.WhoId == con.id){
                system.debug('ts.Related_to_Account__c:- '+ts.Related_to_Account__c);
                ts.Related_to_Account__c = con.AccountId;
                system.debug('ts.Related_to_Account__c:- '+ts.Related_to_Account__c);
            }
        }
    }
}