({
    fethcInitPayload : function(component, event, helper) {
        try{
            var action = component.get("c.initBuild");
            component.set("v.loaded",false);
            action.setParams({
                recId:component.get('v.recordId')
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    try{
                        var stillimageLst = component.get("v.stillImage");
                        var respBody = response.getReturnValue().cdLinks;
                        component.set("v.loaded",true);
                        console.log('returned results: ' + JSON.stringify(respBody));
                        for(var rec in respBody){
                            if(respBody[rec].ContentDocument.Title.startsWith("draw")){
                                var prefixURL = '/sfc/servlet.shepherd/document/download/';
                                component.set("v.stillImage",prefixURL+respBody[rec].ContentDocument.Id); 
                            }
                            if(respBody[rec].ContentDocument.Title.startsWith("staticDraw")){
                                var prefixURL = '/sfc/servlet.shepherd/document/download/';
                                component.set("v.staticImage",prefixURL+respBody[rec].ContentDocument.Id);
                            }
                        }                      
                        
                        console.log('staticImage results: ' + JSON.stringify(component.get("v.stillImage"))); 
                    }
                    catch(e){
                        alert(e);
                    }
                    
                    
                }
                else{
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && online[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }        }
                }
                
            });
            
            $A.enqueueAction(action); 
        }
        
        catch(e){
            alert(e);
        } 
    },
    deleteImage : function(component, event, helper,imageId) {
        try{
            component.set("v.loaded",false);
            var action = component.get("c.deleteImageFromCanvas");
            component.set("v.loaded",false);
            action.setParams({
                imageId:imageId,
                acocuntID : component.get('v.recordId')
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.loaded",true);
                    try{
                        
                    }
                    catch(e){
                        alert(e);
                    }
                    
                    
                }
                else{
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && online[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }        }
                }
                
            });
            
            $A.enqueueAction(action); 
        }
        
        catch(e){
            alert(e);
        } 
    },
    removeDeletedRowForViewUpload : function(component, event, helper) {
        try{
            component.set("v.showConfirmDialog",false);   
            var AllRowsList = component.get("v.stillImage");
            var killID =  JSON.parse(JSON.stringify(AllRowsList));
            var recordContentID =  killID.split("/");
            helper.deleteImage(component, event, helper,recordContentID[5]);
            var listOfContentIDsToDelete = component.get("v.contentIDsToDel");
            listOfContentIDsToDelete.push(recordContentID[5]);
            component.set("v.contentIDsToDel",listOfContentIDsToDelete);
            component.set("v.stillImage", '');
            component.set("v.saveNature",true);
            component.set("v.saveVisible",true);  
        }        
        catch(e){
            alert(e);
        } 
    },
})