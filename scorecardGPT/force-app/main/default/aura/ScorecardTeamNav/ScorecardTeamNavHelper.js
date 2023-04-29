({
    getTeamMembers : function(component, scorecardId){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.currentuserId",userId);
        console.log("teamNav.h.getTeamMembers");
        var action = component.get("c.getTeamMembers");
        action.setParams({ scorecardId: scorecardId });
        action.setCallback(this, function(actionResult) {
            console.log("teamNav.h.callback");
            console.log(actionResult.getReturnValue());
            if(actionResult.getState() === 'SUCCESS'){
                var response = JSON.parse(actionResult.getReturnValue());
                if(response.success){
                    component.set("v.members", response.model);
                    if(response.model.length > 0){
                        component.set("v.visible", true);
                    }
                }else{
                    this.onError(component, response.message);
                }
            } else {
                this.onError(component, "There was an error sending the request to the server.\r\nPlease try again later..");
            }
        });
        
        $A.enqueueAction(action); 
    },
    getscorecarduser : function(component,event,helper){
        var memberid = event.getSource().get("v.value");
        var scorecardId = component.get('v.scorecardId');
        var action = component.get("c.deleteScorecardUser");
        action.setParams({ 
            "scorecardId": scorecardId,
            "UserId": memberid
        });
        action.setCallback(this, function(actionResult) {
            if(actionResult.getState() === 'SUCCESS'){ 
                if(actionResult.getReturnValue()){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Scorecard user deactivated successfully',
                        duration:' 6000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester',
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Warning',
                        message: 'You can not deactivate the user. Scorecard should have atleast one Author Or Lead Reviewer',
                        duration:' 6000',
                        key: 'info_alt',
                        type: 'warning',
                        mode: 'pester',
                    });
                    toastEvent.fire();
                    //$A.get('e.force:refreshView').fire();
                }
            } 
        });
        
        $A.enqueueAction(action); 
    },
    getUserRole : function (component,event,helper){
        debugger
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var action = component.get("c.returnUserRole");
        action.setParams({
            "userId": userId,
            "scorecard_Id":component.get('v.scorecardId')
        });
        
        action.setCallback(this, function(a) {
            debugger
            //alert('Return Value:'+a.getReturnValue());
            var state = a.getState();
            if (state === "SUCCESS"){
                console.log(a.getReturnValue());
                component.set("v.Role",a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    getInvitations : function(component, event, helper) {
        
        var idParamValue = helper.getURLParameterValue().scorecard;
        var action = component.get("c.getInvitations");
        action.setParams({ scorecardId: idParamValue });
        action.setCallback(this, function(actionResult) {
            if(actionResult.getState() === 'SUCCESS'){
                component.set("v.Invitations",actionResult.getReturnValue());
            }
        });
        
        $A.enqueueAction(action); 
    },
    
    getURLParameterValue: function() {
        debugger
        var querystring = location.search.substr(1);
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });

        console.log('paramValue-' + paramValue);
        return paramValue;
    },
    getInvitationDetail : function(component, event, helper) {
        debugger
         var Invitationidx = event.target.id;
         var action = component.get("c.getInvitationDetail");
        action.setParams({ Invitationidx : Invitationidx });
        action.setCallback(this, function(actionResult) {
            debugger
            if(actionResult.getState() === 'SUCCESS'){
                component.set("v.InvitationDetail",actionResult.getReturnValue());
                console.log(actionResult.getReturnValue());
            }
        });
        
        $A.enqueueAction(action); 
    },
    getUserEmail : function(component, event, helper) {
        debugger
    var UserId = $A.get("$SObjectType.CurrentUser.Id");
         var action = component.get("c.getUserEmail");
        action.setParams({ UserId : UserId });
        action.setCallback(this, function(actionResult) {
            debugger
            if(actionResult.getState() === 'SUCCESS'){
                component.set("v.UserEmail",actionResult.getReturnValue());
                console.log(actionResult.getReturnValue());
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
            // console.log(component.get("v.ListSection"));
        });
        $A.enqueueAction(action);
   }
})