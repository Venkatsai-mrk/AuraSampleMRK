({
	 init: function(component, event, helper) {      
        try{
        
                     var pageReference = component.get("v.pageReference");
        // alert(JSON.stringify(pageReference));
        var rId = pageReference.state.c__crecordId;
        if(rId != null && rId != ''){
            component.set("v.crecordId", rId);
        }
                    console.log('crecordId=='+component.get("v.crecordId"));
        var workspaceAPI = component.find("workspace");
        workspaceAPI.focusTab().then(function(response) {
                var focusedTabId = response.tabId;
                //  alert(focusedTabId);
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: "Prescription"
                });
            })
            .catch(function(error) {
                
            });
                
            
       
           // $A.enqueueAction(action);
     }
        
        catch (e){
            console.log('e==='+e);
        }

       
    },
  
})