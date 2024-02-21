({
    doInit : function(component, event, helper) {
        
        //Fetching Record Type Id  
        var recordTypeId = component.get( "v.pageReference" ).state.recordTypeId;  
        component.set('v.recTypeId' , recordTypeId);
        
        var val = component.find("isBillable").get("v.value");
        if(val == true){
            component.set('v.hideBill' , false);
            component.set('v.hideBilled' , false);
        }
        else if(val == false)
        {
            component.set('v.hideBill' , true);
            component.set('v.hideBilled' , true);
        }
        
        //for isBilled
        var val = component.find("isBilld").get("v.value");
        if(val == true){
            component.set('v.hide' , true);
            component.set('v.hideBill' , true);
        }
        else if(val == false)
        {
            component.set('v.hide' , false);
            //component.set('v.hideBill' , false);
        }
        
        
    },
    
    disableFields : function(component, event, helper) {
        var val = component.find("isBilld").get("v.value");
        if(val == true){
            component.set('v.hide' , true);
            component.set('v.hideBill' , true);
        }
        else if(val == false)
        {
            component.set('v.hide' , false);
            component.set('v.hideBill' , false);
        }
    },
    
    disableBillFields : function(component, event, helper) {
        var val = component.find("isBillable").get("v.value");
        if(val == true){
            component.set('v.hideBill' , false);
            component.set('v.hideBilled' , false);
        }
        else if(val == false)
        {
            component.set('v.hideBill' , true);
            component.set('v.hideBilled' , true);
        }
    },
    
    
    searchKeyChange : function(component, event, helper) {
        var searchKey = component.find("searchKey").get("v.value");
        console.log('searchKey:::::'+searchKey);
        var action = component.get("c.searchKeyResult");
        action.setParams({
            "searchKey": searchKey
        });
        action.setCallback(this, function(a) {
            component.set("v.Procedures", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    handleCreateProcedure : function(component, event, helper) {
        component.find("accForm").submit();
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": 'success',
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    },
    
    handleSubmit : function(component, event, helper) {
        event.preventDefault(); // Prevent default submit
        var fields = event.getParam("fields");
        var CptCode = component.find("cptCode").get("v.value");
        fields["ElixirSuite__CPT_HCPCS_Code__c"] = CptCode; // Prepopulate cpt code field
        component.find('accForm').submit(fields); // Submit form
    },
    
    handleComponentEvent: function(component, event, helper) {
        var eventValue = event.getParams().selectedValue;
        
        var action = component.get("c.searchKeyProc");
        action.setParams({
            "proId": eventValue.Id
        });
        action.setCallback(this, function(a) {
            component.set("v.Procedures", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
   
    
    Cancel : function(component, event, helper) {
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "ElixirSuite__Procedure__c"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    handleSuccess: function(cmp, event, helper) {
        var params = event.getParams();
        cmp.find("navService").navigate({
            "type": "standard__recordPage",
            "attributes": {
                "recordId": params.response.id,
                "objectApiName": "ElixirSuite__Procedure__c",
                "actionName": "view"
            }
        });
    }
    
})