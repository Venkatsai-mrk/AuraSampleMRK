({
    createObjectData: function(component, event) {
        // get the allergyList from component and add(push) New Object to List  
        var RowItemList = component.get("v.allergyList");
        RowItemList.push({
             'sobjectType': 'ElixirSuite__Medical_Examination__c',
            'AllergyName':'',
            'Substance': '',
            'SubstanceCode': '',
            'Reaction': '', 
            'Severity':'',
            'Notes' : '',
            'ElixirSuite__Account__c' : component.get("v.patientID")
        });
        
        // set the updated list to attribute (allergyList) again    
        
       // component.set("v.allergyList", []); 
       
        component.set("v.allergyList", RowItemList);
        
        //      alert(JSON.stringify(component.get("v.allergyList")));
        
    },
    
    // helper function for check if Substance Code is not null/blank on save  
    validateRequired: function(component, event) {
        var isValid = true;
        var allAllergyRows = component.get("v.allergyList");
        for (var indexVar = 0; indexVar < allAllergyRows.length; indexVar++) {
            if (allAllergyRows[indexVar].ElixirSuite__Substance_Code__c == '') {
                isValid = false;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "info!",
                    "message": "Substance Code Can\'t be Blank on Row Number " + (indexVar + 1)
                });
                toastEvent.fire();
                //alert('Substance Code Can\'t be Blank on Row Number ' + (indexVar + 1));
            }
        }
        return isValid;
    },
    emptyCheck : function(component, event) {
        var isValid = false;
        var allAllergyRows = component.get("v.allergyListCopyToSave");
        for (var indexVar = 0; indexVar < allAllergyRows.length; indexVar++) {
            if (allAllergyRows[indexVar].ElixirSuite__Substance_Code__c != '') {
                isValid = true;
                
                
            }
        }
        return isValid;
    },
    dataFetchDecision : function(component, event,helper) {
        if(component.get("v.column").ElixirSuite__Form_Specific_Data__c){
            
        }
        else {
            
            var action = component.get("c.fetchAcctAllergies");
            action.setParams({ 'acctId' : component.get("v.patientID")
                              
                             });
            action.setCallback(this, function(response) {
                var result = response.getReturnValue();
                var state = response.getState();
                if (state === "SUCCESS") {  
                    component.set("v.allergyList",result.accountSpeicificAllergies);
                }
            });
            $A.enqueueAction(action); 
        }
    }
})