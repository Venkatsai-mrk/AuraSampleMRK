({
    init: function (cmp) {
        const items = [
           // {"value":"ElixirSuite__Drug_Name__c", "label":"Medication Name"},
            {"value":"reasonLabel", "label":"Reason"},
            {"value":"Route", "label":"Route"},
          // {"value":"CreatedBy", "label":"Created By"},
           // {"value":"CreatedDate", "label":"Created Date"},
          //  {"value":"LastModifiedDate", "label":"Modified Date"},            
           ];
        cmp.set("v.options", items);
        var action = cmp.get("c.getPresColumns");
        action.setParams({});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                if(!$A.util.isUndefinedOrNull(result)){
                    var defaultValues = [];
                    let savedItems = [];
                    savedItems = result.split(';');
                    savedItems.forEach(function(column){ 
                        let idx = items.findIndex(obj => obj.value === column);
                        if(idx!=-1){
                            defaultValues.push(items[idx].value);
                        }
                    });
                    cmp.set("v.values", defaultValues);
                }
    			console.log('columns2'+columns);
            }
            else{
                var errors = response.getError();
                if (errors && Array.isArray(errors) && errors.length > 0) {                   
                    console.log(errors[0].message);
                }
            }
        });
        $A.enqueueAction(action); 
    },
    showOptions:function(cmp){
        cmp.set("v.showOptions",true); 
    },
    cancel:function(cmp){
        cmp.set("v.showOptions",false); 
    },
    Save: function (cmp) {
        var action = cmp.get("c.saveColumns");
        action.setParams({"columns":cmp.get("v.values")});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                var cmpEvent = cmp.getEvent("PrescriptionTableConfigEvt"); 
                //Set event attribute value
                cmpEvent.setParams({ "columns" : cmp.get("v.values") }); 
                cmpEvent.fire();                                     
                cmp.set("v.showOptions",false); 
                
            }
            else{
                cmp.set("v.showOptions",false);               
            }
        });
        $A.enqueueAction(action);
    }
});