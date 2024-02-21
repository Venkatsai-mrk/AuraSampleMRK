({
    getUser : function(component, event, helper) {
        var action = component.get("c.getCurrentlyLoggedInUser");
        console.log('AccountId--'+component.get("v.AccountId"));
        action.setCallback(this, function (response){
            //alert('response.getRetunrValue()----'+response.getReturnValue());
            component.set("v.CurrentUserDetails",response.getReturnValue());
            console.log("user details-"+JSON.stringify(component.get("v.CurrentUserDetails")));
        });
        $A.enqueueAction(action);
        
    },
    validateRequired: function(component, event) {
        var isValid = true;
        var allAllergyRows = component.get("v.newVitalSign");
        // for (var indexVar = 0; indexVar < allAllergyRows.length; indexVar++) {
        if (allAllergyRows.ElixirSuite__Blood_Pressure_Systolic__c == ' ' &&
            allAllergyRows.ElixirSuite__Blood_Pressure_Diasystolic__c == ' ' &&
            allAllergyRows.ElixirSuite__Temperature__c == ' ' &&
            allAllergyRows.ElixirSuite__Pulse__c == ' ' &&
            allAllergyRows.ElixirSuite__Respiration__c == ' ' &&
            allAllergyRows.ElixirSuite__Oxygen_Saturation__c == ' ') {
            isValid = false;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : "error",
                "title": "PLEASE FILL ATLEAST 1 FIELD!",
                "message": "No Input!"
            });
            toastEvent.fire();
            
        }
        
        //  }
        return isValid;
    },
    validateRequiredForForms: function(component, event) {
        var isValid = true;
        var allAllergyRows = component.get("v.newVitalSign");
        // for (var indexVar = 0; indexVar < allAllergyRows.length; indexVar++) {
        if (allAllergyRows.ElixirSuite__Blood_Pressure_Systolic__c == '' &&
            allAllergyRows.ElixirSuite__Blood_Pressure_Diasystolic__c == '' &&
            allAllergyRows.ElixirSuite__Temperature__c == '' &&
            allAllergyRows.ElixirSuite__Pulse__c == '' &&
            allAllergyRows.ElixirSuite__Respiration__c == '' &&
            allAllergyRows.ElixirSuite__Oxygen_Saturation__c == '') {
            isValid = false;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : "error",
                "title": "PLEASE FILL ATLEAST 1 FIELD!",
                "message": "No Input!"
            });
            toastEvent.fire();
            
        }
        
        //  }
        return isValid;
    },
    unitsArrange : function(component, event, helper,res) {
        for(let rec in res){
            if(res[rec].hasOwnProperty('ElixirSuite__Respiration__c')){
                if(res[rec].ElixirSuite__Respiration__c.includes('Breaths/Minute')){
                    res[rec].ElixirSuite__Respiration__c = res[rec].ElixirSuite__Respiration__c.replace('Breaths/Minute','');
                }
            }
            if(res[rec].hasOwnProperty('ElixirSuite__Oxygen_Saturation__c')){
                if(res[rec].ElixirSuite__Oxygen_Saturation__c.includes('%')){
                    res[rec].ElixirSuite__Oxygen_Saturation__c=  res[rec].ElixirSuite__Oxygen_Saturation__c.replace('%','');
                }
            }
            if(res[rec].hasOwnProperty('ElixirSuite__Blood_Pressure_Diasystolic__c')){
                if(res[rec].ElixirSuite__Blood_Pressure_Diasystolic__c.includes('mmHg')){
                    res[rec].ElixirSuite__Blood_Pressure_Diasystolic__c=  res[rec].ElixirSuite__Blood_Pressure_Diasystolic__c.replace('mmHg','');
                }
            } 	
            if(res[rec].hasOwnProperty('ElixirSuite__Blood_Pressure_Systolic__c')){
                if(res[rec].ElixirSuite__Blood_Pressure_Systolic__c.includes('mmHg')){
                    res[rec].ElixirSuite__Blood_Pressure_Systolic__c = res[rec].ElixirSuite__Blood_Pressure_Systolic__c.replace('mmHg','');
                }
            }
            if(res[rec].hasOwnProperty('ElixirSuite__Temperature__c')){
                if(res[rec].ElixirSuite__Temperature__c.includes('F*')){
                    res[rec].ElixirSuite__Temperature__c = res[rec].ElixirSuite__Temperature__c.replace('F*','');
                }
            }
            if(res[rec].hasOwnProperty('ElixirSuite__Pulse__c')){
                if(res[rec].ElixirSuite__Pulse__c.includes('BPM')){
                    res[rec].ElixirSuite__Pulse__c =  res[rec].ElixirSuite__Pulse__c.replace('BPM','');
                }
            }
        }
    }
})