({
    onUploadButtonClicked: function(component){
        var fileName = component.get("v.fileName");
        var fileSize = component.get("v.fileSize");
        var attachedToId = component.get("v.recordId");
        var action = component.get("c.getUploadData");
        action.setParams({fileName: fileName, attachedToId: attachedToId, redirectUrl: window.location.href, fileSize: fileSize });
		action.setCallback(this, function(actionResult) {
            if(actionResult.getState() === 'SUCCESS'){
                var data = JSON.parse(actionResult.getReturnValue());
                document.getElementById('s3form').action = data.actionUrl;
                document.getElementById("key").value = data.key;
                document.getElementById("acl").value = data.acl;
                document.getElementById("policy").value = data.policy;
                document.getElementById("awsaccesskeyid").value = data.accessKey;
                document.getElementById("signature").value = data.signature;
                document.getElementById("success_action_redirect").value = window.location.href;
                document.getElementById("x-amz-credential").value = data.credential;
                document.getElementById("x-amz-date").value = data.requestDate;
                document.getElementById("x-amz-signature").value = data.signature;
                document.getElementById("submitBtn").click();
            } else {
                alert("There was an error uploading the file. Please try again later..");
            }

            component.set("v.isLoading", false);
        });
        
        component.set("v.isLoading", true);
        $A.enqueueAction(action); 
    },

    onRecordIdReady: function(component){
        debugger
        var recordId = component.get("v.recordId");
        var recordType = component.get("v.recordType");
        var action = component.get("c.getAttachedFiles");
        action.setParams({ recordId: recordId, recordType: recordType });
		action.setCallback(this, function(actionResult) {
            debugger
            if(actionResult.getState() === 'SUCCESS'){
                var result = actionResult.getReturnValue();
                if(result !== ""){
                    var data = JSON.parse(result);
                    component.set("v.attachedFiles", data);
                    component.set("v.numberOfFiles", data.length);
                }
            } 
            component.set("v.isLoading", false);
        });
        
        component.set("v.isLoading", true);
        $A.enqueueAction(action); 
    },

    onFileChanged: function(component, event){
        var file = event.target;
        component.set("v.fileSize", file.files[0].size);
        component.set("v.fileName", file.files[0].name);
    },

    onFileDelete: function(component, event){
        var fileName = "";
        var data = component.get("v.attachedFiles");
        debugger;
        for(var i = 0; i < data.length; i++){
            var file = data[i];
            if(file.fileId === event.currentTarget.id){
                fileName = file.fileName;
                break;
            }
        }

        component.set("v.selectedFileName", fileName);
        component.set("v.selectedFileId", event.currentTarget.id);
        component.set("v.showDeleteModal", true);
    },

    onFileDeleteCancel: function(component){
        component.set("v.selectedFileId", "");
        component.set("v.showDeleteModal", false);
    },

    onFileDeleteConfirm: function(component){
        var fileId = component.get("v.selectedFileId");
        var recordType = component.get("v.recordType");

        var action = component.get("c.deleteFile");
        action.setParams({ recordId: fileId, recordType: recordType });
		action.setCallback(this, function(actionResult) {
            if(actionResult.getState() === 'SUCCESS'){
                var result = actionResult.getReturnValue();
                 if(result !== ""){
                    var data = JSON.parse(result);
                    component.set("v.attachedFiles", data);
                    component.set("v.numberOfFiles", data.length);
                }
            } 
            component.set("v.isLoading", false);
            component.set("v.showDeleteModal", false);
        });
        
        component.set("v.isLoading", true);
        $A.enqueueAction(action); 
    }
})