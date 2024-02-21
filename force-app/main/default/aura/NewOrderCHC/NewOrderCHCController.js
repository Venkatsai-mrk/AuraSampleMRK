({
    init: function(component, event, helper) {

        var pageReference = component.get("v.pageReference");

        var ws = pageReference.state.c__accountId;

        // var result = ws.substring(21, 39);

        component.set("v.crecordId", ws);
        var rId = component.get("v.recordId");
        console.log('Inside NewOrder' + component.get("v.recordId"));
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
           // alert(focusedTabId);
           if(rId != null && rId != ''){
            workspaceAPI.closeTab({tabId: focusedTabId});
        }
       })
        workspaceAPI.focusTab().then(function(response) {
                var focusedTabId = response.tabId;
                // alert(focusedTabId);
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: "New Order"
                });
            })
            .catch(function(error) {
                console.log(error);
            });
           
        // console.log('crecrecordID ON newORder CHC'+JSON.stringify(component.get("v.crecordId")));


    },
    handleFieldChangeAura: function(component, event) {
        const isDirty = event.getParam('isDirty');
        var unsaved = component.find("unsaved");
        unsaved.setUnsavedChanges(isDirty, { label: 'Lab Order' });
    },
    /* handleCloseNewOrderTab: function(component, event) {
         alert('In handleCloseNewOrderTab @@@@@@@@@@@@@@@@@@');
         var workspaceAPI = component.find("workspace");
         workspaceAPI.focusTab().then(function(response) {
                 var focusedTabId = response.tabId;
                 // alert(focusedTabId);
                 workspaceAPI.closeTab({ tabId: focusedTabId });
             })
             .catch(function(error) {
                 console.log(error);
             });
         alert('In handleCloseNewOrderTab #####################');
     }*/
    handleFilterChange: function(component, event) {


        var CloseClicked = event.getParam('close');
        component.set('v.message', 'Close Clicked');


        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({ tabId: focusedTabId });
            })
            .catch(function(error) {
                console.log(error);
            });
    },
})