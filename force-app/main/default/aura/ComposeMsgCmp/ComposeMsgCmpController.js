({
    doInit : function(component, event, helper) {
        component.set("v.showModal",true);
        var patientId = component.get("v.patientID");
        console.log(patientId+' patientId mahi');
    },
    handlePHICheck : function(component, event, helper) {
    	component.set("v.PHIcheckbox", event.getSource().get('v.checked'));
    },
    sendMessage : function(component, event, helper) {
        console.log(component.get("v.patientID")+' accId');
        var subject = component.find("mySubject").get("v.value");
        var message = component.find("myMessage").get("v.value");
        var fileMsg = component.get("v.fileMessageLst");
        var base64 = component.get("v.base64Lst");
        var myCheckbox = component.get("v.PHIcheckbox");
        console.log(fileMsg+' fileMsg '+base64+' base64');
        console.log("CheckBOX " + myCheckbox);
        
        if(($A.util.isUndefinedOrNull(subject) || $A.util.isEmpty(subject)) && ($A.util.isUndefinedOrNull(message) || $A.util.isEmpty(message))){
            helper.showToast(component, "Error", "You can not send an empty message!", "error");
            return;
        }
         if($A.util.isUndefinedOrNull(subject) || $A.util.isEmpty(subject)){
            helper.showToast(component, "Error", "Please provide a subject for the message!", "error");
            return;
        }
         if($A.util.isUndefinedOrNull(message) || $A.util.isEmpty(message)){
            console.log('message blank');
            helper.showToast(component, "Error", "You can not send an empty message!", "error");
            return;
        }
        
        var action = component.get('c.insertSubjectAndMessage');
        action.setParams({
            "mySubject" : subject,
            "myMessage" : message,
            "patientId" : component.get("v.patientID"),
            "base64Data" : [],
            "fileName" : JSON.stringify(component.get("v.fileMessageLst")),
            "isPHI" : myCheckbox
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                helper.showToast(component, "Success!", "Message Sent successfully.", "success");
                var appEvent = component.getEvent("refreshMessages");
                appEvent.fire();
                component.set("v.showModal",false);
                    
            }else if (state === "ERROR") {
                helper.showToast(component, "Error", "Message Sending Failed.", "error");
            }
        });
        $A.enqueueAction(action);
    },

    handleUploadFinished: function (component, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        console.log('uploadedFiles', JSON.stringify(uploadedFiles));
         var thisFile = uploadedFiles[0];
         console.log('uploadedFiles size new ****'+ thisFile.ContentSize);
       // alert("Files uploaded : " + uploadedFiles.length);
       var fileMsg = component.get("v.fileMessageLst");
       var base64 = component.get("v.base64Lst");
        
        console.log('fileMsg',fileMsg);
        if(fileMsg.length == 0){
        var imageWrapper = [];
        }
        else{
            var imageWrapper = fileMsg;
        }
        
        for(var i=0;i<uploadedFiles.length;i++){
			 var fileSize2 = uploadedFiles[i].ContentSize;
             console.log('fileSize2'+fileSize2);
            imageWrapper.push({'name':uploadedFiles[i].name, 'value':uploadedFiles[i].documentId});
        }

        component.set("v.fileMessageLst",imageWrapper);
        var fileFinalMsg = component.get("v.fileMessageLst");
        var fileFinalMsgLength = fileFinalMsg.length;

        if(fileFinalMsgLength > 0){
            component.set("v.showAttach",true);
        }
        component.set("v.messageClass",'slds-text-color_success');
        // Get the file name
        uploadedFiles.forEach(file => console.log('handleUploadFinished****',file));
    },

    deleteUploadedFile : function(component, event) { 
        var documentId = event.currentTarget.id;
        var fileFinalMsg = component.get("v.fileMessageLst");
        var idx = fileFinalMsg.findIndex(obj => obj.value === documentId);
        if(idx!=-1){
            fileFinalMsg.splice(idx,1);
        }
        component.set("v.fileMessageLst",fileFinalMsg);
        console.log(JSON.stringify(component.get("v.fileMessageLst")));
        var action = component.get("c.deleteFile");
        console.log('documentId',documentId);
        action.setParams({
            "contentDocumentId": documentId            
        });  
        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state=='SUCCESS'){
                
            }  
        });  
        $A.enqueueAction(action);  
    },

    

    openfileUpload: function (component, event) {
    
        var files = event.getSource().get("v.files");
        var fileList = [];
        var fileNames;
      
        for (var i = 0, len = files.length; i < len; i++) {
          if (fileNames == null) {
            fileNames = files[i].name;
          } else {
            fileNames += ", " + files[i].name;
          }
        }
        for(var i=0;i<files.length;i++){

            var fileMsg = component.get("v.fileMessageLst");

            fileMsg.push(files[i].name);

            component.set("v.fileMessageLst",fileMsg);
        }

        var fileFinalMsg = component.get("v.fileMessageLst");
        var fileFinalMsgLength = fileFinalMsg.length;

        if(fileFinalMsgLength > 0){
            component.set("v.showAttach",true);
        }
        component.set("v.messageClass",'slds-text-color_success');
      
        component.set("v.fileNames", fileNames);
        component.set("v.fileList", fileList);
      
        [...files].forEach(file => {
          let fileReader = new FileReader();
      
          fileReader.onload = function() {
            let fileContents = fileReader.result.split(',')[1];
            let base64Mark = "base64,";
            let dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);
            let base64Data = encodeURIComponent(fileContents);
      
            fileList.push({ fileName: file.name, base64Data: base64Data });
            console.log(JSON.stringify(fileList));
            component.set("v.fileList", fileList);
            console.log('fileList****',fileList);
          };
          fileReader.readAsDataURL(file);
        });
        
            
    },
    hideModalBox : function (component, event) {
        component.set("v.showModal",false);
        component.set("v.replyMsg",false);
    }

})