({
    onInit: function(component, event, helper){
        debugger
        var recordId = component.get("v.recordId");
        if(!recordId || recordId == null || recordId == undefined) return;

        helper.onRecordIdReady(component);
    },

    onFileChanged: function(component, event, helper){
        helper.onFileChanged(component, event);
    },

    onNewButtonClicked: function(component, event, helper){
        document.getElementById("file").value = "";
        component.set("v.showModal", true);
    },

    onCancelButtonClicked: function(component, event, helper){
        component.set("v.showModal", false);
    },

    onUploadButtonClicked: function(component, event, helper){
        var fileName = document.getElementById("file").value;

        if(!fileName || fileName == undefined || fileName == '')
            return;

        helper.onUploadButtonClicked(component);
    },

    onFileDelete: function(component, event, helper){
        helper.onFileDelete(component, event);
    },

    onFileDeleteCancel: function(component, event, helper){
        helper.onFileDeleteCancel(component);
    },

    onFileDeleteConfirm: function(component, event, helper){
        helper.onFileDeleteConfirm(component);
    }
})