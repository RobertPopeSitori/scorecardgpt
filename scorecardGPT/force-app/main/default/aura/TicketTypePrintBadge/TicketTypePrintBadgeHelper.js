({
	fetchData: function (cmp, event, helper) {
        debugger
        var action = cmp.get('c.returnTicketType'); 
        action.setParams({
            "EventId" : cmp.get('v.recordId') 
        });
        action.setCallback(this, function(a){
            debugger
            var state = a.getState(); // get the response state
            var result = a.getReturnValue();
            if(state == 'SUCCESS') {
                console.log(a.getReturnValue());
               // cmp.set('v.startdate',result[0].EventApi__Event__r.EventApi__Start_Date__c);
                //cmp.set('v.enddate',result[0].EventApi__Event__r.EventApi__End_Date__c);
                cmp.set('v.Tickettype', a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    getDates: function (cmp, event, helper) {
        debugger
        var action = cmp.get('c.getdatesfromattendee'); 
        action.setParams({
            "EventId" : cmp.get('v.recordId') 
        });
        action.setCallback(this, function(a){
            debugger
            var state = a.getState(); // get the response state
            var result = a.getReturnValue();
            if(state == 'SUCCESS') {
                console.log(result);
                //console.log(result.hasOwnProperty(key));
                //alert(result.startdate);
               cmp.set('v.startdate',result.startdate);
                cmp.set('v.enddate',result.enddate);
                
            }
        });
        $A.enqueueAction(action);
    }
})