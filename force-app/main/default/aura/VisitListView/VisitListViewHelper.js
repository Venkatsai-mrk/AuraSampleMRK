({
    //Added by Ashwini
    fetchAccountName:function(component, event, helper){
        var action = component.get("c.fetchAccountName");
           action.setParams({ accountId : component.get("v.recordVal") });
           action.setCallback(this, function(response) {
               var state = response.getState();
               if (state === "SUCCESS") {
                   
                   console.log('Patient name  data '+JSON.stringify(response.getReturnValue()));                
                   var records =response.getReturnValue();
                   component.set("v.accName", records);
                   
               }
           
            });
           
           $A.enqueueAction(action);
       },
    helperMethod : function(component, event, helper) {
               
    },

    //Added by Anmol for LX3-8141
    genSuperBill: function(component, patId,lstOfCare){
        
        var action = component.get("c.generateSuperBill");
        action.setParams({ accountId : patId,
                           careLst : lstOfCare });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Result of genSuperBill',result);
                
                if(result==false){
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info',
                        message: 'Please have an active insurance to generate superbill',
                        duration:' 5000',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire(); 
                    
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info',
                        message: 'Superbill creation initiated. Please check the files section of Care Episode',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'info',
                        mode: 'dismissible'
                    });
                    toastEvent.fire(); 
                }
                
            }
            
        });
        
        $A.enqueueAction(action);
        
    }
    //End by Anmol for LX3-8141
    
})