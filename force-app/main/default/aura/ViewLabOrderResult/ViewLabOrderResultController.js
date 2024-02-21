({  
    init: function (component, event, helper) {
       
            
        

    var pageReference = component.get("v.pageReference");
     //  alert('pageref'+JSON.stringify(pageReference));
        var activetab = pageReference.state.c__activetabdetail;
        var rid = pageReference.state.c__rid;
      //  alert('ws'+ws);
        
       
    component.set("v.activetabId", activetab);
         component.set("v.rid", rid);
         var workspaceAPI = component.find("workspace");
         workspaceAPI.focusTab().then(function(response) {
             var focusedTabId = response.tabId;
           //  alert(focusedTabId);
             workspaceAPI.setTabLabel({
                 tabId: focusedTabId,
                 label: "LabOrder Details"
             });
         })
         .catch(function(error) {
             console.log(error);
         });
        
         
  //  console.log('crecrecordID ON newORder CHC'+JSON.stringify(component.get("v.crecordId")));
        
   
  },
    
  
  
  
  })