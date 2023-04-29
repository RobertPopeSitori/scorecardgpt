/*
 * -----------------------------------------------------------------------------
 * COPYRIGHT (C) 2018, FONTEVA, INC.
 * ALL RIGHTS RESERVED.
 *
 * ALL INFORMATION CONTAINED HEREIN IS, AND REMAINS THE PROPERTY OF FONTEVA
 * INCORPORATED AND ITS SUPPLIERS, IF ANY. THE INTELLECTUAL AND TECHNICAL
 * CONCEPTS CONTAINED HEREIN ARE PROPRIETARY TO FONTEVA INCORPORATED AND
 * ITS SUPPLIERS AND MAY BE COVERED BY U.S. AND FOREIGN PATENTS, PATENTS IN
 * PROCESS, AND ARE PROTECTED BY TRADE SECRET OR COPYRIGHT LAW. DISSEMINATION
 * OF THIS INFORMATION OR REPRODUCTION OF THIS MATERIAL IS STRICTLY FORBIDDEN
 * UNLESS PRIOR WRITTEN PERMISSION IS OBTAINED FROM FONTEVA, INC.
 * -----------------------------------------------------------------------------
 */

public class DeleteTestDataCtrl{

    public DeleteTestDataCtrl() { }
    
    @AuraEnabled
    public static boolean prodToggle() {
        string CompanyOrgId = UserInfo.getOrganizationId();
        if(CompanyOrgId == '00D6A0000039vRfUAI'){
            return true;
        } else {
            return false;
        }
    }
        
    @AuraEnabled
    public static void apex_cleanData() {
        try {
            Id CompanyOrgId = UserInfo.getOrganizationId();
            if(CompanyOrgId != '00D6A0000039vRfUAI'){
                Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Price_Rule__c',true);
                Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Assignment_Role__c',true);
                System.debug('inside cleandata');
                CleanTestData.cleanEventData();
                CleanTestData.cleanCommunityData();
                CleanTestData.cleanFormsData();
                CleanTestData.cleanDirectoryData();
                CleanTestData.cleanProgramsData();
                CleanTestData.cleanFundraisingData();
                CleanTestData.cleanFinanceData();
                CleanTestData.cleanSubscriptionData();
                CleanTestData.cleanItemData();
                CleanTestData.cleanSetupData();
                Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Price_Rule__c',false);
                Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Assignment_Role__c',false);
            }
        }
        catch (DMLException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+'\n'+e.getStackTraceString());
        }
    }

}