({
    createTableData : function(component, event, helper) {
        var action = component.get("c.getAllCriteriaRecord");
        
        component.set("v.columns",[{label: 'S. No.',fieldName: 'ElixirSuite__S_No__c',type :'text'},
                                   {label: 'Criteria Name',fieldName: 'Name',type :'Auto Number'},
                                   {label: 'Criteria Type',fieldName: 'ElixirSuite__Criteria_Type__c',type :'text'},
                                   {label: 'Field Value',fieldName: 'ElixirSuite__Field_Value__c',type :'long text area'},
                                   {type: "button", typeAttributes: {
                                       label: 'Edit',
                                       name: 'Edit',
                                       title: 'Edit',
                                       disabled: false,
                                       value: 'edit',
                                       iconPosition: 'left'
                                   }},
                                   {type: "button", typeAttributes: {
                                       label: 'Delete',
                                       name: 'Delete',
                                       title: 'Delete',
                                       disabled: false,
                                       value: 'delete',
                                       iconPosition: 'left'
                                   }}
                                  ]);
        
        action.setParams({
            "parentGroupId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                console.log('data',JSON.stringify(response.getReturnValue()));
                component.set("v.criteriaList",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    criteriaDeleteHandler : function(component, event, helper){
        var rowToDelete = component.get("v.recordToDelete");
        var action = component.get("c.deleteCriteriaRecord");
        component.set("v.isModalOpen", false);
        action.setParams({
            "criteriaRecord" : rowToDelete
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                component.set("v.criteriaList",response.getReturnValue());
               var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Warning',
                            message: 'Please correct the Criteria Logic',
                            key: 'info_alt',
                            type: 'warning'
                        });
                        toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    criteriaEditHandler : function(component, event, helper){
        var rowToDeleteId = component.get("v.recordToDelete").Id;
        var action = component.get("c.editCriteriaHandling");
        
       
        
        action.setParams({
            "crRecord" : component.get("v.recordToDelete")
        });
        
         component.set("v.isModalOpenForNewRecord", true);
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                var res = response.getReturnValue();
                var ageValue = res.age;
                var admitdateValue = res.admitDate;
                var admitEnddateValue = res.admitEndDate;
                var accounts = res.accountList;
                var locs = res.locList;
                var careTeamMembers = res.careTeamMemberList;
                var loctions = res.locationList;
                var criteriatype = res.criteriatype;
                var criteriaOperator = res.operatorValue;
                var fieldapiName = res.fieldApiName;
                
                var parentToChildVar = res.parentToChildPicklistMap;
                var childValues = parentToChildVar[criteriatype];
                
                var childValueList = [];
                
                for (var i = 0; i < childValues.length; i++) {
                    childValueList.push(childValues[i]);
                }
                // set the child list
                component.set("v.childList", childValueList);
                component.set("v.disabledChildField" , false);
               
               // var childValueList =[];
               // childValueList.push(criteriaOperator); 
                
                component.set("v.parentValue",criteriatype);
                component.set("v.disabledParent" , true);
                component.set("v.childValue",criteriaOperator);
                component.set("v.selectedCriteriaType",criteriatype);
                component.set("v.childList",childValueList);
                component.set("v.selectedOperator",criteriaOperator);
                component.set("v.title",'Edit Criteria');
                component.set("v.selectedLookupTypeCriteriaValue",fieldapiName);
                
                var arrayofAllNewSelectedRecord =[];
                
                
                
                if(criteriatype === 'Age'){
                    component.set("v.isOperatorOpen",true);
                    component.set("v.ageValue",ageValue);
                    component.set("v.EmptyCriteriaVal",true);
                    
                }
                else if(criteriatype === 'Admit Date'){
                     component.set("v.isOperatorOpen",false);
                    component.set("v.admitDateValue",admitdateValue);
                      component.set("v.admitEndDateValue",admitEnddateValue);
                    component.set("v.EmptyCriteriaVal",false);
                    
                } else if(criteriatype === 'Current Patient Name'){
                    component.set("v.isOperatorOpen",true);
                    component.set("v.selectedLookupTypeCriteriaValue",'Account');
                    component.set("v.selectedAccountLookUpRecords",accounts);
                     arrayofAllNewSelectedRecord = accounts;
                    component.set("v.EmptyCriteriaVal",true);
                    
                } else if(criteriatype === 'Care Team Member'){
                    component.set("v.isOperatorOpen",true);
                    component.set("v.selectedLookupTypeCriteriaValue",'User');
                    component.set("v.selectedCareTeamLookUpRecords",careTeamMembers);
                     arrayofAllNewSelectedRecord = careTeamMembers;
                    component.set("v.EmptyCriteriaVal",true);
                    
                } else if(criteriatype === 'Location'){
                    component.set("v.isOperatorOpen",true);
                    component.set("v.selectedLookupTypeCriteriaValue",'ElixirSuite__Provider__c');
                    component.set("v.selectedLocationLookUpRecords",loctions);
                    arrayofAllNewSelectedRecord = loctions;
                    component.set("v.EmptyCriteriaVal",true);
                    
                } else if(criteriatype === 'LOC'){
                    component.set("v.isOperatorOpen",true);
                    component.set("v.selectedLookupTypeCriteriaValue",'ElixirSuite__Programs__c');
                    component.set("v.selectedLOCLookUpRecords",locs);
                    arrayofAllNewSelectedRecord = locs;
                    component.set("v.EmptyCriteriaVal",true);
                    
                }
                component.set("v.SelectedRecords",arrayofAllNewSelectedRecord);
                component.set("v.isModalOpenForNewRecord", true);
                
               /* var appEvent  = $A.get("e.c:oneditPrepopulateCriteriaRecordEvent");
                 appEvent.setParams({"accountRecordByEvent" : accounts ,
                                     "locRecordByEvent" : locs,
                                     "careTeamRecordByEvent" : careTeamMembers,
                                     "locationRecordByEvent" : loctions,
                                     "criteriaTypeByEvent" : res.criteriatype,
                                     "operatorByEvent" : criteriaOperator,
                                     "ageByEvent" : ageValue,
                                     "admitDateByEvent" : res.admitDate
                                    }
                                  ); 
                // fire the event  
                appEvent.fire();*/
                
                
                
                
            }
        });
        $A.enqueueAction(action);
    }
})