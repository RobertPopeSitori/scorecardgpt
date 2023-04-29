({
	doInit : function(component, event, helper) {
		
        component.set("v.msgInfo","Processing, Please Wait...");
        var action = component.get("c.cancelScoreCardUser");
        var recid = component.get('v.recordId');
        action.setParams({
          "invitId": component.get('v.recordId')
        });
        var self = this;
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS"){
            	 var infoLength = a.getReturnValue();
                if(infoLength.length == 15 || infoLength.length == 18){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Invitation has been Cacelled successfully."
                    });
                    toastEvent.fire();
                    
                var navURL="/scorecards/s/scorecard-section?scorecard="+a.getReturnValue(); 
               window.open(navURL,"_top");
                                
                }else{
                component.set("v.msgInfo",infoLength);
                   
                }
            }
        });
        $A.enqueueAction(action);
        
        
	}
})