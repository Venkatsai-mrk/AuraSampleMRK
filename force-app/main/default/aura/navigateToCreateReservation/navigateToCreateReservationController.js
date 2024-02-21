({
init : function(component, event, helper) {
    helper.getAccountIdFromURL(component);
},
// handleCustomEvent: function(component, event, helper){
//     component.destroy();
//     alert('completed');
//     //$A.get("e.force:closeQuickAction").fire();
// }
handleCustomEvent: function(component, event, helper) {
    console.log('CAlling Aura'+event.getParam('message'));
    console.log('CAlling Account'+event.getParam('accId'));
    var accId=event.getParam('accId');
    if(component.get("v.accountId")){
    var accountId = component.get("v.accountId");
    var navService = component.find("navService");
    console.log('accountId'+accountId);
    var workspaceAPI = component.find("workspace");
    workspaceAPI.getFocusedTabInfo().then(function(response) {
        var parentTabId = response.tabId;
        if (parentTabId) {
            workspaceAPI.closeTab({
                tabId: parentTabId,
                includeAllSubtabs: true
                
            }).then(function() {
                console.log('Subtabs cleared successfully.');

               
              
            }).catch(function(error) {
                console.log('Error clearing subtabs:', error);
            });
        }
        console.log('accountId'+accountId);

        // Navigate back to the account view page
       
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId, // this is what you will need
                actionName: 'view',
                objectApiName: 'Account' // the object's api name
            }
        };

        navService.navigate(pageReference);
    }).catch(function(error) {
        console.log('Error retrieving focused tab information:', error);

       
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: component.get("v.accountId"), // this is what you will need
                actionName: 'view',
                objectApiName: 'Account' // the object's api name
            }
        };

        navService.navigate(pageReference);
    });  
    }
    else{
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      "recordId": accId
     });
    navEvt.fire();
        
    }
}

})