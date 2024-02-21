({
    init: function (cmp) {
        const items = [
            {"value":"formCategory", "label":"Category"},
            {"value":"status", "label":"Status"},
            {"value":"careEpisode", "label":"Care Episode"},
            {"value":"content1", "label":"Approval Level 1"},
            {"value":"content2", "label":"Approval Level 2"},
            {"value":"content3", "label":"Approval Level 3"},
            {"value":"content4", "label":"Approval Level 4"},
            {"value":"content5", "label":"Approval Level 5"},
            {"value":"CreatedBy", "label":"Created By"}
        ];
        cmp.set("v.options", items);
        var action = cmp.get("c.getFormsColumns");
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
                var refreshEvt = $A.get("e.c:FormsRefreshEvt");
                refreshEvt.setParams({ "columns" : cmp.get("v.values") });
                refreshEvt.fire();
                cmp.set("v.showOptions",false); 
            }
            else{
                    cmp.set("v.showOptions",false);               
            }
        });
        $A.enqueueAction(action);
    }
});