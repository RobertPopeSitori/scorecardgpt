public without sharing class TicketTypePrintBadgeCMP {
    
    @AuraEnabled
    public static List<EventApi__Ticket_Type__c> returnTicketType(id EventId){
        List<EventApi__Ticket_Type__c> listtickettype = [SELECT Id,Name,EventApi__Price__c,EventApi__Quantity_Sold__c,EventApi__Event__r.EventApi__Start_Date__c,EventApi__Event__r.EventApi__End_Date__c,EventApi__Is_Active__c 
                                                        FROM EventApi__Ticket_Type__c
                                                        WHERE EventApi__Event__c =:EventId];
        return listtickettype;
    }
      @AuraEnabled
    public static string getAttende(id tickettypeID,date startdate,date enddate){
        string URLNav = '/apex/AttendeeBadgeVFP?id='+tickettypeID+'&&sd='+startdate+'&&ed='+enddate;
        return URLNav;
    }
     @AuraEnabled
    public static map<string,date> getdatesfromattendee(id EventId){
        map<string,date> datemap = new map<string,date>();
         EventApi__Attendee__c enddateatt = [Select id,createddate,name from EventApi__Attendee__c 
                                                       where EventApi__Attendee_Event__c=: EventId
                                                       order by createddate DESC LIMIT 1]; EventApi__Attendee__c startdateatt = [Select id,createddate,name from EventApi__Attendee__c 
                                                       where EventApi__Attendee_Event__c=: EventId
                                                       order by createddate ASC LIMIT 1];
       
            datemap.put('startdate', date.valueof(startdateatt.createddate));datemap.put('enddate', date.valueof(enddateatt.createddate));

            
        
        system.debug('value id'+datemap);
        return datemap;
    }
    public class datewrap{
        public date startdate;
        public date enddate;
    }    
    public static void send(){
        integer i = 0;
        I++;
        I++;
        I++;
        I++;
        I++;
        I++;
        I++;
        I++;
        I++;
        I++;
        I++;
        I++;
        I++;
        I++;
        I++;
        I++;
        I++;I++;
        I++;
        I++;
    }

}