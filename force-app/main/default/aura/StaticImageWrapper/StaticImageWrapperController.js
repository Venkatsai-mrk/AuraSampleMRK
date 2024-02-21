({
    myAction :  function(cmp, event, helper) {
        var section = cmp.get("v.section");
        cmp.set("v.staticName",section['ElixirSuite__Static_file_name__c']);
    },
    getValueFromLwcStatic :  function(cmp, event, helper) {
        var imgData = event.getParam('dataToSend').pngOut;
        var section = cmp.get("v.section");
        section['ImageData'] = imgData;
        cmp.set("v.section",section);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "PROCESSING COMPLETE!",
            "message": "IMAGE UPDATED SUCCESSFULLY.",
            "type" : "info"
        });
    toastEvent.fire();
    },
    
    inititateNewImg : function(cmp, event, helper) {
        // Concurrently changing aura:if isTrue attribute causes bug.
        // Refer https://salesforce.stackexchange.com/questions/281201/error-component-find-get-is-not-a-function-in-lightning

        //cmp.set("v.isStaticImageRefresh",false);
        //cmp.set("v.isStaticImageRefresh",true);
        //alert('aura complete');
    },

    getDataToSend : function(cmp) {
        var dataToSend = cmp.find("staticDrawAnnotationChild").handleSaveForm();
        
        var section = cmp.get("v.section");
        section['ImageData'] = dataToSend.pngOut;
        cmp.set("v.section",section);

        //console.log("saved imgdata in section");
    }
})