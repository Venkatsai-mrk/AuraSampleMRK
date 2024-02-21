({
    // To prepopulate the seleted value pill if value attribute is filled
    doInit : function( component, event, helper ) {
        $A.util.toggleClass(component.find('resultsDiv'),'slds-is-open');
        if( !$A.util.isEmpty(component.get('v.value')) ) {
            helper.searchRecordsHelper( component, event, helper, component.get('v.value') );
        }
    },
    
    // When a keyword is entered in search box
    searchRecords : function( component, event, helper ) {
        if( !$A.util.isEmpty(component.get('v.searchString')) ) {
            helper.searchRecordsHelper( component, event, helper, '' );
        } else {
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    
    // When an item is selected
    selectItem : function( component, event, helper ) {
       
        if(!$A.util.isEmpty(event.currentTarget.id)) {
            var recordsList = component.get('v.recordsList');
            var index = recordsList.findIndex(x => x.value === event.currentTarget.id)
            if(index != -1) {
                var selectedRecord = recordsList[index];
            }
            component.set('v.selectedRecord',selectedRecord);
            component.set('v.value',selectedRecord.value);
            component.set("v.checkValue" , false);
            var prescription = component.get('v.fromPrescription');
            var jsonListNew='';
            if(prescription == "Medication"){
                let jsonList =   component.get('v.jsonList');
                jsonList.medicationId = selectedRecord.value;
                component.set("v.jsonList" , jsonList);
                jsonListNew=component.get('v.jsonList');
              }
            if(prescription == "Dosage"){
                let jsonList =   component.get('v.jsonList');
                jsonList.dosageFormId = selectedRecord.value;
                component.set("v.jsonList" , jsonList);
                jsonListNew=component.get('v.jsonList');
              }
            if(prescription == "Route"){
                let jsonList =   component.get('v.jsonList');
                jsonList.RouteId = selectedRecord.value;
                component.set("v.jsonList" , jsonList);
                jsonListNew=component.get('v.jsonList');
              }
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
            var cmpEvent1 = $A.get("e.c:LookUpEvent");
            if(jsonListNew.length == 0){
            cmpEvent1.setParams({
            "lookUpData" :  selectedRecord.value,
            "actionStatus":'inserted'
            ,"objectName":component.get("v.objectName")
            });
        }
            else{
                cmpEvent1.setParams({
            "lookUpData" :  selectedRecord.value,
            "actionStatus":'inserted'
            ,"objectName":component.get("v.objectName")
            ,"dosageJsonList":JSON.parse(JSON.stringify(jsonListNew))
            });
            }
            cmpEvent1.fire();
        }
    },
    handleSubstanceChange: function (component, event, helper) {
        var selectedSubstance = component.get("v.value");
        var action = component.get("c.getSubstanceCode");
        action.setParams({
            substanceName: selectedSubstance
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var substanceCode = response.getReturnValue();
                component.set("v.substanceCode", substanceCode);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error("Error:", errors[0].message);
                } else {
                    console.error("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    showRecords : function( component, event, helper ) {
        if(!$A.util.isEmpty(component.get('v.recordsList')) && !$A.util.isEmpty(component.get('v.searchString'))) {
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    
    // To remove the selected item.
    removeItem : function( component, event, helper ){
        if(!component.get("v.disabled")){
        component.set('v.selectedRecord','');
        component.set('v.value','');
        component.set('v.searchString','');
        var cmpEvent1 = $A.get("e.c:LookUpEvent");
        cmpEvent1.setParams({
        "lookUpData" :  ''
            ,"objectName":component.get("v.objectName"),
            "actionStatus":'removed'});
         cmpEvent1.fire();
        setTimeout( function() {
            component.find( 'inputLookup' ).focus();
        }, 250);
        }
    },
    
    // To close the dropdown if clicked outside the dropdown.
    blurEvent : function( component, event, helper ){
        var searchList =  component.get('v.recordsList'); 
        var searchWord = component.get("v.searchString");
        var selectedRecord = component.get("v.selectedRecord");
        if(selectedRecord == ""){
            component.set("v.checkValue" , true);
        }
        else{
             component.set("v.checkValue" , false);
        }
         $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        
    },
})