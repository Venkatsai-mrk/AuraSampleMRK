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
        alert('lwc event received');
        var objValue = cmp.get("v.freeDrawImageValue");
        if(!$A.util.isUndefinedOrNull(event.getParam('dataToSend').pngOut)){
            if(!objValue.includes(event.getParam('dataToSend').pngOut)){
                objValue.push(event.getParam('dataToSend').pngOut);
            }
            cmp.set("v.freeDrawImageValue",objValue);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "PROCESSING COMPLETE!",
                "message": "IMAGE UPDATED SUCCESSFULLY.",
                "type" : "info"
            });
            toastEvent.fire();
        }
        if(!$A.util.isUndefinedOrNull(event.getParam('dataToSend').fileName)){
            // alert('inside filename if'+event.getParam('dataToSend').fileName);
            var srGargbage = cmp.get("v.staticResourceGarbage");
            srGargbage.push(event.getParam('dataToSend').fileName);
            cmp.set("v.staticResourceGarbage",srGargbage);
            console.log('garbage  '+JSON.stringify(cmp.get("v.staticResourceGarbage")));
            helper.applyCSS(cmp, event);
        }
        
        // cmp.set("v.freeDrawImageValue",event.getParam('dataToSend').pngOut);
        console.log('lwc received value '+event.getParam('dataToSend'));
        console.log('after set multiple  '+JSON.stringify(cmp.get("v.freeDrawImageValue")));
        // console.log('lwc received value '+event.getSource().get("v.value"));
        
    },
    updateForm : function(cmp, event, helper) {
        try{
            cmp.set("v.loaded",false);
            var action = cmp.get("c.saveDrawData");
            action.setParams({
                staticResToDel : cmp.get("v.staticResourceGarbage"),
                imageParametre : cmp.get("v.freeDrawImageValue"), // for dynamic
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
    removeDeletedRowForViewUpload : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;        
        var AllRowsList = component.get("v.stillImage");
        var killID =  JSON.parse(JSON.stringify(AllRowsList[index]));
        var recordContentID =  killID.split("/");
        var listOfContentIDsToDelete = component.get("v.contentIDsToDel");
        listOfContentIDsToDelete.push(recordContentID[5]);
        component.set("v.contentIDsToDel",listOfContentIDsToDelete);
        
        AllRowsList.splice(index, 1);      
        component.set("v.stillImage", AllRowsList);
    },
    inititateNewImg : function(cmp, event, helper) {
        cmp.set("v.isStaticImageRefresh",false);
        cmp.set("v.isStaticImageRefresh",true);
    },
 
    handleConfirmDialogYes :  function(component, event, helper) {
        helper.removeDeletedRowForStaticImage(component, event, helper);
    },
    handleConfirmDialogNo:function(component, event, helper) {
        component.set("v.showConfirmDialog",false);       
    },
    showDiaglogueBox:function(component, event, helper) {
        component.set("v.showConfirmDialog",true);
    }
})