({
    myAction : function(component, event, helper) {
        var column = component.get("v.column");
        let imageType = column.ElixirSuite__IMG_Type_of_Upload__c;
        let uniqueName = column.ElixirSuite__IMG_Default_Button_Label__c;
        if(imageType.toUpperCase() == 'SINGLE'){
            component.set("v.multiple",false);
        }else{
            component.set("v.multiple",true);
        }
        component.set("v.uniqueName",uniqueName);
    },
    handleUploadFinished : function(component, event, helper) {
        let recentlyUploadedFileIds = [];
        let column = component.get("v.column");
        let fileName = '';
        fileName = column.ElixirSuite__IMG_File_Name__c;
        let alreadyUploadedFiles = component.get("v.uploadDocumentIds");
        let uploadedFiles = event.getParam("files");
        let isMultiple = component.get("v.multiple");
        let currentDate = (new Date()).toString();
        let index  = currentDate.indexOf('GMT')-1;
        let  dateAfter = currentDate.substr(0,index);
        for(var rec in uploadedFiles){
            recentlyUploadedFileIds.push(uploadedFiles[rec].documentId);
            let nameOfFile = fileName + '_' + component.get("v.patientName") + '_' +
                        dateAfter + (isMultiple?('_IMG'+ Math.floor(Math.random() * 10000 + 1)) :'');
            alreadyUploadedFiles.push({"Id":uploadedFiles[rec].documentId, "Name":nameOfFile, "Remove":false});
        }
        component.set("v.uploadDocumentIds",alreadyUploadedFiles);
        component.set("v.recentlyUploadedFileIds",recentlyUploadedFileIds);
        if(!isMultiple){
            helper.evaluateButtonStatus(component);
        }
        alert('File uploaded successfuly!');
    },
    openRemoveFile :function(component, event, helper){
        let isMultiple = component.get("v.multiple");
        let msg ='Are you sure you want to remove this file?';
        if (!confirm(msg)) {
            return false;
        }else {
            helper.removeFile(component, event);
            if(!isMultiple){
                helper.evaluateButtonStatus(component);
            }
        }
    },
    saveAndUpdateImages :function(component, event, helper){
      var cancel = event.getParam("cancel");
      if($A.util.isUndefinedOrNull(cancel) || cancel==false){
        helper.updateImages(component, event, helper);
      }else if(cancel){
        helper.deleteImages(component, event, helper);
      }
    }
})