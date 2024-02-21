({
	 init: function (cmp) {
       /*const items = [
            
            {"value":"icdCode", "label":"ICD Code"},
            {"value":"icdDescription", "label":"ICD Description"},
            {"value":"icdVersion", "label":"ICD Version"},
            {"value":"diagnosisType", "label":"Diagnosis Type"},
            {"value":"dateDiagonoses", "label":"Date Diagnoses"},
            {"value":"notes", "label":"Notes"}
             ];*/
        //cmp.set("v.options", items);
        var action = cmp.get("c.getDiagnosisColumns");
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log('getting values from custom setting**** '+result);
            var state = response.getState();
            console.log('state '+state);
            if (state === "SUCCESS") {
            
            	var result = response.getReturnValue();
                console.log('result**',JSON.stringify(result));
                var resCol  = result.diagnosisColumns;
               // var reqFields  = result.requiredFields;
                var reqFieldsMap  = result.mapRequiredFields;
                console.log('reqFieldsMap**',reqFieldsMap);
                console.log('reqFieldsMap ==**',JSON.stringify(reqFieldsMap));
                
                // Convert reqFieldsMap to a list of objects with label and value properties
                var reqFieldsList = [];
                for (var key in reqFieldsMap) {
                    if (reqFieldsMap.hasOwnProperty(key)) {
                        reqFieldsList.push({ label: key, value: reqFieldsMap[key] });
                    }
                }

                // Now, you can use reqFieldsList in your component
                console.log('reqFieldsList ==**', JSON.stringify(reqFieldsList));
                //var items=JSON.stringify(reqFieldsList);
                cmp.set("v.options", reqFieldsList);
                
                
                
                var reqFieldsApi  = result.requiredFieldsApi;
                console.log('reqFieldsApi**',reqFieldsApi);
                console.log('reqFieldsApi ==**',JSON.stringify(reqFieldsApi));
                var reqFieldsLabel = result.requiredFieldsLabel;
                console.log('reqFieldsLabel**',reqFieldsMap);
                console.log('reqFieldsLabel ==**',JSON.stringify(reqFieldsLabel));
                cmp.set("v.reqFieldApi", reqFieldsApi);
                cmp.set("v.reqFieldLabel", reqFieldsLabel);
            
            	if(!$A.util.isUndefinedOrNull(resCol)){
                    var defaultValues = [];
                    let savedItems = [];
                    savedItems = resCol.split(';');
                    console.log('savedItems**',savedItems);
                    
                    for (var i=0;i<savedItems.length;i++) {
                        console.log('inside 53',savedItems[i]);
                        defaultValues.push(savedItems[i]);
                    }
                    
                    cmp.set("v.values", defaultValues);
                    console.log('defaultValues**',defaultValues);
                    
                }
            	var col = cmp.get("v.options");
              /*  if(reqFieldsMap!=null){
                    console.log('line 56****');
                    
                    for ( var key in reqFieldsMap ) {
                        col.push({"value":reqFieldsMap[key], "label":key});
                    }
                    
                    cmp.set("v.options", col);
                }*/
                var defaultValues = cmp.get("v.values");
                console.log('defaultValues****',defaultValues.length);
                if(defaultValues.length>0){
                    
                    var refreshEvt = $A.get("e.c:ElixirOEM_DiagnosisColumnsEvent");
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
   showOptions:function(cmp){
        cmp.set("v.showOptions",true); 
    },
    cancel:function(cmp){
        cmp.set("v.showOptions",false); 
    },
   /* Save: function (cmp) {
        
        var valuesLst = cmp.get("v.values");
        console.log('valuesLst***',valuesLst.length);
        
        if(valuesLst.length > 10){
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info',
                        message: 'You can select upto 10 fields',
                        duration:' 5000',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
        }
        else{
        var action = cmp.get("c.saveColumns");
        console.log('values***',JSON.stringify(cmp.get("v.values")));
        action.setParams({"columns":cmp.get("v.values")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state***',state);
            if (state === "SUCCESS") {
                 console.log('values***',JSON.stringify(cmp.get("v.values")));
                console.log('reqFieldApi***',JSON.stringify(cmp.get("v.reqFieldApi")));
                console.log('reqFieldLabel***',JSON.stringify(cmp.get("v.reqFieldLabel")));
                 
                var refreshEvt = $A.get("e.c:ElixirOEM_DiagnosisColumnsEvent");
                refreshEvt.setParams({ "columns" : cmp.get("v.values"),
                                      "finalColumnsApi" : cmp.get("v.reqFieldApi"),
                                      "finalColumnsLabel" : cmp.get("v.reqFieldLabel")});
                refreshEvt.fire();
                console.log('*Event Fire*');
                cmp.set("v.showOptions",false); 
            }
            else{
                cmp.set("v.showOptions",false);               
            }
        });
    }
        $A.enqueueAction(action);
    }*/
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
        console.log('values***', JSON.stringify(cmp.get("v.values")));
        action.setParams({ "columns": cmp.get("v.values") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state***', state);
            if (state === "SUCCESS") {
                console.log('values***', JSON.stringify(cmp.get("v.values")));
                console.log('reqFieldApi***', JSON.stringify(cmp.get("v.reqFieldApi")));
                console.log('reqFieldLabel***', JSON.stringify(cmp.get("v.reqFieldLabel")));

                var refreshEvt = $A.get("e.c:ElixirOEM_DiagnosisColumnsEvent");
                refreshEvt.setParams({
                    "columns": cmp.get("v.values"),
                    "finalColumnsApi": cmp.get("v.reqFieldApi"),
                    "finalColumnsLabel": cmp.get("v.reqFieldLabel")
                });
                refreshEvt.fire();
                console.log('*Event Fire*');
                cmp.set("v.showOptions", false);
            } else {
                cmp.set("v.showOptions", false);
            }
        });

        $A.enqueueAction(action);
    }
}

})