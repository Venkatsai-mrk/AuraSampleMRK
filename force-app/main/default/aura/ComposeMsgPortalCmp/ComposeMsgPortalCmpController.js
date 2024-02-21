({
    doInit : function(component, event, helper) {
       var action = component.get("c.getCustomSetting");
            action.setCallback(this, function(response){
            var resp=response.getReturnValue();
            console.log("resp: " + JSON.stringify(resp));
            var messagingSettings=resp.ElixirSuite__Disable_Messaging_buttons_from_portal__c;
            let savedItems = [];
                console.log("savedItems: " + JSON.stringify(savedItems));
                if (messagingSettings) {
                    savedItems = messagingSettings.split(';').map(function(item) {
                        return item.trim();
                    });
                
                    console.log("savedItems: " + JSON.stringify(savedItems));
                }
            
            if(savedItems.includes('New') ){
                
                helper.showToast(component, "Messaging disabled", "You do not have permission to send messages .", "error");
                $A.get("e.force:closeQuickAction").fire();
                }
                else{
                    component.set("v.openComposeMessage",true);
                    helper.fetchPortalMessageSetting(component, event, helper);
                }
   			 });
			$A.enqueueAction(action);
        
    },
    sendMessage : function(component, event, helper) {
        console.log(component.get("v.patientID")+' patientID');
        var subject = component.find("mySubject").get("v.value");
        console.log(subject+' subject');
        var message = component.find("myMessage").get("v.value");
        console.log(message+' message');
        var selectedTeamMember = component.find("teamMemberSelect").get("v.value");
        console.log('selectedTeamMember = ', selectedTeamMember);
        var isComposeFromCareTeam = component.get("v.composeMsgFromCareTeam");
        if(isComposeFromCareTeam){
            if($A.util.isUndefinedOrNull(selectedTeamMember)){
                selectedTeamMember = component.get("v.careTeamDetails").value;
            }
        }
        if(($A.util.isUndefinedOrNull(subject) || $A.util.isEmpty(subject)) && ($A.util.isUndefinedOrNull(message) || $A.util.isEmpty(message))){
            helper.showToast(component, "Error", "You can not send an empty message!", "error");
            return;
        }
        if($A.util.isUndefinedOrNull(selectedTeamMember) || $A.util.isEmpty(selectedTeamMember)){
            helper.showToast(component, "Error", "Please select Facility/Care Team Member to proceed!", "error");
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
        

        console.log('fileList in send',component.get("v.fileList"));

        var fileList = component.get("v.fileList");

        var fileMsg = component.get("v.fileMessageLst");
        var base64 = component.get("v.base64Lst");
        
        var action = component.get('c.insertSubjectAndMessage');
        action.setParams({
            "mySubject" : subject,
            "myMessage" : message,
            "patientId" : component.get("v.patientID"),
            "selectedTeamMemberId" : selectedTeamMember,
            //"attachmentLst" : JSON.stringify({'fileList' :fileList}),
            "base64Data" : [],
            "fileName" : JSON.stringify(component.get("v.fileMessageLst"))
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                helper.showToast(component, "Success!", "Message Sent successfully.", "success");
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                component.set("v.openComposeMessage",false);

            }else if (state === "ERROR") {
            helper.showToast(component, "Error", "Message Sending Failed.", "error");
            }
        });
        $A.enqueueAction(action);
    },

    handleUploadFinished: function (component, event) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
       // alert("Files uploaded : " + uploadedFiles.length);
       var fileMsg = component.get("v.fileMessageLst");
       var base64 = component.get("v.base64Lst");
       if(fileMsg.length == 0){
       var imageWrapper = [];
        }
        else{
            var imageWrapper = fileMsg;
        }
        for(var i=0;i<uploadedFiles.length;i++){

            fileMsg.push(uploadedFiles[i].name);
            base64.push(uploadedFiles[i].documentId);
            imageWrapper.push({'name':uploadedFiles[i].name, 'value':uploadedFiles[i].documentId});
        }

        component.set("v.fileMessageLst",imageWrapper);
        component.set("v.base64Lst",base64);
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
    handleTeamMemberChange : function (component, event) {
        var selectedValue = event.getSource().get("v.value");
        console.log(selectedValue+' selectedValue onchange');
        component.set("v.selectedTeamMemberId",selectedValue);
    },
    hideModalBox : function (component, event) {
        $A.get("e.force:closeQuickAction").fire();
        component.set("v.openComposeMessage",false);
    }

})