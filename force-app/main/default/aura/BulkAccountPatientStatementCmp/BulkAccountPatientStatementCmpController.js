({
    doInit : function(component) {
        
component.set("v.showModal",false);
        console.log('line 5****');
        var action = component.get("c.checkProfile");
        var toastEvent = $A.get("e.force:showToast");    
        action.setCallback(this, function (response){            
            var state = response.getState(); 
            if (state === "SUCCESS") {
                
                console.log('line 11***',response.getReturnValue());
                component.set("v.showModal",false);
                if(response.getReturnValue() != 'System Administrator'){
                   
                    toastEvent.setParams({
                        "type": "warning",
                        "title" : "Don't have access to generate bulk patient statement!",
                        "message": "Please contact System Admin.",
                        
                    });
                    toastEvent.fire(); 
                    
                    var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
            "listViewName": null,
            "scope": "Account"
        });
        navEvent.fire();
                    
                    window.setTimeout($A.getCallback(function() {
                location.reload(); 
            }), 5000);
                    
                    
                    }
                
                else{
        component.set("v.showModal",true);
}
                
            }
            else{
                //getting errors if callback fails
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        
        $A.enqueueAction(action); 
        
    },
    
    generateStatement : function(component) {
        var toastEvent = $A.get("e.force:showToast");
        if(component.get("v.fromDate") == null || component.get("v.toDate") == null){
            toastEvent.setParams({
                title : 'Info',
                message: 'Dates cannot be blank',
                duration:' 5000',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire(); 
            
        }
        else if(component.get("v.fromDate") > component.get("v.toDate")){
            toastEvent.setParams({
                title : 'Info',
                message: 'From Date cannot be greater than To Date',
                duration:' 5000',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire(); 
            
        }
            else{
                
                var fromDate = component.get("v.fromDate");
                var endDate = component.get("v.toDate");
                var finalParametre = fromDate + '$' + endDate;

                
                var action = component.get("c.bulkPatientStatementExist");
        action.setParams({ 
                          startDate : fromDate,
                          endDate : endDate});        
        action.setCallback(this, function (response){            
            var state = response.getState(); 
            if (state === "SUCCESS") {
                console.log('line 46***',response.getReturnValue());
                if(response.getReturnValue()){
                
                var url = '/apex/ElixirSuite__BulkAccountPatientStatementPDFPage?orderId='+finalParametre;
                var newWindow;
                newWindow = window.open(url);
                newWindow.focus();
                
                
                component.set("v.fromDate",null);
                component.set("v.toDate",null);
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewName": null,
                    "scope": "Account"
                });
                navEvent.fire();
                
            }
else {
                    toastEvent.setParams({
                        "type": "warning",
                        "title" : "NO PROCEDURES PRESENT IN THE SPECIFIED DATE!",
                        "message": "Please input different filter.",
                        
                    });
                    toastEvent.fire(); 
                }
                
            }
            else{
                //getting errors if callback fails
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        
        $A.enqueueAction(action); 
                
            }
    },
    
    hideModalBox : function(component) {
        
        
        component.set("v.fromDate",null);
        component.set("v.toDate",null);
        var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
            "listViewName": null,
            "scope": "Account"
        });
        navEvent.fire();
    }
})