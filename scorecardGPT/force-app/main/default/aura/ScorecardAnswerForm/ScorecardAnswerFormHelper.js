({
    onInit : function(component) {
        debugger
        var scorecardId = component.get("v.scorecardId");
        var questionId = component.get("v.questionId");
        
        
        var action = component.get("c.getQuestionDetailsForAnswer");
        action.setParams({scorecardId: scorecardId, questionId: questionId });
        action.setCallback(this, function(actionResult) {
            debugger
            if(actionResult.getState() === 'SUCCESS'){
                var rawData = actionResult.getReturnValue();
                //alert('Return Value: '+rawData);
                var response = JSON.parse(rawData);
                
                if(response.success){
                    component.set("v.isLoading", false);
                    component.set("v.model", response.model);
                    console.log(response.model);
                    
                    component.set("v.answer", response.model.review.htmlText);
                    component.set("v.reviewId", response.model.review.id);
                    component.set("v.selectedRubric", response.model.review.rubric.id);
                    component.set("v.selectedStatus", response.model.review.status);
                    component.set("v.sectionId", response.model.sectionId);
                    component.set("v.sectionName", response.model.sectionName);
                    document.getElementById("status").value = response.model.review.status;
                    
                    if(response.model.review.rubric.id)
                    {
                        //allow some time for the rubrics to bind..
                        setTimeout(function(){
                            document.getElementById(response.model.review.rubric.id).click();
                        }, 100);
                    }
                }
                else
                {
                    component.set("v.redirectUrl", response.url);
                    this.onError(component, response.message);
                }
            } 
            else 
            {
                component.set("v.isLoading", false);
                this.onError(component, "There was an error sending the request to the server.\r\nPlease try again later..");
            }
            
        });
        
        $A.enqueueAction(action); 
    },
    
    onSaveChanges: function(component){
        var model = component.get("v.model");
        model.review.htmlText = component.get("v.answer");
        model.review.rubric.id = component.get("v.selectedRubric");
        model.review.status = component.get("v.selectedStatus");
        
        component.set("v.isLoading", true);
        var action = component.get("c.submitAnswer");
        action.setParams({ modelJson: JSON.stringify(model) });
        action.setCallback(this, function(actionResult) {
            debugger
            if(actionResult.getState() === 'SUCCESS'){
                
                var rawData = actionResult.getReturnValue();
                var response = JSON.parse(rawData);
                
                if(response.success){
                    
                    var saveContinue = component.get("v.continue");
                    if(saveContinue){
                        window.location.href = response.url;
                        return;
                    }
                    
                    component.set("v.model", response.model);
                    if(response.model.review.rubric.id){
                        //allow some time for the rubrics to bind..
                        setTimeout(function(){
                            document.getElementById(response.model.review.rubric.id).click();
                        }, 100);
                    }
                    this.onPopMessage(component, "success", "Changes Saved", "The changes you submitted were successfully saved!");
                }else{
                    this.onError(component, response.message);
                }
            } else {
                this.onError(component, "There was an error sending the request to the server.\r\nPlease try again later..");
            }
        });
        
        $A.enqueueAction(action); 
    },
    
    onPopMessage: function(component, type, title, message){
        component.set("v.isLoading", false);
        component.set("v.notificationTitle", title);
        component.set("v.notificationType", type);
        component.set("v.notificationContent", message);
        component.set("v.showNotification", true);
    },
    
    onError: function(component, message){
        component.set("v.isLoading", false);
        this.onPopMessage(component, "error", "Error Encountered", message);
    },
    
    onCommentSave: function(component, comment){
        var model = new Object();
        model.reviewId = reviewId;
        model.comment = comment;
        
        var action = component.get("c.submitComment");
        action.setParams({ modelJson: JSON.stringify(model) });
        action.setCallback(this, function(actionResult) {
            
            component.set("v.isLoading", false);
            if(actionResult.getState() === 'SUCCESS'){
                
                var rawData = actionResult.getReturnValue();
                var response = JSON.parse(rawData);
                
                if(response.success){
                    component.set("v.model", response.model);
                    if(response.model.review.rubric.id){
                        //allow some time for the rubrics to bind..
                        setTimeout(function(){
                            document.getElementById(response.model.review.rubric.id).click();
                        }, 100);
                    }
                    this.onPopMessage(component, "success", "Changes Saved", "The changes you submitted were successfully saved!");
                }else{
                    this.onError(component, response.message);
                }
            } else {
                this.onError(component, "There was an error sending the request to the server.\r\nPlease try again later..");
            }
            
        });
        
        component.set("v.isLoading", true);
        $A.enqueueAction(action);
    },
    
    getParameter: function(paramName){
        var url = decodeURIComponent(window.location.search.substring(1));
        var keyPairs = url.split('&');
        var value = '';
        
        for (var i = 0; i < keyPairs.length; i++) {
            var keyPair = keyPairs[i].split('=');
            if (keyPair[0] === paramName) {
                value = keyPair[1] === undefined ? '' : keyPair[1];
                break;
            }
        }
        
        return value;
    },
    
    getScorecardReview: function(component, event, helper){
        var scorecardId = component.get("v.scorecardId");
        var questionId = component.get("v.questionId");
        //alert('ScorecardId: '+scorecardId);
        //alert('QuestionId: '+questionId);
        var action = component.get("c.getScoreReview");
        action.setParams({scorecardId: scorecardId, questionId: questionId });
        action.setCallback(this, function(actionResult) {
            
            if(actionResult.getState() === 'SUCCESS'){
                component.set('v.ScorecardReview',actionResult.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },
    getRole : function(component, event, helper) {
        debugger
    var userId = $A.get("$SObjectType.CurrentUser.Id");
    var action = component.get("c.getUserRole");
    action.setParams({
    userId: userId,
     });
    action.setCallback(this, function(actionResult) {
    debugger
    if(actionResult.getState() === 'SUCCESS'){
        console.log(actionResult.getReturnValue());
        component.set('v.Role',actionResult.getReturnValue());
    }
     });

    $A.enqueueAction(action);
    },
    onSaveChangesRev : function(component,event,helper) {
        debugger
        var model = component.get("v.model");
        var Role = component.get("v.Role");
        var reviewid = component.get("v.reviewId");
        var answer = component.get("v.answer");
        var rubric = component.get("v.selectedRubric");
        var status = component.get("v.selectedStatus");
        var questionId = component.get("v.questionId"); 
        component.set("v.isLoading", true);
        var action = component.get("c.submitRevAnswer");
        action.setParams({ 
            answer : answer,
            rubric : rubric,
            status : status,
            questionId : questionId,
            Role : Role,
            reviewid : reviewid
        });
       
        action.setCallback(this, function(actionResult) {
            	debugger
                console.log(actionResult.getReturnValue());
                
            if(actionResult.getState() === 'SUCCESS'){
                
                var rawData = actionResult.getReturnValue();
                this.onPopMessage(component, "success", "Changes Saved", "The changes you submitted were successfully saved!");
              /* var response = JSON.parse(rawData);
                
                if(response.success){
                    
                    var saveContinue = component.get("v.continue");
                    if(saveContinue){
                        window.location.href = response.url;
                        return;
                    }
                    
                    component.set("v.model", response.model);
                    if(response.model.review.rubric.id){
                        //allow some time for the rubrics to bind..
                        setTimeout(function(){
                            document.getElementById(response.model.review.rubric.id).click();
                        }, 100);
                    }
                    this.onPopMessage(component, "success", "Changes Saved", "The changes you submitted were successfully saved!");
                }else{
                    this.onError(component, response.message);
                }*/
            } else {
                this.onError(component, "There was an error sending the request to the server.\r\nPlease try again later..");
            }
        });
        
        $A.enqueueAction(action); 
    },
    getRevReview : function(component,event,helper) {
        debugger
    var questionId = component.get("v.questionId"); 
     var action = component.get("c.getRevAnswer");
        action.setParams({ 
            questionId : questionId
        });
       
        action.setCallback(this, function(actionResult) {
            	debugger
                var result = actionResult.getReturnValue();
                console.log(actionResult.getReturnValue());
                console.log(result[0].Review__c);
            if(actionResult.getState() === 'SUCCESS'){
                component.set("v.revAnswer",actionResult.getReturnValue());
            }
     });
        
        $A.enqueueAction(action); 
    },
    getAuthReview : function(component, event, helper) {
        debugger
    var questionId = component.get("v.questionId"); 
     var action = component.get("c.getAuthReview");
        action.setParams({ 
            questionId : questionId
        });
       
        action.setCallback(this, function(actionResult) {
            	debugger
                var result = actionResult.getReturnValue();
               // console.log(actionResult.getReturnValue());
                //console.log(result[0].Review__c);
            if(actionResult.getState() === 'SUCCESS'){
                component.set("v.AuthAnswer",actionResult.getReturnValue());
            }
     });
        
        $A.enqueueAction(action); 
    },
    getCompleteReview : function(component,event,helper) {
        debugger
        var questionId = component.get("v.questionId");
       // alert(questionId);
     var action = component.get("c.getCompleteReview");
        action.setParams({ 
            questionId : questionId
        });
       
        action.setCallback(this, function(actionResult) {
            	debugger
                var result = actionResult.getReturnValue();
            //alert(result);
               console.log("his is completed Questions Answer",result);
               // console.log(actionResult.getReturnValue());
                //console.log(result[0].Review__c);
            if(actionResult.getState() === 'SUCCESS'){
                component.set("v.CompleteAnswer",actionResult.getReturnValue());
            }
            
     });
        
        $A.enqueueAction(action); 
    },
     getSections : function(component,evevnt,helper) {
        debugger
		var scorecardId = component.get('v.scorecardId');
        var action = component.get("c.getSectionList");
        action.setParams({
            "scoreCardId":scorecardId
        });
         action.setCallback(this, function(result) {
             debugger
            var state = result.getState();
             console.log('List of Section'+result.getReturnValue());
            if (state === "SUCCESS"){
                var results = result.getReturnValue();    
                var plValues = [];    
                for (var i = 0; i < results.length; i++) {    
                    plValues.push({    
                        label: results[i].Title__c,    
                        value: results[i].Id    
                    });    
                }    
                component.set("v.ListSection" , results);
            }
             console.log(component.get("v.ListSection"));
        });
        $A.enqueueAction(action);
   },
    getSCname : function(component,event,helper){
        var scorecardId = component.get("v.scorecardId");
        var action = component.get("c.getscorecard");
        action.setParams({scorecardId: scorecardId});
        action.setCallback(this, function(actionResult) {
            debugger
            if(actionResult.getState() === 'SUCCESS'){
                
                component.set("v.scorecardName",actionResult.getReturnValue());
            } else {
                this.onError(component, "There was an error sending the request to the server.\r\nPlease try again later..");
            }
            
            
        });
        
        
        $A.enqueueAction(action); 
    },
     getQuestionList : function(component,event,helper){
        debugger
        var sectionId = component.get("v.sectionId");
        var action = component.get("c.QuestionList");
        action.setParams({sectionId: sectionId});
        action.setCallback(this, function(actionResult) {
            debugger
            var state = actionResult.getState();
            console.log('total Questions'+JSON.stringify(actionResult.getReturnValue()));
            if(actionResult.getState() === 'SUCCESS'){
                var results = actionResult.getReturnValue();    
                var plValues = [];    
                for (var i = 0; i < results.length; i++) {    
                    plValues.push({    
                        label: results[i].Title__c,    
                        value: results[i].Id    
                    });    
                }  
                component.set("v.QuestionList",results);
            } else {
                this.onError(component, "There was an error sending the request to the server.\r\nPlease try again later..");
            }
        });
        $A.enqueueAction(action); 
    }
})