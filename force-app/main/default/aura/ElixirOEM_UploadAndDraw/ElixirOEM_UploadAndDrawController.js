({
    myAction : function(component, event, helper) {
        helper.fethcInitPayload(component, event, helper);
        component.set("v.loaded",false);
        component.set("v.loaded",true);
        
    },
    getValueFromLwcStatic :  function(cmp, event, helper) {
        cmp.set("v.freeDrawImageValueStatic",event.getParam('dataToSend').pngOut);
        console.log(' dataToSend '+JSON.stringify(event.getParam('dataToSend')));
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "PROCESSING COMPLETE!",
            "message": "IMAGE UPDATED SUCCESSFULLY.",
            "type" : "info"
        });
        toastEvent.fire();
        cmp.set("v.saveNature",false);
        if(!$A.util.isUndefinedOrNull(event.getParam('dataToSend').fileName)){
            //  alert('inside filename if'+event.getParam('dataToSend').fileName);
            var srGargbage = cmp.get("v.staticResourceGarbage");
            srGargbage.push(event.getParam('dataToSend').fileName);
            cmp.set("v.staticResourceGarbage",srGargbage);
            console.log('garbage  '+JSON.stringify(cmp.get("v.staticResourceGarbage")));
        }
    },
    getValueFromLwc : function(cmp, event, helper) {
        try{
            console.log('lwc event received'+event.getParam('dataToSend'));
            cmp.set("v.freeDrawImageValue",event.getParam('dataToSend').pngOut);
            cmp.set("v.saveNature",false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "PROCESSING COMPLETE!",
                "message": "IMAGE UPDATED SUCCESSFULLY.",
                "type" : "info"
            });
            toastEvent.fire();
        }
        
        
        catch(e){
            alert(e);
        }
        
        
    },
    pushImageUploadIds :  function(cmp, event, helper) {
        var srGargbage = cmp.get("v.staticResourceGarbage");
        srGargbage.push(event.getParam('dataToSend').fileName);
        cmp.set("v.staticResourceGarbage",srGargbage);
        console.log('garbage  '+JSON.stringify(cmp.get("v.staticResourceGarbage")));
        alert('done');
    },
    updateForm : function(cmp, event, helper) {
        try{
            cmp.set("v.loaded",false);
            var action = cmp.get("c.saveDrawData");
            action.setParams({
                staticResToDel : cmp.get("v.staticResourceGarbage"),               
                imageFileName : 'demoAttachment',
                staticImageParam : cmp.get("v.freeDrawImageValueStatic"),
                acocuntID : cmp.get("v.recordId"),
                staticResToDel : cmp.get("v.staticResourceGarbage"),
            });
            action.setCallback(this, function(resp){
                var state = resp.getState();
                if(resp.getState() === 'SUCCESS')
                {
                    cmp.set("v.loaded",true);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "mode" : "dismissible",
                        "type" : "success",
                        "message": "The record has been updated successfully."
                    });
                    toastEvent.fire();
                    helper.fethcInitPayload(cmp, event, helper);
                    cmp.set("v.saveVisible",false);
                }
                else {
                    cmp.set("v.loaded",true);
                }
            });
            $A.enqueueAction(action);
        }
        catch(e){
            alert(e);
        }
        
    },
    
    inititateNewImg : function(cmp, event, helper) {
        cmp.set("v.isStaticImageRefresh",false);
        cmp.set("v.isStaticImageRefresh",true);
    },
    removeDeletedRowForStaticImage : function(component, event, helper) {
        try{
            var AllRowsList = component.get("v.staticImage");
            var killID =  JSON.parse(JSON.stringify(AllRowsList));
            var recordContentID =  killID.split("/");
            helper.deleteImage(component, event, helper,recordContentID[5]);
            component.set("v.staticImage", '');
            component.set("v.saveNature",true);
            component.set("v.saveVisible",true);
        }
        catch(e){
            alert(e);
        }
    },
    handleConfirmDialogYes :  function(component, event, helper) {
        helper.removeDeletedRowForViewUpload(component, event, helper);
    },
    handleConfirmDialogNo:function(component, event, helper) {
        component.set("v.showConfirmDialog",false);       
    },
    showDiaglogueBox:function(component, event, helper) {
        component.set("v.showConfirmDialog",true);
    }
})