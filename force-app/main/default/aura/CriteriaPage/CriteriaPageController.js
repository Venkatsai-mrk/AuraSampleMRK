({
	doInit : function(component, event, helper) {
		var action = component.get("c.getDependentPicklist");
        action.setParams({
            ObjectName : component.get("v.objectName"),
            parentField : component.get("v.parentFieldAPI"),
            childField : component.get("v.childFieldAPI")
        });
        component.set("v.childList",[]);
        
        action.setCallback(this, function(response){
         	var status = response.getState();
            if(status === "SUCCESS"){
                var pickListResponse = response.getReturnValue();
                
                //save response 
                component.set("v.pickListMap",pickListResponse.pickListMap);
                component.set("v.parentFieldLabel",pickListResponse.parentFieldLabel);
                component.set("v.childFieldLabel",pickListResponse.childFieldLabel);
                
                component.set("v.isOperatorOpen",true);
                // create a empty array for store parent picklist values 
                var parentkeys = []; // for store all map keys 
                var parentField = []; // for store parent picklist value to set on lightning:select. 
                
                // Iterate over map and store the key
                for (var pickKey in pickListResponse.pickListMap) {
                    parentkeys.push(pickKey);
                }
                
                //set the parent field value for lightning:select
                if (parentkeys != undefined && parentkeys.length > 0) {
                    parentField.push('--- None ---');
                }
                
                for (var i = 0; i < parentkeys.length; i++) {
                    parentField.push(parentkeys[i]);
                }  
                // set the parent picklist
                component.set("v.parentList", parentField);
                
            }
        });
        
        $A.enqueueAction(action);
	},
    dateFieldHandler : function(component, event, helper){
        var result = component.find("admitField").get("v.value");
       
        component.set("v.admitDateField",result);
        
    },
    endDateFieldHandler : function(component, event, helper){
        var result = component.find("admitEndField").get("v.value");
      
        
        component.set("v.admitEndDateField",result);
    },
    ageInputHandler : function(component,event,helper){
        var result = component.find("AgeField").get("v.value");
        component.set("v.ageField",result);
        console.log('age',component.get("v.ageField"));
    },
    childFieldChange : function(component, event, helper){
        var childselectedvalue =   event.getSource().get("v.value");
            //component.find("childField").get("v.value"); 
            
        component.set("v.selectedOperator",childselectedvalue);
       
    },
    parentFieldChange : function(component, event, helper) {
    	var controllerValue =  event.getSource().get("v.value");
            //component.find("parentField").get("v.value");// We can also use event.getSource().get("v.value")
        var pickListMap = component.get("v.pickListMap");
        console.log('controllerValue',controllerValue);
        if(controllerValue=='Admit Date'){
            component.set("v.isOperatorOpen",false);
            component.set("v.EmptyCriteria",false);
            
        }else{
            component.set("v.isOperatorOpen",true);
             component.set("v.EmptyCriteria",true);
        }
       
        console.log('pickListMap1', JSON.stringify(pickListMap));
              
        
        if (controllerValue != '--- None ---') {
             //get child picklist value
            var childValues = pickListMap[controllerValue];
             
            var childValueList = [];
            childValueList.push('--- None ---');
            for (var i = 0; i < childValues.length; i++) {
                childValueList.push(childValues[i]);
            }
            // set the child list
            
            component.set("v.childList", childValueList);
             component.find("childField").set("v.value", '--- None ---');
            if(childValues.length > 0){
                component.set("v.disabledChildField" , false);  
            }else{
                component.set("v.disabledChildField" , true); 
                
            }
            
        } else {
           component.set("v.childList", ['--- None ---']);
            component.set("v.disabledChildField" , true);
             component.find("childField").set("v.value", '--- None ---');
        }
        
        var lookupSelected =controllerValue.replaceAll(" ", "");
        component.set('v.selectedLookupTypeCriteriaValue',component.get('v.criteriaTypeMap')[lookupSelected]);
        console.log('controllerValue1', lookupSelected);
         console.log('controllerValue2', JSON.stringify(component.get('v.criteriaTypeMap')[lookupSelected]));
        component.set("v.selectedCriteriaType",controllerValue);
        component.set("v.selectedOperator",'--- None ---');
        component.set("v.SelectedRecords" , []);
	},
    handleComponentEvent : function(component, event, helper) {
       
        // get the selected object record from the COMPONENT event 	 
        var listSelectedItems =  component.get("v.SelectedRecords");
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        listSelectedItems.push(selectedAccountGetFromEvent);
        component.set("v.SelectedRecords" , listSelectedItems); 
        //console.log('listSelectedItems1',JSON.stringify(listSelectedItems));
    },
    handleSave : function(component, event, helper){
       // try{
      //var ct =   new Promise($A.getCallback(function(resolve, reject) {
      
        var st;
        var st2;
        var addRecord = true;
        var addCType = true;
        var storeCriteriaType;
        console.log('save method2' ,component.get("v.selectedOperator"));
        console.log('save method2' ,component.get("v.selectedCriteriaType"));
        
        if(component.get("v.selectedCriteriaType") === undefined || component.get("v.selectedCriteriaType") === '--- None ---'){
            addCType = false;
            helper.showToast(component,event,'Please Select Correct Criteria Type');
        }
        else if( (component.get("v.selectedOperator") === undefined || component.get("v.selectedOperator") === '--- None ---') && component.get("v.selectedCriteriaType")!='Admit Date'){
            
            addRecord = false;
            helper.showToast(component,event,'Please Select Correct Operator');
            
        }else if(component.get("v.selectedCriteriaType") == 'Age'){
            console.log('1',component.get("v.selectedCriteriaType"));
                storeCriteriaType = component.get("v.ageField");
                console.log(storeCriteriaType);
                if(component.get("v.ageField") === undefined || component.get("v.ageField") === '' ){
                    console.log('2',component.get("v.ageField"));
                    storeCriteriaType = component.get("v.ageValue");
                    console.log('3',storeCriteriaType);
                    if(storeCriteriaType === undefined || storeCriteriaType === ''){
                        addRecord = false;
                        helper.showToast(component,event,'Please provide Age value.');
                    }
                }
        }else if(component.get("v.selectedCriteriaType") == 'Admit Date'){
            storeCriteriaType = '';
                console.log('save method',component.get("v.selectedCriteriaType"));
                st = component.get("v.admitDateField");
                st2 = component.get("v.admitEndDateField");
                console.log('save method1',st);
                console.log('save methodend',st2);
                if(st === undefined || st === null){
                    
                    var t = component.get("v.admitDateValue");
                    if(t!= undefined || t!=null){
                        st = t.toString();
                    }else{
                        addRecord = false;
                        helper.showToast(component,event,'Please provide Admit Start Date.');
                    }
                    
                }
                if(st2 === undefined || st2 ===null){
                    var dd =  component.get("v.admitEndDateValue");
                    console.log('save method2',dd);
                    
                    if( dd != undefined || dd!=null ){
                        st2 = dd.toString();
                        
                    }else{
                        st2 = st;
                    }
                    
                    //console.log('save method22',dd.toString());
                    console.log('save method2',st2);
                    console.log('stdate',st);
                    console.log('enddate',st2);
                }
                
                var str = component.get("v.emptyValue");
                var newVal = st +str+ st2;
                var newValueList = component.get("v.newValueList");
                newValueList = [];
                newValueList.push(newVal);
                
                storeCriteriaType = JSON.stringify(newValueList);
                
        }else{
            var dataselected = component.get("v.SelectedRecords");
            if(dataselected.length >0){
                var selectedRecords = component.get("v.SelectedRecords");
                
                if(component.get("v.selectedCriteriaType") == 'LOC'){
                    selectedRecords.forEach(function(record){
                        record["Name"] = record["ElixirSuite__Program_Name__c"];
                        delete record["ElixirSuite__Program_Name__c"];
                        });
                    storeCriteriaType = JSON.stringify(component.get("v.SelectedRecords"));
                    
                }else{
                    storeCriteriaType = JSON.stringify(component.get("v.SelectedRecords"));
                }
                
            }else{
                addRecord = false;
                helper.showToast(component,event,'Please provide Field value');
            }
        }
            
        var action = component.get("c.addcriteria");
        
        if((component.get("v.selectedOperator")) === undefined && component.get("v.selectedCriteriaType")!='Admit Date'){
            component.set("v.selectedOperator",component.find("childField").get("v.value"));
             console.log('4',component.find("childField").get("v.value"));
             console.log('5',component.get("v.selectedOperator"));
        }
          
        if(addRecord === true && addCType === true){
          if(st2>= st || component.get("v.selectedCriteriaType")!='Admit Date'){
              console.log('st2',st2);
              console.log('st',st);
              console.log('combine',storeCriteriaType);
              
            action.setParams({
                "criteriaRecordId": component.get("v.criteriaRecordId"),
                "groupId" : component.get("v.recordId"),
                "criteriaType" : component.get("v.selectedCriteriaType"),
                "operator" : component.get("v.selectedOperator"),
                "selectedvalue" : storeCriteriaType,
                "fieldApiName" : component.get("v.selectedLookupTypeCriteriaValue")
                });
                
            action.setCallback(this ,function(response){
                var status = response.getState();
                if(status === 'SUCCESS'){
                    console.log('save method',status);
                    var result = response.getReturnValue();
                    var storedFilterOnGroup = result[0].ElixirSuite__Account_Group__r.ElixirSuite__Criteria_Filter__c;
                    component.set("v.isModalOpen",false);
                    component.set("v.criteriaList1",result);
                    
                    console.log('result '+result);
                    console.log('result '+result[0]);
                    console.log('result '+storedFilterOnGroup);
                    
                    var appEvent = $A.get("e.c:CriteriaFilterEvent");
                    appEvent.setParams({
                        "filterLogic" :  storedFilterOnGroup});
                    appEvent.fire();
                    
                    
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
          }else{
               
             var emp = component.get("v.EmptyCriteria");
              if(st!=undefined && st2!=undefined){
                  if(emp === false ){
                      var toastEvent = $A.get("e.force:showToast");
                      toastEvent.setParams({
                          title: 'Error',
                          type: 'error',
                          message: 'Admit End Date should be greater than or equal to Admit Start Date'
                      });
                      toastEvent.fire();
                  }
              }
              storeCriteriaType = '';
              st2='';
              st='';
              
          }
    }
    },
    handleonEditComponentEvent : function(component, event) {
       
        var a = event.getParam("operatorByEvent");
        var b = event.getParam("criteriaTypeByEvent");
              
        console.log('eve3',event.getParam("criteriaTypeByEvent"));
        console.log('eve4',event.getParam("operatorByEvent"));
        
        var criteriaTypeGetFromEvent = event.getParam("criteriaTypeByEvent");
        if(criteriaTypeGetFromEvent === 'Age'){
            
            component.set("v.ageValue",event.getParam("ageByEvent"));
        }
        else if(criteriaTypeGetFromEvent === 'Admit Date'){
            component.set("v.admitDateValue",event.getParam("admitDateByEvent"));
             console.log('eve2',event.getParam("admitDateByEvent"));
        }
        else if(criteriaTypeGetFromEvent === 'Current Patient Name'){
            
            component.set("v.selectedLookupTypeCriteriaValue",'Account');
            component.set("v.selectedAccountLookUpRecords",event.getParam("accountRecordByEvent"));
        }
        else if(criteriaTypeGetFromEvent === 'Care Team Member'){
            component.set("v.selectedLookupTypeCriteriaValue",'User');
            component.set("v.selectedCareTeamLookUpRecords",event.getParam("careTeamRecordByEvent"));
        }
        else if(criteriaTypeGetFromEvent === 'Location'){
            component.set("v.selectedLookupTypeCriteriaValue",'ElixirSuite__Provider__c');
            component.set("v.selectedLocationLookUpRecords",event.getParam("locationRecordByEvent"));
        }
        else if(criteriaTypeGetFromEvent === 'LOC'){
            component.set("v.selectedLookupTypeCriteriaValue",'ElixirSuite__Programs__c');
            component.set("v.selectedLOCLookUpRecords",event.getParam("locRecordByEvent"));
        }
        component.set("v.parentValue",event.getParam("criteriaTypeByEvent"));
        component.set("v.childValue",event.getParam("operatorByEvent"));
         component.set("v.selectedCriteriaType",event.getParam("criteriaTypeByEvent"));
          
    },
    
    handleOnClearComponentEvent :  function(component,event){
        // get the selected object record from the COMPONENT event 	 
        var listSelectedItems =  component.get("v.SelectedRecords");
        var selectedAccountGetFromEvent = event.getParam("clearedRecordByEvent");
        console.log('selectedAccountGetFromEvent',selectedAccountGetFromEvent.Id);
        
        for(var i = 0; i < listSelectedItems.length; i++){
            if(listSelectedItems[i].Id == selectedAccountGetFromEvent.Id){
                listSelectedItems.splice(i, 1);
                 console.log('listSelectedItems',JSON.stringify(listSelectedItems));
            }
        }
       
        component.set("v.SelectedRecords" , listSelectedItems); 
    },
    
    closeModel : function(component,event,helper){
        component.set("v.isModalOpen", false);
    },
    
    changeHandler : function(component,event){
        
        
        component.set("v.refreshflag",true);
        component.set("v.childValue",'equals');
    }
})