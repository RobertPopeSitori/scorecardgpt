({
	onInit : function(component, event, helper) {
		var scoreId = component.get("v.scorecardId");
		if(scoreId && scoreId != ''){
			console.log('c.onInit');
			helper.onInit(component);
		}
	}
})