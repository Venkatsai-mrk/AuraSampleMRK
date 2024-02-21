({
    myAction : function(component, event, helper) {
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            var issubTab = response.isSubtab;
            if(issubTab)
            {
                workspaceAPI.getTabInfo(
                    { tabId:focusedTabId}
                ).then(function(response1){                   
                });
                workspaceAPI.setTabLabel({
                    
                    label: "TimeLine"
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                });
                workspaceAPI.setTabLabel({
                    label: "TimeLine"
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:variable",
                iconAlt: "TimeLine"
            });
            
        });
        
    }
})