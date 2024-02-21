({
    // function call on component Load
    doInit: function(component, event, helper) {
        helper.createObjectData(component, event);
        var action = component.get("c.PicklistFromTH");
        console.log("in do-init");
          action.setCallback(this,function(response){
              
            var data=response.getReturnValue();
            
                component.set("v.LOC",data[0]);
              
              });
        var action3 = component.get('c.LicensBasdPermission');
        action3.setParams({
        });
        
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                
                var wrapList = response.getReturnValue();
                component.set("v.Ehr",wrapList.isEhr);
                component.set("v.Billing",wrapList.isRcm);
                component.set("v.ContactCentr",wrapList.isContactCenter);
            }
        });
        $A.enqueueAction(action3);
        $A.enqueueAction(action);
       },
 
   
    Save: function(component, event, helper) {
        console.log('inside save');
          console.log('action-->');
        
       if (helper.validateRequired(component, event)) {
            console.log('PUSH FUNCTIONALITY'); 
        var Id = component.get("v.recordId");
        component.set("v.TreatList.ElixirSuite__Pre_assessment__c",Id);
        console.log('sah lkup id'+component.get("v.TreatList.ElixirSuite__Pre_assessment__c"));
        console.log('recordId-->'+Id);
        console.log('contact list value'+JSON.stringify(component.get("v.TreatList")))
           var action = component.get("c.saveTreatmentHistoryRecords");
    
            action.setParams({
                "Records": component.get("v.TreatList")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                         component.set("v.TreatList", []);
                    helper.createObjectData(component, event);
                    
                }
                
                 $A.get("e.force:closeQuickAction").fire(); 
                var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "type" : "Success",
        "title": "Success!",
        "message": "TREATMENT HISTORY ADDED SUCCESSFULLY!."
    });
    toastEvent.fire();
                
                $A.get('e.force:refreshView').fire();
                
            });
           
            $A.enqueueAction(action);
        }
       
   },
 
    addNewRow: function(component, event, helper) {
       
        helper.createObjectData(component, event);
    },
 
    removeDeletedRow: function(component, event, helper) {
    
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
       
        var AllRowsList = component.get("v.TreatList");
        AllRowsList.splice(index, 1);
       
        component.set("v.TreatList", AllRowsList);
    },
})