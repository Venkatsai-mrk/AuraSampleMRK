({
    doInit : function(component, event, helper) {
        console.log('123400--> '+JSON.stringify(component.get("v.relatedDiagnosis")));
        console.log('defy '+JSON.stringify(component.get("v.problemIndexInDiagnoses")));
        console.log('problem tall tree  '+JSON.stringify(component.get("v.problemRecord")));
        
        //  console.log('problem oindex in daignoses '+JSON.stringify(problemIndexInDiagnoses));
        
        
    },
    handleDiagnosesSelection : function(component, event, helper) {
        var value= event.getSource().get("v.checked");
        var problemRecord = component.get("v.problemRecord");
        var getJSON = component.get("v.relatedDiagnosis");   
        console.log('problem records --> '+JSON.stringify(problemRecord));
        if(!$A.util.isUndefinedOrNull(problemRecord.alreadyExisting) && problemRecord.alreadyExisting){
            problemRecord['isrelatedDiagnosesUpdated'] = true; 
            if(!$A.util.isUndefinedOrNull(getJSON.alreadyExistingDaignoses) && getJSON.alreadyExistingDaignoses) {
                getJSON['isDeleted'] = !value;
                component.set("v.relatedDiagnosis",getJSON);
            }
            else {
                getJSON['isAdded'] = value;
                getJSON['ElixirSuite__Dataset1__c'] = problemRecord.Id;
                component.set("v.relatedDiagnosis",getJSON);
            }
            component.set("v.problemRecord",problemRecord);
        }
        
        else {
            getJSON.diagnosesIsChecked=value;
            component.set("v.relatedDiagnosis",getJSON);
        }
        //   getJSON.listOfRelatedDiagnoses[problemIndex].problemIsChecked=value;
        //console.log('index diagnoses '+JSON.stringify(diagnosesIndex));
        console.log('total child '+JSON.stringify(getJSON));
        //diagnosesIsChecked
        
        // masterList['listOfRelatedDiagnoses'] = listOfrelatedDiagnoses;
        
        // masterList.listOfRelatedDiagnoses[problemIndex].problemIsChecked=value;
        //asterList[problemIndex].problemIsChecked=value;
        //console.log('rrrrrrrf'+JSON.stringify(updatedJsn));
        // component.set("v.problem",masterList);
        // 
        /*  var indexDiagnoses =  event.getSource().get("v.name");
        
                var getJSON = component.get("v.goalsList");
          var index = event.getSource().get("v.name");
        var value= event.getSource().get("v.checked");
        var arr = index.split('$');
        var diagnosesIndex = arr[0];
        var problemIndex = arr[1];
                     getJSON[problemIndex].listOfRelatedDiagnoses[diagnosesIndex].diagnosesIsChecked=value;
     //   getJSON.listOfRelatedDiagnoses[problemIndex].problemIsChecked=value;
        console.log('index diagnoses '+JSON.stringify(diagnosesIndex));
        console.log('total child '+JSON.stringify(getJSON));
      //diagnosesIsChecked
      
                    masterList['listOfRelatedDiagnoses'] = listOfrelatedDiagnoses;
                          
                     // masterList.listOfRelatedDiagnoses[problemIndex].problemIsChecked=value;
       //asterList[problemIndex].problemIsChecked=value;
        //console.log('rrrrrrrf'+JSON.stringify(updatedJsn));
       // component.set("v.problem",masterList);
        console.log(event.getSource().get("v.name"));
        var getJSON = component.get("v.relatedDiagnosis");
        */
    }
})