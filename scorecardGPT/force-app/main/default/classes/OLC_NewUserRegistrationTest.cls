@isTest
public class OLC_NewUserRegistrationTest {
    
    private static final String SELF_REGISTRATION_ACCOUNT_NAME = 'Community Portal Self Registration Account';

    @IsTest
    public static void testLookForExistingUser_ExpectUserFound() {
        String email = 'testemail123@aplusify.com';
        Account acc = createAccount('Test Account', 'aplusify.com');
        Contact con = createContact('Test', 'Con', email, acc);
        User oUser = createUser(con);
        String ret = '';
        Test.startTest();
        ret = OLC_NewUserRegistration.lookForExistingUser(email);
        Test.stopTest();
        System.assert(ret != null, 'User was not found with the given email');
    }

    @IsTest
    public static void testLookingForContact_ExpectContactFound() {
        String email = 'testemail123@aplusify.com';
        Account acc = createAccount('Test Account', 'aplusify.com');
        Contact con = createContact('Test', 'Con', email, acc);
        User oUser = createUser(con);
        Test.startTest();
        List<Map<String, String>> ret = OLC_NewUserRegistration.lookForExistingContact(email);
        Test.stopTest();
        System.assert(ret != null, 'Contact not found with the given email');
    }

    @IsTest
    public static void testLookingForAccount_ExpectAccountsFound() {
        String email = 'testemail123@aplusify.com';
        Account acc = createAccount('Test Account', 'aplusify.com');
        Account acc2 = createAccount('Second Test Account', '2aplusify.com');
        Contact con = createContact('Test', 'Con', email, acc);
        User oUser = createUser(con);
        List<Map<String, String>> ret = OLC_NewUserRegistration.lookForExistingAccountsWithValidEmailDomain(email);
        System.assert(ret != null, 'No accounts found with the given email');
    }

    @IsTest
    public static void testLookingForAccount_ExpectSelfRegistrationAccountFound() {
        String email = 'testemail@gmail.com';
        Account acc = createAccount('Test Account', '');
        Account selfRegAccount = createAccount(SELF_REGISTRATION_ACCOUNT_NAME, '');
        Contact con = createContact('Test', 'Con', email, acc);
        User oUser = createUser(con);
        Test.startTest();
        List<Map<String, String>> ret = OLC_NewUserRegistration.lookForExistingAccountsWithValidEmailDomain(email);
        Test.stopTest();
        System.assert(ret != null, 'Unable to find self registration account');
    }

    @IsTest
    public static void testCreateNewAccount_ExpectAccountCreated() {
        Map<String, Object> params = new Map<String, Object>();
        params.put('orgName', 'Test Account');
        params.put('adminId', '');
        params.put('webUrl', 'https://google.com');
        params.put('type', 'Institution');
        params.put('subType', 'K-12');
        params.put('street', '12300 Twinbrook Parkway');
        params.put('city', 'Rockville');
        params.put('zipCode', '20852');
        params.put('country', 'United States');
        params.put('state', 'Maryland');
        params.put('Org_Type__c', 'Institution');

        Test.startTest();
        String retId = OLC_NewUserRegistration.createNewAccount(params);
        Test.stopTest();
    }

    @IsTest
    public static void testActivateUser_ExpectUserActivated() {
        String email = 'testemail@gmail.com';
        Account acc = createAccount('Test Account', '');
        Account selfRegAccount = createAccount(SELF_REGISTRATION_ACCOUNT_NAME, '');
        Contact con = createContact('Test', 'Con', email, acc);

        Test.startTest();
        String ret = OLC_NewUserRegistration.finishRegistration(con.Id, 'testing123', '/s/#/profile', selfRegAccount.Id);
        Test.stopTest();
        List<User> testUser = [SELECT Id FROM User LIMIT 1 ];
    }

    private static Account createAccount(String name, String emailDomain) {
            Account acc = new Account();
            acc.Name = name;
            acc.FS_Email_Domain__c = emailDomain;
            acc.Vendor_Type__c = 'N/A';
            insert acc;
            return acc;
    }

    private static Contact createContact(String firstName, String lastName, String email, Account acc) {
            Contact con = new Contact();
            con.FirstName = firstName;
            con.LastName = lastName;
            con.AccountId = acc.Id;
            con.OrderApi__Work_Email__c = email;
            insert con;
            return con;
    }

    private static User createUser(Contact contactToActivate) {
            User oUser = new User();

            oUser.FirstName = contactToActivate.FirstName;
            oUser.LastName = contactToActivate.LastName ;
            oUser.Email = contactToActivate.OrderApi__Work_Email__c;
            oUser.CommunityNickname = constructNickName(contactToActivate.OrderApi__Work_Email__c);
            System.debug(oUser.CommunityNickname);
            oUser.Username = contactToActivate.OrderApi__Work_Email__c;
            oUser.Alias = constructAlias(contactToActivate);
            oUser.TimeZoneSidKey = 'America/Los_Angeles';
            oUser.EmailEncodingKey = 'UTF-8';
            oUser.LanguageLocaleKey = 'en_US';
            oUser.LocaleSidKey = 'en_US';
            oUser.IsActive = true;
            oUser.ContactId = contactToActivate.Id;
            oUser.ProfileId = getCommunityHubLoginUserProfileId();

            insert oUser;
            return oUser;
    }

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
         Id COMMUNITY_USER_PROFILE_NAME = '00e1U000002IC5x';
        return COMMUNITY_USER_PROFILE_NAME;
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
}