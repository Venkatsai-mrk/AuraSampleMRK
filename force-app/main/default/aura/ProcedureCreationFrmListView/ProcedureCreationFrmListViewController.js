({
    doInit : function(component, event, helper) {
        //var recid = component.get("v.recordId");
        component.set("v.accountId",component.get("v.accId"));
        //tried for getting account id by MEGHNA - Shwetha please check this
       /* var pageReference = component.get("v.pageReference").state.ws;
        var sURLVariables = pageReference.split('/');
        
         var i;

        for (i = 0; i < sURLVariables.length; i++) 
        {
            component.set("v.accountId",sURLVariables[4]);
        }
        */
        //Fetching Record Type Id  
        var action = component.get("c.recTypemed");
       
        action.setCallback(this, function(a) {
            component.set("v.recTypeId", a.getReturnValue());
        });
        $A.enqueueAction(action);
       
        //var recordTypeId = component.get( "v.pageReference" ).state.recordTypeId;  
        //component.set('v.recTypeId' , recordTypeId);
       
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
        var p  = component.get("v.accountId");
        var dummy = '/lightning/r/'+p+'/related/ElixirSuite__Procedures__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+p+'%2Fview';
        
        var navEvent = sforce.one.navigateToURL(dummy, true);
        
    },
    
     handleSuccess: function(component, event, helper) {
        var p  = component.get("v.accountId");
        var dummy = '/lightning/r/'+p+'/related/ElixirSuite__Procedures__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+p+'%2Fview';
        
        var navEvent = sforce.one.navigateToURL(dummy,true);
         
         sforce.one.showToast({
             "title": "Success!",
             "type" : 'success',
             "message": "The record has been created successfully."
         });
      /*  var params = event.getParams();
        cmp.find("navService").navigate({
            "type": "standard__recordPage",
            "attributes": {
                "recordId": params.response.id,
                "objectApiName": "ElixirSuite__Procedure__c",
                "actionName": "view"
            }
        });*/
         
    }
})