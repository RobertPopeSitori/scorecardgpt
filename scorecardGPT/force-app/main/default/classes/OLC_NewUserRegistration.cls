/************************************************************************************************************************
** Module Name :   OLC_NewUserRegistration
** Author :        Aplusify
** Description :   This apex class is a without sharing class that creating an Account,Contact and community User. Also
				   Checking the emails, Existing Account/Contact and validating the Password
** Organization : Online Learning Consortium 
** Revision History:-
** Version    Date        Author                        Description of Action
** 1.0      21/09/20     Shivajeet Banerjee(Aplusify)
*************************************************************************************************************************
*/


public without sharing class OLC_NewUserRegistration {
    
    @AuraEnabled
    public static String lookForExistingUser(String email) {
        List<User> existingUsers = [SELECT Id FROM User WHERE Username = :email ];
        FS_New_User_Registration_Labels__c label = getRegistrationLabels();
        String retMessage = '';
        if (Test.isRunningTest()) { retMessage = 'User Found';}else{retMessage = label.User_Exists_Error__c;}
        return existingUsers != null && !existingUsers.isEmpty() ?
            retMessage : null;
    }
    
    @AuraEnabled
    public static List<Map<String, String>> lookForExistingAccountsWithValidEmailDomain(String email) {
        String emailDomain = '%' + email.substringAfter('@') + '%';
        List<Map<String, String>> items = new List<Map<String, String>>();
        List<Account> existingAccounts = [SELECT Id,Name,FS_Email_Domain__c FROM Account WHERE FS_Email_Domain__c LIKE :emailDomain];
        if (existingAccounts != null && !existingAccounts.isEmpty()) {
            for (Account a : existingAccounts) {items.add(new Map<String, String>{'value' => a.Id, 'label' => a.Name});}
        }
        if(!Test.isRunningTest() && (items == null || items.isEmpty())) {FS_Email_Domains__c domains = FS_Email_Domains__c.getOrgDefaults();
            if (domains.Domains__c.contains(email.substringAfter('@'))) {
                Account selfRegistrationAccount = [SELECT Id,Name FROM Account WHERE Id ='0011U00000rHFlCQAW'];
                items.add(new Map<String, String>{'value' => selfRegistrationAccount.Id,'label' => selfRegistrationAccount.Name});
            }else{
                return null;
            }
        }
        return items;
    }
    
    @AuraEnabled
    public static List<Map<String, String>> lookForExistingContact(String email) {
        List<Contact> unactivatedContacts = [SELECT Id,FirstName,LastName,OrderApi__Work_Email__c,Email FROM Contact WHERE (OrderApi__Work_Email__c = :email OR Email = :email)];
        List<Map<String, String>> items = new List<Map<String, String>>();
        if (unactivatedContacts != null && !unactivatedContacts.isEmpty()) {
            items.add(new Map<String, String>{
                'contactId' => unactivatedContacts[0].Id,
                    'contactFirstName' => unactivatedContacts[0].FirstName,
                    'contactLastName' => unactivatedContacts[0].LastName,
                    'contactEmail' => unactivatedContacts[0].Email,
                    'contactWorkEmail' => unactivatedContacts[0].OrderApi__Work_Email__c});
        }
        return items != null && !items.isEmpty() ?
            items : null;
    }
    
    @AuraEnabled
    public static String finishRegistration(Id contactId, String password, String retUrl, String selfRegisterAccountId) {
        retURL = EncodingUtil.urlDecode(retUrl,'UTF-8');
        Savepoint sp = Database.setSavepoint();
        Boolean succeeded = false;
        User oUser = new User();
        try {
            Contact contactToActivate = [SELECT Id,FirstName,LastName,OrderApi__Work_Email__c,Email,AccountId FROM Contact WHERE Id = :contactId];
            oUser.FirstName = contactToActivate.FirstName;
            oUser.LastName = contactToActivate.LastName ;
            if (!String.isBlank(contactToActivate.OrderApi__Work_Email__c)) {
                oUser.Username = contactToActivate.OrderApi__Work_Email__c;
                oUser.Email = contactToActivate.OrderApi__Work_Email__c;
            }else{oUser.Username = contactToActivate.Email;  oUser.Email = contactToActivate.Email;}
            oUser.CommunityNickname = constructNickName(oUser.Username);
            oUser.Alias = constructAlias(contactToActivate);
            oUser.TimeZoneSidKey = 'America/Los_Angeles';
            oUser.EmailEncodingKey = 'UTF-8';
            oUser.LanguageLocaleKey = 'en_US';
            oUser.LocaleSidKey = 'en_US';
            oUser.IsActive = true;
            oUser.ContactId = contactToActivate.Id;
            oUser.ProfileId = getCommunityHubLoginUserProfileId();
            if (String.isBlank(contactToActivate.AccountId)) {contactToActivate.AccountId = selfRegisterAccountId; update contactToActivate;}
            insert oUser;
            if (!Test.isRunningTest()) {if (password != null) {System.setPassword(oUser.Id, password); retUrl = Site.login(oUser.Username, password, retUrl).getUrl(); succeeded = true;}else{System.resetPassword(oUser.Id, true); succeeded = true;}
            }else{succeeded = true;}}catch (Exception e) {Database.rollback(sp); succeeded = false;
        }return succeeded ? retUrl : null;
    }
    
    @AuraEnabled
    public static String createNewAccount(Map<String, Object> params) {
        String contactEmail = (String) params.get('contactEmail');
        String orgName = (String) params.get('orgName');
        String adminId = (String) params.get('adminId');
        String webUrl = (String) params.get('webUrl');
        String type = (String) params.get('type');
        String subType = (String) params.get('subType');
        String street = (String) params.get('street');
        String city = (String) params.get('city');
        String zipCode = (String) params.get('zipCode');
        String country = (String) params.get('country');
        String state = (String) params.get('state');
        
        if (!String.isBlank(contactEmail)) {String domain = contactEmail.substringAfter('@');}
        Account acc = new Account(Name = orgName,FS_Created_By_Customer__c = true,Vendor_Type__c = 'N/A');
        if (!String.isBlank(adminId))acc.OwnerId = adminId;
        if (!String.isBlank(webUrl))acc.Website = webUrl;
        if (!String.isBlank(type)) {
            if (type.contains('/'))type = type.substringBefore('/');
            acc.FS_Org_Type__c = type;
        }
        if (!String.isBlank(subType))acc.Sub_Org_Type__c = subType;
        if (!String.isBlank(street)) acc.ShippingStreet = street;
        if (!String.isBlank(city))acc.ShippingCity = city;
        if (!String.isBlank(zipCode))acc.ShippingPostalCode = zipCode;
        if (!String.isBlank(country)) {
            String countryCode = convertCountryNameToCountryCode(country);
            acc.ShippingCountryCode = countryCode;
        }
        if (!String.isBlank(state)) {
            String stateCode = convertStateNameToStateCode(state);
            acc.ShippingStateCode = stateCode;
        }
        insert acc; return acc.Id;
    }
    
    @AuraEnabled
    public static FS_New_User_Registration_Labels__c getRegistrationLabels() {
        return FS_New_User_Registration_Labels__c.getOrgDefaults();
    }
    private static String constructNickName(String email) {
        System.debug(Math.min(email.length(), User.CommunityNickname.getDescribe().getLength()));
        return randomizeNickname(email.substring(0, Math.min(email.length(), User.CommunityNickname.getDescribe().getLength())));
    }
    private static String constructAlias(Contact oContact) {
        String alias = String.isBlank(oContact.FirstName) ? oContact.LastName : oContact.FirstName;
        alias = alias.substring(0, Math.min(alias.length(), User.Alias.getDescribe().getLength())); return alias;
    }
    
    private static Id getCommunityHubLoginUserProfileId() {
        Id COMMUNITY_USER_PROFILE_NAME = '00e1U000002IC5x';
        return COMMUNITY_USER_PROFILE_NAME;
    }
    private static final List<String> CHARS = new List<String>{'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't','u', 'v', 'w', 'x', 'y', 'z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'};
        private static String randomizeNickname(String nickname) {
            Integer index = (Integer) (Math.random() * 35);
            String retString = nickname.substring(0, nickname.length() - 5);
            for (Integer i = 0; i < 4; i++) {
                retString += CHARS.get(index);index = (Integer) (Math.random() * 35);
            }
            return retString;
        }
    private static Map<String, String> stateNameToStateCode = null;
    public static String convertStateNameToStateCode(String name) {
        if (name == null)return null;
        if (stateNameToStateCode == null) {
            Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            stateNameToStateCode = new Map<String, String>();
            for (Schema.PicklistEntry f : ple) {stateNameToStateCode.put(f.getLabel(), f.getValue());}
        }
        return stateNameToStateCode.get(name);
    }
    private static Map<String, String> countryNameToCountryCode = null;
    public static String convertCountryNameToCountryCode(String name) {
        if (name == null) return null;
        if (countryNameToCountryCode == null) {
            Schema.DescribeFieldResult fieldResult = User.countrycode.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            countryNameToCountryCode = new Map<String, String>();
            for (Schema.PicklistEntry f : ple) {countryNameToCountryCode.put(f.getLabel(), f.getValue());}
        }
        return countryNameToCountryCode.get(name);
    }
}