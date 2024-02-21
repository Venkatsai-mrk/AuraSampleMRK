({
    mg:[],
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method 
        var action = component.get("c.fetchLookUpValues");
        
        var baId =component.get("v.lstSelectedRecords");
        console.log('Equipment selected======'+JSON.stringify(baId));
         
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            //'ObjectName' : component.get("v.objectAPIName"),
            //'ExcludeitemsList' : component.get("v.lstSelectedRecords")
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
                    component.set("v.Message", 'No Equipments Found...');
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