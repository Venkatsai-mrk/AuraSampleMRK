({
    myAction : function(component, event, helper) {
        
    
        helper.fetchMsgSubject(component, event, helper);//added by Anmol
        
        helper.fetchMsgAttachment(component, event, helper);//added by Anmol
        helper.fetchPortalMessageSetting(component, event, helper);//added by Anmol
        
    },
    
    goBack : function(component, event, helper) {
            var action = component.get("c.getListViews");
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('response.getState(); ',response.getState());
                if (state === "SUCCESS") {
                    console.log('success');
                    var listviews = response.getReturnValue();
                    console.log(listviews[0].Id);
                    var navEvent = $A.get("e.force:navigateToList");
                    navEvent.setParams({
                        "listViewId": listviews[0].Id,
                        "listViewName": listviews[0].Name,
                        "scope": "ElixirSuite__Message_Subject__c"
                    });
                    navEvent.fire();
                    
                }
                
            });
            $A.enqueueAction(action);
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
    handleConfirmDialogNo : function(component, event, helper) {
        component.set("v.showModalBookmarkPrompt",false);
    },
    
    hideModalBox : function(component, event, helper) {
        
        component.set("v.isShowModal",false);
        helper.navToListView(component, event, helper);//added by Anmol
        
    },
    navToReplyBoxCmp : function(component, event, helper) {
        component.set("v.replyMsg",true);
    }
})