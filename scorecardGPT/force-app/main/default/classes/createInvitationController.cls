public class createInvitationController{

    @AuraEnabled
    public static string returnUserRole(string userId,string scorecard_Id){
        string role='';
        User ur=[SELECT id from User Where Id=:userId];
        for(Scorecard_User__c scoreUser:[SELECT Role__c,User__c  FROM Scorecard_User__c WHERE Scorecard__c =:scorecard_Id])
        {
            if(scoreUser.User__c == ur.id){
                role=scoreUser.Role__c;
            }
        }
        return role;
    }
    
    @AuraEnabled
    public static boolean updateScoreCard(String invitId,String scoreCardId,string InviteRole) {
       
       try{
       Invitation__c invit = new Invitation__c();
       invit.Id = invitId;
       invit.Scorecard__c = scoreCardId;
       invit.Role__c = InviteRole;
       invit.Status__c = 'Invited';
       update invit;
       }catch(exception e){return false;}
       return true;
    }
    
        @AuraEnabled
    public static string insertinvite(String scorecardid,String fname,string lname, string email, string selectedValue,List<string> selectedSection) {
        system.debug('selectedSection'+selectedSection);
       /* string section;
        for(string sec : selectedSection){
            section = sec+',';
        }*/
       // system.debug('section'+section);
       List<Invitation__c> invitlist = new list<Invitation__c>();
        Invitation__c invit = new Invitation__c();
        invit.Scorecard__c = scorecardid;
        invit.Role__c = selectedValue;
        invit.Status__c = 'Invited';
        invit.Section__c = string.valueof(selectedSection);
       /* invit.AssessmentAndFeedback__c = feedback;
        invit.CourseOverviewAndInformation__c = cinfo;
        invit.ContentAndActivities__c = content;
        invit.DesignAndLayout__c = design;
        invit.CourseTechnologyAndTool__c = ctech;
        invit.Interaction__c = interaction;*/
        invit.First_Name__c = fname;
        invit.Last_Name__c = lname;
        invit.Email__c = email;
        //invit.Resentmail__c = true;
        invitlist.add(invit);
        if(invitlist.size() > 0){
             insert invitlist;
            Invitation__c Invite = [SELECT id,First_Name__c,Last_Name__c,Email__c,Resentmail__c  FROM Invitation__c 
                                WHERE Email__c =:invitlist[0].email__c order by createddate Desc LIMIT 1];
           //ScorecardteamNavController.ResendInvitation(invite.Id);
             return 'Inserted Successfully';
        }else{
            return 'insert failled';
        }        
        
    }
    
    @AuraEnabled
    public static List<Scorecard_Section__c>  getSectionList(String scoreCardId) {
        List<Scorecard_Section__c> Section = [select id,title__c from Scorecard_Section__c where Scorecard__c =: scoreCardId];
        system.debug('Sections are'+Section);
        return Section;
    }
}