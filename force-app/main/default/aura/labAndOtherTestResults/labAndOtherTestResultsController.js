({  
    doInit:function(component,event,helper){  
        console.log('record id for attachment'+component.get("v.recordId"));
        helper.getuploadedFiles(component);
    },      
    
    previewFile :function(component,event,helper){  
        //  var rec_id = event.currentTarget.id; 
        var rec_id = event.getSource().get("v.name");
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [rec_id]
        });  
    },  
    handleClose : function(component,event,helper){  
        component.set("v.isOpen",false);
    },
    UploadFinished : function(component, event, helper) { 
        var uploadedFiles = event.getParam("files");
        var documentIdLst = [];
        for(var rec in uploadedFiles){
            documentIdLst.push(uploadedFiles[rec].documentId);
        }
        component.set("v.currentlyUploadedDocumetIDs",documentIdLst);
        // var documentId = uploadedFiles[0].documentId;  
        var fileName = uploadedFiles[0].name;  
        helper.UpdateDocument(component,event,documentIdLst); 
        // helper.getuploadedFiles(component);   
        component.find('notifLib').showNotice({
            "variant": "info",
            "header": "Success",
            "message": "File Uploaded successfully!!",
            closeCallback: function() {}
        });  
        
    }, 
    
    delFiles:function(component,event,helper){
     //   component.find("Id_spinner").set("v.class" , 'slds-show');
        var documentId = event.currentTarget.id; 
        var documentId = event.getSource().get("v.name");
        helper.delUploadedfiles(component,event,documentId);  
    },
    
})