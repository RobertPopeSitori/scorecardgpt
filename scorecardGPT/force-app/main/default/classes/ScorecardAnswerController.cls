public without sharing class ScorecardAnswerController 
{
    @AuraEnabled
    public static string submitAnswer(string modelJson)
    {
        ScorecardQuestionViewModel model = (ScorecardQuestionViewModel)JSON.deserialize(modelJson, ScorecardQuestionViewModel.class);
        if(model == null) return invalidInputParameter();
        
        Scorecard_Role__mdt permission = ScorecardUserHelper.getRolePermissions(model.scorecardId);
        if(!permission.Answer_Question__c) return invalidInputParameter();
        
        Scorecard_Review__c review = model.review.toReviewObject();
        update review;
        
        modelJson = getQuestionDetailsForAnswer(model.scorecardId, model.id);
        return modelJson;
    }
    
    @AuraEnabled
    public static string submitComment(string answerId, string commentHtml)
    {
        if(String.isNotBlank(commentHtml)){
            ScorecardHelper.insertScorecardComment(answerId, commentHtml, 'Answer');
        }
        
        List<Scorecard_Comment__c> comments = ScorecardHelper.getReviewComments(answerId);
        List<ScorecardCommentViewModel> model = ScorecardCommentViewModel.toList(comments);
        
        return JSON.serialize(model);
}
    
    @AuraEnabled
    public static string getQuestionDetailsForAnswer(string scorecardId, string questionId)
    {
        AuraResponse response = new AuraResponse();
        
        try 
        {
            if(string.isBlank(scorecardId) || string.isBlank(questionId))
                return invalidInputParameter();
            
            if(!StringHelper.isValidSalesforceId(scorecardId, Scorecard__c.class))
                return invalidInputParameter();
            
            if(!StringHelper.isValidSalesforceId(questionId, Scorecard_Question__c.class))
                return invalidInputParameter();
            
            Scorecard_Role__mdt permission = ScorecardUserHelper.getRolePermissions(scorecardId);
            //if(!permission.Answer_Question__c) return invalidInputParameter();
            
            Scorecard_Question__c question = ScorecardHelper.getQuestion(questionId);
            //if(question == null) return invalidInputParameter();
            
            if(!permission.View_All_Sections__c) {
                if(!ScorecardHelper.isPermittedInSection(scorecardId, question.Section__c))
                    return invalidPermission();
            }
            
            ScorecardQuestionViewModel model = new ScorecardQuestionViewModel();
            model.id = question.Id;
            model.description = question.Description__c;
            model.question = question.Question__c;
            model.order = integer.valueOf(question.Order__c);
            model.scorecardId = scorecardId;
            model.sectionId = question.Section__c;
            model.sectionName = question.Section__r.Title__c;
            
            Scorecard_Review__c review = ScorecardHelper.getQuestionAnswer(question.Id);
            List<Scorecard_Comment__c> coms = new List<Scorecard_Comment__c>();
            
            if(review == null) {
                review = ScorecardHelper.setQuestionAnswer(question.Id);
            } 
            
            model.review = new ScorecardReviewViewModel(review, permission);
            
            coms = ScorecardHelper.getReviewComments(review.Id);
            if(coms.size() > 0) model.review.comments = ScorecardCommentViewModel.toList(coms);
            
            List<Scorecard_Rubric__c> rubrics = ScorecardHelper.getRubricItems(question.Id);
            model.rubrics = ScorecardRubricViewModel.listToView(rubrics);
            
            model.userCanAnswer = permission.Answer_Question__c;
            if(model.userCanAnswer){
                if(question.Status__c == 'In Review' || question.Status__c == 'For Final Review' || question.Status__c == 'In Final Review' || question.Status__c == 'Completed'){
                    model.userCanAnswer = false;
                } 
                
                if(review.Status__c == 'Completed' || review.Status__c == 'In Review')
                {
                    model.userCanAnswer = false;
                    
                    response.success = false;
                    response.model = model;
                    response.message = 'The answer is already in ' + review.Status__c + ' status. You can no longer add files or edit your answer at this point.';
                    response.url = '/scorecard-section?scorecard=' + model.scorecardId + '&section=' + question.Section__c;
                    
                    return JSON.serialize(response);
                }
            }
            
            model.userCanFinalReview = permission.Review_Question_Final__c;
            if(model.userCanFinalReview){
                if(question.Status__c == 'Draft' || question.Status__c == 'For Review' || question.Status__c == 'In Review' || question.Status__c == 'Completed'){
                    model.userCanFinalReview = false;
                } 
            }
            
            model.userCanReview = permission.Review_Question__c;
            if(model.userCanReview){
                if(question.Status__c == 'Draft' || question.Status__c == 'In Final Review' || question.Status__c == 'Completed'){
                    model.userCanReview = false;
                } 
            }
            
            response.url = getNextUrl(scorecardId, questionId);
            response.success = true;
            response.model = model;
        } 
        catch (Exception ex) 
        {
            system.debug('**ERROR:' + ex.getMessage());
            response.success = false;
            response.message = 'Invalid or missing input parameter. \r\nPlease check in with your administrator.';
        }
        
        return JSON.serialize(response);
    }
    
    @AuraEnabled
    public static string invalidInputParameter()
    {
        AuraResponse response = new AuraResponse();
        response.success = false;
        response.message = 'Invalid or missing input parameter. \r\nPlease check in with your administrator.';
        return JSON.serialize(response);
    }
    
    @AuraEnabled
    public static string invalidPermission()
    {
        AuraResponse response = new AuraResponse();
        response.success = false;
        response.message = 'You are not allowed to provide an answer to this question. \r\nPlease check in with your administrator.';
        return JSON.serialize(response);
    }
    
    public static string getNextUrl(string scorecardId, string questionId)
    {
        ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);
        
        boolean getKey = false;
        Id firstKey = null;
        Id nextKey = null;
        for(Id sId : detail.Sections.keySet())
        {
            if(nextKey != null) break;
            
            Scorecard_Section__c section = detail.Sections.get(sId);
            for(Id qId : detail.Questions.keySet())
            {
                Scorecard_Question__c question = detail.Questions.get(qId);
                if(question.Section__c == sId)
                {
                    if(firstKey == null) firstKey = qId;
                    if(getKey){ getKey = false; nextKey = qId; }
                    if(qId == Id.valueOf(questionId)){ getKey = true; }
                    if(nextkey != null) break;
                }
            }
            
        }
        
        if(nextKey == null) nextKey = firstKey;
        if(nextKey == null) nextKey = questionId;
        
        return 'scorecard-answer-form?question=' + nextKey + '&scorecard=' + scorecardId;
}
    
    @AuraEnabled
    public static List<Scorecard_Review__c> getScoreReview(string scorecardId, string questionId){//
        return [SELECT Id,Scorecard_User__r.Role__c, Question__c,Review__c   
                FROM Scorecard_Review__c
                WHERE Question__c=:questionId];
    }

    @AuraEnabled
    public static String getUserRole(string userId) {
        string role = '';
        user ur = new user();
        ur = [select id from user where id=:userId];
        for(scorecard_user__c Suser : [select id,role__c,User__c from scorecard_User__c where user__c =: UserId]){
            if(Suser.User__c == ur.Id){
                role = Suser.Role__c;
            }
        }
        return role;
    }
    @AuraEnabled
    public static String submitRevAnswer(string answer,string rubric, string status, string questionId, string Role, string reviewid) {
        string Massage = 'Success';
        string Reviewtype = 'Answer';
        List<Scorecard_Review__c> SRRList = new List<Scorecard_Review__c>();
        if(answer != null && answer != '' && questionId != null && questionId != '') {
        Scorecard_Review__c SRR = new Scorecard_Review__c();
            SRR.Id = reviewid;
        SRR.Review__c = answer;
        SRR.Status__c = status;
        SRR.Rubric__c = rubric;
       // SRR.Question__c = questionId;
        SRR.Type__c = Reviewtype;
        SRR.Role__c = Role;    
        SRRList.add(SRR);
        }
        update SRRList;
        return Massage;
       
    }
     @AuraEnabled
    public static List<Scorecard_Review__c> getRevAnswer(string questionId) {
        List<Scorecard_Review__c> ScReview = new List<Scorecard_Review__c>();
        ScReview = [select id,review__c from Scorecard_Review__c where Question__c =: questionId AND Role__c = 'Reviewer'];
        return ScReview;
        
        
    }
     @AuraEnabled
    public static List<Scorecard_Review__c> getAuthAnswer(string questionId) {
        List<Scorecard_Review__c> ScAuthReview = new List<Scorecard_Review__c>();
        ScAuthReview = [select review__c from Scorecard_Review__c where Question__c =: questionId AND Scorecard_User__r.Role__c = 'Author' limit 1];
        return ScAuthReview;
        
        
    }
    
        @AuraEnabled
    public static List<Scorecard_Review__c> getCompleteReview(string questionId) {
        
        List<Scorecard_Review__c> SccompleteReview = new List<Scorecard_Review__c>();
        SccompleteReview.clear();
        SccompleteReview = [select review__c,status__c,Question__r.Question__c,Question__r.title__c from Scorecard_Review__c where Question__c =: questionId AND status__c = 'Completed' limit 1];
        
        return SccompleteReview;
       
        
    }
      @AuraEnabled
    public static Scorecard_Question__c getSectionName(string questionId) {
        
        Scorecard_Question__c ScQuestion = new Scorecard_Question__c();
        ScQuestion.clear();
        ScQuestion = [select Section_Name__c from Scorecard_Question__c where id =: questionId];
        
        return ScQuestion;
       
        
    }  
     @AuraEnabled
    public static List<Scorecard_Section__c>  getSectionList(String scoreCardId) {
        List<Scorecard_Section__c> Section = [select id,title__c from Scorecard_Section__c where Scorecard__c =: scoreCardId];
        system.debug('Sections are'+Section);
        return Section;
    }
    @AuraEnabled
    public static Scorecard__c getscorecard(string scorecardId){
        return [select id,title__c from scorecard__c where id=:scorecardId];
    }
    @AuraEnabled
    public static List<Scorecard_Question__c> QuestionList(string sectionId){
        return [select id,Title__c,Description__c,Question__c from Scorecard_question__c where Section__c=:sectionId];
    }
}