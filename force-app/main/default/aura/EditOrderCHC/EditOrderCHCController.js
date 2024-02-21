({
    init: function(component, event, helper) {
        
        var pageReference = component.get("v.pageReference");
        
        var ws = pageReference.state.c__accountId;
        var labOrderId = pageReference.state.c__labOrderId;
        console.log('ws '+ws);
        console.log('labOrderId '+labOrderId);
        component.set("v.crecordId", ws);
        component.set("v.labOrderId", labOrderId);
        var rId = component.get("v.recordId");
        console.log('Inside NewOrder' + component.get("v.recordId"));
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            if(rId != null && rId != ''){
                workspaceAPI.closeTab({tabId: focusedTabId});
            }
        })
        workspaceAPI.focusTab().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Update Order"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
        
    },
    handleFieldChangeAura: function(component, event) {
        const isDirty = event.getParam('isDirty');
        var unsaved = component.find("unsaved");
        unsaved.setUnsavedChanges(isDirty, { label: 'Lab Order' });
    },
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