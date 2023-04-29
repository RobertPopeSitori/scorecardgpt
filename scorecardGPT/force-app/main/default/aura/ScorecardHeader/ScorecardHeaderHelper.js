({
	onInit : function(component) 
	{
		console.log("h.onInit");
		var scoreId = component.get("v.scorecardId");
		var action = component.get("c.getScorecardSummary");
		action.setParams({scorecardId: scoreId });
		action.setCallback(this, function(actionResult) {
			console.log("h.callback");
			if(actionResult.getState() === 'SUCCESS'){

				console.log('MODEL:' + actionResult.getReturnValue());

				var response = JSON.parse(actionResult.getReturnValue());
				if(response.success){
					component.set("v.model", response.model);
					component.set("v.showSummary", true);
				}
			}
		});
        
		console.log("h.enqueue");
		$A.enqueueAction(action); 
	}
})