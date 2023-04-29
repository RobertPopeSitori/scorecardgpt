public class ScorecardTriggerHandler  implements ITriggerHandler
{
    public static Boolean TriggerDisabled = false;
    private static final ScorecardTriggerHandler handler = new ScorecardTriggerHandler();
    public static ScorecardTriggerHandler getInstance(){ return handler; }
 

    public Boolean IsDisabled()
    {
        List<Trigger_Setup__mdt> setup = [SELECT Enabled__c FROM Trigger_Setup__mdt WHERE MasterLabel = 'Scorecards' ];
        if(setup.size() > 0 && !setup[0].Enabled__c)
            return true;
        else
            return TriggerDisabled;
    }

    public void BeforeInsert(List<SObject> newItems) { }

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { }

    public void BeforeDelete(Map<Id, SObject> oldItems) { }

    public void AfterInsert(Map<Id, SObject> newItems) 
    { 

        List<SObject> cards = newItems.values();
        if(cards.isEmpty()) return;

        List<Id> templateIds = new List<Id>();
        for(SObject card : cards)
        {
            Scorecard__c scorecard = (Scorecard__c)card;

            if(string.isBlank(scorecard.Template__c)) continue;
            templateIds.add(scorecard.Template__c);
        }

        Map<Id, ScorecardHelper.ScorecardTemplateDetail> templates = ScorecardHelper.getTemplates(templateIds);
        Map<Id, Scorecard__c> scorecardMaps = new Map<Id, Scorecard__c>();
        List<Scorecard_Section__c> sections = new List<Scorecard_Section__c>();

        for(SObject card : cards)
        {
            Scorecard__c scorecard = (Scorecard__c)card;
            scorecardMaps.put(scorecard.Id, scorecard);

            if(string.isBlank(scorecard.Template__c)) continue;

            ScorecardHelper.ScorecardTemplateDetail template = templates.get(scorecard.Template__c);
            if(template != null)
            {
                for(Scorecard_Template_Section__c item : template.Sections.values())
                {
                    Scorecard_Section__c section = new Scorecard_Section__c();
                    section.Scorecard__c = scorecard.Id;
                    section.Description__c = item.Description__c;
                    section.Order__c = item.Order__c;
                    section.Template__c = item.Id;
                    section.Title__c = item.Title__c;

                    sections.add(section);
                }
            }
        }

        if(sections.size() > 0)
        {
            insert sections;

            Scorecard__c scorecard; 
            ScorecardHelper.ScorecardTemplateDetail template;
            Map<Id, Scorecard_Section__c> sectionsMap = new Map<Id, Scorecard_Section__c>();
            List<Scorecard_Question__c> questions = new List<Scorecard_Question__c>();
            for(Scorecard_Section__c section : sections)
            {
                sectionsMap.put(section.Id, section);

                scorecard = scorecardMaps.get(section.Scorecard__c);
                template = templates.get(scorecard.Template__c);

                for(Scorecard_Template_Question__c item : template.Questions.values())
                {
                    if(item.Template_Section__c.equals(section.Template__c))
                    {
                        Scorecard_Question__c question = new Scorecard_Question__c();
                        question.Section__c = section.Id;
                        question.Description__c = item.Description__c;
                        question.Max_Score__c = item.Max_Score__c;
                        question.Order__c = item.Order__c;
                        question.Question__c = item.Question__c;
                        question.Status__c = 'Draft';
                        question.Template__c = item.Id;
						question.Title__c = item.Title__c;

                        questions.add(question);
                    }
                 }
            }

            if(questions.size() > 0)
            {
                insert questions;

                Scorecard_Section__c section;
                Map<Id, Scorecard_Question__c> questionsMap = new Map<Id, Scorecard_Question__c>();
                List<Scorecard_Rubric__c> rubrics = new List<Scorecard_Rubric__c>();
                for(Scorecard_Question__c question : questions)
                {
                    questionsMap.put(question.Id, question);

                    section = sectionsMap.get(question.Section__c);
                    scorecard = scorecardMaps.get(section.Scorecard__c);
                    template = templates.get(scorecard.Template__c);
                    for(Scorecard_Template_Rubric__c item : template.Rubrics.values())
                    {
                        if(item.Template_Question__c.equals(question.Template__c))
                        {
                            Scorecard_Rubric__c rubric = new Scorecard_Rubric__c();
                            rubric.Question__c = question.Id;
                            rubric.Description__c = item.Description__c;
                            rubric.Recommendation__c = item.Recommendation__c;
                            rubric.Value__c = item.Value__c;
                            rubric.Template__c = item.Id;

                            rubrics.add(rubric);
                        }

                    }
                }

                if(rubrics.size() > 0){
                    insert rubrics;
                }
            }
        }
    }

    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        //System.debug('Test debug log');
    }

    public void AfterDelete(Map<Id, SObject> oldItems) {}

    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}