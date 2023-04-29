({
    onPreview : function(component, event, helper) {

		debugger;
		var localId = event.getSource().get("v.value");
		var items = component.get("v.items");
		for(var i = 0; i < items.length; i++)
		{
			var item = items[i];
			if(item.id == localId)
			{
				component.set("v.previewHtml", item.htmlText);
				component.set("v.previewStatus", item.status);
				component.set("v.previewScore", item.rubric ? item.rubric.score : '');
                component.set("v.itemId",item.id);
				component.set("v.previewScoreName", item.rubric ? item.rubric.description : '');
				component.set("v.showPreviewModal", true);
			}
		}
    },

	onPreviewClosed: function(component, event, helper){
		component.set("v.showPreviewModal", false);
	}
})