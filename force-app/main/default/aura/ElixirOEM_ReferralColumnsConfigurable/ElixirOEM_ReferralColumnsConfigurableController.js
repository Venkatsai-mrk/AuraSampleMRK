({
    init: function (cmp) {
        const items = [
            {"value":"ElixirSuite__Provider__c", "label":"Location"},
            {"value":"ElixirSuite__Referred_Out_Organization__c", "label":"Referred Out Organization"},
            {"value":"ElixirSuite__User__c", "label":"Care Team Member"},
            {"value":"ElixirSuite__Referred_To__c", "label":"Referred To"},
            {"value":"ElixirSuite__Email_CTM__c", "label":"Email (CTM)"},
            {"value":"ElixirSuite__Phone_CTM__c", "label":"Phone (CTM)"},
            {"value":"ElixirSuite__Email_Referred_To__c", "label":"Email"},
            {"value":"ElixirSuite__Phone_Referred_To__c", "label":"Phone"},
              {"value":"CreatedBy", "label":"Created By "},
            
        ];
        cmp.set("v.options", items);
        var action = cmp.get("c.getProblemColumns");
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
                var cmpEvent = cmp.getEvent("ElixirOEM_ProblemColumnsEvent"); 
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