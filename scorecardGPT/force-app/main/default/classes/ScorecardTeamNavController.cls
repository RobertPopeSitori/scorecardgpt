public without sharing class ScorecardTeamNavController  
{
    @AuraEnabled
    public static string getTeamMembers(string scorecardId)
        
    {
        AuraResponse response = new AuraResponse();
        
        if(String.isBlank(scorecardId))
        {
            response.success = false;
            response.message = 'Missing parameterL scorecardId.';
            return JSON.serialize(response);
        }
        
        List<Scorecard_User__c> users = ScorecardUserHelper.getScorecardUsers(scorecardId);
        List<ScorecardTeamModel> modelList = ScorecardTeamModel.toList(users);
        
        response.success = true;
        response.model = modelList;
        return JSON.serialize(response);
    }
    
    @AuraEnabled
    public static boolean deleteScorecardUser(string scorecardId,string UserId){
        boolean result;
        Scorecard_User__c carduser=[SELECT Id,Is_Active__c,Scorecard__c,User__c,Role__c  
                                    FROM Scorecard_User__c
                                    WHERE Scorecard__c =:scorecardId
                                    AND User__c =:UserId
                                    AND Is_Active__c = true
                                    LIMIT 1];
        system.debug('carduser role:-'+carduser.Role__c);
        system.debug('Id:-'+carduser.id);
        
        /*If(carduser.Role__c == 'Author' || carduser.Role__c == 'Lead Reviewer'){
List<Scorecard_User__c> listscorecarduser=[SELECT Id,Is_Active__c,Scorecard__c,User__c,Role__c  
FROM Scorecard_User__c
WHERE Scorecard__c =:scorecardId
//AND Role__c =: carduser.Role__c
//AND Is_Active__c = true
AND Id = :carduser.id];
If(listscorecarduser.size()>0){
result=FALSE;
}
}

If(carduser.Role__c == 'Author' || carduser.Role__c == 'Lead Reviewer'){
List<Scorecard_User__c> listscorecarduser1=[SELECT Id,Is_Active__c,Scorecard__c,User__c,Role__c  
FROM Scorecard_User__c
WHERE Scorecard__c =:scorecardId
AND Role__c =: carduser.Role__c
AND Is_Active__c = true
AND Id != :carduser.id];
If(listscorecarduser1.size()>0){
carduser.Is_Active__c = false;
update carduser;
result=TRUE;
}else{
result=FALSE;
}
}

If(carduser.Role__c != 'Author' && carduser.Role__c != 'Lead Reviewer'){
carduser.Is_Active__c = false;
update carduser;
result=TRUE;
}
*/
        If(carduser.Role__c == 'Author' || carduser.Role__c == 'Lead Reviewer'){
            /*List<Scorecard_User__c> listscorecarduser=[SELECT Id,Is_Active__c,Scorecard__c,User__c,Role__c  
FROM Scorecard_User__c
WHERE Scorecard__c =:scorecardId
AND Role__c =: carduser.Role__c
AND Is_Active__c = true
AND Id = :carduser.id];
If(listscorecarduser.size()>0){
result=FALSE;
}*/
            List<Scorecard_User__c> listscorecarduser=[SELECT Id,Is_Active__c,Scorecard__c,User__c,Role__c  
                                                       FROM Scorecard_User__c
                                                       WHERE Scorecard__c =:scorecardId
                                                       AND Role__c =: carduser.Role__c
                                                       AND Is_Active__c = true
                                                       AND Id != :carduser.id];
            If(listscorecarduser.size()>0){
                carduser.Is_Active__c = false;
                update carduser;
                result=TRUE;
            }else{
                result=FALSE;
            }
        }else{
            carduser.Is_Active__c = false;
            update carduser;
            result=TRUE;
        }
        return result;
    }
    
    @AuraEnabled
    public static string returnUserRole(string userId,string scorecard_Id){
        string role='';
        User ur=[SELECT id from User Where Id=:userId];
            for(Scorecard_User__c scoreUser:[SELECT Role__c,User__c  FROM Scorecard_User__c WHERE Scorecard__c =:scorecard_Id])
        {
            if(scoreUser.User__c == ur.id){
                system.debug('Inside Correct check');
                role=scoreUser.Role__c;
            }
        }
        return role;
    }
    
    
    @AuraEnabled 
    public static List<Invitation__c> getInvitations(string scorecardId){
        List<Invitation__c> listOfInvitations = [SELECT Id,CreatedBy.Name,Status__c,Scorecard__c, First_Name__c,
                                                 Last_Name__c 
                                                 FROM Invitation__c 
                                                 WHERE Scorecard__c =:scorecardId //'a2y7d000000tuxkAAA' //:scorecardId
                                                 AND (Status__c = 'Invited' OR Status__c = 'Decline') ];
        return listOfInvitations;//.size()>0 ? listOfInvitations : null;
    }
    
    @AuraEnabled 
    public static List<Invitation__c> getInvitationDetail(string Invitationidx){
        List<Invitation__c> listOfInvitations = [SELECT Id,Name,CreatedBy.Name,Status__c,Scorecard__c,scorecard__r.title__c, First_Name__c,Role__c,Email__c,
                                                 Last_Name__c 
                                                 FROM Invitation__c 
                                                 WHERE Id =:Invitationidx
                                                ];
        return listOfInvitations;
    }
    
    
    @AuraEnabled
    public static Scorecard_User__c getUserEmail(string UserId){
        
        Scorecard_User__c ScUser = [SELECT Role__c,User__c,Scorecard_User_Email_Address__c  FROM Scorecard_User__c WHERE User__c =:UserId AND Is_Active__c = true Limit 1];
        
        return ScUser;
    }
    
    
    @AuraEnabled
    public static Invitation__c ResendInvitation(string InvitationId){
        string Msg = 'Success';
        Invitation__c Invite = [SELECT id,First_Name__c,Last_Name__c,Email__c,Resentmail__c  FROM Invitation__c 
                                WHERE id =:InvitationId];
        system.debug(Invite);
        invite.Resentmail__c = true;
        update invite;
        Invite.Resentmail__c = false;
        update invite;
        return invite;
        
        
        
      
    }
    
    @AuraEnabled
    public static String SaveandResendInvitation(List<Invitation__c> Invitation,List<string> selectedSection){
        system.debug(' invite'+Invitation);
        List<Invitation__c> invite = new List<Invitation__c>();
        for(Invitation__c invitee : Invitation) {
            Invitation__c inv = new Invitation__c();
            inv.Id = invitee.id;
            inv.Section__c = string.valueOf(selectedSection);
           /* inv.AssessmentAndFeedback__c = feedback;
            inv.ContentAndActivities__c = 
            inv.CourseOverviewAndInformation__c = cinfo;
            inv.CourseTechnologyAndTool__c = ctech;
            inv.DesignAndLayout__c = design;
            inv.Interaction__c = interaction;*/
            inv.First_Name__c = invitee.First_Name__c;
            inv.Last_Name__c = invitee.Last_Name__c;
            inv.Role__c = invitee.Role__c;
            inv.Email__c = invitee.Email__c;
            invite.add(inv);
        }
        // invite.add(Invitation);
        system.debug('Invite : '+invite);
        if(invite.size() > 0) {
            update invite;
            ScorecardteamNavController.ResendInvitation(invite[0].Id);
        }
        return 'msg';
    }
      @AuraEnabled
    public static List<Scorecard_Section__c>  getSectionList(String scoreCardId) {
        List<Scorecard_Section__c> Section = [select id,title__c from Scorecard_Section__c where Scorecard__c =: scoreCardId];
        system.debug('Sections are'+Section);
        return Section;
    }
     @AuraEnabled
    public static void  emailcodetest() {
       
    }
    
}