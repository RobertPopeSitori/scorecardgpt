/**
  Created by Admin on 18-07-2019.
 */
global with sharing class FS_BadgeRoutingRule extends Framework.Domain {
    public FS_BadgeRoutingRule(List<OrderApi__Badge__c> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new FS_BadgeRoutingRule(sObjectList);
        }
    }
    public override void beforeInsert() {
        Framework.Log.push(FS_BadgeRoutingRule.class.getName(), 'Before Insert');
        FS_BadgeRoutingRule.badgeWSPRelate((List<OrderApi__Badge__c>) records);
        Framework.Log.pop();
    }
    public static void badgeWSPRelate(List<OrderApi__Badge__c> badgeRecords) {
        Set<Id> solIds = new Set<Id>();
        for (OrderApi__Badge__c badg : badgeRecords) {
            solIds.add(badg.OrderApi__Sales_Order_Line__c);
        }
        Map<Id, OrderApi__Sales_Order_Line__c> solMap = new Map<Id, OrderApi__Sales_Order_Line__c>(
        [select Id, (select Id,FS_End_Date__c from Workshop_Pass__r) from
                OrderApi__Sales_Order_Line__c where Id IN :solIds]);
        for(OrderApi__Badge__c badge : badgeRecords){
            if(solMap.get(badge.OrderApi__Sales_Order_Line__c) != null){
                OrderApi__Sales_Order_Line__c soLine = solMap.get(badge.OrderApi__Sales_Order_Line__c);
                for (FS_Workshop_Pass__c wSPass : soLine.Workshop_Pass__r) {
                    badge.OrderApi__Expired_Date__c = wSPass.FS_End_Date__c;
                    badge.FS_WorkshopPass__c = wSPass.Id;
                    badge.FS_Workshop_Pass_Expiration_Date__c = wSPass.FS_End_Date__c;
                }
            }
        }
    }
}