({
    doInit : function(component,event,helper){
        debugger
        helper.getSections(component,event,helper);
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var action = component.get("c.returnUserRole");
        action.setParams({
            "userId": userId,
            "scorecard_Id":component.get('v.scorecardId')
        });
        
        action.setCallback(this, function(a) {
            //alert('Return Value:'+a.getReturnValue());
            var state = a.getState();
            if (state === "SUCCESS"){
                component.set("v.Role",a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    handleSuccess : function(component, event, helper) {
        debugger
        //alert('Select Option:'+component.get("v.selectedValue"));
        // var courseinfo = component.get("v.CourseOverviewAndInformation");
        component.find('notifLib').showToast({
            "variant": "success",
            "title": "Success!",
            "message": "Student record has been inserted successfully."
        });
        var action = component.get("c.updateScoreCard");
        //alert('getParam:'+event.getParam("id"));
        action.setParams({
            "invitId": event.getParam("id"),
            "scoreCardId":component.get('v.scorecardId'),
            "InviteRole":component.get("v.selectedValue")
        });
        var self = this;
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
                
                /*var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": event.getParam("id"),
                    "slideDevName": "detail"
                });
                navEvt.fire();*/
                $A.get('e.force:refreshView').fire(); 
            }
        });
        $A.enqueueAction(action);
        
    },
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    handleError: function (cmp, event, helper) {
        cmp.find('notifLib').showToast({
            "title": "Something has gone wrong!",
            "message": event.getParam("message"),
            "variant": "error"
        });
    },
    save : function(component, event, helper) {
        debugger
        var scorecardid = component.get('v.scorecardId');
        var selectedValue = component.get('v.selectedValue');
        var fname = component.get("v.firstname");
        var lname = component.get("v.lastname");
        var email = component.get("v.email");
        var selectedSection = [];
        var checkvalue = component.find("checkSection");
      //var checkvalue =  event.currentTarget.value;
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
     var action = component.get("c.insertinvite");
        
        action.setParams({
            "scorecardid": scorecardid,
            "fname":fname,
            "lname":lname,
            "email":email,
            "selectedValue":selectedValue,
            "selectedSection" : selectedSection
            
        });
        var self = this;
        action.setCallback(this, function(a) {
            debugger
            var state = a.getState();
            if (state === "SUCCESS"){
                alert('A Collaborator has been invited to this scorecard.');
                component.find('notifLib').showToast({
                    "variant": "success",
                    "title": "Success!",
                    "message": "A Collaborator has been invited to this scorecard."
                });
                $A.get('e.force:refreshView').fire();
            }else{
             cmp.find('notifLib').showToast({
            "title": "Something has gone wrong!",
            "message": event.getParam("message"),
            "variant": "error"
        });
            }
        });
        $A.enqueueAction(action);
    },
    handleChange : function (component, event, helper) {    
        //Get the Selected values       
        var selectedValues = event.getParam("value");    
        //Update the Selected Values      
        component.set("v.selectedVal", selectedValues);    
        }
    
})