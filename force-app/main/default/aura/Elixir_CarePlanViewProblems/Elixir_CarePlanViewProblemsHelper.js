({
    fetchDiagnoses : function(component, event, helper) {
       
        var problemId = component.get("v.problemId");
        
        var action = component.get("c.fetchRelatedDiagnosis");
        action.setParams({
            problemId: problemId
        });
        //  component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //   component.find("Id_spinner").set("v.class" , 'slds-hide');
                var res = response.getReturnValue();
                console.log('DIAGNOSIS RESP '+JSON.stringify(res));
               //  alert('diagnosis complete');
                var masterList = component.get("v.problem");
                masterList['listOfRelatedDiagnosis'] = res;
                component.set("v.problem",masterList);
                component.set("v.problemFirstCallBack",true);
            }
            
        });
        
        $A.enqueueAction(action);
    },
    heirarchyDescisionTree : function(component, event, helper) {
        var csSetting = component.get("v.customSetting");
        var labelApiMap = component.get("v.labelApicombo_CustomSetting");
        var fieldsLabel = csSetting.ElixirSuite__Relationship_level_1__c;
        var arrayOfFieldsLabel = [];
        var apiArray = [];
        if(fieldsLabel.includes(';')){
            arrayOfFieldsLabel = fieldsLabel.split(';');
            for(let rec in arrayOfFieldsLabel){
                apiArray.push(labelApiMap[arrayOfFieldsLabel[rec]]);
            }
            var relation_Heirarchy = {'relLevel' : '',
                                          'heirarchyLevel' : ''
                                         };
            
            var stringValue = [];
            for(let rec in apiArray){
          		stringValue.push(csSetting.apiArray[rec]);
            }
            relation_Heirarchy.relLevel = stringValue.join(';');
            relation_Heirarchy.heirarchyLevel = '';
        }
       
      
        
    }
})