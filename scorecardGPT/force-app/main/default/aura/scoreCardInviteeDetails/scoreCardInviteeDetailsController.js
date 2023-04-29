({
    doInit : function(component, event, helper){
        helper.getInvitation(component,event,helper);
    },
    changeInviteeStatus : function(component, event, helper) {
        //debugger
        component.set("v.isLoading", true);
        let action = component.get("c.inviteeStatusChange");
        var id_str = helper.getURLParameterValue().id;
        //var id_str = 'a3q530000005fMc';
        console.log('$$$$'+id_str);
        action.setParams({ 'inviteesId' : id_str });
        action.setCallback(this, function(response) {
            //debugger
            let state = response.getState();
            var scorecard = component.get('v.ScorecardID');
            console.log('SCORECARD : '+scorecard);
            console.log('RESPONSE'+response.getReturnValue());
            console.log('STATE : '+state);
            if (state === "SUCCESS") {
                if(response.getReturnValue() == null){
                      alert('You have already accepted the invitation');
                    $A.get('e.force:refreshView').fire();
                    component.set("v.isLoading", false);
                }else if(response.getReturnValue() == 'Invite Accepted'){
                    alert("Thank you for accepting the invitation");
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/OLC/s/scorecard-section?scorecard="+scorecard
                    });
                    urlEvent.fire();
                    component.set("v.isLoading", false);
                } else if(response.getReturnValue() == 'User Already Exist') {
                    alert("User Already Exist");
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/OLC/s/scorecard-section?scorecard="+scorecardId
                    });
                    urlEvent.fire();
                  component.set("v.isLoading", false);
                }
             } else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE");
            }
                else if (state === "ERROR") {
                    console.log('Err@@');
                    var errors = response.getError();
                    if (errors) {
                        console.log('Err@@1'+errors);
                       // if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        //}
                    }
                }
              else {
                alert("You Are Already a Member");
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);	
    },
    declineInviteeStatus : function(component, event, helper) {
        //debugger
        component.set("v.isLoading", true);
        let action = component.get("c.DeclineInvitee");
        var id_str = helper.getURLParameterValue().id;
        action.setParams({ 'inviteesId' : id_str });
        action.setCallback(this, function(response) {
            //debugger
            let state = response.getState();
            console.log(response.getReturnValue());
            if (state === "SUCCESS") {
                if(response.getReturnValue() == null){
                    alert('You have already accepted the invitation');
                    $A.get('e.force:refreshView').fire();
                    component.set("v.isLoading", false);
                }else {
                    alert("Invitation Declined Successfully");
                  //  $A.get('e.force:refreshView').fire();
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/OLC/s/"
                    });
                    urlEvent.fire();
                    component.set("v.isLoading", false);
                } 
            }else {
                alert("You cannot Accept with Another User");
                $A.get('e.force:refreshView').fire();
                 
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);	
    }
})