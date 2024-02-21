({
    removeFile :function(component, event){
        var fileId = event.getSource().get("v.name");
        let alreadyUploadedFiles = component.get("v.uploadDocumentIds");
        let idx = alreadyUploadedFiles.findIndex(obj => obj.Id === fileId);
        if(idx!=-1){
            alreadyUploadedFiles[idx]['Remove'] = true;
            component.set("v.uploadDocumentIds",alreadyUploadedFiles);
        }
    },
    updateImages :function(component, event, helper){
        var action = component.get("c.saveImages");
        action.setParams({ 
                        "formId" :event.getParam("formUniqueId"),
                        "patientName" :component.get("v.patientName"),
                        "uniqueName"  :component.get("v.uniqueName"),
                        "uploadDocumentIds"  :JSON.stringify(component.get("v.uploadDocumentIds"))});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
            }
            else{
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {                   
                }
            }
        });
        $A.enqueueAction(action);   
    },
    deleteImages :function(component, event, helper){
        var action = component.get("c.deleteFiles");
        action.setParams({ 
                        "documentIdsToDel"  :component.get("v.recentlyUploadedFileIds")
                    });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
            }
            else{
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {                   
                }
            }
        });
        $A.enqueueAction(action);   
    },
    evaluateButtonStatus :function(component){
        let alreadyUploadedFiles = component.get("v.uploadDocumentIds");
        let filesCount = 0;
        alreadyUploadedFiles.forEach(function(file){
            let removedFile = file.Remove;
            if(!removedFile){
                filesCount++;
            }
        });
        if(filesCount>=1){
            component.set("v.disabled",true);
        }else{
            component.set("v.disabled",false);
        }
    }
})