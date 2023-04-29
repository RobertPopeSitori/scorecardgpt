({
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