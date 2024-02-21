({
    doInit : function(component, event, helper) {
        /*var action = component.get('c.getPatient');
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(response.getReturnValue()+' response');
            if(state === 'SUCCESS'){
                var patientId = response.getReturnValue();
                component.set("v.patientId",patientId);
            }
        });
        $A.enqueueAction(action);*/
        
        let message = component.get("v.message");
       console.log('message '+message);
        if(!message.ElixirSuite__Parent_Message__c){
            if(message.ElixirSuite__Subject__c.includes('RE')){
                message.ElixirSuite__Subject__c = message.ElixirSuite__Subject__c;
            }else{
                message.ElixirSuite__Subject__c = 'RE: '+ message.ElixirSuite__Subject__c;
            }
            component.set("v.message",message);
        }
    },
    handlePHICheck : function(component, event, helper) {
    	component.set("v.PHIcheckbox", event.getSource().get('v.checked'));
    },
    sendMessage : function(component,event, helper) {
        var subject = component.find("mySubject").get("v.value");
        console.log(subject+' subject');
        var messageBody = component.find("myMessage").get("v.value");
        var myCheckbox = component.get("v.PHIcheckbox");
        console.log(messageBody+' messageBody');

        var messageObj = component.get('v.message');
        console.log(JSON.stringify(messageObj)+' Message object');
        
        messageObj.ElixirSuite__Subject__c = subject;
        //messageObj.ElixirSuite__Message_Details_lookup__r[0].ElixirSuite__Message_Body__c = messageBody;
        console.log(JSON.stringify(messageObj)+' Message object after update');
        var fileMsg = component.get("v.fileMessageLst");
        var base64 = component.get("v.base64Lst");
        
        if(($A.util.isUndefinedOrNull(subject) || $A.util.isEmpty(subject)) && ($A.util.isUndefinedOrNull(messageBody) || $A.util.isEmpty(messageBody))){
            helper.showToast(component, "Error", "You can not send an empty message!", "error");
            return;
        }
         if($A.util.isUndefinedOrNull(subject) || $A.util.isEmpty(subject)){
            helper.showToast(component, "Error", "Please provide a subject for the message!", "error");
            return;
        }
         if($A.util.isUndefinedOrNull(messageBody) || $A.util.isEmpty(messageBody)){
            console.log('message blank');
            helper.showToast(component, "Error", "You can not send an empty message!", "error");
            return;
        }
        
        var action = component.get('c.insertSubjectAndMessage');
        console.log(component.get("v.patientId")+' patient id in reply box');
        action.setParams({
            "patientId" : component.get("v.patientId"),
            "message" : [messageObj],
            "messageBody" : messageBody,
            "base64Data" : [],
            "fileName" : JSON.stringify(component.get("v.fileMessageLst")),
            "isPHI" : myCheckbox
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
              helper.showToast(component, "Success!", "Message Sent successfully.", "success");
              component.set("v.showModal",false);
              component.set("v.replyMsg",false);
            }else if (state === "ERROR") {
              helper.showToast(component, "Error", "Message Sending Failed.", "error");
            }
        });
        $A.enqueueAction(action);
    },
    hideModalBox : function (component, event) {
        component.set("v.showModal",false);
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
})