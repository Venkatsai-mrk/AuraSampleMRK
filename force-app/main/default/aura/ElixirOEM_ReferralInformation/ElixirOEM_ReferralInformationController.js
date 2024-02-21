({
    doInit : function(component, event, helper) {        
        component.set("v.loaded",false);         
        try{
            helper.setDefaultJSON(component, event, helper);
            helper.setDefaultData(component, event, helper);
            var action = component.get("c.referralInfoInitPayload");
            action.setParams({
                "accountId" :  component.get("v.accountId")
            });
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") {  
                    try{
                        component.set("v.loaded",true); 
                        console.log(' screen 2 '+JSON.stringify(response.getReturnValue()));
                        let result =  response.getReturnValue();                  
                        let patientInfo = result.patientInfo;
                        let patientVOBDetails = result.patientVOBDetails;
                        if(!$A.util.isEmpty(patientInfo)){
                            component.set("v.patientInfo",patientInfo[0]);    
                        }
                        if(!$A.util.isEmpty(patientVOBDetails)){
                            component.set("v.patientVOBDetails",patientVOBDetails[0]);   
                        }                    
                        result.lstToReturn.forEach(function(element) {
                            element['isSelected'] = false;
                        });  
                        component.set("v.files",result.lstToReturn);  
                        helper.setDefaultChartEntities(component, event, helper,result); 
                    }
                    catch(e){
                        alert('error in screen 2 '+e);
                    }
                }
                else if (STATE === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log('Error in init');
                        }
                    } 
                }
                component.set("v.LoadingText", false);
            });
            $A.enqueueAction(action);
        }
        catch(e){
            alert(e)
        }
        
    },
    handleUploadFinished : function (component) {
        console.log('Over upload finished with record Id '+component.get("v.accountId"));
        try{  
            var action = component.get("c.handlingAfterUpload");
            action.setParams({
                "accountId": component.get("v.accountId")
            });
            
            action.setCallback(component, function(response) {
                console.log('state Chetan' +state);
                
                var state = response.getState();
                let result =  response.getReturnValue();                  
                
                
                if(state=="SUCCESS"){
                    component.set("v.files",result);  
                }
            });
            $A.enqueueAction(action);
            
        }catch(error){
            console.log(JSON.Stringify(error)+' error --> '+error);
        }
    },
    
    
    openEntityWindow : function(component, event, helper) {
        let mapOfsObjLabelAndApi = {'Vitals' : 'ElixirSuite__Medical_Examination__c;Vital_Sign',
                                    'Allergies' : 'ElixirSuite__Medical_Examination__c;Allergy',
                                    'Diagnosis Codes' : 'ElixirSuite__Diagnosis_Code__c',
                                    'Procedure Codes' : 'ElixirSuite__Procedure__c',
                                    'Problems' : 'ElixirSuite__Dataset1__c',
                                    'Medications' : 'ElixirSuite__Prescription_Order__c',
                                    'Notes' : 'Notes',
                                    'Lab Results' : 'ElixirSuite__UA_Sample_Details__c;Lab_Order'};
        let index = event.getSource().get("v.name");       
        let checked = event.getSource().get("v.checked");       
        console.log('index '+index);
        let chartSummaryOptions = component.get("v.chartSummaryOptions");
        console.log('chartSummaryOptions '+JSON.stringify(chartSummaryOptions));
        let objLabel = chartSummaryOptions[index].label;      
        if(checked){
            component.set("v.loaded",false); 
            var action = component.get("c.fetchEntityData");
            action.setParams({
                "enitity" : mapOfsObjLabelAndApi[objLabel],
                "accountId" :  component.get("v.accountId"),
                "objLabel" : objLabel
            });
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") { 
                    component.set("v.loaded",true);                    
                    let mapOfColumnAndFields = {'Vitals' : ['ElixirSuite__Temperature__c', 'ElixirSuite__Pulse__c', 'ElixirSuite__Blood_Pressure_Diasystolic__c;ElixirSuite__Blood_Pressure_Systolic__c','ElixirSuite__BMI__c'],
                                                'Allergies' : ['ElixirSuite__Allergy_Name__c' , 'ElixirSuite__Reaction__c', 'ElixirSuite__Severity__c','ElixirSuite__Note__c'],
                                                'Diagnosis Codes' : ['ElixirSuite__Diagnosis_Code_and_Name__c' , 'ElixirSuite__Code_Description1__c', 'ElixirSuite__Version__c'],
                                                'Procedure Codes' : ['Name','ElixirSuite__Code_Description__c','ElixirSuite__Code_Category__c'],
                                                'Problems' : ['Name','ElixirSuite__SNOMED_CT_Code__c','ElixirSuite__Problem_Type__c','ElixirSuite__Date_Onset__c'],
                                                'Medications' : ['ElixirSuite__Drug_Name__c','ElixirSuite__Reason_new__c','ElixirSuite__Route_New__c','ElixirSuite__Number_of_Times_Days_Weeks__c'],
                                                'Lab Results' : ['Name','ElixirSuite__Medical_Test__c','ElixirSuite__Status__c'],
                                               };
                    if(mapOfsObjLabelAndApi[objLabel] == 'Notes'){                   
                        chartSummaryOptions[index].entityData =  helper.arrangelstvalueAsForms(component, event, helper,response.getReturnValue().formLst);
                    }
                    else {
                        chartSummaryOptions[index].isOpenOnlyforSelected=false;
                        let result =  response.getReturnValue().dataToRet;                 
                        result.forEach(function(element, index) {
                            element['isSelected'] = false;
                            if(element['isSelected']){
                                chartSummaryOptions[index].isOpenOnlyforSelected=true; 
                            }
                            let cols = mapOfColumnAndFields[objLabel];
                            let count = 1;
                            cols.forEach(function(element_data) {
                                if(element_data.includes(';')){
                                    let arr = element_data.split(';');
                                    let val = element[arr[0]]+'/'+element[arr[1]];
                                   //added for column fix
                                    if(val)
                                    {
                                    element['column_'+count] = val;
                                    console.log('column' + val);
                                    }                                   
                                }
                                else {
                                    //added for column fix
                                    if(element[element_data])
                                    {
                                        console.log('element[element_data] ' + element[element_data]);
                                    element['column_'+count] = element[element_data];
                                }
                                }
                                count++;
                            });  
                            
                        });  
                        chartSummaryOptions[index].entityData = result;
                    }
                    component.set("v.chartSummaryOptions",chartSummaryOptions);
                    console.log('chartSummaryOptions openEntityWindow '+JSON.stringify(component.get("v.chartSummaryOptions")));
                }
                else if (STATE === "ERROR") {
                    component.set("v.loaded",true); 
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log('Error in entity')
                        }
                    } 
                }
                    else {
                        component.set("v.loaded",true); 
                    }
                component.set("v.LoadingText", false);
            });
            $A.enqueueAction(action);
        }
        else {
            component.set("v.chartSummaryOptions",chartSummaryOptions); 
        }
        
        
    },
    createDynamicColumns : function() {
        
    },
    previewFile :function(event){  
        //  var rec_id = event.currentTarget.id; 
        var rec_id = event.getSource().get("v.name");
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [rec_id]
        });  
    },  
    closeModal : function(component) {
        //component.set("v.isOpen",false);
         /************Nikhil**************/ 
        var workspaceAPI =component.find("workspace");
        if(component.get("v.backPage2")){
         component.set("v.isOpen",false);       
        }else{
         window.history.go(-2);        
        }
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error){
            console.log(error);
        });
    },
    closePageTwo : function(component) {
        try{  
            var cmpEvent = component.getEvent("ElixirOEM_ReferralToggle");        
            cmpEvent.setParams({            
                "pageNumber" : "Two" });        
            cmpEvent.fire();
        }
        catch(e){
            alert('closePageTwo error '+e);
        }
        
    },
    backFromPageTwo : function(component) {
        try{  
            var cmpEvent = component.getEvent("ElixirOEM_ReferralToggle");         
            cmpEvent.setParams({            
                "pageNumber" : "BackFromTwo" });        
            cmpEvent.fire();
        }
        catch(e){
            alert('backFromPageTwo error '+e);
        }
        
    },
    edit : function(component, event) {
        /* var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": component.get("v.recordId")
        });
        editRecordEvent.fire();*/
        console.log(JSON.stringify(event.getSource())+' '+event.getSource());
        console.log(JSON.stringify( event.getSource().get("v.name")));
        
        component.set('v.openEditNotes',false);
        
        let index = event.getSource().get("v.name");       
        let chartSummaryOptions = component.get("v.chartSummaryOptions");
        console.log(chartSummaryOptions[index])
        if(chartSummaryOptions[index]){
            component.set('v.openEditNotes',true);
        }
    },
    onSelected : function(component, event) {
        let nameChartSummary = event.getSource().get("v.name");       
        let checked = event.getSource().get("v.checked");  
        let chartSummaryOptions = component.get("v.chartSummaryOptions");
        for(var key in chartSummaryOptions) {
            if(chartSummaryOptions[key].label ===nameChartSummary ){
                chartSummaryOptions[key].isOpenOnlyforSelected=checked;
                
            }
        }
        
        component.set("v.chartSummaryOptions",chartSummaryOptions);
        console.log('chartSummaryOptions in onselect '+JSON.stringify(chartSummaryOptions));
    },
    selectAllRows: function(component, event) {
        try {
            var isChecked = event.getSource().get("v.checked");
            let index = event.getSource().get("v.name");
            var chartSummaryOptions = component.get("v.chartSummaryOptions");
            chartSummaryOptions[index].isSelected = isChecked;
            
            var entityData = chartSummaryOptions[index].entityData;
            entityData.forEach(function(entity) {
                entity.isSelected = isChecked;
            });           
            component.set("v.chartSummaryOptions", chartSummaryOptions);
        }       
        catch (e) {
            console.log('Error in selectAllRows: ' + e);
        }       
    },
	selectAllFiles: function(component, event) {
        var isChecked = event.getSource().get("v.checked");
        var fileLst = component.get("v.files");
        
        for (var i = 0; i < fileLst.length; i++) {
            fileLst[i].isSelected = isChecked;
        }
        
        component.set("v.files", fileLst);
    },
})