({
    doInit : function(component, event, helper) {
        console.log('value for default'+component.get("v.isDefault"));
        var pageReference = component.get("v.pageReference");
             console.log('pageReference in allnewforms: '+JSON.stringify(pageReference));
             var recordVal = pageReference.state.c__recordVal;
            if(recordVal != null && recordVal != ''){
                component.set("v.recordVal", recordVal);
            }

            var workspaceAPI = component.find("workspace");
             workspaceAPI.getFocusedTabInfo().then(function (response) {
                 var focusedTabId = response.tabId;
                 var issubTab = response.isSubtab;
                 console.log('afctab', focusedTabId);
                 
                 if (issubTab) {
                     workspaceAPI.getTabInfo({ tabId: focusedTabId }).then(function (response1) {
                         console.log('afctabinfo', response1);
                     });
                     workspaceAPI.setTabLabel({
                         label: "Care Plan"
                     });
                 } else if (response.subtabs && response.subtabs.length > 0) {
                     workspaceAPI.getTabInfo({ tabId: response.subtabs[0].tabId }).then(function (response1) {
                         console.log('tabId: response.subtabs[0].tabId: ' + response1);
                     });
                     workspaceAPI.setTabLabel({
                         label: "Care Plan"
                     });
                 } else {
                     console.error("No subtabs found");
                 }
                 
                 workspaceAPI.setTabIcon({
                     tabId: focusedTabId,
                     icon: "utility:answer",
                     iconAlt: "Notes"
                 });
             }).catch(function (error) {
                 console.error("Error:", error);
             });
       // component.set("v.openMainModal",true);
        helper.fetchRelatedNotes(component, event, helper,component.get("v.recordVal"));
        var today = new Date();
        component.set('v.todayString', today.toISOString());
        var action = component.get("c.getData");
        console.log('component.get("v.recordVal"): '+component.get("v.recordVal"))
        action.setParams({ 
            accountId : component.get("v.recordVal")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.carePlanName",response.getReturnValue().accountName+"'"+'s'+' CP - '+response.getReturnValue().countRecords);
                var listOfProblems = response.getReturnValue();
                console.log('listOfProblems 17',listOfProblems);
                if(!$A.util.isUndefinedOrNull(listOfProblems.patientBirthDateFromAccount)){
                    var dob = new Date(listOfProblems.patientBirthDateFromAccount); 
                    var patientDOB = dob.getFullYear() + "-" + (dob.getMonth() + 1) + "-" + dob.getDate();
                }
                console.log('carePlanId '+listOfProblems.carePlanId);
                //if(!$A.util.isUndefinedOrNull(listOfProblems.carePlanId))
                component.set("v.carePlanId",listOfProblems.carePlanId);
                component.set("v.masterProblems",listOfProblems);
                component.set("v.HierarchyLevel",listOfProblems.Hierarchy);
                console.log('listOfProblems-- '+JSON.stringify(component.get("v.HierarchyLevel")));
                component.set("v.accountName",listOfProblems.accountName);
                component.set("v.usersList",listOfProblems.listOfAllUsers);
                component.set("v.userName",listOfProblems.userName);
                //  component.set("v.Strength",listOfProblems.Strength);
                component.set("v.userId",listOfProblems.userId);
                component.set("v.clinicalSupervisionId",listOfProblems.userId);
                component.set('v.todayString', new Date().toISOString());
                component.set('v.patientBirthDate', patientDOB );  
                component.set("v.pickListValuesListForStatus",listOfProblems.pickListValuesList); 
                component.set("v.customSetting",listOfProblems.careplanCustomSettingHeirarchy);
               // var appEvent = $A.get("e.ElixirSuite:AccountEvent"); 
                //appEvent.setParams({"Id" : component.get("v.recordVal")}); 
                //appEvent.fire();
            }else{
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        $A.enqueueAction(action);
        
    },
    openDualListBox: function(component) {
        component.set("v.relateEHRNotes",true);
    },
    handleEHRNotesEvent: function(component, event) {
        var selectedValues = event.getParam("selectedValues");
        var selectedFormNames = event.getParam("selectedFormNames");
        component.set("v.selectedValues", selectedValues);
        component.set("v.selectedFormNames", selectedFormNames);
    },
    setUserId : function(component, event) {
        var value = event.getSource().get("v.value");
        component.set("v.userId",value);
        
    },
    setClinicalSupervisionId  : function(component, event) {
        var value = event.getSource().get("v.value");
        component.set("v.clinicalSupervisionId",value);
        
    },
    handleComponentEvent: function(component) {
        var hideProblemMainModal = event.getParam("hideProblemMainModal");
        var acc = component.find('mainDiv');
        $A.util.removeClass(acc, 'slds-show');
        $A.util.addClass(acc, 'slds-hide');
        
    },
    addProblems	:	function(component) {
        //component.set("v.openMainModal",true);
        var listOfProblems = component.get("v.masterProblems");
        var allProblemsList = listOfProblems.listOfProblem;
        var setOfIds = [];
        for(var probRec in allProblemsList){
            if(! $A.util.isUndefinedOrNull(allProblemsList[probRec].Id)){
                setOfIds.push(allProblemsList[probRec].Id);
                
            }
        }
        console.log('df'+JSON.stringify(setOfIds));
        var action = component.get("c.getAllProblems");
        action.setParams({ 
            existingProblems : setOfIds,
            accountId : component.get("v.recordVal")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                
                var listOfProblems = response.getReturnValue().listOfProblem;     
                component.set("v.allProblems",listOfProblems);
                component.set("v.openModalAllProblems",true);
                console.log('Call back '+JSON.stringify(listOfProblems));
                
            }else{
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        $A.enqueueAction(action);  
    },
    /*existingProblemsActive :	function(component, event, helper) {
    },*/
    closeMainModal:	function(component) {
        console.log('cancel clicked')
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef:"c:CarePlan_ListView",
                        componentAttributes: {
                            recordVal : component.get("v.recordVal"),
                        }
                    });
                    evt.fire();
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    .catch(function(error) {
                        console.log('Error in closing the tab: '+error);
                    })
       // component.set("v.openMainModal",false);
    },
    
    /*customProblemsActive : function(component, event, helper) {
    },*/
    closeModalAllProblems : function(component) {       
        component.set("v.openModalAllProblems",false);
    },
    statusChange : function(component , event){
        var status = event.getSource().get('v.value');
        component.set('v.status', status);
    },
    dueDate  :  function(component, event) {
        console.log('inside due date');
        var endDate = event.getSource().get('v.value');
        var problems = component.get("v.masterProblems");
        var listOfProblems = problems.listOfProblem;
        console.log('inside due date',listOfProblems);
        for(var problemRec in listOfProblems){
            listOfProblems[problemRec]['endDate'] = endDate;
            var goals = listOfProblems[problemRec]['listOfGoal'];
            var def = listOfProblems[problemRec]['listOfDef'];
            if(! $A.util.isUndefinedOrNull(def)){
                for(var goalRec in def){
                    def[goalRec]['endDate'] = endDate;
                    var tasks = def[goalRec]['listOfTask'];
                    var interventions = def[goalRec]['listOfIntervention'];
                    if(! $A.util.isUndefinedOrNull(interventions)){
                        for(var IntRec in interventions){
                            interventions[IntRec]['endDate'] = endDate;
                        }
                    }
                    if(! $A.util.isUndefinedOrNull(tasks)){
                        for(var taskRec in tasks){
                            tasks[taskRec]['endDate'] = endDate;
                            
                            var interventions = tasks[taskRec]['listOfIntervention'];
                            if(! $A.util.isUndefinedOrNull(interventions)){
                                for(var IntRec in interventions){
                                    interventions[IntRec]['endDate'] = endDate;
                                }
                            }
                        }
                    }
                    
                }
            }
            if(! $A.util.isUndefinedOrNull(goals)){
                for(var goalRec in goals){
                    goals[goalRec]['endDate'] = endDate;
                    var tasks = goals[goalRec]['listOfTask'];
                    var interventions = goals[goalRec]['listOfIntervention'];
                    if(! $A.util.isUndefinedOrNull(interventions)){
                        for(var IntRec in interventions){
                            interventions[IntRec]['endDate'] = endDate;
                        }
                    }
                    if(! $A.util.isUndefinedOrNull(tasks)){
                        for(var taskRec in tasks){
                            tasks[taskRec]['endDate'] = endDate;
                            
                            var interventions = tasks[taskRec]['listOfIntervention'];
                            if(! $A.util.isUndefinedOrNull(interventions)){
                                for(var IntRec in interventions){
                                    interventions[IntRec]['endDate'] = endDate;
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        component.set("v.masterProblems" , problems);
        
    },
    editEnable  : function(component) {
        component.set("v.editEnabled",false);
    },
    handleConfirmDialogNo:function(component) {
        component.set("v.showConfirmDialog",false);
    },
    
    handleConfirmDialogYes :  function(component) {
        var procedureStartCmp = component.find("procedure-start_time");
        var strtProcedureTime = procedureStartCmp.get('v.value');
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get('v.value');
        if(endProcedureTime == null )
        {
            var today = new Date();
            endProcedureTime = today;
        }
        var allValid = [].concat(component.find('field')).reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        var dateValid = true;
        
        if(! ($A.util.isUndefinedOrNull(endProcedureTime) || $A.util.isUndefinedOrNull(strtProcedureTime))){
            var today = new Date();
            var dte = new Date(strtProcedureTime);
            var endte = new Date(endProcedureTime);
            
            dte.setHours(dte.getHours(),dte.getMinutes(),0,0);
            endte.setHours(endte.getHours(),endte.getMinutes(),0,0);
            today.setHours(today.getHours(),today.getMinutes(),0,0);
            
            
            if((endte.setDate(endte.getDate()) > today))
            {
                procedureEndCmp.setCustomValidity("End Time cannot be greater than the Current Time.");
                procedureEndCmp.reportValidity();
                dateValid = false;
            }
            else
            {
                procedureEndCmp.setCustomValidity("");
                procedureEndCmp.reportValidity();
            }
            
            if((dte.setDate(dte.getDate()) >today)){
                procedureStartCmp.setCustomValidity("Start Time cannot be greater than the Current Time.");
                procedureStartCmp.reportValidity();
                dateValid = false;
                console.log('ss');
            }
            
            else{
                procedureStartCmp.setCustomValidity("");
                procedureStartCmp.reportValidity();
                
            }
        }
        
        var carePlanName = component.get("v.carePlanName");
        console.log('carePlanName ',carePlanName);
        var endDateCmp = component.find('endDate');
        var endDate = endDateCmp.get('v.value');
        var stDateCmp = component.find('fieldst');
        var startDate =  component.get("v.startDate");
        var today = new Date();
        if(startDate>endDate){         
            endDateCmp.setCustomValidity("End date cannot be less than start date");
            endDateCmp.reportValidity();
            dateValid = false;
        }
        else{
            endDateCmp.setCustomValidity("");
            endDateCmp.reportValidity();
            
        }
        var dte = new Date(startDate);
        if((dte.setDate(dte.getDate()+1) <today)){
            stDateCmp.setCustomValidity("Start date cannot be less than today");
            stDateCmp.reportValidity();
            dateValid = false;
        }
        else{
            stDateCmp.setCustomValidity("");
            stDateCmp.reportValidity();
            
        }
        
        console.log(startDate+'gg'+endDate);
        if(allValid==false || dateValid==false){
            if(allValid == false){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Failed!",
                    "message": "Please fill all the mandatory fields."
                });
                toastEvent.fire();
            }          
        }
        else{
            console.log('master problems '+JSON.stringify(component.get("v.masterProblems")));
            var carePlanName = component.get("v.carePlanName");
            // console.log('--> '+JSON.stringify(component.get("v.masterProblems")));
            var action = component.get("c.saveData");
            console.log('--> '+JSON.stringify(component.get("v.masterProblems")));
            // component.find("Id_spinner").set("v.class" , 'slds-show');
            action.setParams({ 
                userId : component.get("v.userId"),
                clinicalSupervisionId : component.get("v.clinicalSupervisionId"),
                carePlanName : carePlanName,
                status : component.get("v.status"),
                startDate	:	component.get("v.startDate"),
                endDate	:	component.get("v.endDate"),
                masterData :  JSON.stringify(component.get("v.masterProblems")),
                starttimeProcedure :component.get('v.todayString'),
                endtimeProcedure : endProcedureTime,
                accountId : component.get("v.recordVal"),
                description:  component.get('v.Description'),
                approvedValues: JSON.stringify(component.get("v.approvedValues"))
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") { 
                    component.set("v.openMainModal",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : 'success',
                        "message": "Care Plan saved successfully."
                    });
                    toastEvent.fire();  
                    var createEvent = component.getEvent("RefreshCarePlan");
                    createEvent.fire();
                    //   component.find("Id_spinner").set("v.class" , 'slds-hide'); 
                    // $A.get('e.force:refreshView').fire();
                    
                }
                else{
                    
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }        }
                }
            });
            $A.enqueueAction(action); 
            
        }
        
        
    },
    
    procedureValidity  : function(component ,event ,helper){
        var valid = true;
        valid = helper.helperMethod(component , valid);
    },
    
    editEnableBlur : function(component) {
        component.set("v.editEnabled",true);
    }, 
    Save : function(component) {
        /*var goalList = component.get("v.allGoalsShow");
        console.log('goalList '+goalList);
        var goalMap = component.get('v.goalsMap');
        for (var goalRec in goalList){
            console.log('goalList[goalRec]',goalList[goalRec]);
            goalMap["Name"] = goalList[goalRec].Name;
            goalMap["Description"] = goalList[goalRec].ElixirSuite__Description__c;
            //goalMap["endDate"] = goalList[goalRec].DueDate;
        }
        console.log('goalMap '+goalMap);
        component.set("v.goalsMap",goalMap);  
        console.log('goalMaps '+JSON.stringify(component.get("v.goalsMap")));*/
        
        var procedureStartCmp = component.find("procedure-start_time");
        var strtProcedureTime = procedureStartCmp.get('v.value');
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get('v.value');
        
        var allValid = [].concat(component.find('field')).reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        var dateValid = true;
        
        if(! ($A.util.isUndefinedOrNull(endProcedureTime) || $A.util.isUndefinedOrNull(strtProcedureTime))){
            var today = new Date();
            var dte = new Date(strtProcedureTime);
            var endte = new Date(endProcedureTime);
            
            dte.setHours(dte.getHours(),dte.getMinutes(),0,0);
            endte.setHours(endte.getHours(),endte.getMinutes(),0,0);
            today.setHours(today.getHours(),today.getMinutes(),0,0);
            
            
            if((endte.setDate(endte.getDate()) > today))
            {
                procedureEndCmp.setCustomValidity("End Time cannot be greater than the Current Time.");
                procedureEndCmp.reportValidity();
                dateValid = false;
            }
            else
            {
                procedureEndCmp.setCustomValidity("");
                procedureEndCmp.reportValidity();
            }
            
            if((dte.setDate(dte.getDate()) >today)){
                procedureStartCmp.setCustomValidity("Start Time cannot be greater than the Current Time.");
                procedureStartCmp.reportValidity();
                dateValid = false;
                console.log('ss');
            }
            else{
                procedureStartCmp.setCustomValidity("");
                procedureStartCmp.reportValidity();
                
            }
        }
        
        
        var carePlanName='';
        
        console.log('carePlanName ',carePlanName);
        var endDateCmp = component.find('endDate');
        var endDate = endDateCmp.get('v.value');
        var stDateCmp = component.find('fieldst');
        var startDate =  component.get("v.startDate");
        var today = new Date();
        
        if(startDate>endDate){         
            endDateCmp.setCustomValidity("End date cannot be less than start date");
            endDateCmp.reportValidity();
            dateValid = false;
        }
        else{
            endDateCmp.setCustomValidity("");
            endDateCmp.reportValidity();
            
        }
        if($A.util.isUndefinedOrNull(endDate)){
            endDateCmp.setCustomValidity("End date cannot be blank");
            endDateCmp.reportValidity();
            dateValid = false; 
        }
        var dte = new Date(startDate);
        if((dte.setDate(dte.getDate()+1) <today)){
            stDateCmp.setCustomValidity("Start date cannot be less than today");
            stDateCmp.reportValidity();
            dateValid = false;
        }
        else{
            stDateCmp.setCustomValidity("");
            stDateCmp.reportValidity();
            
        }
        if($A.util.isUndefinedOrNull(startDate)){
            stDateCmp.setCustomValidity("Start date cannot be blank");
            stDateCmp.reportValidity();
            dateValid = false; 
        }
        if(endProcedureTime == null )
        {
            //component.set("v.showConfirmDialog",true);
            //return;
            procedureEndCmp.setCustomValidity("Complete this field");
            procedureEndCmp.reportValidity();
            allValid = false;
        }
        console.log(startDate+'gg'+endDate);
        if(allValid==false || dateValid==false){
            if(allValid == false){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Failed!",
                    "message": "Please fill all the mandatory fields."
                });
                toastEvent.fire();
            }          
        }
        else{
            // Add Goals from top
            if(!$A.util.isUndefinedOrNull(component.get("v.allGoalsShow"))){
                var listOfTopLevelGoals = component.get('v.allGoalsShow');
                var masterProblems = component.get("v.masterProblems");
                masterProblems['listOfTopLevelGoals'] = listOfTopLevelGoals;
                component.set('v.masterProblems',masterProblems);
                console.log('component.listOfTopLevelGoals' +JSON.stringify(component.get('v.masterProblems')) );
            }
            //Add Objective from top
            if(!$A.util.isUndefinedOrNull(component.get("v.intervent"))){
                var listOfTasks = component.get('v.intervent');
                var problemsTask = component.get("v.masterProblems");
                problemsTask['listOfObjectives'] = listOfTasks;
                component.set('v.masterProblems',problemsTask);
                console.log('component.intervent' +JSON.stringify(component.get('v.masterProblems')) );
            }
            
            //Add Intervention From top
            if(!$A.util.isUndefinedOrNull(component.get("v.interventJson"))){
                var allIntervList = component.get('v.interventJson');
                var problems = component.get("v.masterProblems");
                problems['listOfInterventions'] = allIntervList;
                component.set('v.masterProblems',problems);
                console.log('component.' +JSON.stringify(component.get('v.masterProblems')) );
            }
            var carePlanName = component.get("v.carePlanName");
            var action = component.get("c.saveData");
            console.log('--> '+JSON.stringify(component.get("v.masterProblems")));
            if(component.get("v.carePlanName") != null)
            {
                var carePlanName = component.get("v.carePlanName");
            }
            else
            {
                carePlanName.setCustomValidity("Complete this field");
            }
            
            console.log('component.get("v.approvedValues")'+ component.get("v.approvedValues"));
            console.log('endtimeProcedure'+ component.get('v.endString'));
            action.setParams({ 
                userId : component.get("v.userId"),
                clinicalSupervisionId : component.get("v.clinicalSupervisionId"),
                carePlanName : carePlanName,
                status : component.get("v.status"),
                startDate	:	component.get("v.startDate"),
                endDate	:	component.get("v.endDate"),
                masterData :  JSON.stringify(component.get("v.masterProblems")),
                starttimeProcedure :component.get('v.todayString'),
                endtimeProcedure : component.get('v.endString'),
                accountId : component.get("v.recordVal"),
                description:  component.get('v.Description'),
                approvedValues: JSON.stringify(component.get("v.approvedValues")),
                selectedValues: component.get("v.selectedValues"),
                selectedFormNames:component.get("v.selectedFormNames"),
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state for care plan save '+state);
                if (state === "SUCCESS") { 
                    component.set("v.openMainModal",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : 'success',
                        "message": "Care Plan saved successfully."
                    });
                    toastEvent.fire();
                    var createEvent = component.getEvent("RefreshCarePlan");
                    createEvent.fire();
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef:"c:CarePlan_ListView",
                        componentAttributes: {
                            recordVal : component.get("v.recordVal"),
                        }
                    });
                    evt.fire();  
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    .catch(function(error) {
                        console.log('Error in closing the tab: '+error);
                    })
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }        }
                }
            });
            $A.enqueueAction(action); 
            
        }
    },
    
    addGoals : function(component) { 
        var listOfGoalsExist = component.get("v.allGoalsShow");
        var setOfIds = [];
        for(var goalRec in listOfGoalsExist){
            if(! $A.util.isUndefinedOrNull(listOfGoalsExist[goalRec])){
                setOfIds.push(listOfGoalsExist[goalRec].Id);
                
            }
        } 
        console.log('df'+JSON.stringify(setOfIds)); 
        var action = component.get("c.getAllGoals");
        action.setParams({ 
            existingGoals : setOfIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                
                var listOfGoals = response.getReturnValue().listOfTemplateProblemGoal;     
                component.set("v.allGoals",listOfGoals);
                console.log('All Goals '+JSON.stringify(listOfGoals));
                component.set("v.customGoalModal",true);
            }else{
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        $A.enqueueAction(action);  
    },
    
    GoalEvent : function(component, event) { 
        var message = event.getParam("message"); 
        component.set("v.eventMessage", message);
        event.stopPropagation();
        console.log('messages '+message);
        var listOfGoals = component.get("v.eventMessage");
        var prevvalue =  component.get("v.allGoalsShow");
        if(prevvalue != null && prevvalue!= undefined){
            for(var prev in prevvalue){
                listOfGoals.push(prevvalue[prev]);
            }
        }
        component.set("v.allGoalsShow",listOfGoals);
        console.log('allGoalsShow inside careplancontroller',component.get("v.allGoalsShow"));
        component.set("v.customGoalModal",false);
    },
    
    objEvent : function(component,event) { 
        var message = event.getParam("message"); 
        component.set("v.eventMessage", message ); 
        console.log('messages '+message);
        var listOfObj = component.get("v.eventMessage");
        event.stopPropagation();
        var prevvalue =  component.get("v.allTasksListShow");
        if(prevvalue != null && prevvalue!= undefined){
            for(var prev in prevvalue){
                listOfObj.push(prevvalue[prev]);
            }
        }
        component.set("v.allTasksListShow",listOfObj);
        component.set("v.customTask",false);
    },
    
    addObjective : function(component) { 
        var setOfIds = [];
        if(! $A.util.isUndefinedOrNull(component.get("v.allTasksListShow"))){
            var listOfTask = component.get("v.allTasksListShow");
            for(var taskRec in listOfTask){
                if(! $A.util.isUndefinedOrNull(listOfTask[taskRec].Id)){
                    setOfIds.push(listOfTask[taskRec].Id);           
                }
            } 
            
        }
        console.log('df '+JSON.stringify(setOfIds));
        var action = component.get("c.getAllTasks");
        action.setParams({ 
            existingTasks : setOfIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                  
                var listOfTasks = response.getReturnValue();     
                component.set("v.allTasksList",listOfTasks);
                console.log('All Tasks '+JSON.stringify(listOfTasks));
                component.set("v.customTask",true);
                console.log('All objectives ');
            }else{
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        $A.enqueueAction(action); 
    },
    
    addIntervention : function(component) { 
        var setOfIds = [];
        var listOfInt = component.get("v.allIntervList");
        for(var taskRec in listOfInt){
            if(! $A.util.isUndefinedOrNull(listOfInt[taskRec].Id)){
                setOfIds.push(listOfInt[taskRec].Id);           
            }
        }
        console.log('df '+JSON.stringify(setOfIds));
        var action = component.get("c.getAllInterventions");
        action.setParams({ 
            existingInts : setOfIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                   
                var listOfTasks = response.getReturnValue();     
                component.set("v.allIntsList",listOfTasks);
                console.log('All Interventions '+JSON.stringify(listOfTasks));
                component.set("v.customInt",true);
                console.log('All Interventions ');
                component.set("v.carePlanInterv",true);
            }else{
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        $A.enqueueAction(action); 
    },
    
    IntrvEvent : function(component, event) {  
        var message = event.getParam("message"); 
        component.set("v.eventMessage", message ); 
        console.log('messages '+message);
        var listOfIntrv = message;
        event.stopPropagation();
        var prevvalue =  component.get("v.allIntervList");
        if(prevvalue != null && prevvalue!= undefined){
            for(var prev in prevvalue){
                listOfIntrv.push(prevvalue[prev]);
            }
        }
        component.set("v.allIntervList",listOfIntrv);
    },
    AddNotes : function(component) {
        component.set("v.openModalAddNotes" , true);
        component.set("v.openNotes" , true);
    },
    setGoalValue : function (component, event) {
        console.log('event.getParamss ' + JSON.stringify(event.getParam('goal')));
        var goal=event.getParam('goal');
        console.log('event.getParam ' + goal[0].Id);
        var listOfGoalsExist = component.get("v.allGoalsShow");
        console.log('listOfGoalsExist' + JSON.stringify(listOfGoalsExist));
        for(var goalRec in listOfGoalsExist){
            console.log('listOfGoalsExist[goalRec].Id '+listOfGoalsExist[goalRec].Id);
            if(!$A.util.isUndefinedOrNull(listOfGoalsExist[goalRec])  && listOfGoalsExist[goalRec].Id === goal[event.getParam('index')].Id){
                console.log('listOfGoalsExist'+listOfGoalsExist.indexOf(listOfGoalsExist[goalRec]));
                listOfGoalsExist.splice(listOfGoalsExist.indexOf(listOfGoalsExist[goalRec]), 1);
            } 
        } 
        component.set('v.allGoalsShow',listOfGoalsExist);
        console.log('v.allGoals '+ JSON.stringify(component.get('v.allGoalsShow')));
    },
    sliceInterventionEvent : function (component, event) {
        var interv = event.getParam('Intervention');
        console.log('interv' + JSON.stringify(interv));
        var listOfIntervExist =component.get('v.interventJson');
        console.log('listOfIntervExist' + JSON.stringify(listOfIntervExist));
        for(var intervRec in listOfIntervExist){
            if(!$A.util.isUndefinedOrNull(listOfIntervExist[intervRec])  && listOfIntervExist[intervRec].Id === interv.Id){
                console.log('listOfIntervExistif'+listOfIntervExist.indexOf(listOfIntervExist[intervRec]));
                listOfIntervExist.splice(listOfIntervExist.indexOf(listOfIntervExist[intervRec]), 1);
            } 
        } 
        component.set('v.interventJson',listOfIntervExist);
        component.set('v.allIntervList',listOfIntervExist);
        console.log('v.interventJson '+ JSON.stringify(component.get('v.interventJson')));
    },
    ObjectiveIntervEvents : function(component, event) {
        var message = event.getParam("intervent"); 
        var inter = component.get("v.intervent" ); 
        if(inter.length > 0){
            var matchFound = false;
            for(var prev in inter){
                if(inter[prev].Id == message.Id){
                    inter[prev] = message;
                    console.log('inter[prev] '+inter[prev]);
                    matchFound=true;
                }
                
            }
            if(!matchFound){
                inter.push(message);
                console.log('inter '+JSON.stringify(inter));
            }
        }
        else{
            inter.push(message);
        }
        
        component.set("v.intervent", inter);  
        console.log('intervention '+ JSON.stringify(component.get("v.intervent")));
    },
    
    InterventionTopEvent : function(component, event) {
        if(component.get('v.carePlanInterv')){
            var message = event.getParam("InterventionJSON"); 
            var inter = component.get("v.interventJson" ); 
            if(inter.length > 0){
                var matchFound = false;
                for(var prev in inter){
                    if(inter[prev].Id == message.Id){
                        inter[prev] = message;
                        console.log('inter[prev] '+inter[prev]);
                        matchFound=true;
                    }
                    
                }
                if(!matchFound){
                    inter.push(message);
                    console.log('inter '+JSON.stringify(inter));
                }
            }
            else{
                inter.push(message);
            }
            
            component.set("v.interventJson", inter);  
            console.log('intervention '+ JSON.stringify(component.get("v.interventJson")));
        }
        
    }
})