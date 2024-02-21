({
    getValueFromLwcStatic :  function(cmp, event, helper) {
        var imgData = event.getParam('dataToSend').pngOut;
        var section = cmp.get("v.section");
        section['ImageData'] = imgData;
        cmp.set("v.section",section);
        console.log('imgData '+imgData);
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
        var dataToSend = cmp.find("dynamicDrawAnnotationChild").handleSaveForm();
        
        if (dataToSend) {
            var section = cmp.get("v.section");
            section['ImageData'] = dataToSend.pngOut;
            cmp.set("v.section",section);
        }

        //console.log("saved imgdata in section");
    }

})