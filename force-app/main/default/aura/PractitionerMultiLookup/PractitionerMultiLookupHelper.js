({
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method 
        var action = component.get("c.fetchLookUpValues");
        var baId =component.get("v.lstSelectedRecords");
        
    	var ids=[];
    		for (var i= 0 ; i < baId.length ; i++){
        		ids.push(baId[i]);
    	}
    	var accoutIds=JSON.stringify(ids);
         action.setParams({
            'acc' : ids,
        });
        
      
        
         // set a callBack
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Success:",JSON.stringify(response.getReturnValue()));
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.}
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Practitioners Found...');
                } else {
                    component.set("v.Message", '');
                    // set searchResult list with return value from server.
                }
                component.set("v.listOfSearchRecords", storeResponse); 
                console.log('listOfSearchRecords new'+JSON.stringify(component.get("v.listOfSearchRecords")));
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
})