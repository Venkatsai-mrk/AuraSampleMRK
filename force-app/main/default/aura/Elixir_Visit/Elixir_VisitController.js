({
    createRecordNew: function (component, event, helper) {
        let myPromise = new Promise(function(myResolve, myReject) {
            let x = 0;
            if (x == 0) {
                myResolve("OK");
            } else {
                myReject("Error");
            }
        });
        myPromise.then(
            function(value) {
                //   helper.helperMethod(component , event , helper);
                alert('here after promise');
                var action = component.get("c.countExistingRecords");    
                action.setParams({
                    acctId:  component.get("v.recId")
                    
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        alert('true');
                    }
                });           
                $A.enqueueAction(action);
            },
            function(error) { /* code if some error */ }
        );
        
    },
})