({
    SearchHelper: function(component) {
        var allData = component.get('v.allOptions');
        var searchKeyWord = component.get("v.searchKeyword");
        var fillData = allData.filter(function(dat) {
            console.log('dat name'+dat.Name);
            return (dat.ElixirSuite__Problem_Name__c.toLowerCase()).startsWith(searchKeyWord.toLowerCase());
        });  
        if($A.util.isEmpty(fillData)){
            component.set("v.templateProblems", []);
            var templateProblems = component.get("v.templateProblems");
            templateProblems = templateProblems.concat(component.get("v.NewProblemRecordsList"));
            component.set("v.existingProblems.data",templateProblems);
        }
        else {
            
            component.set("v.templateProblems", fillData);
            var templateProblems = component.get("v.templateProblems");
            templateProblems = templateProblems.concat(component.get("v.NewProblemRecordsList"));
            component.set("v.existingProblems.data",templateProblems);
        }
        
        console.log('helper ret ' + JSON.stringify(component.get("v.templateProblems")));
        
    },
    isValidationRequiered :  function(component,finalJsonToSave) {
        var isEmpty  = false;
        for (var validation in finalJsonToSave) {
            
            if(finalJsonToSave[validation].problemIsChecked){
                isEmpty = true;
                break;
            }
            
            
        }
        return isEmpty;
    },
    createObjectData: function(component, event) {
        // get the problemList from component and add(push) New Object to List  
        var RowItemList = component.get("v.NewProblemRecordsList");
        RowItemList.push({
            "Name":"",
            "ElixirCS__Problem_Name__c":"",            
            "problemIsChecked":false,
            "isProblemEditable":true,
            "displayRelatedDaignoses":false,
            "HealthCloudGA__EvidenceLabel__c" :"",
            "isAddedFromTemplate" : false,
            "isProblemToInsert": false,
            "relatedDiagnoses":[],             
            "relatedNotes":[{"ElixirCS__Notes__c":"","isEditableNotes":true}]}); // related notes will be only 1 for now; As we are not clear with notes right now;
        component.set("v.NewProblemRecordsList", []);      
        component.set("v.NewProblemRecordsList", RowItemList);
        var itemData  = component.get("v.NewProblemRecordsList");
        itemData = itemData.concat(component.get("v.templateProblems"));
        component.set("v.existingProblems.data",itemData);
    },
    // helper function for check if Intervention is not null/blank on save  
    validateRequired: function(component, event) {
        var isValid = true;
        var allAllergyRows = component.get("v.glucoseList");
        for (var indexVar = 0; indexVar < allAllergyRows.length; indexVar++) {
            if (allAllergyRows[indexVar].Intervention_s__c == '') {
                isValid = false;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "info!",
                    "message": "Intervention Can\'t be Blank on Row Number " + (indexVar + 1)
                });
                toastEvent.fire();
                
            }
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
    hideSpinner:function(cmp){
        
        cmp.set("v.IsSpinner",false);
        
    },
    checkTemplateValidation : function(component, event) {
        var flagPass = false ; 
        var getTemplateProblem =  component.get("v.templateProblems");
        for(var rec in getTemplateProblem){
            if(getTemplateProblem[rec].problemIsChecked){
                flagPass = true; 
                 break ; 
            }
           
        }
        return flagPass ; 
    }, 
    checkNonTemplateValidation : function(component, event) {
        var flagPass = false ; 
        var getNonTemplateProblem =  component.get("v.NewProblemRecordsList");
        for(var rec in getNonTemplateProblem){
            if(getNonTemplateProblem[rec].problemIsChecked){
                flagPass = true; 
                break ; 
            }
            
        }
        return flagPass ; 
    },
    checkFiledsValidity : function(component,event,helper){
        var getUndefinedProperty  = component.find('URFiledsValid');
        var fieldsValid ; 
        if(!$A.util.isUndefinedOrNull(getUndefinedProperty) && Array.isArray(getUndefinedProperty)){
            fieldsValid = component.find('URFiledsValid').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true); 
        }
         return fieldsValid;
    }
   
    
})