/**
 * Created by Admin on 25-06-2019.
 */
@isTest
public class FS_ValidateJoinProcessTest {
    @isTest
    static void recordInsertion() {
        Boolean flagt;
        //Inserting Account
        Account a = FS_TestUtils.createAccount('Test Account');
        List<Account> accounts = [SELECT Id from Account WHERE Id =: a.Id];
        System.assertEquals(accounts.size(), 1);
        //Inserting contact
        Contact c = new Contact(lastName = 'test', firstName = 'contact', title = 'Manager', AccountId = a.Id);
        insert c;
        List<Contact> contacts = [SELECT Id from Contact WHERE AccountId = :a.Id and Id = :c.Id];
        System.assertEquals(contacts.size(), 1);
        //Inserting User
        Profile p = [SELECT Id,Name FROM profile WHERE Name='Fonteva 	Customer Community Login User'];
        User u=new User();
        u.firstName='first2';
        u.profileId=p.Id;
        u.lastName = 'last2';
        u.Email = 'gdasari+atest2@fusion.com';
        u.userName = 'gdasari+atest2@fusion.com';
        u.companyName = 'TEST';
        u.Title = 'title';
        u.Alias = 'alias';
        u.timeZoneSidKey = 'America/Los_Angeles';
        u.emailEncodingKey = 'UTF-8';
        u.languageLocaleKey = 'en_US';
        u.localeSidKey = 'en_US';
        u.contactId=c.Id;
        insert u;
        //Inserting Itemclass
        OrderApi__Item_Class__c itemclass = new OrderApi__Item_Class__c();
        itemclass.Name = 'Individual Membership';
        insert itemclass;
        List<OrderApi__Item_Class__c> itemClasses = [SELECT Id FROM OrderApi__Item_Class__c WHERE Id = :itemclass.Id];
        System.assertEquals(itemClasses.size(),1);
        //Inserting Item
        OrderApi__Item__c item = new OrderApi__Item__c();
        item.Name = 'Professional Membership';
        item.OrderApi__Item_Class__c = itemclass.Id;
        insert item;
        List<OrderApi__Item__c> items = [SELECT Id FROM OrderApi__Item__c WHERE Id = :item.Id];
        System.assertEquals(items.size(), 1);
        //inserting membership
        OrderApi__Subscription__c member = new OrderApi__Subscription__c();
        member.OrderApi__Account__c = a.Id;
        member.OrderApi__Contact__c = c.Id;
        member.OrderApi__Item__c = item.Id;
        member.OrderApi__Item_Class__c = itemclass.Id;
        insert member;
        System.runAs(u){
            FS_ValidateJoinProcess jP = new FS_ValidateJoinProcess();
            jP.validateJoinProcess();
            List<OrderApi__Subscription__c> membrShipLst = [SELECT Id,OrderApi__Status__c,OrderApi__Item_Class__r.Name,OrderApi__Item_Class__c FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c = :u.contactId AND OrderApi__Item_Class__r.Name = 'Individual Membership'AND OrderApi__Status__c !='Cancelled'];
            if(membrShipLst.size()>0){
                flagt = true;
            }
            System.assertEquals(flagt,true);
        }
        //Inserting Account for another User
        Account ac = new Account(Name = 'Test');
        insert ac;
        List<Account> accs = [SELECT Id FROM Account WHERE Id = :a.Id];
        System.assertEquals(accounts.size(), 1);
        //Inserting contact
        Contact con = new Contact(lastName = 'testing', firstName = 'contactf', Title = 'Managers', AccountId = ac.Id);
        insert con;
        List<Contact> conList = [SELECT Id FROM Contact WHERE AccountId = :a.Id and Id = :c.Id];
        System.assertEquals(contacts.size(), 1);
        //Insert User
        User us=new User();
        us.firstName='first';
        us.profileId=p.Id;
        us.lastName = 'lastn';
        us.Email = 'gdasari+atest@fusion.com';
        us.userName = 'gdasari+atest@fusion.com';
        us.companyName = 'TEST';
        us.Title = 'title';
        us.Alias = 'alia';
        us.timeZoneSidKey = 'America/Los_Angeles';
        us.emailEncodingKey = 'UTF-8';
        us.languageLocaleKey = 'en_US';
        us.localeSidKey = 'en_US';
        us.contactId=con.Id;
        insert us;
        System.runAs(us){
            FS_ValidateJoinProcess jPC = new FS_ValidateJoinProcess();
            jPC.validateJoinProcess();
        }
    }
}