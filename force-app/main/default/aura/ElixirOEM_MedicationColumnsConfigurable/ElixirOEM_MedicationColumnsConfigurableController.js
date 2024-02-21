({
    init: function (cmp) {
       /* const items = [
            {"value":"strength", "label":"Strength"}
            
        ];
       cmp.set("v.options", items);
       console.log('options**** '+JSON.stringify(items));*/
        var action = cmp.get("c.getMedicationColumns");
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log('getting values from custom setting**** '+result);
            var state = response.getState();
            console.log('state '+state);
        		if (state === "SUCCESS") {
            
            	var result = response.getReturnValue();
                console.log('result**',JSON.stringify(result));
                var resCol  = result.medicationColumns;
               	var reqFieldsMap  = result.mapRequiredFields;
                
              console.log('reqFieldsMap=========='+reqFieldsMap);
            
                 
                var reqFieldsList = [];
                for (var key in reqFieldsMap) {
                    if (reqFieldsMap.hasOwnProperty(key)) {
                        reqFieldsList.push({ label: key, value: reqFieldsMap[key] });
                    }
                }
        		// Later, concatenate the new values to the existing values
			//	cmp.set("v.options", items.concat(reqFieldsList));
				cmp.set("v.options", reqFieldsList);
                
                var reqFieldsApi  = result.requiredFieldsApi;
                var reqFieldsLabel = result.requiredFieldsLabel;
                
                cmp.set("v.reqFieldApi", reqFieldsApi);
                cmp.set("v.reqFieldLabel", reqFieldsLabel);
            
            	if(!$A.util.isUndefinedOrNull(resCol)){
                    var defaultValues = [];
                    let savedItems = [];
                    savedItems = resCol.split(';');
                   
                    for (var i=0;i<savedItems.length;i++) {
                        console.log('inside 53',savedItems[i]);
                        defaultValues.push(savedItems[i]);
                    }
                    cmp.set("v.values", defaultValues);
                    
                    
                }
            	var col = cmp.get("v.options");
                
				var defaultValues = cmp.get("v.values");
                if(defaultValues.length>0){
                    
                    var refreshEvt = $A.get("e.c:ElixirOEM_MedicationColumnsEvent");
                    refreshEvt.setParams({ "columns" : cmp.get("v.values"),
                                          "finalColumnsApi" : reqFieldsApi,
                                          "finalColumnsLabel" : reqFieldsLabel});
                    refreshEvt.fire();
                    
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
    showOptions1:function(cmp){
       cmp.set("v.showOptions",true); 
    },
    cancel:function(cmp){
        cmp.set("v.showOptions",false); 
     },
    Save: function (cmp) {
       var valuesLst = cmp.get("v.values");
    	console.log('valuesLst***', valuesLst.length);

    	if (valuesLst.length > 10) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: 'Info',
            message: 'You can select up to 10 fields',
            duration: '5000',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
    	} else {
        var action = cmp.get("c.saveColumns");
        action.setParams({ "columns": cmp.get("v.values") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state***', state);
            if (state === "SUCCESS") {
                console.log('Preparing to fire event...');
                var refreshEvt = $A.get("e.c:ElixirOEM_MedicationColumnsEvent");
                refreshEvt.setParams({
                    "columns": cmp.get("v.values"),
                    "finalColumnsApi": cmp.get("v.reqFieldApi"),
                    "finalColumnsLabel": cmp.get("v.reqFieldLabel")
                });
                refreshEvt.fire();
                console.log('Event fired successfully!');
                cmp.set("v.showOptions", false);
            } else {
                cmp.set("v.showOptions", false);
            }
        });

        $A.enqueueAction(action);
    }
    }
});