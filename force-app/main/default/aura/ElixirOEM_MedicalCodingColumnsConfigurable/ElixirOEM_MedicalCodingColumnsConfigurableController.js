({
    init: function (cmp) {
        const items = [
            {"value":"modifier1", "label":"Modifier 1"},
            {"value":"modifier2", "label":"Modifier 2"},
            {"value":"modifier3", "label":"Modifier 3"},
            {"value":"modifier4", "label":"Modifier 4"},
            {"value":"diagCode", "label":"Diagnosis Codes"},
            {"value":"procStart", "label":"Procedure Start"},
            {"value":"procEnd", "label":"Procedure End"},
            {"value":"duration", "label":"Units/Duration"},
            {"value":"placeOfService", "label":"Place Of Service"},
            {"value":"claimStatus", "label":"Claim Status"},
            {"value":"readyForBilling", "label":"Is Ready for Billing"},
            {"value":"claimGenerated", "label":"Claim Generated"},
            {"value":"isProcessed", "label":"Is Processed"},
            {"value":"careEpisode", "label":"Care Episode"},
            {"value":"status", "label":"Status"},
            {"value":"cancelationReason", "label":"Cancelation Reason"},
           // {"value":"CreatedBy", "label":"Created By"},
        ];
        cmp.set("v.options", items);
        var action = cmp.get("c.getProcedureColumns");
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
            //  var result = response.getReturnValue();
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