({
    searchField : function(component, event, helper) {
        var currentText = event.getSource().get("v.value");   
        component.set("v.LoadingText", true);
        if(currentText.length > 0) {
            component.set('v.EmpList',true);
        }
        else {
            component.set('v.EmpList',false);
        }
        console.log('codeCategory '+component.get("v.codeCategory"));
         console.log('referenceCode '+component.get("v.selectReferenceCode"));
        var action = component.get("c.modfierList");
        action.setParams({
            referenceCode : component.get("v.selectReferenceCode"),
            codeCategory : component.get("v.codeCategory")
        });
        action.setCallback(this, function(response){
            let arrNames = [];
            let arrNamesFinal = [];
            var STATE = response.getState();
            
            if(STATE === "SUCCESS") {
                var junctionRec = response.getReturnValue();
                console.log(' junctionRec '+JSON.stringify(junctionRec));
                for(let rec in junctionRec){
                let value1,value2,value3,value4;
                let Id1,Id2,Id3,Id4;
                
                    if(junctionRec[rec].ElixirSuite__Modifier1__r){
                        Id1 = junctionRec[rec].ElixirSuite__Modifier1__r.Id;
                        value1 = junctionRec[rec].ElixirSuite__Modifier1__r.Name
                    }
                     if(junctionRec[rec].ElixirSuite__Modifier2__r){
                          Id2 = junctionRec[rec].ElixirSuite__Modifier2__r.Id;
                        value2 = junctionRec[rec].ElixirSuite__Modifier2__r.Name
                    }
                     if(junctionRec[rec].ElixirSuite__Modifier3__r){
                          Id3 = junctionRec[rec].ElixirSuite__Modifier3__r.Id;
                        value3 = junctionRec[rec].ElixirSuite__Modifier3__r.Name
                    }
                     if(junctionRec[rec].ElixirSuite__Modifier4__r){
                          Id4 = junctionRec[rec].ElixirSuite__Modifier4__r.Id;
                        value4 = junctionRec[rec].ElixirSuite__Modifier4__r.Name
                    }
                    arrNames.push( {'Id' : Id1, 'Value' : value1},
                                 {'Id' : Id2, 'Value' : value2},
                                 {'Id' : Id3, 'Value' : value3},
                                 {'Id' : Id4,  'Value' : value4}); 
                }
                 arrNames.forEach(function(element, index) {
                          console.log(' element '+JSON.stringify(element));
                     if(!$A.util.isUndefinedOrNull(element.Value)){
                       arrNamesFinal.push(element);  
                     }
                        }); 
const unique = [];
for (const item of arrNamesFinal) {
  const isDuplicate = unique.find((obj) => obj.Value === item.Value);
  if (!isDuplicate) {
    unique.push(item);
  }
}
        console.log(' unique '+JSON.stringify(unique));         
                component.set("v.searchRecords", unique);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        
                    }
                } else {  
                    
                }
            }
            component.set("v.LoadingText", false);
        });
        $A.enqueueAction(action);
        
    }, //!allData.cptCode_Procedure
    setSelectedRecord : function(component, event, helper) {
        component.set('v.EmpList',false);
        var currentText = event.currentTarget.id;
        let modifierDataLst = [];
         var modifierData = component.get("v.modifierData");
        modifierData.forEach(function(element, index) {
                          console.log('modifierData element '+JSON.stringify(element));
                     if(!$A.util.isUndefinedOrNull(element.modfierId)){
                       modifierDataLst.push(element.modfierId);  
                     }
                        }); 
 console.log('modifierData id '+JSON.stringify(modifierDataLst));
        if(modifierDataLst.includes(currentText)){
           component.set("v.duplicateModifier", true);
              
        }else{
        console.log('set id '+event.currentTarget.id);
        console.log('set Name '+event.currentTarget.dataset.name);
        // component.set("v.selectModifierRecordId", event.currentTarget.id);
         component.set("v.modfierInstance.modfierId",currentText);
        component.set("v.selectRecordName", event.currentTarget.dataset.name);
           var selectModifierRecordId = component.get("v.modfierInstance.modfierId");
         console.log('selectModifierRecordId '+selectModifierRecordId);
        if(event.currentTarget.dataset.name=='Other | N/A'){
            component.set("v.EmpOther",true);
        }else{ component.set("v.EmpOther",false);
             }
       
        let arr = component.get("v.searchRecords");
        let arrIndex = arr.findIndex(obj => obj.Id == currentText);
        component.set("v.modfierInstance.description",arr[arrIndex].ElixirSuite__Code_Description__c); 
        console.log('set id '+event.currentTarget.dataset.name);
        var cmpEvent = component.getEvent("FiringSelectedId"); 
        cmpEvent.fire(); 
        }
     // modifierData='';
    }, 
    resetData : function(component, event, helper) {
        component.set("v.selectRecordName", "");
        component.set("v.selectRecordId", "");
         component.set("v.modfierInstance.modfierId","");
        let finalModLst = [];
          var modifierData = component.get("v.modifierData");
        modifierData.forEach(function(element, index) {
         console.log('modifierData reset data '+JSON.stringify(element));
          if(!$A.util.isUndefinedOrNull(element.modfier) || !$A.util.isEmpty(element.modfier) || element.modfier!=""){
             finalModLst.push(element) ;       
          }
        }); 
         console.log('finalModLst reset data '+JSON.stringify(finalModLst));
        component.set("v.modifierData",finalModLst);
        var cmpEvent = component.getEvent("FiringSelectedId");
        // Get the value from Component and set in Event
        cmpEvent.setParams( { "SelectedId" : ""} );
        cmpEvent.fire();
    }
})