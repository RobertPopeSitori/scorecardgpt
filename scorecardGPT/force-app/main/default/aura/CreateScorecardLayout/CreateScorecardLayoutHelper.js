({
	fetchingTemplate : function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        //alert(userId);
		var action = component.get('c.getTemplateName');
        console.log('Called Apex Class');
        action.setParams({  uId : userId  });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state\
            if(state == 'SUCCESS') {
                component.set('v.temp', a.getReturnValue());
                console.log(a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})