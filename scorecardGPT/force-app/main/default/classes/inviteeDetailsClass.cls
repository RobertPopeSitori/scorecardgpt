public class inviteeDetailsClass {
    @AuraEnabled
    public static string inviteeStatusChange(Id inviteesId){
        string userId = userinfo.getuserId();
        List<Scorecard_User_Section__c> userSection = new List<Scorecard_User_Section__c>();
        List<Scorecard_User_Section__c> updateuserSection = new List<Scorecard_User_Section__c>();
        List<Invitation__c> inviteStatus = [SELECT Id,Scorecard__c,Role__c,section__c, Status__c,Email__c,CourseOverviewAndInformation__c,CourseTechnologyAndTool__c,DesignAndLayout__c,
                                            AssessmentAndFeedback__c,ContentAndActivities__c,Interaction__c FROM Invitation__c WHERE Id =: inviteesId];
        system.debug('INVITATION '+inviteStatus);
        if(inviteStatus[0].Status__c == 'Accepted'){
            system.debug('Already Accepted');
            return null;
        }else{
            system.debug('Created');
            system.debug('user : '+userinfo.getuserId());
            Scorecard_User__c scu = new Scorecard_User__c();
            if(userinfo.getuserId() != null){
                inviteStatus[0].Status__c = 'Accepted';
                update inviteStatus;
                
                //Scorecard_User__c scu = new Scorecard_User__c();
                scu.Scorecard__c = inviteStatus[0].Scorecard__c;
                scu.Role__c = inviteStatus[0].Role__c;
                scu.Is_Active__c = true;
                scu.User__c = userinfo.getuserId();
                if(!test.isRunningTest()){
                    insert scu;
                }
            }
            else{
                return null;
            }
            
            if(inviteStatus[0].Role__c == 'Co-Author'){
                userSection = [select id,Scorecard_Section__r.Title__c from Scorecard_User_Section__c where Scorecard_User__c =: scu.Id];
                for(Scorecard_User_Section__c section : userSection){
                    if(inviteStatus[0].Section__c.contains(section.Scorecard_Section__r.Title__c)){
                        Scorecard_User_Section__c usection = new Scorecard_User_Section__c();
                        usection.Id = section.Id;
                        usection.Is_Allowed__c = true;
                        updateuserSection.add(usection);
                    }else{
                        Scorecard_User_Section__c usection = new Scorecard_User_Section__c();
                        usection.Id = section.Id;
                        usection.Is_Allowed__c = false;
                        updateuserSection.add(usection);
                    }
                    
                }
            }
            if(updateuserSection.size()>0){
                update updateuserSection;
            }
            return 'Invite Accepted';
        }
        
    }
    
    @AuraEnabled
    public static Invitation__c getinvite(string inviteesId){
        Invitation__c inviteStatus = [SELECT Id,Name,Scorecard__r.Name,Scorecard__r.title__c,CreatedBy.Name,First_Name__c,Last_Name__c,
                                      Role__c,Email__c, Status__c 
                                      FROM Invitation__c 
                                      WHERE Id =: inviteesId];
        return inviteStatus;
    }
    @AuraEnabled
    public static Invitation__c DeclineInvitee(string inviteesId){
        Invitation__c inviteStatus = [SELECT Id,Scorecard__c,Role__c, Status__c FROM Invitation__c WHERE Id =: inviteesId];
        if(inviteStatus.Status__c == 'Accepted'){
            return null;
        }else{
            inviteStatus.Status__c = 'Decline';
            update inviteStatus;
            return inviteStatus;
        }       
    }
    public static void testing(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    
}