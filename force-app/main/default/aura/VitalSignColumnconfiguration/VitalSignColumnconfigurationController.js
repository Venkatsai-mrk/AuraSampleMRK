({
    init: function (cmp) {
        const items = [
            {"value":"BloodPressureSystolic", "label":"Blood Pressure Systolic"},
            {"value":"BloodPressureDiasystolic", "label":"Blood Pressure Diasystolic"},
            {"value":"Temperature", "label":"Temperature"},
            {"value":"Pulse", "label":"Pulse"},
            {"value":"Respiration", "label":"Respiration"},
            {"value":"OxygenSaturation", "label":"Oxygen Saturation"},
            {"value":"VitalAdministeredBy", "label":"Vital Administered By"}
        ];
        cmp.set("v.options", items);
        var action = cmp.get("c.getVitalSignColumns");
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
                    console.log('defaultValues ==', defaultValues);
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
        try{
            var action = cmp.get("c.saveVitalSignColumns");
        action.setParams({"vitalsColumns":cmp.get("v.values")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var refreshEvt = cmp.getEvent("ElixirOEM_VitalSignColumnsEvent");
                refreshEvt.setParams({ "vitalsColumns" : cmp.get("v.values") });
                refreshEvt.fire();
                cmp.set("v.showOptions",false); 
            }
            else{
                    cmp.set("v.showOptions",false);               
            }
        });
        $A.enqueueAction(action);
        }
        catch(e){
            console.log(e)
        }
    }
});