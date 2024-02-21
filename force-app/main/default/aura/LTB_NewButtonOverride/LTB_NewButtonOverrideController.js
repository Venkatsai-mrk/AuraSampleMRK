({
	myAction : function(component, event, helper) {
        /*
        const queryString = window.location.search; 
        console.log(queryString);
        var result = queryString.indexOf("ElixirSuite__Lab__c");
        var id = queryString.substring(result+22,result+40);
        component.set("v.recordId",id);
        console.log(id);
        */
        
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
        component.set("v.recordId", addressableContext.attributes.recordId)

	},
    
    handleFilterChange: function(component, event) {


        var CloseClicked = event.getParam('close');
        component.set('v.message', 'Close Clicked');


        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
})