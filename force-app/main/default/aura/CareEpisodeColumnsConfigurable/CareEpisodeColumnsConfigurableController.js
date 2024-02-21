({
    init: function (cmp) {
        const items = [
            {"value":"account", "label":"Account"},
            {"value":"admDate", "label":"Admit Date"},
            {"value":"provider", "label":"Care Episode Location"},
            {"value":"discDate", "label":"Discharge Date"},
            {"value":"location", "label":"Location"},
            {"value":"locAdd", "label":"Location Address"},
            {"value":"perEnd", "label":"Period End"},
            {"value":"perStart", "label":"Period Start"},
            {"value":"prior", "label":"Priority"},
            {"value":"reason", "label":"Reason"},
            {"value":"status", "label":"Status"},
            {"value":"authNum", "label":"Pre Authorization Number"},
            {"value":"days", "label":"Days"},
            {"value":"parentCareEpisode", "label":"Parent Care Episode"}
        ];
        cmp.set("v.options", items);
        var action = cmp.get("c.getFormsColumns");
        action.setParams({});
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            console.log('state***',state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result**',JSON.stringify(result));
                var resCol  = result.careEpisodeColumns;
                var reqFields  = result.requiredFields;
                var reqFieldsMap  = result.mapRequiredFields;
                var reqFieldsApi  = result.requiredFieldsApi;
                var reqFieldsLabel = result.requiredFieldsLabel;
                cmp.set("v.reqFieldApi", reqFieldsApi);
                cmp.set("v.reqFieldLabel", reqFieldsLabel);
               /* var savedItems = resCol.split(';');
                for (var i=0;i<savedItems.length;i++) {
                    console.log('inside 37',savedItems[i]);
                }*/
                
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
                console.log('reqFields****',reqFields);
                if(reqFieldsMap!=null){
                    console.log('line 56****');
                    
                    for ( var key in reqFieldsMap ) {
                        col.push({"value":reqFieldsMap[key], "label":key});
                    }
                    
                    cmp.set("v.options", col);
                }
                var defaultValues = cmp.get("v.values");
                console.log('defaultValues****',defaultValues.length);
                if(defaultValues.length>0){
                    
                    var refreshEvt = $A.get("e.c:CareEpisodeRefreshEvt");
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
    Save: function (cmp) {
        
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
        
        action.setParams({"columns":cmp.get("v.values")});
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                var refreshEvt = $A.get("e.ElixirSuite:CareEpisodeRefreshEvt");
                refreshEvt.setParams({ "columns" : cmp.get("v.values"),
                                      "finalColumnsApi" : cmp.get("v.reqFieldApi"),
                                      "finalColumnsLabel" : cmp.get("v.reqFieldLabel")});
                refreshEvt.fire();
                cmp.set("v.showOptions",false); 
            }
            else{
                cmp.set("v.showOptions",false);               
            }
        });
    }
        $A.enqueueAction(action);
    }
    
})