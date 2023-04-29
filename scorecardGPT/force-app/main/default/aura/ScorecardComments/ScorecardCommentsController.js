({
	onInit: function (component, event, helper) {
		component.set("v.showNewModal", false);

		var parentId = component.get("v.parentId");
		
		if(!parentId || parentId.trim() == "") return;
		helper.onInit(component);
	},

	onNewButtonClicked: function(component, event, helper){
		component.set("v.showNewModal", true);
		setTimeout(function(){
			var editor = document.getElementById("commentField");
			editor.value = "";
			editor.focus();
		}, 200);
	},

	onCancelClicked: function(component, event, helper){
		component.set("v.showNewModal", false);
	},

	onSaveClicked: function(component, event, helper){
		var comment = document.getElementById("commentField");
		if(!comment || comment.value.trim() == ""){
			document.getElementById("commentField").focus();
			return;
		}

		component.set("v.showNewModal", false);
		component.set("v.isLoading", true);

		helper.onSaveComment(component, comment.value);
	}
})