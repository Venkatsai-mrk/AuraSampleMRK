({
    updateCareEpisode : function (component, event, CareId) {
        
        var accountId = component.get("v.currentAccountId");

        var formId = component.get("v.formUniqueId");

        var procedureId = component.get("v.procedureId");

        console.log('accountId***',accountId);
        console.log('formId***',formId);
        console.log('procedureId***',procedureId);

      if(formId!=undefined){
        var action = component.get("c.updateCareEpisode");
        
        action.setParams({ 'careId': CareId,
                           'accId': accountId,
                           'formUnId': formId});

          action.setCallback(this, function(response){
              var state = response.getState();
              if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log("success for updateCareEpisode",result);
              }
              else {
                      console.log("failure for updateCareEpisode");
              }
                });
                $A.enqueueAction(action);
}
        else{
            console.log('else line 31');
            var action = component.get("c.updateProcCareEpisode");
        
        action.setParams({ 'careId': CareId,
                           'accId': accountId,
                           'procId': procedureId});

          action.setCallback(this, function(response){
              var state = response.getState();
              if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log("success for updateCareEpisode",result);
              }
              else {
                      console.log("failure for updateCareEpisode");
              }
                });
                $A.enqueueAction(action);
        }
        
    }
})