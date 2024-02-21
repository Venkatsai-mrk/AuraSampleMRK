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
                    
                    label: "Billing Summary"
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                });
                workspaceAPI.setTabLabel({
                    label: "Billing Summary"
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:multi_picklist",
                iconAlt: "Billing Summary"
            });
        });
       var accountid=component.get("v.recordId1");
         var action = component.get("c.billSum");
         action.setParams ({
            accountid : accountid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.recordId2", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
	},
    handleClickPastEstimate : function(component, event, helper) {
		component.set("v.opencoc",true);
        component.set("v.openPayschedule",false);
         component.set("v.openClaimHistry",false);
		component.set("v.openPaymentHistory",false);
	},
    handleClickViewPaymentSchedule:function(component, event, helper) {
        component.set("v.opencoc",false);
        component.set("v.openClaimHistry",false);
		component.set("v.openPaymentHistory",false);
		component.set("v.openPayschedule",true);
	},
     handleClickViewClaimHsry:function(component, event, helper) {
        component.set("v.opencoc",false);
         component.set("v.openPayschedule",false);
         component.set("v.openPaymentHistory",false);
		component.set("v.openClaimHistry",true);
	},
     handleClickViewPaymentHistory:function(component, event, helper) {
        component.set("v.opencoc",false);
         component.set("v.openPayschedule",false);
         component.set("v.openClaimHistry",false);
		component.set("v.openPaymentHistory",true);
	},
})