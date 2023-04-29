({
    onInit : function(component, event, helper) 
    
    {
        
        debugger
        console.log("teamNav.c.onInit");
     
        var scoreId = component.get("v.scorecardId");
        if(scoreId){
            helper.getTeamMembers(component, scoreId);
        }
        helper.getUserRole(component,event,helper);
        helper.getUserEmail(component,event,helper);
        helper.getInvitations(component, event, helper);
       
    },
    
    
    createInvitation : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CreateInvitationCmp",
            componentAttributes: {
                
            }
        });
        evt.fire();
    },
    removeMember : function(component,event,helper){
        helper.getscorecarduser(component,event,helper);
    },
    
    openInvitationDetail : function(component,event,helper){
        helper.getSections(component,event,helper);
        helper.getInvitationDetail(component, event, helper);
        component.set("v.isOpen",true);
    },
    closeModel : function(component,event,helper){
        component.set("v.isOpen",false);
    },
    cancelInvite : function(component,event,helper){
        component.set("v.cancelInvite",true);
    },
    AcceptInvite : function(component,event,helper){
        component.set("v.AcceptInvite",true);
    },
    DeclineInvite :  function(component,event,helper){
        component.set("v.DeclineInvite",true);
    },
    ResendInvite :function(component,event,helper){
        debugger
        var inviteIDx = component.get("v.InvitationDetail[0].Id");
        console.log(inviteIDx);
        var action = component.get("c.ResendInvitation");
        action.setParams({ 'InvitationId': inviteIDx });
        action.setCallback(this, function(actionResult) {
            debugger
            console.log(actionResult.getState());
            if(actionResult.getState() === 'SUCCESS'){
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Invitation Resent Successfully',
                    duration:' 6000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester',
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            component.set("v.isOpen",false);
            
        });
        $A.enqueueAction(action);
    },
    edit : function(component,event,helper) {
        component.set("v.editEmail",false);
       component.set("v.editButton",false); 
    },
    SaveResendInvite : function(component,event,helper){
        debugger
        var inviteIDx = component.get("v.InvitationDetail");
        var selectedSection = [];
         var checkvalue = component.find("checkSection");
          if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                selectedSection.push(checkvalue.get("v.text"));
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    selectedSection.push(checkvalue[i].get("v.text"));
                }
            }
        }
        console.log('selectedSection-' + selectedSection);
        console.log(inviteIDx);
        var action = component.get("c.SaveandResendInvitation");
        action.setParams({
            "Invitation": inviteIDx,
            "selectedSection" : selectedSection
        });
        action.setCallback(this, function(a) {
            debugger
            //alert('Return Value:'+a.getReturnValue());
            var state = a.getState();
            if (state === "SUCCESS"){
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Invitation Saved And Resent Successfully',
                    duration:' 6000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester',
                });
                toastEvent.fire();
                 $A.get('e.force:refreshView').fire();
            }
            component.set("v.isOpen",false);
        });
        $A.enqueueAction(action);
    },
    editclose : function(component,event,helper) {
        component.set("v.editButton" , true);
        component.set("v.editEmail",true);
    },
    Emailtest : function(component,event,helper) {
        var action = component.get("c.emailcodetest");
        action.setCallback(this, function(actionResult) {
            console.log(actionResult.getState());
            if(actionResult.getState() === 'SUCCESS'){
                debugger
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Invitation Resent Successfully',
                    duration:' 6000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester',
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            component.set("v.isOpen",false);
            
        });
        $A.enqueueAction(action);
    }
    
    
    
})