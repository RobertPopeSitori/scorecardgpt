({
    onInit : function(component, event, helper) {
        debugger
		component.set("v.showCommentModal", false);
		component.set("v.continue", false);
        var scorecardId = helper.getParameter("scorecard");
        if(scorecardId){
            component.set("v.scorecardId", scorecardId);
        } else {
            scorecardId = component.get("v.scorecardId");
        }

        var questionId = helper.getParameter("question");
        if(questionId){
            component.set("v.questionId", questionId);
        } else {
            questionId = component.get("v.questionId");
        }

        if(!scorecardId || !questionId) return;
        component.set("v.isLoading", true);

        helper.onInit(component);
        helper.getScorecardReview(component, event, helper);
         helper.getRole(component, event, helper);
        helper.getRevReview(component, event, helper);
        helper.getCompleteReview(component,event,helper);
       // helper.getAuthReview(component, event, helper); 
        helper.getSCname(component,event,helper); 
    },

    hideNotification: function(component, event){
        component.set("v.showNotification", false);

        var redirectUrl = component.get("v.redirectUrl");
        if(redirectUrl && redirectUrl.length > 0){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({ "url": redirectUrl });
            urlEvent.fire();
        }
    },

    onClearAnswer: function(component, event, helper){
        component.set("v.answer", "");
    },

    onSaveChanges: function(component, event, helper){
        helper.onSaveChanges(component);
    },

	onSaveContinue: function(component, event, helper){
		component.set("v.continue", true);
        helper.onSaveChanges(component);
    },

    onRubricViewClicked: function(component, event, helper){
        var showRubric = component.get("v.showRubric");
        if(showRubric) component.set("v.showRubric", false);
        else component.set("v.showRubric", true);
    },

    onMenuClicked: function(component, event, helper){
        var menu = component.find("questionMenu");
        $A.util.toggleClass(menu, "slds-is-open");
    },

    onScoreClicked: function(component, event, helper){
        debugger
        var whichRubric = event.currentTarget.id;
        component.set("v.selectedRubric", whichRubric);
    },
    
    onStatusChanged: function(component, event, helper){
        var status = document.getElementById("status").value;
        component.set("v.selectedStatus", status);
    },

	onNewCommentClicked: function(component, event, helper){
		component.set("v.showCommentModal", true);
	},

	onCancelComment: function(component, event, helper){
		component.set("v.comment", "");
		component.set("v.showCommentModal", false);
	},

	onSubmitComment: function(component, event, helper){
		var comment = component.get("v.comment");
		if(!comment || comment.trim() == ""){
			return;
		}

		component.set("v.showCommentModal", false);
		component.set("v.isLoading", true);

		helper.onCommentSave(component, comment);
	},
    onSaveChangesRev : function(component,event,helper) {
        debugger
        helper.onSaveChangesRev(component,event,helper);
    },
    onSaveContinueRev : function(component,event,helper) {
        component.set("v.continue", true);
        helper.onSaveChangesRev(component,event,helper);
    },
    openDropdown : function(component,event,helper) {
        debugger
        helper.getSections(component,event,helper);
        component.set("v.opendrop",true);
    },
    closeDropdown : function(component,event,helper) {
        component.set("v.opendrop",false);
        component.set("v.openQuestionDropdown",false);
    },
    openDropdownQuestion : function(component,event,helper) {
        helper.getQuestionList(component,event,helper);
        component.set("v.openQuestionDropdown",true);
    }
    
})