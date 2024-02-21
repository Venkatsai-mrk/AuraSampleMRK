({
    init: function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        // alert(JSON.stringify(pageReference));
        var rId = pageReference.state.c__crecordId;
        component.set("v.crecordId", rId);
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
                console.log(error);
            });

        /** var evt = $A.get("e.force:navigateToComponent");
          evt.setParams({
              componentDef:"ElixirSuite:tableForLabOrder",
              componentAttributes: {
                  patientID : component.get("v.recordId"),
                  nameSpace : ''
              }
          });
          evt.fire();**/
        /**var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          mode: "sticky",
          message: "This is a subtab"
        });
        toastEvent.fire();**/
    },
})