({
	onInit: function(component){
		var parentId = component.get("v.parentId");

		var action = component.get("c.getComments");
        action.setParams({parentId: parentId });
		action.setCallback(this, function(actionResult) 
		{
			if(actionResult.getState() === 'SUCCESS')
			{                
				var rawData = actionResult.getReturnValue();
				var response = JSON.parse(rawData);
				if(response.success) {
					component.set("v.comments", response.model);
					component.set("v.numberOfComments", response.model.length);
				}
			}
        });
        
        $A.enqueueAction(action); 
	},

	onSaveComment: function (component, comment) {
		var action = component.get("c.saveComment");
		var parentId = component.get("v.parentId");
		var parentType = component.get("v.parentType");

		console.log('parentId:' + parentId);
		console.log('parentType:' + parentType);
		console.log('comment:' + comment);

        action.setParams({parentId: parentId, parentType: parentType, commentText: comment });
		action.setCallback(this, function(actionResult) 
		{
			component.set("v.isLoading", false);
			console.log(actionResult.getReturnValue());
			if(actionResult.getState() === 'SUCCESS')
			{                
				var rawData = actionResult.getReturnValue();
				var response = JSON.parse(rawData);

				if(response.success){
					component.set("v.comments", response.model);
					component.set("v.numberOfComments", response.model.length);
				}
			}
        });
        
        $A.enqueueAction(action); 
	}
})