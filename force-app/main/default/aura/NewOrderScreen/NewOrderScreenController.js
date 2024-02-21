({
	myAction : function(component, event, helper) {
        
          var pageRef = component.get("v.pageReference");

        console.log(JSON.stringify(pageRef));

        var state = pageRef.state; // state holds any query params

        console.log('state = '+JSON.stringify(state));

        var base64Context = state.inContextOfRef;

        console.log('base64Context = '+base64Context);

        if (base64Context.startsWith("1\.")) {

            base64Context = base64Context.substring(2);

            console.log('base64Context = '+base64Context);

        }

        var addressableContext = JSON.parse(window.atob(base64Context));

        console.log('addressableContext = '+JSON.stringify(addressableContext));

         if(addressableContext.type==="standard__component"){

            component.set("v.recordId", addressableContext.state.force__recordId)

        }

        else if(addressableContext.type==="standard__recordPage" || addressableContext.type==="standard__recordRelationshipPage"){

            component.set("v.recordId", addressableContext.attributes.recordId)

        }

       

       

       

         console.log("recordId page ref*** "+component.get("v.recordId"));
        
        
        
        console.log('recordId****',component.get("v.accId"));
        var pageURL = window.location.pathname;
        console.log('pageURL****',pageURL);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            var issubTab = response.isSubtab;
            // console.log('afctab',focusedTabId);
            if(issubTab)
            {
                workspaceAPI.getTabInfo(
                    { tabId:focusedTabId}
                ).then(function(response1){
                    
                });
                workspaceAPI.setTabLabel({
                    
                    label: "New Order"
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                    //  console.log('afctabinfo',response1);
                });
                workspaceAPI.setTabLabel({
                    label: "New Order"
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:collection_alt",
                iconAlt: "New Order"
            });
        })
        
               workspaceAPI.isConsoleNavigation().then(function(response) {
            console.log('app type**',response);
                     component.set("v.isConsoleApp",response);
        })
		
	},
    getValueFromLwc : function(component, event, helper) {
        
        console.log('neworderscreen****',event.getParam('itemList2'));
        component.set("v.addedLst",event.getParam('itemList2'));
        
        var addedLst = component.get("v.addedLst");
        console.log('addedLst****',addedLst);
                
        let sObjLst = {'keysToSave' : component.get("v.addedLst")};
        
        var action = component.get("c.saveOrder");
        
        action.setParams({
            'orderLst': JSON.stringify(sObjLst),
            'accountId' : component.get("v.recordId")
        });
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            console.log('saveorder***',state);
            if (state === "SUCCESS") {
                
                var result = response.getReturnValue();
                console.log('result save order',result);
                
               /* var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Order Created',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'dismissible'
                });
                toastEvent.fire();*/
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": result
                });
                navEvt.fire();
                
                 // Close the current subtab
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            workspaceAPI.closeTab({tabId: tabId});
        });
      //  window.location.reload();
                
            }
                        });
        $A.enqueueAction(action);
        
        
    },
    
    closeLwc : function(component, event, helper) {
        
        var isConsole = component.get("v.isConsoleApp");
        console.log('isConsole***',isConsole);
        
        if(isConsole){
              // Close the current subtab
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            workspaceAPI.closeTab({tabId: tabId});
        });
window.setTimeout($A.getCallback(function() {
                  $A.get('e.force:refreshView').fire();
                  //  window.location.reload();
                }), 300);
    }
        else{
            helper.navToListView(component, event, helper);//added by Anmol
        }
        
    }
})