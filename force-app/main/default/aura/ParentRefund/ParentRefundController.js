({
	myAction : function(component, event, helper) {
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            var issubTab = response.isSubtab;
            // console.log('afctab',focusedTabId);
            if(issubTab)
            {
                workspaceAPI.getTabInfo(
                    { tabId:focusedTabId}
                ).then(function(){
                    
                });
                workspaceAPI.setTabLabel({
                    
                    label: "Refunds"
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(){                 
                });
                workspaceAPI.setTabLabel({
                    label: "Refunds"
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:collection_alt",
                iconAlt: "Schedule Appointment"
            });
        })
        
        console.log('recordId51****',component.get("v.recordId"));
        helper.getAccountInfo(component);
		
	},
    generateRefundStatement : function(component, event) {
        var changeValue = event.getParam("checked");
          console.log('changeValue--'+changeValue);
    
    },
    createRefundReq : function(component) {
        
         //Call Child aura method
        var childComponent = component.find("processRefund");
        childComponent.processRefundRequest();
        
    },
    
    processRefunds : function(cmp) {
        
         //Call Child aura method
        var childComponent = cmp.find("processRefund");
        childComponent.processRefunds();
        
    },
    navToAccRecord: function(component) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
        navEvt.fire();
    },
    navToListView: function() {
        // Sets the route to /lightning/o/Account/home
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/o/Account/home'
        });
        urlEvent.fire();
    },
    
})