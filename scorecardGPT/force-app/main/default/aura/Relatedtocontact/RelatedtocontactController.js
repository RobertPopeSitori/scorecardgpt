({
    init: function (cmp, event, helper) {
        cmp.set('v.columns', [
            {label: 'Contact Name', fieldName: 'contactname__c', type: 'text'},
            {label: 'Id', fieldName: 'ContactId', type: 'text'},
            {label: 'Role', fieldName: 'Roles', type: 'text'}
        ]);
        var action = cmp.get("c.getcontactrole");
        action.setParams({ recordId : cmp.get("v.recordId")});
 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
              cmp.set('v.data',response.getReturnValue());
           // alert(JSON.stringify(response.getReturnValue()))   ;          
            }
                      
        });
 
        $A.enqueueAction(action);
           }
   
})