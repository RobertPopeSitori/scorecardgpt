@IsTest
public class ScorecardAnswerControllerTest 
{
	/*static testmethod void willSubmitAnswer()
	{
		string modelJson = '{}';
		string response = ScorecardAnswerController.submitAnswer(modelJson);
		System.assert(String.isNotBlank(response));

		Id scorecardId = ScorecardHelperTest.insertScorecard('My Test Scorecard', null);
		ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);
		Id questionId = null;
		Scorecard_Question__c question;
		for(Id entryId : detail.Questions.keySet()){
			questionId = entryId;
			question = detail.Questions.get(entryId);
			break;
		}

		Scorecard_User__c scUser = new Scorecard_User__c();
		scUser.User__c = UserInfo.getUserId();
		scUser.Role__c = 'Author';
		scUser.Scorecard__c = scorecardId;
		insert scUser;

		Scorecard_Role__mdt permission = new Scorecard_Role__mdt();
		permission.Answer_Type__c = 'Answer';

		ScorecardQuestionViewModel model = new ScorecardQuestionViewModel();
		model.scorecardId = scorecardId;
		model.review = new ScorecardReviewViewModel(ScorecardHelper.getQuestionAnswer(questionId), permission);
		modelJson = JSON.serialize(model);
		response = ScorecardAnswerController.submitAnswer(modelJson);
	}

	static testmethod void willGetQuestionDetailsForAnswerObserver()
	{
		Test.startTest();

		Id scorecardId = ScorecardHelperTest.insertScorecard('My Test Scorecard', null);
		ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);
		Scorecard_Question__c question;
		Id questionId = null;
		for(Id entryId : detail.Questions.keySet()){
			questionId = entryId;
			question = detail.Questions.get(entryId);
			break;
		}

		string result = ScorecardAnswerController.getQuestionDetailsForAnswer(null, questionId);
		AuraResponse response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, null);
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer('fakeScorecardId', questionId);
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, 'fakeQuestionId');
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, questionId);
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		List<string> usedIds = new List<string>();
		usedIds.add(UserInfo.getUserId());

		Scorecard_User__c scUser = new Scorecard_User__c();
		scUser.User__c = UserInfo.getUserId();
		scUser.Role__c = 'Observer';
		scUser.Scorecard__c = scorecardId;
		insert scUser;

		result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, questionId);
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		Test.stopTest();
	}

	static testmethod void willGetQuestionDetailsForAnswerAuthor()
	{
		Test.startTest();

		Id scorecardId = ScorecardHelperTest.insertScorecard('My Test Scorecard', null);
		ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);
		Scorecard_Question__c question;
		Id questionId = null;
		for(Id entryId : detail.Questions.keySet()){
			questionId = entryId;
			question = detail.Questions.get(entryId);
			break;
		}

		string result = ScorecardAnswerController.getQuestionDetailsForAnswer(null, questionId);
		AuraResponse response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, null);
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer('fakeScorecardId', questionId);
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, 'fakeQuestionId');
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, questionId);
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		List<string> usedIds = new List<string>();
		usedIds.add(UserInfo.getUserId());

		Scorecard_User__c scUser = new Scorecard_User__c();
		scUser.User__c = UserInfo.getUserId();
		scUser.Role__c = 'Author';
		scUser.Scorecard__c = scorecardId;

		insert scUser;

		try{
			result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, questionId);
			response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		}catch(Exception e){}

		Test.stopTest();
	}

	static testmethod void willGetQuestionDetailsForAnswerCoAuthor()
	{
		Test.startTest();

		Id scorecardId = ScorecardHelperTest.insertScorecard('My Test Scorecard', null);
		ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);
		Scorecard_Question__c question;
		Id questionId = null;
		for(Id entryId : detail.Questions.keySet()){
			questionId = entryId;
			question = detail.Questions.get(entryId);
			break;
		}

		string result = ScorecardAnswerController.getQuestionDetailsForAnswer(null, questionId);
		AuraResponse response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, null);
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer('fakeScorecardId', questionId);
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, 'fakeQuestionId');
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, questionId);
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		List<string> usedIds = new List<string>();
		usedIds.add(UserInfo.getUserId());

		Scorecard_User__c scUser = new Scorecard_User__c();
		scUser.User__c = UserInfo.getUserId();
		scUser.Role__c = 'Co-Author';
		scUser.Scorecard__c = scorecardId;
		insert scUser;

		List<Scorecard_User_Section__c> permittedSections = [	SELECT Id, Is_Allowed__c, Scorecard_Section__c, Scorecard_User__r.User__c
																FROM Scorecard_User_Section__c
																WHERE Scorecard_User__r.User__c = :UserInfo.getUserId() ];

		for(Scorecard_User_Section__c section : permittedSections)
		{
			if(section.Scorecard_Section__c == question.Section__c)
			{
				section.Is_Allowed__c = false;
				break;
			}
		}

		update permittedSections;

		try{
			result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, questionId);
			response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		}catch(Exception e){}

		List<Scorecard_Review__c> reviews = [SELECT Id FROM Scorecard_Review__c WHERE Question__c = :questionId ];
		delete reviews;

		try{
			result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, questionId);
			response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		}catch(Exception e){}

		Test.stopTest();
	}

	static testmethod void willGetQuestionDetailsForAnswerAuthorInReview()
	{
		Test.startTest();

		Id scorecardId = ScorecardHelperTest.insertScorecard('My Test Scorecard', null);
		ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);
		Scorecard_Question__c question;
		Id questionId = null;
		for(Id entryId : detail.Questions.keySet()){
			questionId = entryId;
			question = detail.Questions.get(entryId);
			break;
		}

		string result = ScorecardAnswerController.getQuestionDetailsForAnswer(null, questionId);
		AuraResponse response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, null);
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer('fakeScorecardId', questionId);
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, 'fakeQuestionId');
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, questionId);
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		List<string> usedIds = new List<string>();
		usedIds.add(UserInfo.getUserId());

		Scorecard_User__c scUser = new Scorecard_User__c();
		scUser.User__c = UserInfo.getUserId();
		scUser.Role__c = 'Author';
		scUser.Scorecard__c = scorecardId;
		insert scUser;

		try{
			result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, questionId);
			response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		}catch(Exception e){}

		question.Status__c = 'In Review';
		update question;

		Scorecard_Review__c review = ScorecardHelper.getQuestionAnswer(question.Id);
		review.Status__c = 'Completed';
		update review;

		try{
			result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, questionId);
			response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		}catch(Exception e){}

		Test.stopTest();
	}

	static testmethod void willGetQuestionDetailsForAnswerLeadReviewerInReview()
	{
		Test.startTest();

		Id scorecardId = ScorecardHelperTest.insertScorecard('My Test Scorecard', null);
		ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);
		Scorecard_Question__c question;
		Id questionId = null;
		for(Id entryId : detail.Questions.keySet()){
			questionId = entryId;
			question = detail.Questions.get(entryId);
			break;
		}

		string result = ScorecardAnswerController.getQuestionDetailsForAnswer(null, questionId);
		AuraResponse response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, null);
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer('fakeScorecardId', questionId);
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, 'fakeQuestionId');
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, questionId);
		response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);

		List<string> usedIds = new List<string>();
		usedIds.add(UserInfo.getUserId());

		Scorecard_User__c scUser = new Scorecard_User__c();
		scUser.User__c = UserInfo.getUserId();
		scUser.Role__c = 'Lead Reviewer';
		scUser.Scorecard__c = scorecardId;
		insert scUser;

		question.Status__c = 'In Review';
		update question;

		try{
			result = ScorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, questionId);
			response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		}catch(Exception e){}

		Test.stopTest();
	}

	static testmethod void willReturnInvalidPermission()
	{
		string result = ScorecardAnswerController.invalidPermission();
		AuraResponse response = (AuraResponse)JSON.deserialize(result, AuraResponse.class);
		System.assert(response.success == false);
	} */
    static testmethod void test1(){
     Id scorecardId = ScorecardHelperTest.insertScorecard('My Test Scorecard', null);
		ScorecardHelper.ScorecardDetail detail = ScorecardHelper.getScorecard(scorecardId);
		Scorecard_Question__c question;
		Id questionId = null;
		for(Id entryId : detail.Questions.keySet()){
			questionId = entryId;
			question = detail.Questions.get(entryId);
			break;
		}
        Scorecard_Rubric__c rubric = new Scorecard_Rubric__c();
        rubric.Question__c = questionId;
        rubric.Description__c = 'test';
        rubric.Value__c = 0.0;
        
        Id sectionId;
        for(Id sId : detail.Sections.keySet()){
            sectionId = sId;
            break;
        }
        
        insert rubric;
        Scorecard_Review__c sr = new Scorecard_Review__c();
        sr.Question__c = questionId;
        sr.Review__c = 'test';
        sr.Status__c = 'Completed';
        sr.Type__c = 'Answer';
        insert sr;
        string uid = UserInfo.getUserId();
        test.startTest();
        ScorecardAnswerController.getScoreReview(scorecardId, questionId);
        ScorecardAnswerController.getCompleteReview(questionId);
        ScorecardAnswerController.getAuthAnswer(questionId);
        ScorecardAnswerController.getRevAnswer(questionId);
        ScorecardAnswerController.getSectionList(scoreCardId);
        ScorecardAnswerController.getNextUrl(scorecardId, questionId);
        ScorecardAnswerController.getSectionName(questionId);
        ScorecardAnswerController.getUserRole(uid);
        scorecardAnswerController.getQuestionDetailsForAnswer(scorecardId, questionId);
        scorecardAnswerController.invalidInputParameter();
        ScorecardAnswerController.invalidPermission();
        ScorecardAnswerController.submitRevAnswer('Answer', rubric.id, 'In Progress', questionId, 'Author', sr.id);
        ScorecardAnswerController.getscorecard(scorecardId);
        ScorecardAnswerController.QuestionList(sectionId);
        
         //   ScorecardAnswerController.getUserRole(usedIds[0]);
        test.stopTest();
	}
}