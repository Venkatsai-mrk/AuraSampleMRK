({
    open : function(component, event, helper) {
        var prevCareId = component.get("v.previousCare");
        
        const items = {"value":prevCareId, "label":prevCareId};

        component.set("v.selectedCare", items);

        component.set("v.promptUserForInput", true);
        component.set("v.currentCareEpisode", '');

        var selectedRec = component.get("v.selectedCare");

        console.log('selected care***',JSON.stringify(selectedRec));
    },

    cancel : function(component, event, helper) {
        component.set("v.promptUserForInput", false);
    },

    selectedRecord : function(component, event, helper){
        
        console.log('enter in selected record***');
        var message = event.getParam("lookUpData"); 
        console.log('message****',message);
        component.set("v.currentCareEpisode", message);

        component.set("v.previousCare", 'removed');
    },
    done : function(component, event, helper) {
        var careId = component.get("v.currentCareEpisode");
        var prevCareId = component.get("v.previousCare");
        console.log('careId***done',careId);
        console.log('formId***done',component.get("v.formUniqueId"));

        console.log('previousCare***done',prevCareId);

        if(prevCareId==undefined){}
        else if(prevCareId!='' && prevCareId!='removed'){

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Error",
                "message": "Care Episode is already attached"
            });
            toastEvent.fire();

            return;

        }

       /* if(careId==null || careId==''){

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Error",
                "message": "Please select a Care Episode"
            });
            toastEvent.fire();

            return;

        }*/

        helper.updateCareEpisode(component, event, careId);//added by Anmol
       component.set("v.promptUserForInput", false);
       var appEvent = $A.get("e.ElixirSuite:FormsRefreshEvt");
       appEvent.setParams({"route" : component.get("v.procTableVal")}); 
       appEvent.fire();
    },

})
