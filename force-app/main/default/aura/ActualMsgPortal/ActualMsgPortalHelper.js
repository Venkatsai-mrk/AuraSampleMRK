({
    fetchMsgSubject: function (component, event, helper) {
      var recId;
      var isFromNewMessages = component.get("v.isFromNewMessages");
      if(isFromNewMessages){
        recId = component.get("v.messageRecordId");
        console.log('message recId');
      }else{
        recId = component.get("v.recordId");
      }
        var action = component.get("c.fetchSubject");
        action.setParams({ 'msgSubId' :recId});
          action.setCallback(this, function(response){
              var state = response.getState();
              if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log("success for fetchMsgSubject",result);
                if(result.ElixirSuite__Archived__c == undefined){
                  component.set("v.archiveButton",true);
                  component.set("v.unArchiveButton",false);
                }else{
                  component.set("v.archiveButton",false);
                  component.set("v.unArchiveButton",true);
                }
                if(result.ElixirSuite__Bookmarked__c == undefined){
                  component.set("v.bookMarkButton",true);
                  component.set("v.removeBookMarkButton",false);
                }else{
                  component.set("v.bookMarkButton",false);
                  component.set("v.removeBookMarkButton",true);
                }
                component.set("v.message",result);   
              }
              else {
                      console.log("failure for fetchMsgSubject");
              }
                });
                $A.enqueueAction(action);
          },
    
    fetchMsgAttachment: function (component, event, helper) {

      var recId;
      var isFromNewMessages = component.get("v.isFromNewMessages");
      if(isFromNewMessages){
        recId = component.get("v.messageRecordId");
      }else{
        recId = component.get("v.recordId");
      }
        console.log(recId+' recId mahi');
        var action = component.get("c.fetchFiles");
        action.setParams({ 'msgSubId' :recId});
          action.setCallback(this, function(response){
              var state = response.getState();
              if (state === "SUCCESS") {
                var result = response.getReturnValue();
                  console.log(result+' result');
                   if (result.length > 0) {
                        component.set("v.isShowAttachButton", true);
                    }
                console.log("success for fetchMsgAttachment",result);
                component.set("v.fileList",result);   
              }
              else {
                      console.log("failure for fetchMsgAttachment");
              }
                });
                $A.enqueueAction(action);
          },
    	
    	  fetchPortalMessageSetting: function(component, event, helper){
            var action = component.get("c.getCustomSetting");
            action.setCallback(this, function(response){
            var resp=response.getReturnValue();
            console.log("resp: " + JSON.stringify(resp));
            var messagingSettings=resp.ElixirSuite__Disable_Messaging_buttons_from_portal__c;
            let savedItems = [];
                console.log("savedItems: " + JSON.stringify(savedItems));
                if (messagingSettings) {
                    savedItems = messagingSettings.split(';').map(function(item) {
                        return item.trim();
                    });
                
                    console.log("savedItems: " + JSON.stringify(savedItems));
                }
              component.set("v.portalMessage" , !savedItems.includes('New'));
              component.set("v.diableDeleteFromPortal", !savedItems.includes('Delete'));

                if (savedItems.includes('Archive')) {
                    component.set("v.disableArchiveFromPortal", false);
                }
                
                if (savedItems.includes('Bookmark')) {
                    component.set("v.disableBookmarkFromPortal", false);
                } 
   			 });
			$A.enqueueAction(action);
         
    		},

          navToListView: function (component, event, helper) {

            var action = component.get("c.getListViews");
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var listviews = response.getReturnValue();
                    var navEvent = $A.get("e.force:navigateToList");
                    navEvent.setParams({
                        "listViewId": listviews.Id,
                        "listViewName": null,
                        "scope": "ElixirSuite__Message_Subject__c"
                    });
                    navEvent.fire();
                    
                }
                
            });
            $A.enqueueAction(action);
              }
})