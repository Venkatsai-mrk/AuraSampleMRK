({
    createObjectData: function(component, event) {
        // get the glucoseList from component and add(push) New Object to List  
        var RowItemList = component.get("v.glucoseList");
        RowItemList.push({
            'sobjectType': 'ElixirSuite__Medical_Examination__c',
            'ElixirSuite__Glucose_Reading__c': '',
            'ElixirSuite__Intervention__c': '',
            'ElixirSuite__Type_of_check__c': '',
            'ElixirSuite__Note__c' : '',
            'ElixirSuite__Account__c' : component.get("v.patientID")
        });
        
        // set the updated list to attribute (glucoseList) again    
        
        component.set("v.glucoseList", []);      
        component.set("v.glucoseList", RowItemList);
        
        //      alert(JSON.stringify(component.get("v.glucoseList")));
        
    },
    // helper function for check if Intervention is not null/blank on save  
    validateRequired: function(component, event) {
        var isValid = true;
        var allAllergyRows = component.get("v.glucoseList");
        for (var indexVar = 0; indexVar < allAllergyRows.length; indexVar++) {
            if (allAllergyRows[indexVar].ElixirSuite__Intervention__c == '') {
                isValid = false;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "info!",
                    "message": "Intervention Can\'t be Blank on Row Number " + (indexVar + 1)
                });
                toastEvent.fire();
                
            }
            break;
        }
        return isValid;
    },
    emptyCheck: function(component, event) {
        var isValid = false;
        var allAllergyRows = component.get("v.glucoseListCopyToSave");
        for (var indexVar = 0; indexVar < allAllergyRows.length; indexVar++) {
            if (allAllergyRows[indexVar].ElixirSuite__Intervention__c != '') {
                isValid = true;
                                
            }
            break;
        }
        return isValid;
    },
    setAllPicklistValues: function(component) {
        var action = component.get("c.getAllPicklistValues");
        
        
        action.setCallback(this, function(response) {
            var res = response.getReturnValue();
            
            // console.log('helper ret ' + JSON.stringify(response.getReturnValue()));
            // component.set("v.AvailableTest", res['AvailableTest']);
            component.set("v.InterventionValues", res['InterventionValues']);
            component.set("v.typeCheck", res['typeCheck']);
            // component.set("v.OrderViaValues", res['OrderViaValues']);
            // alert('order via val '+JSON.stringify( res['OrderViaValues']));
            
            
            
            
        });
        
        $A.enqueueAction(action);
        
        
    },
})