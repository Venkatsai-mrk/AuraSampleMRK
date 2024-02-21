({
    hideModal : function(component, event, helper) {
        component.set("v.showModal", false);
    },
    
    deleteRecord : function(component, event, helper) {
        var recId = component.get("v.recordId");
        var action = component.get("c.delSubject");
        action.setParams({ 'msgSubId' :recId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log("success for delMsg",result);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Deletion Successful!",
                    "message": "Message is successfully deleted"
                });
                toastEvent.fire();
                component.set("v.isShowModal",false);
                component.set("v.showModal",false);  
                helper.navToListView(component, event, helper);
                helper.navigateToListView(component, event, helper);
            }
            else {
                console.log("failure for delMsg",response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    archiveMsg : function(component, event, helper) {
        
        var recId = component.get("v.recordId");
        var action = component.get("c.arcSubject");
        action.setParams({ 'msgSubId' :recId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log("success for archiveMsg",result);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Message Archived Successful!",
                    "message": "Message is successfully archived"
                });
                toastEvent.fire();
                component.set("v.showModal",false);
                component.set("v.archivePrompt",false);
                component.set("v.unArchivePrompt",true);
                helper.navToListView(component, event, helper);
              }
              else {
                  console.log("failure for delMsg");
              }
          });
        $A.enqueueAction(action);
    },
    UnarchiveMsg : function(component, event, helper) {
        
        var recId = component.get("v.recordId");
        var action = component.get("c.unArcSubject");
        action.setParams({ 'msgSubId' :recId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log("success for archiveMsg",result);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Message Unarchived Successfully!",
                    "message": "Message is successfully Unarchived"
                });
                toastEvent.fire();
                component.set("v.showModal",false);
                component.set("v.archivePrompt",true);
                component.set("v.unArchivePrompt",false);
                helper.navToListView(component, event, helper);
              }
              else {
                  console.log("failure for delMsg");
              }
          });
        $A.enqueueAction(action);
    },
    bookmarkMsg : function(component, event, helper) {
        
        var recId = component.get("v.recordId");
        var action = component.get("c.bookmrkSubject");
        action.setParams({ 'msgSubId' :recId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log("success for bookmarkMsg",result);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Message Bookmark Successful!",
                    "message": "Message is successfully bookmarked"
                });
                toastEvent.fire();
                component.set("v.showModal",false);  
                component.set("v.showModal",false);   
                component.set("v.bookMarkPrompt",false);
                component.set("v.removeBookMarkPrompt",true); 
                helper.navToListView(component, event, helper);
              }
              else {
                  console.log("failure for delMsg");
              }
          });
        $A.enqueueAction(action);
    },
    removeBookmarkMsg : function(component, event, helper) {
        
        var recId = component.get("v.recordId");
        var action = component.get("c.removeBookmrkSubject");
        action.setParams({ 'msgSubId' :recId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log("success for bookmarkMsg",result);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Message Bookmark Removed Successfully!",
                    "message": "Message Bookmark is successfully Removed"
                });
                toastEvent.fire();
                component.set("v.showModal",false);  
                component.set("v.showModal",false);    
                component.set("v.bookMarkPrompt",true);
                component.set("v.removeBookMarkPrompt",false); 
                helper.navToListView(component, event, helper);
              }
              else {
                  console.log("failure for delMsg");
              }
          });
        $A.enqueueAction(action);
    }
})