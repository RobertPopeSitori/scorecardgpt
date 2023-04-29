/**
* Created by cmudd on 2019-05-29.
* @author Christopher Mudd
* @date 5/29/19
*
* @description queries the database for pre-existing accounts related to the user-supplied email. If found,
* attempts to activate those users before creating a new user
*/

public without sharing class FS_NewUserRegistrationController {
    
    private static final String COMMUNITY_USER_PROFILE_NAME = 'Fonteva Customer Community Login User';
    private static final String SELF_REGISTRATION_ACCOUNT_NAME = 'Community Portal Self Registration Account';
    //    private static final String USER_ROLE_NAME = 'FON - Partner Account Partner User';
    
    
    @AuraEnabled
    public static String lookForExistingUser(String email) {
        List<User> existingUsers = [
            SELECT Id
            FROM User
            //                WHERE Username = :email
            WHERE Username = :email
        ];
        
        FS_New_User_Registration_Labels__c label = getRegistrationLabels();
        System.debug('users for method====' + existingUsers);
        System.debug(existingUsers != null && !existingUsers.isEmpty());
        System.debug(label);
        
        String retMessage = '';
        if (Test.isRunningTest()) {
            retMessage = 'User Found';
        } else {
            retMessage = label.User_Exists_Error__c;
        }
        return existingUsers != null && !existingUsers.isEmpty() ?
            retMessage : null;
    }
    
    @AuraEnabled
    public static List<Map<String, String>> lookForExistingAccountsWithValidEmailDomain(String email) {
        
        System.debug('looking for accounts with email domain');
        String emailDomain = '%' + email.substringAfter('@') + '%';
        
        List<Map<String, String>> items = new List<Map<String, String>>();
        
        List<Account> existingAccounts = [
            SELECT Id,Name,FS_Email_Domain__c
            FROM Account
            WHERE FS_Email_Domain__c LIKE :emailDomain
        ];
        
        //        List<Account> existingAccounts = [
        //                SELECT Id,Name
        //                FROM Account
        //                WHERE Name LIKE :emailDomain
        //        ];
        
        if (existingAccounts != null && !existingAccounts.isEmpty()) {
            for (Account a : existingAccounts) {
                System.debug(a);
                items.add(new Map<String, String>{
                    'value' => a.Id, 'label' => a.Name
                        });
            }
        }
        
        System.debug(items);
        
        if (!Test.isRunningTest() && (items == null || items.isEmpty())) {
            System.debug('checking domain against custom setting: ' + emailDomain);
            FS_Email_Domains__c domains = FS_Email_Domains__c.getOrgDefaults();
            if (domains.Domains__c.contains(email.substringAfter('@'))) {
                Account selfRegistrationAccount = [
                    SELECT Id,Name
                    FROM Account
                    WHERE Name = :SELF_REGISTRATION_ACCOUNT_NAME
                ];
                items.add(new Map<String, String>{
                    'value' => selfRegistrationAccount.Id,
                        'label' => selfRegistrationAccount.Name
                        });
            } else {
                System.debug('Should return null');
                return null;
            }
        }
        return items;
    }
    
    @AuraEnabled
    public static List<Map<String, String>> lookForExistingContact(String email) {
        List<Contact> unactivatedContacts = [
            SELECT Id,
            FirstName,
            LastName,
            OrderApi__Work_Email__c,
            Email
            FROM Contact
            WHERE (OrderApi__Work_Email__c = :email OR Email = :email)
        ];
        
        List<Map<String, String>> items = new List<Map<String, String>>();
        
        if (unactivatedContacts != null && !unactivatedContacts.isEmpty()) {
            
            items.add(new Map<String, String>{
                'contactId' => unactivatedContacts[0].Id,
                    'contactFirstName' => unactivatedContacts[0].FirstName,
                    'contactLastName' => unactivatedContacts[0].LastName,
                    'contactEmail' => unactivatedContacts[0].Email,
                    'contactWorkEmail' => unactivatedContacts[0].OrderApi__Work_Email__c
                    });
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
        
        //        if (ApexPages.currentPage().getParameters().get('startURL') != null) {
        //            retUrl = ApexPages.currentPage().getParameters().get('startURL');
        //        }
        
        System.debug('retUrl: ' + retUrl);
        
        System.debug(contactId);
        System.debug(password);
        
        try {
            Contact contactToActivate = [
                SELECT Id,
                FirstName,
                LastName,
                OrderApi__Work_Email__c,
                Email,
                AccountId
                FROM Contact
                WHERE Id = :contactId
            ];
            
            oUser.FirstName = contactToActivate.FirstName;
            oUser.LastName = contactToActivate.LastName ;
            if (!String.isBlank(contactToActivate.OrderApi__Work_Email__c)) {
                oUser.Username = contactToActivate.OrderApi__Work_Email__c;
                oUser.Email = contactToActivate.OrderApi__Work_Email__c;
            } else {
                oUser.Username = contactToActivate.Email;
                oUser.Email = contactToActivate.Email;
            }
            oUser.CommunityNickname = constructNickName(oUser.Username);
            //            System.debug(oUser.CommunityNickname);
            oUser.Alias = constructAlias(contactToActivate);
            oUser.TimeZoneSidKey = 'America/Los_Angeles';
            oUser.EmailEncodingKey = 'UTF-8';
            oUser.LanguageLocaleKey = 'en_US';
            oUser.LocaleSidKey = 'en_US';
            oUser.IsActive = true;
            oUser.ContactId = contactToActivate.Id;
            oUser.ProfileId = getCommunityHubLoginUserProfileId();
            //            oUser.UserRoleId = getUserRoleId();
            
            if (String.isBlank(contactToActivate.AccountId)) {
                contactToActivate.AccountId = selfRegisterAccountId;
                update contactToActivate;
            }
            system.debug('<<123user'+oUser);
            insert oUser;
            system.debug('<<user'+oUser);
            if (!Test.isRunningTest()) {
                if (password != null) {
                    System.debug('setting password: ' + password);
                    System.setPassword(oUser.Id, password);
                    //                Site.createPortalUser(oUser, contactToActivate.AccountId, password, true);
                    //                oUser = refreshUser(oUser);
                    //                PageReference p = Site.login(oUser.Username, password, '/apex/FS_CustomProfilePage');
                    retUrl = Site.login(oUser.Username, password, retUrl).getUrl();
                    //                Aura.redirect(p);
                    succeeded = true;
                } else {
                    
                    System.debug('resetting password');
                    System.resetPassword(oUser.Id, true);
                    succeeded = true;
                }
            } else {
                succeeded = true;
            }
            //            System.resetPassword(oUser.Id, true);
            
        } catch (Exception e) {
            System.debug('===== Error occurred ===== ' + '\n' + e);
            Database.rollback(sp);
            succeeded = false;
        }
        return succeeded ? retUrl : null;
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
        
        if (!String.isBlank(contactEmail)) {
            String domain = contactEmail.substringAfter('@');
        }
        Account acc = new Account(
            Name = orgName,
            //                FS_Email_Domain__c = domain,
            FS_Created_By_Customer__c = true,
            Vendor_Type__c = 'N/A'
            //                OwnerId = adminId
        );
        if (!String.isBlank(adminId)) {
            acc.OwnerId = adminId;
        }
        if (!String.isBlank(webUrl)) {
            acc.Website = webUrl;
        }
        if (!String.isBlank(type)) {
            if (type.contains('/')) {
                type = type.substringBefore('/');
            }
            acc.FS_Org_Type__c = type;
        }
        if (!String.isBlank(subType)) {
            acc.Sub_Org_Type__c = subType;
        }
        if (!String.isBlank(street)) {
            acc.ShippingStreet = street;
        }
        if (!String.isBlank(city)) {
            acc.ShippingCity = city;
        }
        if (!String.isBlank(zipCode)) {
            acc.ShippingPostalCode = zipCode;
        }
        if (!String.isBlank(country)) {
            String countryCode = convertCountryNameToCountryCode(country);
            acc.ShippingCountryCode = countryCode;
        }
        if (!String.isBlank(state)) {
            String stateCode = convertStateNameToStateCode(state);
            acc.ShippingStateCode = stateCode;
        }
        insert acc;
        return acc.Id;
    }
    
    @AuraEnabled
    public static FS_New_User_Registration_Labels__c getRegistrationLabels() {
        return FS_New_User_Registration_Labels__c.getOrgDefaults();
    }
    
    //    private static User refreshUser(User oUser) {
    //        return [
    //                SELECT Id,FirstName,LastName,Username
    //                FROM User
    //                WHERE Username = :oUser.Username
    //        ];
    //    }
    
    private static String constructNickName(String email) {
        System.debug(Math.min(email.length(), User.CommunityNickname.getDescribe().getLength()));
        return randomizeNickname(email.substring(0, Math.min(email.length(), User.CommunityNickname.getDescribe().getLength())));
    }
    private static String constructAlias(Contact oContact) {
        String alias = String.isBlank(oContact.FirstName) ? oContact.LastName : oContact.FirstName;
        alias = alias.substring(0, Math.min(alias.length(), User.Alias.getDescribe().getLength()));
        return alias;
    }
    private static Id getCommunityHubLoginUserProfileId() {
        Profile oProfile = [SELECT Id FROM Profile WHERE Name = :COMMUNITY_USER_PROFILE_NAME LIMIT 1];
        System.debug('++++++login user profile: ');
        System.debug(oProfile);
        return oProfile.Id;
    }
    private static final List<String> CHARS = new List<String>{
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
            'u', 'v', 'w', 'x', 'y', 'z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0'
            };
                private static String randomizeNickname(String nickname) {
                    Integer index = (Integer) (Math.random() * 35);
                    String retString = nickname.substring(0, nickname.length() - 5);
                    for (Integer i = 0; i < 4; i++) {
                        retString += CHARS.get(index);
                        index = (Integer) (Math.random() * 35);
                    }
                    return retString;
                }
    private static Map<String, String> stateNameToStateCode = null;
    public static String convertStateNameToStateCode(String name) {
        if (name == null) {
            return null;
        }
        
        if (stateNameToStateCode == null) {
            Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            stateNameToStateCode = new Map<String, String>();
            for (Schema.PicklistEntry f : ple) {
                stateNameToStateCode.put(f.getLabel(), f.getValue());
            }
        }
        
        return stateNameToStateCode.get(name);
    }
    private static Map<String, String> countryNameToCountryCode = null;
    public static String convertCountryNameToCountryCode(String name) {
        if (name == null) {
            return null;
        }
        if (countryNameToCountryCode == null) {
            Schema.DescribeFieldResult fieldResult = User.countrycode.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            countryNameToCountryCode = new Map<String, String>();
            for (Schema.PicklistEntry f : ple) {
                countryNameToCountryCode.put(f.getLabel(), f.getValue());
            }
        }
        return countryNameToCountryCode.get(name);
    }

    //    private static Id getUserRoleId() {
    //        UserRole oRole = [SELECT Id FROM UserRole WHERE Name = :USER_ROLE_NAME LIMIT 1];
    //        return oRole.Id;
    //    }
}