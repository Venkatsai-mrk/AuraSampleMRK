({
    doInit : function(component) {
        var pageReference = component.get("v.pageReference");
            console.log('pageReference in edit careplan: '+JSON.stringify(pageReference));
            var decisionTree = pageReference.state.c__decisionTree;
            if(decisionTree != null && decisionTree != ''){
                component.set("v.decisionTree", decisionTree);
            }
            var countOfApprovalLevel = pageReference.state.c__countOfApprovalLevel;
            if(countOfApprovalLevel != null && countOfApprovalLevel != ''){
                component.set("v.countOfApprovalLevel", countOfApprovalLevel);
            }
            var selectedRow = pageReference.state.c__selectedRow;
            if(selectedRow != null && selectedRow != ''){
                component.set("v.selectedRow", selectedRow);
            }
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
        var treatmentPlanId = component.get("v.selectedRow");
        var accountId = component.get("v.recordVal");
         
        // alert('care plan '+component.get("v.carePlan"));
        // alert('Selected Row '+component.get("v.recordVal"));
        // alert('case Id '+component.get("v.selectedRow"));
        
        var action = component.get("c.getData");
        var today = new Date();
        var nameSpace ;
        component.set('v.todayString', today.toISOString());
        action.setParams({
            "caseId" : treatmentPlanId,
            "patientId" : accountId
        });
        action.setCallback(this , function(response){
            var respWrapper = response.getReturnValue();
            //var dob = new Date(respWrapper.patientBirthDate);
            var state = response.getState();
            if(state == 'SUCCESS'){
                console.log('master problems ',respWrapper);
                nameSpace = '';
                if(!$A.util.isUndefinedOrNull(respWrapper.patientBirthDate)){
                    var dob = new Date(respWrapper.patientBirthDate); 
                    console.log('dob ',dob);
                    //var patientDOB = dob.getFullYear() + "-" + (dob.getMonth() + 1) + "-" + dob.getDate();
                }
                component.set("v.nameSpace",respWrapper.nameSpace);
                component.set("v.Description",respWrapper.carePlan.ElixirSuite__Description__c);
                component.set("v.carePlanName",respWrapper.carePlan.ElixirSuite__Treatment_Plan_Name__c);
                component.set("v.accountName",respWrapper.accountName);
                component.set("v.usersList",respWrapper.listOfAllUsers);
                component.set("v.carePlan",respWrapper.carePlan);
                component.set("v.verifyCode" , respWrapper.VerficationCode);
                component.set("v.patientBirthDate",respWrapper.patientBirthDate);
                component.set("v.customSetting",respWrapper.careplanCustomSettingHeirarchy);
                component.set("v.allGoalsShow",respWrapper.listOfGoal);
                component.set("v.allTasksListShow",respWrapper.listOfObjs);
                component.set("v.allIntervList",respWrapper.listOfTasks);
                component.set("v.masterProblems",respWrapper);
            }else{
                console.log('failed');
            }
        });
        $A.enqueueAction(action);
        component.set("v.isLoadingComp",true);
       
    },
    addGoals : function(component) { 
        var listOfGoalsExist = component.get("v.allGoalsShow");
        console.log('allGoalsShow in addgoals edit',listOfGoalsExist);
        var setOfIds = [];
        for(var goalRec in listOfGoalsExist){
            if(! $A.util.isUndefinedOrNull(listOfGoalsExist[goalRec])){
                if(listOfGoalsExist[goalRec].ElixirSuite__Template_Problem__c){
                    setOfIds.push(listOfGoalsExist[goalRec].ElixirSuite__Template_Problem__c);
                }
                else{
                    setOfIds.push(listOfGoalsExist[goalRec].Id);
                }
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
    
    objEvent : function(component, event) { 
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
                if(! $A.util.isUndefinedOrNull(listOfTask[taskRec])){
                    if(listOfTask[taskRec].ElixirSuite__Template_Problem__c){
                        setOfIds.push(listOfTask[taskRec].ElixirSuite__Template_Problem__c);
                    }
                    else{
                        setOfIds.push(listOfTask[taskRec].Id);    
                    }
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
        console.log('allIntervList inside addIntervention edit',listOfInt);
        for(var taskRec in listOfInt){
            if(! $A.util.isUndefinedOrNull(listOfInt[taskRec])){
                if(listOfInt[taskRec].ElixirSuite__Template_Problem__c){
                    setOfIds.push(listOfInt[taskRec].ElixirSuite__Template_Problem__c);
                }
                else{
                    setOfIds.push(listOfInt[taskRec].Id);  
                }
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
        for(var goalRec in listOfGoalsExist){
            console.log('listOfGoalsExist[goalRec].Id '+listOfGoalsExist[goalRec].Id);
            console.log('goal[0].Id '+goal[0].Id);
            if(!$A.util.isUndefinedOrNull(listOfGoalsExist[goalRec])  && listOfGoalsExist[goalRec].Id === goal[0].Id){
                console.log('listOfGoalsExist'+listOfGoalsExist.indexOf(listOfGoalsExist[goalRec]));
                listOfGoalsExist.splice(listOfGoalsExist.indexOf(listOfGoalsExist[goalRec]), 1);
            } 
        } 
        component.set('v.allGoalsShow',listOfGoalsExist);
        console.log('v.allGoals '+ JSON.stringify(component.get('v.allGoalsShow')));
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
        
    },
    
    handleDueDateForTree : function(component ,event){
        var nameSpace = 'ElixirSuite__';
        console.log('df'+JSON.stringify(component.get("v.masterProblems.listOfProblem")));
        console.log('df2'+JSON.stringify(component.get("v.masterProblems")));
        var endDate = event.getSource().get('v.value');
        var problems = component.get("v.masterProblems");
        var listOfProblems = problems.listOfProblem;
        for(var problemRec in listOfProblems){
            listOfProblems[problemRec]['ElixirSuite__Due_Date__c'] = endDate;
            
            if($A.util.isUndefinedOrNull(listOfProblems[problemRec][nameSpace+'Dataset1__c'])){
                //No Action taken
            }else{
                listOfProblems[problemRec]['Action'] = 'UPDATE';
            }
            //var goals = listOfProblems[problemRec]['listOfGoal'];
            //var def = listOfProblems[problemRec]['listOfDef'];
            
            /*  if(! $A.util.isUndefinedOrNull(def)){
                for(var goalRec in def){
                    def[goalRec]['ElixirSuite__Due_Date__c'] = endDate;
                    if($A.util.isUndefinedOrNull(def[goalRec][nameSpace+'Dataset2__c'])){
                        //No Action Taken
                    }else{
                        def[goalRec]['Action'] = 'UPDATE';;
                    }
                    
                    var tasks = def[goalRec]['listOfTask'];
                    var interventions_directParent = def[goalRec]['listOfIntervention'];
                    if(! $A.util.isUndefinedOrNull(tasks)){
                        for(var taskRec in tasks){
                            tasks[taskRec]['ElixirSuite__Due_Date__c'] = endDate;
                            
                            var interventions = tasks[taskRec]['listOfIntervention'];
                            if(! $A.util.isUndefinedOrNull(interventions)){
                                for(var IntRec in interventions){
                                    interventions[IntRec]['ElixirSuite__Due_Date__c'] = endDate;
                                }
                            }
                        }
                    }
                    if(! $A.util.isUndefinedOrNull(interventions_directParent)){
                        for(var taskRec in interventions_directParent){
                            interventions_directParent[taskRec]['ElixirSuite__Due_Date__c'] = endDate;
                            
                            
                        }
                    }
                }
            }
            
            if(! $A.util.isUndefinedOrNull(goals)){
                for(var goalRec in goals){
                    goals[goalRec]['ElixirSuite__Due_Date__c'] = endDate;
                    
                    if($A.util.isUndefinedOrNull(goals[goalRec][nameSpace+'Dataset2__c'])){
                        //No Action Taken
                    }else{
                        goals[goalRec]['Action'] = 'UPDATE';;
                    }
                    
                    var tasks = goals[goalRec]['listOfTask'];
                    var interventions_directParent = goals[goalRec]['listOfIntervention'];
                    if(! $A.util.isUndefinedOrNull(tasks)){
                        for(var taskRec in tasks){
                            tasks[taskRec]['ElixirSuite__Due_Date__c'] = endDate;
                            
                            var interventions = tasks[taskRec]['listOfIntervention'];
                            if(! $A.util.isUndefinedOrNull(interventions)){
                                for(var IntRec in interventions){
                                    interventions[IntRec]['ElixirSuite__Due_Date__c'] = endDate;
                                }
                            }
                        }
                    }
                    if(! $A.util.isUndefinedOrNull(interventions_directParent)){
                        for(var taskRec in interventions_directParent){
                            interventions_directParent[taskRec]['ElixirSuite__Due_Date__c'] = endDate;
                            
                            
                        }
                    }
                }
            }*/
        }
        component.set("v.masterProblems" , problems);
        var objCompB = component.find('carePlanParent');
        if(Array.isArray(objCompB)){
            for(let rec in objCompB){
                objCompB[rec].sampleMethod(endDate);
            }
        }
        else {
            objCompB.sampleMethod(endDate);
        }
        
        console.log('updated CP'+JSON.stringify(component.get("v.masterProblems")));
    },
    setTherapist : function(component ,event){
        var nameSpace = component.get('v.nameSpace');
        nameSpace = 'ElixirSuite__';
        var value = event.getSource().get("v.value");
        var obj = component.get("v.carePlan");
        obj[nameSpace+'Primary_Therapist__c'] = value;
        component.set("v.carePlan" , obj);
    },
    setClinicalSupervisor : function(component ,event){
        var nameSpace = 'ElixirSuite__';
        var value = event.getSource().get("v.value");
        var obj = component.get("v.carePlan");
        obj[nameSpace+'Clinical_supervisor__c'] = value;
        component.set("v.ElixirSuite__Clinical_supervisor__c" , obj);
    },
    closeMainModal  : function(component){
        component.set("v.openViewCarePlanModal",false);
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
    },
    editEnable  : function(component) {
        component.set("v.editEnabled",false);
    },
    editEnableBlur : function(component) {
        component.set("v.editEnabled",true);
    },
    addProblems	:	function(component) {
        component.set("v.openMainModal",true);
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
            existingProblems : setOfIds
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
    
     procedureValidity  : function(component ,event ,helper){
        var valid = true;
        valid = helper.helperMethod(component , valid);
         console.log('valid'+valid);
    },
    
    Save : function(component) {
        
        console.log('dfv'+JSON.stringify(component.get("v.masterProblems")));
        /*var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);*/
        
        var allValid = true;
        console.log('allValid '+allValid);
        //  console.log(component.get("v.status"));
        var carePlanName = component.get("v.carePlanName");
        console.log('carePlanName ',carePlanName);
        var dateValid = true;
        var procedureStartCmp = component.find("procedure-start_time");
        var strtProcedureTime = procedureStartCmp.get('v.value');
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get('v.value');
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
        else{
            allValid = false;
            procedureEndCmp.setCustomValidity("Complete this field");
            procedureEndCmp.reportValidity();
        }
        
        if(allValid==false || dateValid==false){
                        if(allValid == false){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Failed!",
                    "message": "Please fill all the mandatory fields."
                });
                toastEvent.fire();
            }          
        }else{
            console.log('--> '+JSON.stringify(component.get("v.masterProblems")));
            
            var action = component.get("c.saveData");
            
            console.log('--> '+JSON.stringify(component.get("v.masterProblems")));
            action.setParams({ 
                carePlanName : carePlanName,
                caseId : component.get("v.selectedRow"),
                status : component.get("v.status"),
                caseRec  : component.get("v.carePlan"),
                masterData :  JSON.stringify(component.get("v.masterProblems")),
                starttimeProcedure :component.get('v.todayString'),
                endtimeProcedure : component.get('v.endString'),
                signatureComment :  component.get("v.signComment"), //signaturecomment
                signatureImage :  component.get("v.attachId" ),  //signature image
                signatureDate :  component.get("v.dateTodayForForm"), //signature date
                signeeName : component.get("v.signee1"),
                approvalLevel : component.get("v.LevelOfApproval"),
                Description : component.get("v.Description")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {   
                    component.set("v.openViewCarePlanModal",false);
                    var createEvent = component.getEvent("RefreshCarePlan");
                    createEvent.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : 'success',
                        "message": "Care Plan saved successfully."
                    });
                    toastEvent.fire();
                    
                    
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
            
        }
    },
    patientSignProcess : function(component) {
        var action = component.get("c.checkLoggedInUserApprovalAuthorityForLevel_1");    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                if(response.getReturnValue().alloWProceed){
                    if(response.getReturnValue().setUpEntity == 'Patient'){
                        component.set("v.sObjectName",'Account');  
                          component.set("v.setUpKey",'Patient');  
                        if( $A.util.isUndefinedOrNull(component.get("v.verifyCode")) ){
                            alert('OTP is not yet generated for Patient. Please generate OTP first.');
                        }
                        else{
                            component.set("v.verifyOtp",true);    
                            component.set("v.LevelOfApproval" , 'Level1');
                        } 
                    }
                    else {
                        component.set("v.sObjectName",'User'); 
                          component.set("v.setUpKey",''); 
                        if( $A.util.isUndefinedOrNull(response.getReturnValue().verficationCode)){
                            alert('OTP is not yet generated for User. Please generate OTP first.');
                        }
                        else {
                            component.set("v.verifyCode",response.getReturnValue().verficationCode);
                            component.set("v.verifyOtp",true);    
                            component.set("v.LevelOfApproval" , 'Level1'); 
                        }
                    }
                    
                    
                }
                else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "YOU ARE NOT AUTHORISED TO SIGN THIS CAREPLAN",
                        "message": "UNAUTHORISED USER!",
                        "type" : "error"
                    });
                    toastEvent.fire();
                }
                
                
                
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
        
        console.log("dfghjk" ,component.get("v.verifyCode"));
        
    },
    
    parentComponentEvent : function(component , event){
        console.log('att id' , event.getParam("signeeName"));
        var attId = event.getParam("attachementId"); 
        var commentSign = event.getParam("signComment");
        var dateToday = event.getParam("dateToday");
        var button = event.getParam("showButton"); 
        var signName = event.getParam("signeeName"); 
        var isCancelled = event.getParam("cancelKey");
        var val = '-';
        var button1 = event.getParam("showButton1"); 
        if( $A.util.isUndefinedOrNull(commentSign) ){
            component.set("v.signComment" , val);
        }
        else{
            component.set("v.signComment" , commentSign);
        }
        ///sfc/servlet.shepherd/version/download/
        ///servlet/servlet.FileDownload?file=
        if(component.get("v.setUpKey") == 'Patient'){
            component.set("v.attachId" , '/servlet/servlet.FileDownload?file='+attId);
        }
        else {
            component.set("v.attachId" , attId);
        }
      
      //  component.set("v.attachId" , '/sfc/servlet.shepherd/version/download/'+attId);
       
        component.set("v.dateTodayForForm" , dateToday );
        component.set("v.signee1" , signName);
        console.log('the val is' , component.get("v.signComment"));
        component.set("v.showSign" , button);
        component.set("v.newSign" , button1);
        if(isCancelled == 'isCancelled'){
            component.set("v.LevelOfApproval" , '');
        }
    },
})