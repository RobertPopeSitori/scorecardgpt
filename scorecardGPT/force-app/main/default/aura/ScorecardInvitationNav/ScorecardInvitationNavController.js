({
    doInit : function(component, event, helper) {
        helper.getInvitations(component, event, helper);
        /*var scoreId = component.get("v.scorecardId");
        if(scoreId){
            helper.getInvitations(component, scoreId);
        }*/
    }
})