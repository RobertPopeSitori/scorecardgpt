public without sharing class ScorecardHelper  
{
	@Future
    public static void evaluateStatus(Set<Id> scorecardIds, Set<Id> sectionIds, Set<Id> questionIds)
	{
		evaluateQuestionStatus(questionIds);
		evaluateSectionStatus(sectionIds);
		evaluateScorecardStatus(scorecardIds);		
	}

	public static void evaluateScorecardStatus(Set<Id> scorecardIds)
	{
		List<Scorecard__c> scorecards = [		SELECT Id, In_Progress_Sections__c, In_Review_Sections__c,
														Completed_Sections__c, Status__c, Number_Of_Sections__c
													FROM Scorecard__c
													WHERE Id IN :scorecardIds ];

		for(Scorecard__c scorecard : scorecards)
		{
			if(scorecard.In_Progress_Sections__c > 0)
			{
				scorecard.Status__c = 'In Progress';
				continue;
			}

			if(scorecard.In_Review_Sections__c > 0)
			{
				scorecard.Status__c = 'In Review';
				continue;
			}

			if(scorecard.Number_Of_Sections__c == scorecard.Completed_Sections__c)
			{
				scorecard.Status__c = 'Completed';
				continue;
			}
		}

		update scorecards;
	}

	public static void evaluateSectionStatus(Set<Id> sectionIds)
	{
		List<Scorecard_Section__c> sections = [		SELECT Id, In_Progress_Questions__c, In_Review_Questions__c,
														Completed_Questions__c, Status__c
													FROM Scorecard_Section__c
													WHERE Id IN :sectionIds ];

		for(Scorecard_Section__c section : sections)
		{
			if(section.In_Progress_Questions__c > 0)
			{
				section.Status__c = 'In Progress';
				continue;
			}

			if(section.In_Review_Questions__c > 0)
			{
				section.Status__c = 'In Review';
				continue;
			}

			section.Status__c = 'Completed';
		}

		update sections;
	}

	public static void evaluateQuestionStatus(Set<Id> questionIds)
	{
		List<Scorecard_Question__c> questions = [	SELECT Id, In_Progress_Answers__c, In_Review_Answers__c,
														In_Final_Review_Answers__c, Status__c
													FROM Scorecard_Question__c
													WHERE Id IN :questionIds ];

		for(Scorecard_Question__c question : questions)
		{
			if(question.In_Progress_Answers__c > 0)
			{
				question.Status__c = 'Draft';
				continue;
			}

			if(question.In_Review_Answers__c > 0)
			{
				question.Status__c = 'In Review';
				continue;
			}

			if(question.In_Final_Review_Answers__c > 0)
			{
				question.Status__c = 'In Final Review';
				continue;
			}

			question.Status__c = 'Completed';
		}

		update questions;
	}

	public static boolean checkReviewEditPermission(string questionStatus, string reviewStatus, 
        string scorecardId, Scorecard_Role__mdt permission){

        if(!permission.Answer_Question__c) return false;

        if(reviewStatus == 'In Review' || reviewStatus == 'For Final Review' || reviewStatus == 'In Final Review' || reviewStatus == 'Completed'){
            return false;
        }

        return true;
    }

    public static List<Scorecard_Review__c> getAllReviews(List<Id> questionIds)
    {
        List<Scorecard_Review__c> reviews = [   SELECT Id, Question__c, Review__c, Rubric__c, Status__c, Scorecard_User__r.User__c,
                                                    Scorecard_User__r.Role__c, LastModifiedDate, Scorecard_User__r.User__r.Name,
                                                    Question__r.Section__r.Scorecard__c, Rubric__r.Id, Rubric__r.Description__c,
                                                    Rubric__r.Recommendation__c, Rubric__r.Value__c, Type__c, Number_Of_Files__c,
                                                    Question__r.Status__c, LastModifiedBy.Name
                                                FROM Scorecard_Review__c
                                                WHERE (Question__c IN :questionIds) ];

        return reviews;
    }

	public static Scorecard_Review__c setQuestionAnswer(Id questionId)
	{
		Scorecard_Review__c review = new Scorecard_Review__c();
        review.Question__c = questionId;
        review.Status__c = 'In Progress';
        review.Type__c = 'Answer';
        insert review;

        return review;
	}

	public static boolean insertScorecardComment(Id parentId, string commentText, string parentType)
	{
		Scorecard_Comment__c com = new Scorecard_Comment__c();
		com.Comment__c = commentText;
		com.Parent_Id__c = parentId;
		com.Parent_Type__c = parentType;
		insert com;

		return true;
	}

    public static List<Scorecard_Comment__c> getReviewComments(id reviewId)
	{
		List<Scorecard_Comment__c> comments = [	SELECT Id, CreatedBy.Name, CreatedById, Parent_Id__c, Parent_Type__c, Comment__c, CreatedDate 
												FROM Scorecard_Comment__c 
												ORDER BY CreatedDate DESC ];

		return comments;
	}

	public static Scorecard_Review__c getQuestionAnswer(id questionId)
	{
		Scorecard_Review__c review = null;
        List<Scorecard_Review__c> reviews = [   SELECT Id, Question__c, Review__c, Rubric__c, Status__c, Scorecard_User__r.User__c,
                                                    Scorecard_User__r.Role__c, LastModifiedDate, Question__r.Section__r.Scorecard__c, 
                                                    Rubric__r.Id, Rubric__r.Description__c, Rubric__r.Recommendation__c, Rubric__r.Value__c, 
                                                    Question__r.Status__c, LastModifiedBy.Name, Number_Of_Files__c
                                                FROM Scorecard_Review__c
                                                WHERE (Question__c = :questionId) 
													AND (Type__c = 'Answer') ];

        return (reviews.size() == 0) ? null : reviews[0];
	}

    public static boolean isPermittedInSection(Id scorecardId, Id sectionId)
    {
        boolean permitted = false;

        List<Scorecard_User_Section__c> sections = ScorecardUserHelper.getUserSections(scorecardId);
        for(Scorecard_User_Section__c section : sections)
        {
            if(section.Scorecard_Section__c == sectionId){
                permitted = section.Is_Allowed__c;
                break;
            }
        }

        return permitted;
    }

    public static Scorecard_Question__c getQuestion(Id questionId)
    {
        if(string.isBlank(questionId)) return null;

        List<Scorecard_Question__c> questions = [   SELECT Id, Name, Max_Score__c, Order__c, 
                                                        Question__c, Description__c,
                                                        Section__c, Status__c, Template__c,
														Section__r.Id, Section__r.Title__c
                                                    FROM Scorecard_Question__c
                                                    WHERE Id = :questionId ];

        return (questions.size() == 0) ? null : questions[0];
        
    }

    public static List<Scorecard_User__c> getScorecardUsers(Id scorecardId)
    {
        List<Scorecard_User__c> scoreUsers = [  SELECT Id, Role__c, Scorecard__c, Scorecard__r.CreatedDate, 
                                                    Scorecard__r.Id, Scorecard__r.Name, Scorecard__r.Description__c, Scorecard__r.Intent__c,
                                                    Scorecard__r.Language__c, Scorecard__r.Legacy_Id__c, Scorecard__r.Organization__c,
                                                    Scorecard__r.Owner.Name, Scorecard__r.Organization__r.Name, Scorecard__r.Status__c, 
                                                    Scorecard__r.Template__c, Scorecard__r.Template__r.Name, Scorecard__r.Title__c, Scorecard__r.Type__c,
                                                    User__c, User__r.Name
                                                FROM Scorecard_User__c  
                                                WHERE Scorecard__c = :scorecardId ];

        return scoreUsers;
    }

    public static List<Scorecard_User__c> getScorecardUsers(List<Id> scorecardIds)
    {
        List<Scorecard_User__c> scoreUsers = [  SELECT Id, Role__c, Scorecard__c, Scorecard__r.CreatedDate, 
                                                    Scorecard__r.Id, Scorecard__r.Name, Scorecard__r.Description__c, Scorecard__r.Intent__c,
                                                    Scorecard__r.Language__c, Scorecard__r.Legacy_Id__c, Scorecard__r.Organization__c,
                                                    Scorecard__r.Owner.Name, Scorecard__r.Organization__r.Name, Scorecard__r.Status__c, 
                                                    Scorecard__r.Template__c, Scorecard__r.Template__r.Name, Scorecard__r.Title__c, Scorecard__r.Type__c,
                                                    User__c, User__r.Name
                                                FROM Scorecard_User__c  
                                                WHERE Scorecard__c IN :scorecardIds ];

        return scoreUsers;
    }

    public static List<Scorecard__c> getUserScorecards(Id userId)
    {
        List<Scorecard_User__c> scorecardAssignments = [    SELECT Id, Role__c, Scorecard__c, Scorecard__r.CreatedDate, 
                                                                Scorecard__r.Id, Scorecard__r.Name, Scorecard__r.Description__c, Scorecard__r.Intent__c,
                                                                Scorecard__r.Language__c, Scorecard__r.Legacy_Id__c, Scorecard__r.Organization__c,
                                                                Scorecard__r.Owner.Name, Scorecard__r.Organization__r.Name, Scorecard__r.Status__c, 
                                                                Scorecard__r.Template__c, Scorecard__r.Template__r.Name, Scorecard__r.Title__c, Scorecard__r.Type__c
                                                            FROM Scorecard_User__c 
                                                            WHERE (User__c = :userId) ];

        List<Scorecard__c> scorecards = new List<Scorecard__c>();
        if(scorecardAssignments.size() > 0)
        {
            Map<Id, Scorecard__c> scoreMap = new Map<Id, Scorecard__c>();
            for(Scorecard_User__c scoreUser : scorecardAssignments)
            {
                Scorecard__c scorecard = scoreMap.get(scoreUser.Scorecard__c);
                if(scorecard == null)
                {
                    scoreMap.put(scoreUser.Scorecard__c, scoreUser.Scorecard__r);
                }
            }

            scorecards = scoreMap.values();
        }

        return scorecards;
    }

    public static ScorecardDetail getScorecard(Id scorecardId)
    {
        ScorecardDetail detail = new ScorecardDetail();

        List<Scorecard__c> cards = [    SELECT Id, Name, Description__c, Intent__c, Language__c, Legacy_Id__c,
                                            Status__c, Template__c, Organization__c, QSRA_Benchmark_Date_Paid__c,
                                            Self_Assesable_Report__c, Self_Benchmark_Date_Paid__c, Type__c,
                                            Viewable_Report__c, Title__c, Owner.Name, CreatedDate, 
                                            Organization__r.Name
                                        FROM Scorecard__c 
                                        WHERE (Id = :scorecardId) ];

        if(cards.size() == 0) return detail;
        detail.Scorecard = cards[0];
		detail.Progress = 1;

		if(detail.Scorecard.Status__c == 'In Review') detail.Progress = 2;
		if(detail.Scorecard.Status__c == 'For Review') detail.Progress = 2;
		if(detail.Scorecard.Status__c == 'In Final Review') detail.Progress = 3;
		if(detail.Scorecard.Status__c == 'For Final Review') detail.Progress = 3;
		if(detail.Scorecard.Status__c == 'Completed') detail.Progress = 4;

        List<Scorecard_Section__c> sections = [ SELECT Id, Name, Description__c, Order__c, Scorecard__c, Template__c,
                                                        Title__c
                                                FROM Scorecard_Section__c 
                                                WHERE (Scorecard__c = : cards[0].Id) ];
        if(sections.size() == 0) return detail;
        List<Id> tempIds = new List<Id>();
        for(Scorecard_Section__c section : sections)
        {
            detail.Sections.put(section.Id, section);
            tempIds.add(section.Id);
        }

        List<Scorecard_Question__c> questions = [   SELECT Id, Name, Max_Score__c, Description__c, Status__c,
                                                        Order__c, Section__c, Template__c, Question__c,
														Section__r.Id, Section__r.Title__c
                                                    FROM Scorecard_Question__c
                                                    WHERE (Section__c IN :tempIds) 
													ORDER BY Order__c ASC ];
        if(questions.size() == 0) return detail;
        tempIds = new List<Id>();
        for(Scorecard_Question__c question : questions)
        {
            detail.Questions.put(question.Id, question);
            tempIds.add(question.Id);
        }

        List<Scorecard_Rubric__c> rubrics = [   SELECT Id, Name, Description__c, Recommendation__c, Value__c, 
                                                    Question__c, Template__c 
                                                FROM Scorecard_Rubric__c 
                                                WHERE (Question__c IN :tempIds)
												ORDER BY Value__c ASC ];

        if(rubrics.size() == 0) return detail;
        for(Scorecard_Rubric__c rubric : rubrics)
        {
            detail.Rubrics.put(rubric.Id, rubric);
        }

        return detail;
    }

    public static Map<Id, ScorecardTemplateDetail> getTemplates(List<Id> templateIds)
    {

        Map<Id, ScorecardTemplateDetail> detailsMap = new Map<Id, ScorecardTemplateDetail>();
        Map<Id, Scorecard_Template_Section__c> sectionsMap = new Map<Id, Scorecard_Template_Section__c>();
        Map<Id, Scorecard_Template_Question__c> questionsMap = new Map<Id, Scorecard_Template_Question__c>();

        List<Scorecard_Template__c> templates = [   SELECT Id, Name, Availability__c, Description__c, 
                                                        Language__c, Legacy_Id__c, Status__c, Type__c 
                                                    FROM Scorecard_Template__c 
                                                    WHERE (Id IN :templateIds) ];

        if(templates.size() == 0) return detailsMap;
        for(Scorecard_Template__c template : templates)
        {
            ScorecardTemplateDetail detail = new ScorecardTemplateDetail();
            detail.Template = template;

            detailsMap.put(template.Id, detail);
        }                                                   

        List<Scorecard_Template_Section__c> sections = [    SELECT Id, Name, Description__c, Order__c, Template__c, Title__c
                                                            FROM Scorecard_Template_Section__c 
                                                            WHERE (Template__c IN :templateIds)
                                                            ORDER BY Template__c, Order__c ];

        if(sections.size() == 0) return detailsMap;
        ScorecardTemplateDetail detail;
        List<Id> tempIds = new List<Id>();
        for(Scorecard_Template_Section__c section : sections)
        {
            detail = detailsMap.get(section.Template__c);
            detail.Sections.put(section.Id, section);
            sectionsMap.put(section.Id, section);

            tempIds.add(section.Id);
        }                                                           

        List<Scorecard_Template_Question__c> questions = [  SELECT Id, Name, Description__c, Max_Score__c, Order__c, Question__c,
                                                                Template_Section__c, Title__c
                                                            FROM Scorecard_Template_Question__c
                                                            WHERE (Template_Section__c IN :tempIds) 
                                                            ORDER BY Template_Section__c, Order__c ];

        Scorecard_Template_Section__c section;
        if(questions.size() == 0) return detailsMap;
        tempIds = new List<Id>();
        for(Scorecard_Template_Question__c question : questions)
        {
            section = sectionsMap.get(question.Template_Section__c);
            detail = detailsMap.get(section.Template__c);
            detail.Questions.put(question.Id, question);
            questionsMap.put(question.Id, question);

            tempIds.add(question.Id);
        }

        List<Scorecard_Template_Rubric__c> rubrics = [  SELECT Id, Name, Description__c, Recommendation__c, Value__c, Template_Question__c
                                                        FROM Scorecard_Template_Rubric__c
                                                        WHERE (Template_Question__c IN :tempIds)
                                                        ORDER BY Template_Question__c, Value__c ];

        Scorecard_Template_Question__c question;
        if(rubrics.size() == 0) return detailsMap;
        tempIds = new List<Id>();
        for(Scorecard_Template_Rubric__c rubric : rubrics)
        {
            question = questionsMap.get(rubric.Template_Question__c);
            section = sectionsMap.get(question.Template_Section__c);
            detail = detailsMap.get(section.Template__c);
            detail.Rubrics.put(rubric.Id, rubric);

            tempIds.add(question.Id);
        }

        return detailsMap;
    }

    public static List<Scorecard_Rubric__c> getRubricItems(Id questionId)
    {
        List<Scorecard_Rubric__c> rubrics = [   SELECT Id, Description__c, Question__c, Recommendation__c,
                                                    Template__c, Value__c
                                                FROM Scorecard_Rubric__c 
                                                WHERE Question__c = :questionId
												ORDER BY Value__c ASC ];
        return rubrics;
    }

    public class ScorecardTemplateDetail
    {
        public ScorecardTemplateDetail()
        {
            Template = new Scorecard_Template__c();
            Sections = new Map<Id, Scorecard_Template_Section__c>();
            Questions = new Map<Id, Scorecard_Template_Question__c>();
            Rubrics = new Map<Id, Scorecard_Template_Rubric__c>();
        }

        public Scorecard_Template__c Template { get; set; }
        public Map<Id, Scorecard_Template_Section__c> Sections { get; set; }
        public Map<Id, Scorecard_Template_Question__c> Questions { get; set; }
        public Map<Id, Scorecard_Template_Rubric__c> Rubrics { get; set; }
    }

    public class ScorecardDetail
    {
        public ScorecardDetail()
        {
            Sections = new Map<Id, Scorecard_Section__c>();
            Questions = new Map<Id, Scorecard_Question__c>();
            Rubrics = new Map<Id, Scorecard_Rubric__c>();
			Progress = 1;
        }

		public integer Progress { get; set; }
        public Scorecard__c Scorecard { get; set; }
        public Map<Id, Scorecard_Section__c> Sections { get; set; }
        public Map<Id, Scorecard_Question__c> Questions { get; set; }
        public Map<Id, Scorecard_Rubric__c> Rubrics { get; set; }
    }

}