public without sharing class ScorecardSectionListController 
{
    @AuraEnabled
    public static string getSectionList(string scorecardId, string sectionId, string questionId)
    {
        AuraResponse response = new AuraResponse();

        ScorecardSectionListViewModel model = new ScorecardSectionListViewModel();
        if(string.isBlank(scorecardId) || !StringHelper.isValidSalesforceId(scorecardId, Scorecard__c.class)) {
            response.success = false;
            response.message = 'Missing or Invalid Scorecard Id parameter.';
            return JSON.serialize(response);
        } 

        if(!StringHelper.isValidSalesforceId(sectionId, Scorecard_Section__c.class)){
            sectionId = '';
        }

        ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);
        if(detail == null || detail.Scorecard == null) {
            response.success = false;
            response.message = 'Invalid Scorecard Id parameter.';
            return JSON.serialize(response);
        }

        Scorecard_Role__mdt permission = ScorecardUserHelper.getRolePermissions(scorecardId);

        List<Scorecard_User_Section__c> userSections = ScorecardUserHelper.getUserSections(scorecardId);
        Map<string, Scorecard_User_Section__c> userSectionsMap = new Map<string, Scorecard_User_Section__c>();
        for(Scorecard_User_Section__c userSection : userSections)
        {
            string keyName = string.valueOf(userSection.Scorecard_Section__c) + string.valueOf(userSection.Scorecard_User__r.User__c);
            Scorecard_User_Section__c record = userSectionsMap.get(keyName);
            if(record == null){
                userSectionsMap.put(keyName, userSection);
            }
        }

        model.scorecard = new ScorecardViewModel(detail.Scorecard);
        for(Scorecard_Section__c section : detail.Sections.values())
        {
            //uncomment this line to default to first section
            //if(string.isBlank(sectionId)) sectionId = section.Id;

            boolean selected = false;
            if(string.isNotBlank(sectionId)){
                selected = section.Id == Id.valueOf(sectionId);
            }
            
            List<Id> questionIds = new List<Id>();
            List<Scorecard_Question__c> questions = new List<Scorecard_Question__c>();
            for(Scorecard_Question__c question : detail.Questions.values())
            {
                if(question.Section__c == section.Id){
                    questions.add(question);
                    questionIds.add(question.Id);
                }
            }

            List<Scorecard_Review__c> reviews = new List<Scorecard_Review__c>();
            if(questionIds.size() > 0){
                reviews = ScorecardHelper.getAllReviews(questionIds);
            }

            string keyName = string.valueOf(section.Id) + string.valueOf(UserInfo.getUserId());
            Scorecard_User_Section__c userSection = userSectionsMap.get(keyName);

            ScorecardSectionViewModel sectionModel = new ScorecardSectionViewModel(section, questions, selected, permission, reviews);
            if(permission.View_All_Sections__c) {
                sectionModel.userCanAccessSection = true;
            } else {
                sectionModel.userCanAccessSection = (userSection == null ? false : userSection.Is_Allowed__c);
            }

            model.Sections.add(sectionModel);
        }

        response.success = true;
        response.model = model;

        return JSON.serialize(response);
    }

    public class ScorecardSectionListViewModel
    {
        public ScorecardSectionListViewModel(){
            scorecard = new ScorecardViewModel();
            sections = new List<ScorecardSectionViewModel>();
        }

        @AuraEnabled public ScorecardViewModel scorecard { get; set; }
        @AuraEnabled public List<ScorecardSectionViewModel> sections { get; set; }
    }
    @AuraEnabled
    public static Scorecard__c getscorecard(string scorecardId){
        return [select id,title__c from scorecard__c where id=:scorecardId];
    }
}