({
    init: function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        if($A.util.isEmpty(pageReference)){                
            var urlParams = new URLSearchParams(window.location.search);
            console.log(urlParams.get("c__customFormCmp"));
            var componentName = btoa(urlParams.get("c__customFormCmp"));
        }
        if(!$A.util.isEmpty(pageReference)){
            var accId = pageReference.state.c__accountId;
            var record = pageReference.state.c__customFormCmp;
            component.set("v.accountId", accId);
            component.set("v.customFormCmp", record);
            console.log('accId = ', accId);
            console.log('record = ', record[0].ElixirSuite__Component_name__c);
            var componentName = btoa(record[0].ElixirSuite__Component_name__c);
            console.log(componentName);
            var actionType = record[0].ElixirSuite__Action__c;
            
            console.log('componentName = ', atob(componentName));
        }
        
        var attributes = '';
        var formName = '';
        var formUniqueId = '';
        
        $A.createComponent(
            atob(componentName),
            {
                "accountId": component.get("v.accountId"),
                "formName": formName,
                "formUniqueId": formUniqueId,
                "action": actionType,
            },
            function(newCmp, status, errorMessage) {
                // Add the new button to the bodyComponents array
                if (status === "SUCCESS") {
                    console.log('new cmp ', newCmp);
                    var bodyComponents = component.get("v.body");
                    bodyComponents.push(newCmp);
                    component.set("v.body", bodyComponents);                    
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + JSON.stringify(errorMessage));
                }
                
            }
        );
    },
   
})