({
    getLabels : function(component, event, helper) {
        
        var getLabNames = component.get("c.fetchFieldsForSelectedObject");
        component.set("v.loaded",false);
        getLabNames.setCallback(this, function(response) {
            if (component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                component.set("v.loaded",true);
                component.set("v.companySetting", response.getReturnValue());
                component.set( "v.probList",response.ElixirSuite__Problem_List__c);
                console.log("Company Setting loaded."+JSON.stringify(component.get("v.companySetting")));
                console.log("Company Setting loaded.");
                console.log();
            } else {
                console.log("Failed to load Company Setting.");
            }
        });
        $A.enqueueAction(getSettingsAction);
        
    },
    fetchCSValues :  function(component, event, helper) {
        component.set("v.loaded",false);
        var action = component.get("c.fetchValuesForCSSetting");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",true);
                console.log("1234 "+JSON.stringify(response.getReturnValue()));
                var res = response.getReturnValue();
                var existinfCSSetting = component.get("v.lstOfCustomSetting"); 
                for(let rec in existinfCSSetting){
                    
                    for(let child in res){
                        if(existinfCSSetting[rec].value=='ElixirSuite__Problem_List__c'){
                            existinfCSSetting[rec]['valueForCB'] = res[child].ElixirSuite__Problem_List__c;
                            
                        }     
                        if(existinfCSSetting[rec].value=='ElixirSuite__Allergies_Medical_Alerts__c'){
                            existinfCSSetting[rec]['valueForCB'] = res[child].ElixirSuite__Allergies_Medical_Alerts__c;
                            
                        }     
                        if(existinfCSSetting[rec].value=='ElixirSuite__Lab_Order__c'){
                            existinfCSSetting[rec]['valueForCB'] = res[child].ElixirSuite__Lab_Order__c;
                            
                        }     
                        if(existinfCSSetting[rec].value=='ElixirSuite__Prescriptions__c'){
                            existinfCSSetting[rec]['valueForCB'] = res[child].ElixirSuite__Prescriptions__c;
                            
                        }     
                        if(existinfCSSetting[rec].value=='ElixirSuite__MOR_MAR__c'){
                            existinfCSSetting[rec]['valueForCB'] = res[child].ElixirSuite__MOR_MAR__c;
                            
                        }
                        if(existinfCSSetting[rec].value=='ElixirSuite__UR_Notes__c'){
                            existinfCSSetting[rec]['valueForCB'] = res[child].ElixirSuite__UR_Notes__c;
                            
                        }
                        if(existinfCSSetting[rec].value=='ElixirSuite__Doctor_Notes__c'){
                            existinfCSSetting[rec]['valueForCB'] = res[child].ElixirSuite__Doctor_Notes__c;
                            
                        }
                        if(existinfCSSetting[rec].value=='ElixirSuite__Clinician_Notes__c'){
                            existinfCSSetting[rec]['valueForCB'] = res[child].ElixirSuite__Clinician_Notes__c;
                            
                        }
                        if(existinfCSSetting[rec].value=='ElixirSuite__Nurse_Notes__c'){
                            existinfCSSetting[rec]['valueForCB'] = res[child].ElixirSuite__Nurse_Notes__c;
                            
                        }
                        if(existinfCSSetting[rec].value=='ElixirSuite__Discharge_Notes__c'){
                            existinfCSSetting[rec]['valueForCB'] = res[child].ElixirSuite__Discharge_Notes__c;
                            
                        }     
                        if(existinfCSSetting[rec].value=='ElixirSuite__Vital_Signs__c'){
                            existinfCSSetting[rec]['valueForCB'] = res[child].ElixirSuite__Vital_Signs__c;
                            
                        }
                        if(existinfCSSetting[rec].value=='ElixirSuite__Procedure_Code__c'){
                            existinfCSSetting[rec]['valueForCB'] = res[child].ElixirSuite__Procedure_Code__c;
                            
                        } 
                        
                        if(existinfCSSetting[rec].value=='ElixirSuite__Diagnosis_Code__c'){
                            existinfCSSetting[rec]['valueForCB'] = res[child].ElixirSuite__Diagnosis_Code__c;
                            
                        }       
                    }
                    
                }
                component.set("v.lstOfCustomSetting",existinfCSSetting);
                // alert('sucess 2');
                helper.fetchCategoryValues(component, event, helper);
            }
            else{
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && online[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    
    fetchCategoryfieldValues :  function(component, event, helper) {
        
        
        var recId = component.get( "v.recId" );
        var selectedRows= component.get("v.selectedRows");
        
        var getSettingsAction = component.get("c.fetchFieldsForCategoryObject");
        component.set("v.loaded",false);
        getSettingsAction.setCallback(this, function(response) {
            if (component.isValid() && response !== null && response.getState() == 'SUCCESS') {
                component.set("v.loaded",true);
                component.set("v.categorySetting", response.getReturnValue());
                // component.set( "v.probList",response.ElixirSuite__Problem_List__c);
                console.log("Company Setting loaded."+JSON.stringify(component.get("v.categorySetting")));
                var resp = response.getReturnValue();
                var arr  = [];
                for(let rec in resp){
                    var sObjInstance = {'label' : resp[rec],'value' : rec};
                    arr.push(sObjInstance);
                }
                component.set( "v.lstOfCategory",arr); 
                
                // helper.fetchCategoryValues(component, event, helper);   
                
            } else {
                console.log("Failed to load Company Setting.");
            }
        });
        $A.enqueueAction(getSettingsAction);
        
    },
    
    fetchCategoryValues :  function(component, event, helper) {
        component.set("v.loaded",false);
        var action = component.get("c.fetchValuesForCategoriesSetting");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               
                console.log("12345 "+JSON.stringify(response.getReturnValue()));
                var res = response.getReturnValue();
                var arr = [];
                
                const categoryApiNames = [
                    'ElixirSuite__Category__c', 
                    'ElixirSuite__Category1__c', 'ElixirSuite__Category2__c', 'ElixirSuite__Category3__c', 'ElixirSuite__Category4__c', 'ElixirSuite__Category5__c', 
                    'ElixirSuite__Category6__c', 'ElixirSuite__Category7__c', 'ElixirSuite__Category8__c', 'ElixirSuite__Category9__c', 'ElixirSuite__Category10__c', 
                    'ElixirSuite__Category11__c', 'ElixirSuite__Category12__c', 'ElixirSuite__Category13__c', 'ElixirSuite__Category14__c', 'ElixirSuite__Category15__c', 
                    'ElixirSuite__Category16__c', 'ElixirSuite__Category17__c', 'ElixirSuite__Category18__c', 'ElixirSuite__Category19__c'
                ];

                for(let rec in res){
                    for (let categoryApi of categoryApiNames) {
                        let categoryValue = res[rec][categoryApi];

                        if (categoryValue) {
                            arr = arr.concat(categoryValue.split(';'));
                        }
                    }
                }
           
                
          
                var puValueArr = [];
                for(let rec1 in arr){
                    puValueArr.push({'label' : arr[rec1],'value' : arr[rec1],'valueForCAT':false});                    
                }
                
                component.set("v.lstOfCategoryvalues",puValueArr);
                 component.set("v.loaded",true);
                // alert('sucess 3');      
            }
            else{
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && online[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
            
        });
        
        $A.enqueueAction(action);
    }
    
})