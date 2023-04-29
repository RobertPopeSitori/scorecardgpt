/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_PagesApi_Field_ResponseTrigger on PagesApi__Field_Response__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(PagesApi__Field_Response__c.SObjectType);
}