@IsTest
public class ScorecardViewModelsTest  
{
    static testmethod void willInitializeAuthor()
    {
        Test.startTest();
        
        ScorecardAnswerViewModel model = new ScorecardAnswerViewModel();
        model.contents = '';
        model.submittedBy = '';
        model.submittedDate = '';
        model.type = '';
        
        Id scorecardId = ScorecardHelperTest.insertScorecard('My Scorecard', null);
        
        ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);
        Scorecard_Question__c question;
        for(Id questionId : detail.Questions.keySet())
        {
            question = detail.Questions.get(questionId);
            break;
        }
        
        Scorecard_User__c scUser = new Scorecard_User__c();
        scUser.User__c = '0051U000006c4sR';//UserInfo.getUserId();
        scUser.Role__c = 'Author';
        scUser.Scorecard__c = scorecardId;
        insert scUser;
        
        List<Id> questionIds = new List<Id>();
        questionIds.add(question.Id);
        List<Scorecard_Review__c> reviews = ScorecardHelper.getAllReviews(questionIds);
        
        Scorecard_Role__mdt permission = ScorecardUserHelper.getRolePermissions(scorecardId);
        ScorecardQuestionViewModel qModel = new ScorecardQuestionViewModel(question, permission, reviews);
        
        ScorecardRubricViewModel rubModel = new ScorecardRubricViewModel();
        Scorecard_Rubric__c rub = new Scorecard_Rubric__c();
        rubModel = new ScorecardRubricViewModel(rub);
        
        List<Scorecard_Rubric__c> rubs = new List<Scorecard_Rubric__c>();
        rubs.add(rub);
        List<ScorecardRubricViewModel> rubModels = ScorecardRubricViewModel.listToView(rubs);
        
        ScorecardTeamModel tModel = new ScorecardTeamModel('teamId', 'teamName', 'teamRole');
        List<Scorecard_User__c> scUsers = new List<Scorecard_User__c>();
        scUsers.add(scUser);
        
        List<ScorecardTeamModel> tModels = ScorecardTeamModel.toList(scUsers);
        
        ScorecardSectionViewModel vModel = new ScorecardSectionViewModel();
        Scorecard_Section__c source = new Scorecard_Section__c();
        vModel = new ScorecardSectionViewModel(source);
        
        Test.stopTest();
    }
    
    static testmethod void willInitializeReviewer()
    {
        Test.startTest();
        
        ScorecardAnswerViewModel model = new ScorecardAnswerViewModel();
        model.contents = '';
        model.submittedBy = '';
        model.submittedDate = '';
        model.type = '';
        
        Id scorecardId = ScorecardHelperTest.insertScorecard('My Scorecard', null);
        
        ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);
        Scorecard_Question__c question;
        for(Id questionId : detail.Questions.keySet())
        {
            question = detail.Questions.get(questionId);
            break;
        }
        
        Scorecard_User__c scUser = new Scorecard_User__c();
        scUser.User__c = '0051U000006c4sR';//UserInfo.getUserId();
        scUser.Role__c = 'Reviewer';
        scUser.Scorecard__c = scorecardId;
        insert scUser;
        
        List<Id> questionIds = new List<Id>();
        questionIds.add(question.Id);
        List<Scorecard_Review__c> reviews = ScorecardHelper.getAllReviews(questionIds);
        
        Scorecard_Role__mdt permission = ScorecardUserHelper.getRolePermissions(scorecardId);
        ScorecardQuestionViewModel qModel = new ScorecardQuestionViewModel(question, permission, reviews);
        
        Test.stopTest();
    }
    
    static testmethod void willInitializeLeadReviewer()
    {
        Test.startTest();
        
        ScorecardAnswerViewModel model = new ScorecardAnswerViewModel();
        model.contents = '';
        model.submittedBy = '';
        model.submittedDate = '';
        model.type = '';
        
        Id scorecardId = ScorecardHelperTest.insertScorecard('My Scorecard', null);
        
        ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);
        Scorecard_Question__c question;
        for(Id questionId : detail.Questions.keySet())
        {
            question = detail.Questions.get(questionId);
            break;
        }
        
        Scorecard_User__c scUser = new Scorecard_User__c();
        scUser.User__c = '0051U000006c4sR';//UserInfo.getUserId();
        scUser.Role__c = 'Lead Reviewer';
        scUser.Scorecard__c = scorecardId;
        insert scUser;
        
        List<Id> questionIds = new List<Id>();
        questionIds.add(question.Id);
        List<Scorecard_Review__c> reviews = ScorecardHelper.getAllReviews(questionIds);
        
        Scorecard_Role__mdt permission = ScorecardUserHelper.getRolePermissions(scorecardId);
        ScorecardQuestionViewModel qModel = new ScorecardQuestionViewModel(question, permission, reviews);
        
        Test.stopTest();
    }
    
    static testmethod void willInitializeObserver()
    {
        Test.startTest();
        
        ScorecardAnswerViewModel model = new ScorecardAnswerViewModel();
        model.contents = '';
        model.submittedBy = '';
        model.submittedDate = '';
        model.type = '';
        
        Id scorecardId = ScorecardHelperTest.insertScorecard('My Scorecard', null);
        
        ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);
        Scorecard_Question__c question;
        for(Id questionId : detail.Questions.keySet())
        {
            question = detail.Questions.get(questionId);
            break;
        }
        
        Scorecard_User__c scUser = new Scorecard_User__c();
        scUser.User__c = '0051U000006c4sR';//UserInfo.getUserId();
        scUser.Role__c = 'Observer';
        scUser.Scorecard__c = scorecardId;
        insert scUser;
        
        List<Id> questionIds = new List<Id>();
        questionIds.add(question.Id);
        List<Scorecard_Review__c> reviews = ScorecardHelper.getAllReviews(questionIds);
        
        Scorecard_Role__mdt permission = ScorecardUserHelper.getRolePermissions(scorecardId);
        ScorecardQuestionViewModel qModel = new ScorecardQuestionViewModel(question, permission, reviews);
        Test.stopTest();
    }
    
    static testmethod void scorecardViewModelTest(){
        Account acc = new Account(Name='Test Account');
        insert acc;
        
        Scorecard_Template__c ScoreCardTemplate=new Scorecard_Template__c(Name='Template', Language__c='English');
        insert ScoreCardTemplate;
        
        Scorecard__c scorecard = new Scorecard__c(Title__c ='Scorecard',Organization__c =acc.id,Language__c='English',
                                                 Template__c =ScoreCardTemplate.id);
        insert scorecard;
        
        Scorecard_User__c scUser = new Scorecard_User__c();
        scUser.User__c = '0051U000006c4sR';
        scUser.Role__c = 'Author';
        scUser.Scorecard__c = scorecard.id;
        insert scUser;
        List<Scorecard_User__c> scorecarduser = new List<Scorecard_User__c>();
        scorecarduser.add(scUser);
        ScorecardViewModel scorecardView = new ScorecardViewModel();
        ScorecardViewModel scorecardView1 = new ScorecardViewModel(scorecard);
        ScorecardViewModel scorecardView2 = new ScorecardViewModel(scorecard,scorecarduser);
        //scorecardView.ScorecardViewModel(scorecard,scorecarduser);
    }
}