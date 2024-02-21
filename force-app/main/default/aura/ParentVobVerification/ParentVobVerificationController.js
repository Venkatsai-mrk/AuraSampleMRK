({
    myAction : function(component, event, helper) {
        console.log('ParentVobInIt@@-- '+component.get("v.isResult"));
        component.set("v.isResult" , false);
        component.set("v.isPopUp" , true);
    },
    submitDetails: function(component, event, helper) {
        console.log('parentVOB');
        component.set("v.isResult" , false);
        var pageRef = component.get( "v.pageReference" );
        var getRecordId =  pageRef.state.ElixirSuite__recordId;
        component.set("v.isDetailButton",pageRef.state.ElixirSuite__isDetailButton);
        component.set("v.srcId",getRecordId);
        component.set("v.isResult" , true);
        if(component.get("v.isResult")== false){
            component.set("v.isPopUp" , false);
        }
    },
    closePopUp : function(component,event){
        var pageRef = component.get( "v.pageReference" );
        var getRecordId =  pageRef.state.ElixirSuite__recordId;
        component.set("v.isDetailButton",pageRef.state.ElixirSuite__isDetailButton);
        component.set("v.srcId",getRecordId);
        component.find("navigationService").navigate({
            "type": "standard__recordPage",
            "attributes": {
                "recordId": component.get("v.srcId"),
                "objectApiName": "ElixirSuite__VOB__c",
                "actionName": "view"
            }
        });
        var workspaceAPI =component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error){
            console.log(error);
        });
    }
})