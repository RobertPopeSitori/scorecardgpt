public without sharing class ScorecardUserHelper 
{
    public static Scorecard_User__c getScorecardUser(Id scorecardId)
    {
        List<Scorecard_User__c> users = [   SELECT Id, Role__c, Scorecard__c, User__c 
                                            FROM Scorecard_User__c
                                            WHERE (User__c = :UserInfo.getUserId())
                                                AND (Scorecard__c = :scorecardId) 
												AND (Is_Active__c = true)];

        return (users.size() == 0 ? null : users[0]);
    }

    public static Scorecard_Role__mdt getRolePermissions(Id scorecardId)
    {
        Scorecard_User__c scUser = getScorecardUser(scorecardId);
        if(scUser == null) return new Scorecard_Role__mdt();

        List<Scorecard_Role__mdt> permissions = [   SELECT MasterLabel, Answer_Question__c, Create_Scorecard__c, Delete_Scorecard__c,
                                                        Edit_Scorecard__c, Review_Question__c, Review_Question_Final__c,
                                                        View_All_Sections__c, Answer_Type__c, DeveloperName 
                                                    FROM Scorecard_Role__mdt
                                                    WHERE (MasterLabel = :scUser.Role__c) 
                                                    LIMIT 1];
        
        return (permissions.size() == 0 ? new Scorecard_Role__mdt() : permissions[0]);
    }

    public static List<Scorecard_User_Section__c> getUserSections(Id scorecardId)
    {
        List<Scorecard_User_Section__c> userSections = [    SELECT Id, Scorecard_Section__c, Scorecard_User__c,
                                                                Scorecard_Section__r.Scorecard__c, Is_Allowed__c,
                                                                Scorecard_User__r.User__c
                                                            FROM Scorecard_User_Section__c 
                                                            WHERE (Scorecard_Section__r.Scorecard__c = :scorecardId)
                                                                AND (Scorecard_User__r.User__c = :UserInfo.getUserId())
																AND (Scorecard_User__r.Is_Active__c = true) ];
        return userSections;
    }

    public static List<Scorecard_User__c> getScorecardUsers(Id scorecardId)
    {
        List<Scorecard_User__c> scorecardUsers = [	SELECT Id, User__c, Role__c, User__r.Id, User__r.Name 
												    FROM Scorecard_User__c 
												    WHERE (Scorecard__c = :scorecardId) 
														AND (Is_Active__c = true)];
        
        return scorecardUsers;
    }

    public static void grantScorecardSectionsAccess(List<Scorecard_User__c> scUsers)
    {
        List<Id> scoreIds = new List<Id>();
        List<Id> userIds = new List<Id>();
        for(Scorecard_User__c scUser : scUsers)
        {
            scoreIds.add(scUser.Scorecard__c);
            userIds.add(scUser.User__c);
        }

        List<Scorecard_Section__c> sections = [ SELECT Id, Scorecard__c
                                                FROM Scorecard_Section__c 
                                                WHERE (Scorecard__c IN :scoreIds) 
                                                ORDER BY Order__c ];
        
        Map<Id, List<Scorecard_Section__c>> scoreSectionsMap = new Map<Id, List<Scorecard_Section__c>>();
        for(Scorecard_User__c scUser : scUsers)
        {
            List<Scorecard_Section__c> scoreSections = scoreSectionsMap.get(scUser.Scorecard__c);
            if(scoreSections == null)
            {
                scoreSections = new List<Scorecard_Section__c>();
                for(Scorecard_Section__c section : sections)
                {
                    if(section.Scorecard__c == scUser.Scorecard__c)
                    {
                        scoreSections.add(section);
                    }
                }
                scoreSectionsMap.put(scUser.Scorecard__c, scoreSections);
            }
        }

        List<Scorecard_User_Section__c> userSections = new List<Scorecard_User_Section__c>();
        Map<string, Scorecard_User_Section__c> userSectionMap = new Map<string, Scorecard_User_Section__c>();

        for(Scorecard_User__c scUser : scUsers)
        {
            List<Scorecard_Section__c> scoreSections = scoreSectionsMap.get(scUser.Scorecard__c);
            if(scoreSections != null)
            {
                for(Scorecard_Section__c scoreSection : scoreSections)
                {
                    string sectionKey = string.valueOf(scoreSection.Id) + ':' + string.valueOf(scUser.User__c);
                    Scorecard_User_Section__c newSection = userSectionMap.get(sectionKey);
                    if(newSection == null)
                    {
                        newSection = new Scorecard_User_Section__c();
                        newSection.Is_Allowed__c = true;
                        newSection.Scorecard_Section__c = scoreSection.Id;
                        newSection.Scorecard_User__c = scUser.Id;

                        userSectionMap.put(sectionKey, newSection);
                        userSections.add(newSection);
                    }
                }
            }
        }

        if(userSections.size() > 0) insert userSections;
    }

    public static void setupDefaultReviews(List<Scorecard_User__c> scUsers)
    {
        List<Id> scorecardIds = new List<Id>();
        for(Scorecard_User__c scUser : scUsers) {
            scorecardIds.add(scUser.Scorecard__c);
        }

        List<Scorecard_Question__c> questions = [   SELECT Id, Section__r.Scorecard__c 
                                                    FROM Scorecard_Question__c 
                                                    WHERE (Section__r.Scorecard__c IN :scorecardIds) ];
        
        if(questions.size() > 0)
        {
            Scorecard_User__c inMap;
            Map<Id, Scorecard_User__c> scUserMap = new Map<Id, Scorecard_User__c>();
            for(Scorecard_User__c scUser : scUsers)
            {
                inMap = scUserMap.get(scUser.Id);
                if(inMap == null) scUserMap.put(scUser.Id, scUser);
            }

            List<Scorecard_Role__mdt> permissions = [   SELECT MasterLabel, Answer_Question__c, Create_Scorecard__c, Delete_Scorecard__c,
                                                        Edit_Scorecard__c, Review_Question__c, Review_Question_Final__c,
                                                        View_All_Sections__c, Answer_Type__c, DeveloperName 
                                                    FROM Scorecard_Role__mdt ];
            Map<string, Scorecard_Role__mdt> permissionMap = new Map<string, Scorecard_Role__mdt>();
            for(Scorecard_Role__mdt permission : permissions)
            {
                permissionMap.put(permission.MasterLabel, permission);
            }

            Scorecard_Review__c review;
            Scorecard_Role__mdt permission;
            List<Scorecard_Review__c> reviews = new List<Scorecard_Review__c>();
            for(Id key : scUserMap.keySet())
            {
                inMap = scUserMap.get(key);
                permission = permissionMap.get(inMap.Role__c);
                if(permission == null) continue;

                if(permission.Answer_Question__c || permission.Review_Question__c || permission.Review_Question_Final__c)
                {
                    for(Scorecard_Question__c question : questions)
                    {
                        if(question.Section__r.Scorecard__c == inMap.Scorecard__c)
                        {
							if(permission.Answer_Type__c != 'Answer')
							{
								review = new Scorecard_Review__c();
								review.Question__c = question.Id;
								review.Status__c = 'In Progress';
								review.Scorecard_User__c = inMap.Id;
								review.Type__c = permission.Answer_Type__c;

								reviews.add(review); 
							}
                        }
                    }
                }
            }

            if(reviews.size() > 0) insert reviews;
        }



    }

    //public static void sendJoinNotificationEmail(List<Scorecard_User__c> scUsers)
    //{
        //Set<Id> recordIds = new Set<Id>();

        //for(Scorecard_User__c item : scUsers){
            //recordIds.add(item.Id);
        //}

        //List<Scorecard_User__c> scoreUsers = [  SELECT Id, Role__c, User__c, CreatedBy.Name,
                                                    //Scorecard__r.Title__c, 
                                                    //Scorecard__r.Name, User__r.FirstName, User__r.LastName,
                                                    //User__r.Name, User__r.Email 
                                                //FROM Scorecard_User__c
                                                //WHERE Id IN :recordIds ];

        //List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        //Scorecard_Settings__c settings = Scorecard_Settings__c.getInstance();

        //EmailTemplate template = [  SELECT Id, HtmlValue, Subject  
                                    //FROM EmailTemplate 
                                    //WHERE DeveloperName = :settings.Team_Member_Notification_Template__c LIMIT 1 ];

        //for(Scorecard_User__c item : scoreUsers){

            //String[] toAddresses = new List<String>();
            //toAddresses.add(item.User__r.Email);

            //Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            //email.setToAddresses(toAddresses);

            //string html = template.HtmlValue;

            //if(!string.isBlank(item.Role__c))
                //html = html.replace('{!Scorecard_User__c.Role__c}', item.Role__c);
            //else
                //html = html.replace('{!Scorecard_User__c.Role__c}', '');

            //if(!string.isBlank(item.User__r.FirstName))
                //html = html.replace('{!User.FirstName}', item.User__r.FirstName);
            //else 
                //html = html.replace('{!User.FirstName}', '');

            //if(!string.isBlank(item.User__r.LastName))
                //html = html.replace('{!User.LastName}', item.User__r.LastName);
            //else 
                //html = html.replace('{!User.LastName}', '');

            //if(!string.isBlank(item.User__r.Name))
                //html = html.replace('{!User.Name}', item.User__r.Name);
            //else 
                //html = html.replace('{!User.Name}', '');

            //if(!string.isBlank(item.Scorecard__r.Title__c))
                //html = html.replace('{!Scorecard__c.Title__c}', item.Scorecard__r.Title__c);
            //else 
                //html = html.replace('{!Scorecard__c.Title__c}', '');

            //if(!string.isBlank(item.Scorecard__r.Name))
                //html = html.replace('{!Scorecard__c.Name}', item.Scorecard__r.Name);
            //else 
                //html = html.replace('{!Scorecard__c.Name}', '');

            //html = html.replace('{!Scorecard__c.Id}', item.Scorecard__r.Id);
            //html = html.replace('{!Scorecard__c.CreatedBy}', item.CreatedBy.Name);
            //html = html.replace('{!$Label.Instance_Url}', Label.Instance_Url);

            //email.setSubject(template.Subject);
            //email.setHtmlBody(html);
            //email.setSaveAsActivity(false);
            //email.setUseSignature(false);

            //emails.add(email);
        //}

        //try 
        //{
            //Messaging.sendEmail(emails);
        //}
        //catch(Exception e){
            //System.debug('**ERROR:' + e.getMessage());
        //}
    //}
}