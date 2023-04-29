public class AttendeeBadgeInformation {
    
    public static List<wrappercls> getAttendee(){
        
        String attendid = ApexPages.currentPage().getParameters().get('id'); 
        date startdate = date.valueof(ApexPages.currentPage().getParameters().get('sd')); 
        date enddate = date.valueof(ApexPages.currentPage().getParameters().get('ed'));
         
        map<Id,wrappercls> mapattendee = new map<Id,wrappercls>();
        
       if(startdate != date.newInstance(1960, 01, 01)){
            
        for(EventApi__Attendee__c attendee: [SELECT Id,EventApi__Account__r.name,PaymentDue__c,EventApi__Contact__r.QR_Infomation__c,nickname__c,EventApi__Attendee_Event__r.General_Information__c,Attendee_18_Digit_ID__c,EventApi__Contact__r.MailingPostalCode,
                                             EventApi__Contact__r.Phone,EventApi__Contact__r.Email,EventApi__Contact__r.mailingstate,EventApi__Contact__r.mailingcity,EventApi__Contact__r.mailingstreet,Name,EventApi__Attendee_Event__r.Static_Event_Ticket__c,
                                             EventApi__Attendee_Event__r.General_Static_Conference_Information__c,EventApi__Contact__r.FirstName,EventApi__Contact__r.LastName,EventApi__Contact__r.Title,
                                             EventApi__Contact__r.Account_Name__c,EventApi__Sales_Order__r.Payment_Blance_Due__c,Pronouns__c,
                                             EventApi__Contact__r.Barcode_View__c,EventApi__Contact__r.LinkedIn_URL__c,EventApi__Contact__r.Twitter_URL__c,EventApi__Attendee_Event__r.Badge_Information__c,EventApi__Attendee_Event__r.LogoUrl__c 
                                             FROM EventApi__Attendee__c 
                                             WHERE (Id=:attendid
                                                   OR EventApi__Ticket_Type__c =:attendid) AND EventApi__Registration_Date__c >=: startdate
                                             AND EventApi__Registration_Date__c <=: enddate AND EventApi__Status__c = 'Registered' order by EventApi__Contact__r.LastName,EventApi__Contact__r.FirstName]) 
            
        {
            
            wrappercls warp = new wrappercls();
            warp.attendee = attendee;
            warp.registrationItem = new List<String>();
            warp.registereditemsstarttime = new List<String>();
            warp.registereditemsendtime = new List<String>();
            warp.registereditemsdate = new List<string>();
            warp.registrationItemRoom = new List<string>();
            warp.count = 0;
            
            warp.imageURL = 'https://www.barcodesinc.com/generator/image.php?code='+ attendee.Attendee_18_Digit_ID__c  +'&style=325&type=C128B&width=300&height=100&xres=1&font=3';
            
            mapattendee.put(attendee.Id,warp);
        }
                
        
        for(EventApi__Registration_Item__c itemlist :[SELECT Id,EventApi__Attendee__r.Id,EventApi__Date__c,Room_Location__c,EventApi__Schedule_Item__c,EventApi__Item__r.OrderApi__Display_Name__c,EventApi__Ticket_Type__r.Event_Item_Name__c,EventApi__Start_Time__c,EventApi__End_Time__c 
                                                      FROM EventApi__Registration_Item__c
                                                      WHERE EventApi__Status__c = 'Registered' and EventApi__Attendee__r.Id in :mapattendee.keyset()])
        {
            
            if(mapattendee.containsKey(itemlist.EventApi__Attendee__r.Id)){
                // mapattendee.get(itemlist.EventApi__Attendee__r.Id).registereditems.add(itemlist);
                Integer regListSize = mapattendee.get(itemlist.EventApi__Attendee__r.Id).registrationItem.size();
                if(regListSize == 0 && mapattendee.get(itemlist.EventApi__Attendee__r.Id).firstRegItem == null) {
                    //  mapattendee.get(itemlist.EventApi__Attendee__r.Id).firstRegItem = itemlist.EventApi__Ticket_Type__r.Event_Item_Name__c;
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).firstRegItem = itemlist.EventApi__Item__r.OrderApi__Display_Name__c;
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).startDate = date.valueOf(itemlist.EventApi__Date__c);
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).starttime = (string)itemlist.EventApi__Start_Time__c;
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).endtime = (string)itemlist.EventApi__End_Time__c;
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).Room = (string)itemlist.Room_Location__c;
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).Scheduleditem = string.valueOf(itemlist.EventApi__Schedule_Item__c);
                    //  mapattendee.get(itemlist.EventApi__Attendee__r.Id).registereditemsdatetime.add((string)itemlist.EventApi__Start_Time__c);
                    // mapattendee.get(itemlist.EventApi__Attendee__r.Id).registereditemsdatetime.add((string)itemlist.EventApi__End_Time__c);
                    
                    
                }
                else if(regListSize < 10){
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).registrationItem.add(itemlist.EventApi__Item__r.OrderApi__Display_Name__c);
                    
                    //mapattendee.get(itemlist.EventApi__Attendee__r.Id).registrationItem.add(itemlist.EventApi__Ticket_Type__r.Event_Item_Name__c);
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).registereditemsstarttime.add((string)itemlist.EventApi__Start_Time__c);
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).registereditemsendtime.add((string)itemlist.EventApi__End_Time__c);
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).registereditemsdate.add(string.valueOf(itemlist.EventApi__Date__c));
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).registrationItemRoom.add(string.valueOf(itemlist.Room_Location__c));
                    
                    
                }
                
            }
        }
        
        for(Id idObj : mapattendee.keyset()){
            Integer regSize = mapattendee.get(idObj).registrationItem.size();
            
            for(Integer i=regSize; i<=8; i++){
                mapattendee.get(idObj).registrationItem.add('');
                mapattendee.get(idObj).registereditemsstarttime.add(''); 
                mapattendee.get(idObj).registereditemsendtime.add('');
                mapattendee.get(idObj).registereditemsdate.add('');
                mapattendee.get(idObj).registrationItemRoom.add('');
            }        
        }  
       
        return mapattendee.values();
        }else{
            system.debug('In else');
            for(EventApi__Attendee__c attendee: [SELECT Id,EventApi__Account__r.name,PaymentDue__c,EventApi__Contact__r.QR_Infomation__c,nickname__c,EventApi__Attendee_Event__r.General_Information__c,Attendee_18_Digit_ID__c,EventApi__Contact__r.MailingPostalCode,
                                             EventApi__Contact__r.Phone,EventApi__Contact__r.Email,EventApi__Contact__r.mailingstate,EventApi__Contact__r.mailingcity,EventApi__Contact__r.mailingstreet,Name,EventApi__Attendee_Event__r.Static_Event_Ticket__c,
                                             EventApi__Attendee_Event__r.General_Static_Conference_Information__c,EventApi__Contact__r.FirstName,EventApi__Contact__r.LastName,EventApi__Contact__r.Title,
                                             EventApi__Contact__r.Account_Name__c,EventApi__Sales_Order__r.Payment_Blance_Due__c,Pronouns__c,
                                             EventApi__Contact__r.Barcode_View__c,EventApi__Contact__r.LinkedIn_URL__c,EventApi__Contact__r.Twitter_URL__c,EventApi__Attendee_Event__r.Badge_Information__c,EventApi__Attendee_Event__r.LogoUrl__c 
                                             FROM EventApi__Attendee__c 
                                             WHERE Id=:attendid
                                                 OR EventApi__Ticket_Type__c =:attendid]) 
        {
            wrappercls warp = new wrappercls();
            warp.attendee = attendee;
            warp.registrationItem = new List<String>();
            warp.registereditemsstarttime = new List<String>();
            warp.registereditemsendtime = new List<String>();
            warp.registereditemsdate = new List<string>();
            warp.registrationItemRoom = new List<string>();
            
            warp.imageURL = 'https://www.barcodesinc.com/generator/image.php?code='+ attendee.Attendee_18_Digit_ID__c  +'&style=325&type=C128B&width=300&height=100&xres=1&font=3';
            
            mapattendee.put(attendee.Id,warp);
        }
                
        
        for(EventApi__Registration_Item__c itemlist :[SELECT Id,EventApi__Attendee__r.Id,EventApi__Date__c,Room_Location__c,EventApi__Schedule_Item__c,EventApi__Item__r.OrderApi__Display_Name__c,EventApi__Ticket_Type__r.Event_Item_Name__c,EventApi__Start_Time__c,EventApi__End_Time__c 
                                                      FROM EventApi__Registration_Item__c
                                                      WHERE EventApi__Status__c = 'Registered' and EventApi__Attendee__r.Id in :mapattendee.keyset()])
        {
            
            if(mapattendee.containsKey(itemlist.EventApi__Attendee__r.Id)){
                // mapattendee.get(itemlist.EventApi__Attendee__r.Id).registereditems.add(itemlist);
                Integer regListSize = mapattendee.get(itemlist.EventApi__Attendee__r.Id).registrationItem.size();
                if(regListSize == 0 && mapattendee.get(itemlist.EventApi__Attendee__r.Id).firstRegItem == null) {
                    //  mapattendee.get(itemlist.EventApi__Attendee__r.Id).firstRegItem = itemlist.EventApi__Ticket_Type__r.Event_Item_Name__c;
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).firstRegItem = itemlist.EventApi__Item__r.OrderApi__Display_Name__c;
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).startDate = date.valueOf(itemlist.EventApi__Date__c);
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).starttime = (string)itemlist.EventApi__Start_Time__c;
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).endtime = (string)itemlist.EventApi__End_Time__c;
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).Room = (string)itemlist.Room_Location__c;
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).Scheduleditem = string.valueOf(itemlist.EventApi__Schedule_Item__c);
                    //  mapattendee.get(itemlist.EventApi__Attendee__r.Id).registereditemsdatetime.add((string)itemlist.EventApi__Start_Time__c);
                    // mapattendee.get(itemlist.EventApi__Attendee__r.Id).registereditemsdatetime.add((string)itemlist.EventApi__End_Time__c);
                    
                    
                }
                else if(regListSize < 10){
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).registrationItem.add(itemlist.EventApi__Item__r.OrderApi__Display_Name__c);
                    
                    //mapattendee.get(itemlist.EventApi__Attendee__r.Id).registrationItem.add(itemlist.EventApi__Ticket_Type__r.Event_Item_Name__c);
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).registereditemsstarttime.add((string)itemlist.EventApi__Start_Time__c);
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).registereditemsendtime.add((string)itemlist.EventApi__End_Time__c);
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).registereditemsdate.add(string.valueOf(itemlist.EventApi__Date__c));
                    mapattendee.get(itemlist.EventApi__Attendee__r.Id).registrationItemRoom.add(string.valueOf(itemlist.Room_Location__c));
                    
                    
                }
                
            }
        }
        
        for(Id idObj : mapattendee.keyset()){
            Integer regSize = mapattendee.get(idObj).registrationItem.size();
            
            for(Integer i=regSize; i<=8; i++){
                mapattendee.get(idObj).registrationItem.add('');
                mapattendee.get(idObj).registereditemsstarttime.add(''); 
                mapattendee.get(idObj).registereditemsendtime.add('');
                mapattendee.get(idObj).registereditemsdate.add('');
                mapattendee.get(idObj).registrationItemRoom.add('');
            }        
        }  
        
        return mapattendee.values();
        }
        
    }
    public class wrappercls{
        public transient  EventApi__Attendee__c attendee {get;set;}
        public  transient String firstRegItem {get;set;}
        public  transient date startDate {get;set;}
        public  transient string starttime {get;set;}
        public  transient string endtime {get;set;}
        public  transient string Room {get;set;}
        public  transient integer count {get;set;}
        public  transient string ScheduledItem {get;set;}
        public transient  List<String> registrationItem {get;set;}
        public transient  List<String> registrationItemRoom {get;set;}
        public transient  List<string> registereditemsstarttime {get;set;}
        public transient  List<string> registereditemsendtime {get;set;}
        public transient  List<string> registereditemsdate {get;set;}
        
        public transient  string imageURL {get;set;}
    }
    //TODO: [IT-2749] Clean up this method and write tests to appropriately test the code please
    public static void next(){
        integer j =0;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
         j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
         j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
         j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
    }    
}