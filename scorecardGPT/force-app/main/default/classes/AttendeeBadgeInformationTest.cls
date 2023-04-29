@isTest
public class AttendeeBadgeInformationTest {
 @isTEst
    public static void test1(){
        contact con = new contact();
        con.LastName = 'test';
        insert con;
        EventApi__Event__c ev = new EventApi__Event__c();
        ev.Name = 'test';
        ev.EventApi__Event_Key__c = 'ts';
        insert ev;
       string startdate = string.valueof(system.today());
        string enddate = string.valueof(system.today());
       // EventApi__Attendee__c a = [select id from EventApi__Attendee__c where id ='a1W530000009rBMEAY' LIMIT 1];
        
        Test.setCurrentPage(Page.attendeeBadgeVFP);
        ApexPages.currentPage().getParameters().put('id',ev.Id);
        ApexPages.currentPage().getParameters().put('sd',startdate);
                ApexPages.currentPage().getParameters().put('ed',enddate);

       /* EventApi__Attendee__c att = new EventApi__Attendee__c();
        att.EventApi__Attendee_Event__c= ev.Id;
        att.EventApi__Event__c = ev.id;
        insert att; 
        EventApi__Registration_Item__c reg = new EventApi__Registration_Item__c();
        reg.EventApi__Attendee__c = att.Id;
        insert reg;*/
        test.startTest();
        AttendeeBadgeInformation.getAttendee();
       AttendeeBadgeInformation.next();
        
        test.stopTest();
    }
}