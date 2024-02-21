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
                ).then(function(response1){
                    
                });
                workspaceAPI.setTabLabel({
                    
                    label: "View Message"
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                    //  console.log('afctabinfo',response1);
                });
                workspaceAPI.setTabLabel({
                    label: "View Message"
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:chat",
                iconAlt: "View Message"
            });
        })
        
        console.log('patientID : ',component.get("v.patientId"));
        
        helper.fetchMsgSubject(component, event, helper);//added by Anmol
        
        helper.fetchMsgAttachment(component, event, helper);//added by Anmol
        
    },
    
    delMsg : function(component, event, helper) {
        component.set("v.showModalDeletePrompt",true);
    },
    
    archiveMsg : function(component, event, helper) {
        
        component.set("v.showModalArchivePrompt",true);
    },
    
    bookmarkMsg : function(component, event, helper) {
        
        component.set("v.showModalBookmarkPrompt",true);
    },
    
    // viewAttachments : function(component, event, helper) {
    //     component.set("v.isShowAttach",true);
    // },
    
    goBack : function(component, event, handler){
         var evt = $A.get("e.force:navigateToComponent");
      evt.setParams({
          componentDef:"c:customListViewMsgSubject",
          componentAttributes: {
              patientID : component.get("v.patientId"),
              filterVal : component.get("v.filterValue")
          }
      });
      evt.fire();
        component.set("v.isShowModal",false);
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
    },
    
    
    handleConfirmDialogNo : function(component, event, helper) {
        component.set("v.isShowAttach",false);
    },
    
    hideModalBox : function(component, event, helper) {
        
        component.set("v.isShowModal",false);
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        
        helper.navToListView(component, event, helper);//added by Anmol
        
    },
    navToReplyBoxCmp : function(component, event, helper) {
        component.set("v.replyMsg",true);
    }
})