({
    closeModal:function(component,event,helper){  
        debugger
        component.set("v.modelboxes",false);
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
        
    },
    openModal: function(component,event,helper) {
        debugger
        component.set("v.modelboxes",true);
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
        
        
        
    },
    fetchingTemplate : function(component, event, helper) {
        debugger
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