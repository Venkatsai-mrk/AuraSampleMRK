({
    doInit : function(component, event, helper) { 
       //alert('patient id '+JSON.stringify(component.get("v.patientID")));
        //console.log('problem 456  data  '+component.get("v.problemDiagnosesData"));
        var currentIndex = component.get("v.currentIndex");
        console.log('index '+currentIndex);
       
        if(currentIndex >= 10){
            
            new Promise(function(resolve, reject) { 
                resolve(helper.helperInit(component , event , helper));
                
            }) 
        }else{
            helper.helperInit(component , event , helper);
        }
        component.set('v.runScroll',true);
        
        var nameSpace = 'ElixirSuite__';
        component.set('v.columns', [
            {label: 'BP SYSTOLIC', fieldName: nameSpace + 'Blood_Pressure_Systolic__c', type: 'text'},
            {label: 'TEMPRATURE', fieldName: nameSpace + 'Temperature__c}', type: 'text'},
            {label: 'PULSE', fieldName: nameSpace + 'Pulse__c}', type: 'text'},
            {label: 'CODE', fieldName: 'ElixirSuite__ValueSampledDataOriginCodeLabel__c', type: 'text'}
        ]);
        

        
    },
    ToggleValues	:	 function(component, event, helper) {
        var nameSpace = 'ElixirSuite__';
        var name = event.getSource().get("v.name");
        var value = event.getSource().get("v.checked");
        console.log('values '+value);
        console.log('name '+name); 
        var array = name.split('$');
        var Id = array[0];
        //var upperIndex = array[1];
        //var insideIndex = array[2];
        var dataMap = component.get("v.selectedValues");
        console.log('Json '+JSON.stringify(dataMap));
        
        dataMap[Id] = value;
        
        component.set("v.selectedValues",dataMap);
        console.log('JSON '+JSON.stringify(dataMap));
        
    },
    TextValues :	 function(component, event, helper) {
        var nameSpace = 'ElixirSuite__';
        var name = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        console.log('values '+value);
        console.log('name '+name); 
        var array = name.split('$');
        var Id = array[0];
        var type = array[1];
        if( type == 'Text'){
            var dataMap = component.get("v.inputSelectedValues");
            console.log('Json '+JSON.stringify(dataMap));
            
            dataMap[Id] = value;
            
            component.set("v.inputSelectedValues",dataMap);
            console.log('JSON '+JSON.stringify(dataMap));
            
        }
        else if( type == 'TextArea'){
            var dataMap = component.get("v.inputTextAreaSelectedValues");
            console.log('Json '+JSON.stringify(dataMap));
            
            dataMap[Id] = value;
            
            component.set("v.inputTextAreaSelectedValues",dataMap);
            console.log('JSON '+JSON.stringify(dataMap));
        }
        
    },
    multiCheckBoxLeft	:  function(component, event, helper) {
        var nameSpace = 'ElixirSuite__';
        var name = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        console.log('values '+value);
        console.log('name '+name); 
        var array = name.split('$');
        var Id = array[0];
        var upperIndex = array[1];
        var dataMap = component.get("v.selectedValues");
        console.log('Json '+JSON.stringify(dataMap));
        var nameSpace = '' ;
        dataMap[Id] = value;
        
        //handling Radio button functionality
        var columnWiseData = component.get("v.columnWiseData");
        for(var column in columnWiseData){
            console.log('if' + JSON.stringify(columnWiseData[column].data));
            for(var inside in columnWiseData[column].data){
                if(columnWiseData[column].data[inside][nameSpace + 'Data_Entry_Type__c'] == 'Multi checkbox Left' && columnWiseData[column].data[inside].Id != Id){
                    console.log(columnWiseData[column].data[inside].value);
                    columnWiseData[column].data[inside].value = false;
                    dataMap[columnWiseData[column].data[inside].Id] = false;
                }
            }
        }
        component.set("v.columnWiseData",columnWiseData);
        component.set("v.selectedValues",dataMap);
        
        console.log('JSON '+JSON.stringify(dataMap));
        console.log('Final List'+JSON.stringify(columnWiseData));
  
        
    },
    
    dateValues	:  function(component, event, helper) {
        var nameSpace = 'ElixirSuite__';
        var name = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        console.log('values '+value);
        console.log('name '+name); 
        var array = name.split('$');
        var Id = array[0];
        var upperIndex = array[1];
        var dataMap = component.get("v.inputDateSelectedValues");
        console.log('Before date '+JSON.stringify(dataMap));
        dataMap[Id] = value;
        component.set("v.inputDateSelectedValues",dataMap);
        console.log('After date '+JSON.stringify(dataMap));
    },
    dateTimeValues	:	 function(component, event, helper) {
        var nameSpace = 'ElixirSuite__';
        var name = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        console.log('values '+value);
        console.log('name '+name); 
        var array = name.split('$');
        var Id = array[0];
        var upperIndex = array[1];
        var dataMap = component.get("v.inputDateTimeselectedValues");
        console.log('Before dateTime '+dataMap);
        
        dataMap[Id] = value;
        console.log('After dateTime '+JSON.stringify(dataMap));
        component.set("v.inputDateTimeselectedValues",dataMap);
        console.log('After dateTime '+JSON.stringify(dataMap));
    },
    
    
    handleAddAllergy : function(component, event, helper) {
        var nameSpace = 'ElixirSuite__';
        console.log('add a');
        component.set("v.openAddAllergy",true);
        
        console.log('patient id  value '+component.get("v.patientID"));
        console.log('reset value '+component.get("v.openAddAllergy"));
    },
    handleCloseAllergy : function(component, event, helper) {
        component.set("v.openAddAllergy",false);
    },
    handleAllergyData : function(component, event, helper)  {
        var nameSpace = 'ElixirSuite__';
        console.log('getdata '+JSON.stringify(component.get("v.allergyData")));
        var allergyDataRecord = event.getParam("allergyData");
        console.log('event value returned '+JSON.stringify(allergyDataRecord));
        var buffer  = component.get("v.allergyData");
        console.log('getdata after buffer '+JSON.stringify(buffer.data));
        buffer.hasValue = true;
        for(var rec in allergyDataRecord ){
            buffer.data.push(allergyDataRecord[rec]);
        }
        
        component.set("v.allergyData",buffer);
        component.set("v.openAddAllergy",false);
        console.log('set value '+JSON.stringify(component.get("v.allergyData")));
        
        
    },
    handleMedication :  function(component, event, helper)  {
        component.set("v.openUpdateMedication",true);
    },
    HandleRefreshEditForPRoblemDiagnoses :   function(component, event, helper)  {
        var allUpdatedData = event.getParam("afterEditData");
        var getAllData = component.get("v.problemDiagnosesData");
        getAllData.data =allUpdatedData;
        component.set("v.problemDiagnosesData",getAllData);
    },
    handleCloseMedication :  function(component, event, helper)  {
        component.set("v.openUpdateMedication",false);
    },
    handleproblemDaignosesDataEvent :  function(component, event, helper)  {
        console.log('refrenced data   '+JSON.stringify(component.get("v.problemDiagnosesData")));
        var checkHasValue  = component.get("v.problemDiagnosesData");
        checkHasValue.hasValue = true ;
        
        
        var holdCleanArr = JSON.parse(JSON.stringify(checkHasValue.data));
        for(var i = checkHasValue.data.length - 1; i >= 0; i--){
            if(!checkHasValue.data[i].problemIsChecked && !$A.util.isUndefinedOrNull(checkHasValue.data[i].problemIsChecked)){
              holdCleanArr.splice(i,1); 
            }
        }
         checkHasValue.data = holdCleanArr ; 
        
        
     /*   for(var rec in checkHasValue.data){
            if(!checkHasValue.data[rec].problemIsChecked){
                checkHasValue.data.splice(rec,1); 
            }
        }*/
        component.set("v.problemDiagnosesData",checkHasValue);
        component.set("v.problemDiagnosesData.data",component.get("v.problemDiagnosesData").data);
        //  $A.get('e.force:refreshView').fire();
        console.log('getdata for problem '+JSON.stringify(component.get("v.problemDiagnosesData").data));
        /* var problemDiagnosesRecords = event.getParam("problemDiagnosesDataToSave");
        console.log('event value returned for problemDiagnoses '+JSON.stringify(problemDiagnosesRecords));
        var buffer  = component.get("v.problemDiagnosesData");
        console.log('only buffer  '+JSON.stringify(buffer));
        console.log('getdata after buffer problem '+JSON.stringify(buffer.data));
        buffer.hasValue = true;
        var problemDiagnosesToSave  = [];
        var toDeleteRecordsOnForm  = [];
        var toUpdateRecordsOnForm  = [];
         var toUpdateNotesOnForm  = [];
        for(var rec in problemDiagnosesRecords ){
            if(problemDiagnosesRecords[rec].problemIsChecked==true){
                if(!$A.util.isUndefinedOrNull(problemDiagnosesRecords[rec].isrelatedDiagnosesUpdated)  && problemDiagnosesRecords[rec].isrelatedDiagnosesUpdated) {
                    var relatedDiagnoses  =  JSON.parse(JSON.stringify(problemDiagnosesRecords[rec].relatedDiagnoses));                    
                    toUpdateRecordsOnForm=toUpdateRecordsOnForm.concat(relatedDiagnoses);
                }
                 if(!$A.util.isUndefinedOrNull(problemDiagnosesRecords[rec].isrelatedNotesUpdated)  && problemDiagnosesRecords[rec].isrelatedNotesUpdated) {
                    var relatedNotes  =  JSON.parse(JSON.stringify(problemDiagnosesRecords[rec].relatedNotes));                    
                    toUpdateNotesOnForm=toUpdateNotesOnForm.concat(relatedNotes);
                }
                var idx = problemDiagnosesRecords[rec].relatedDiagnoses;              
                var idxData =  JSON.parse(JSON.stringify(idx));
                if(!$A.util.isUndefinedOrNull(idxData)) {
                    for (var j=(idxData.length)-1;j>=0;j--) {    
                        if( idxData[j].diagnosesIsChecked==false) {
                            idx.splice(j,1);                    
                        } 
                        
                    }                   
                }
                problemDiagnosesToSave.push(problemDiagnosesRecords[rec]);            
            }
            else if(!$A.util.isUndefinedOrNull(problemDiagnosesRecords[rec].isDelete)  && problemDiagnosesRecords[rec].isDelete){       
                toDeleteRecordsOnForm.push(problemDiagnosesRecords[rec].Id);
            }
           
            
        
        }
       
        buffer.data=problemDiagnosesToSave;
        component.set("v.problemDiagnosesData",buffer);
        component.set("v.toDeleteRecordsOnForm",toDeleteRecordsOnForm);
        component.set("v.toUpdateRecordsOnForm",toUpdateRecordsOnForm);
         component.set("v.toUpdateNotesToProblemRecordsOnForm",toUpdateNotesOnForm); */       
        component.set("v.openListOfProblems",false);
        component.set("v.showDefaultProcedureNotification",true);        
        //  console.log('set value problem diagnoses'+JSON.stringify(component.get("v.problemDiagnosesData")));
        //  console.log('to delete records'+JSON.stringify(component.get("v.toDeleteRecordsOnForm")));
        // console.log('too update records '+JSON.stringify(component.get("v.toUpdateRecordsOnForm")));
        // console.log('too update Notes  '+JSON.stringify(toUpdateNotesOnForm));
        
        
    },
    
    
    handleMedicationDataEvent : function(component, event, helper)  {
        var buffer  = component.get("v.medicationData");
        buffer.hasValue=true;
        var jsonList = event.getParam("jsonList");
        console.log('JSON LIST RECEIVED '+JSON.stringify(jsonList));
        
        var allData  = [];
        allData.push(jsonList.jsonListForTaper);
        allData.push(jsonList.jsonListForPRN);
        allData.push(jsonList.jsonListForAOrder);
        
        
        var nameSpace ='ElixirSuite__' ;
        var selectedUser = event.getParam("selectedUser");
        var selectedVia = event.getParam("selectedVia");
        for (var j=0;j<allData.length;j++) {
            for(var i=0;i<allData[j].length;i++) {
                var obj = {};
                obj[nameSpace + 'Frequency__c'] = allData[j][i].Days[0].textMessage;
                obj[nameSpace + 'Type__c'] = allData[j][i].types;
                obj[nameSpace+'Drug_Name__c'] = allData[j][i].medicationName;
                obj[nameSpace + 'Route_New__c'] = allData[j][i].Route;
                obj[nameSpace+'Reason_new__c'] = allData[j][i].reasonLabel;
                buffer.data.push(obj);
                
            }
            
        }
        
        component.set("v.medicationData",buffer);
        console.log('buffer data after set ' +JSON.stringify( component.get("v.medicationData")));
        
    },
    handleVitalSignsDataDataEvent :   function(component , event ,helper){
        console.log('getdata for vital '+JSON.stringify(component.get("v.vitalSignsData")));
        var vitalDataRecord = event.getParam("vitalSignDataToSave");
        console.log('event value returned for vital '+JSON.stringify(vitalDataRecord));
        var buffer  = component.get("v.vitalSignsData");
        console.log('getdata after buffer vital '+JSON.stringify(buffer.data));
        buffer.hasValue = true;
        
        buffer.data.push(vitalDataRecord);    
        component.set("v.vitalSignsData",buffer);
        component.set("v.openVitalSign",false); 
        // component.set("v.openVitalSign",false);
        console.log('set value vitals '+JSON.stringify(component.get("v.vitalSignsData")));
        
    },
    handleGlucoseDataEvent : function(component , event ,helper){
        
        console.log('getdata for glucose '+JSON.stringify(component.get("v.allergyData")));
        var glucoseDataRecord = event.getParam("glucoseData");
        console.log('event value returned '+JSON.stringify(glucoseDataRecord));
        var buffer  = component.get("v.glucoseData");
        console.log('getdata after buffer glucose '+JSON.stringify(buffer.data));
        buffer.hasValue = true;
        for(var rec in glucoseDataRecord ){
            buffer.data.push(glucoseDataRecord[rec]);
        }
        
        component.set("v.glucoseData",buffer);
        component.set("v.openGlucoseLog",false);
        console.log('set value '+JSON.stringify(component.get("v.glucoseData")));
    },
    
    handleGlucoselog : function(component , event ,helper){
        component.set("v.openGlucoseLog",true);
    },
    handleCloseGlucose: function(component , event ,helper){
        component.set("v.openGlucoseLog",false);
    },
    handleVitalSigns :  function(component , event ,helper){
        component.set("v.openVitalSign",true);
    },
    handleCloseVitalSigns :  function(component , event ,helper){
        component.set("v.openVitalSign",false);
    },
    handleAddProblems :  function(component , event ,helper){
        console.log('add problems handler data  '+JSON.stringify(component.get("v.problemDiagnosesData").data));
        var problemExists  = component.get("v.problemDiagnosesData").data;
        /*var arr = [];
        for (var problem in problemExists) {
            if(problemExists[problem].isAddedFromTemplate) {
                arr.push(problemExists[problem]);
            }
            
        }
        console.log('arr data '+JSON.stringify(arr));
        component.set("v.problemDiagnosesData.data",problemExists);*/
        component.set("v.existingProblems",component.get("v.problemDiagnosesData")); 
        component.set("v.openListOfProblems",true);
    },
    handleConfirmDialogCancel :  function(component , event ,helper){
        
        component.set("v.openListOfProblems",false);
    },
    openAddProblems :  function(component , event ,helper){
    },
    allowNotesEditable: function(component , event ,helper){
        var allData = component.get("v.problemDiagnosesData.data");
        var parentIndex =  event.getSource().get("v.name");
        component.set("v.parentJSON",allData);
        component.set("v.dataForEdit",allData[parentIndex]);
        component.set("v.openProblemAsEditable",true);
        console.log('pi data to edit  '+JSON.stringify(dataToEdit));
        
    },
    addMultipleNotes : function(component , event ,helper){
        component.set("v.isNotesSectionVisible",true);
    },
    handleNoteAddition : function(component , event ,helper){
        var currentNote = component.get("v.currentCreatedNote"); 
        debugger;
        var toUse = {'data' : currentNote ,
                     'isEditable': true };
        var notesList =   component.get("v.allCreateNotes");
        notesList.push(toUse);
         component.set("v.allCreateNotes",notesList);
          component.set("v.isNotesListVisible",true);
        component.set("v.currentCreatedNote",'');
    },
   handleDeleteNotes :  function(component , event ,helper){
       var currentIndex =  event.getSource().get("v.name");
        var notesList =   component.get("v.allCreateNotes");
       if(notesList.length==0){
         component.set("v.isNotesListVisible",false);    
       }
        notesList.splice(currentIndex,1);
        component.set('v.allCreateNotes',notesList);
    },
     handleEditNotes :  function(component , event ,helper){
          var currentIndex =  event.getSource().get("v.name");
          var notesList =   component.get("v.allCreateNotes");
          notesList[currentIndex].isEditable = false;
         component.set("v.allCreateNotes",notesList);
     component.set("v.totalCurrentIndexForNotes",currentIndex);
     },
    handleBlurNotes :  function(component , event ,helper){
    var currentIndexNotes = component.get("v.totalCurrentIndexForNotes");
          var notesList =   component.get("v.allCreateNotes");
        notesList[currentIndexNotes].data =  event.getSource().get("v.value");
        notesList[currentIndexNotes].isEditable  = true;
        component.set("v.allCreateNotes",notesList);
    },
    onBlurForNotes : function(component , event ,helper){
        var allData = component.get("v.problemDiagnosesData.data");
        var parentIndex =  event.getSource().get("v.label");
        var arr = parentIndex.split('$');
        var upperIndex = arr[0];
        var insideIndex = arr[1];
        var nameSpace = 'ElixirSuite__' ;
        allData[upperIndex].relatedNotes[insideIndex][nameSpace + 'Notes__c']=event.getSource().get("v.value");
        allData[upperIndex].relatedNotes[insideIndex].isEditable=true;
        component.set("v.problemDiagnosesData.data",allData);        
        console.log('pi '+parentIndex);
        console.log('onblue value  '+ event.getSource().get("v.label"));
    },
    allowDaignosesEditable : function(component , event ,helper){
        //  component.set(dataForEdit
        component.set("v.openProblemAsEditable",true);
    },
    onScroll :  function(component, event, helper){
        alert('hheloo there!!');
    },
    
    initHelper	: function(component , event ,helper){
        if($A.util.isUndefinedOrNull(component.get("v.allergyData"))) {
            var allergyData  = {
                'hasValue'  : false,
                'data' : []
            };          
            component.set("v.allergyData",allergyData);           
        }
        var allergy  = component.get("v.allergyData");
        var data = component.get("v.showDetail");  
        var arrayForHeight = ['3 "1"','3 "2"','3 "3"','3 "4"','3 "5"','3 "6"','3 "7"','3 "8"','3 "9"','3 "10"','3 "11"','4 "0"',
                              '4 "1"','4 "2"','4 "3"','4"4"','4 "5"','4 "6"','4 "7"','4 "8"','4 "9"','4 "10"','4 "11"','5 "0"',
                              '5 "1"','5 "2"','5 "3"','5 "4"','4 "5"','4 "6"','4 "7"','4 "8"','4 "9"','4 "10"','4 "11"','5 "0"',
                              '4 "1"','4 "2"','4 "3"','4"4"','4 "5"','4 "6"','4 "7"','4 "8"','4 "9"','4 "10"','4 "11"','5 "0"',
                              '4 "1"','4 "2"','4 "3"','4"4"','4 "5"','4 "6"','4 "7"','4 "8"','4 "9"','4 "10"','4 "11"','5 "0"'];
        component.set('v.heightPicklist',arrayForHeight);
        console.log('array'+JSON.stringify(data));
        var dataMap = component.get("v.selectedValues");//For checkboxes , toggles
        var inputDataMap = component.get("v.inputSelectedValues");//For input
        var inputDateMap = {};// For Date
        var inputTimeMap = {};// For Time
        var inputDateTimeMap = {};//For Date Time
        var matrixCssList = [];
        var styleCssList = [];
        var InputTextareaMap = component.get("v.inputTextAreaSelectedValues");//For input Text Area
        component.set("v.inputFirstCss",'slds-col slds-size_4-of-12');
        component.set("v.inputSecondCss",'slds-col slds-size_4-of-12');
        component.set("v.inputFirstCheckboxClass",'slds-col slds-size_6-of-12');
        component.set("v.inputSecondCheckboxClass",'slds-col slds-size_2-of-12');
        var array = [];
        
        var jsonForCls = { '1' : 'slds-col slds-size_12-of-12',
                          '2'	:	'slds-col slds-size_6-of-12',
                          '3'	: 'slds-col slds-size_4-of-12',
                          '4' : 	'slds-col slds-size_3-of-12',
                          '6'	: 'slds-col slds-size_2-of-12'      
                         };
        var today = new Date();
        component.set('v.today', today.getDate() + "-" + (today.getMonth() + 1) + "-" + today.getFullYear() );
        component.set('v.todayString', today.toISOString());
        
        // Making map fo saving
        var counter = 0;
        var maxCols;
        var isMatrixCompiled = false;
        var ProblemListCompiled = false;
        var histroyListCompiled = false;
        var yesNoCompiled = false;
        var feedbackCompiled = false;
        var nameSpace = 'ElixirSuite__' ;
        
        for(var rec in data){
            if(data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Text Area (Rich)'){                
                helper.utilityPattern(component , data[rec][nameSpace + 'Field_Name__c'] ,data , rec);
                
            }
            if(data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Toggle' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Multi CheckBox' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Multi checkbox Left' 
               ||   data[rec][nameSpace + 'Data_Entry_Type__c'] == 'checkbox Left' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'checkbox'){
                console.log('Id '+data[rec].Id);
                dataMap[data[rec].Id] = false;               
                data[rec]['value'] = false;                
            }
            else if(data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Input :Text Area' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'input:TextArea(Only)'){              
                if(!( $A.util.isEmpty(data[rec][nameSpace + 'Default_Text_Area__c']) || $A.util.isUndefinedOrNull(data[rec][nameSpace + 'Default_Text_Area__c']))){
                    InputTextareaMap[data[rec].Id] = data[rec][nameSpace + 'Default_Text_Area__c'];
                }
                
            }
                else if(data[rec][nameSpace + 'Data_Entry_Type__c'] == 'input:Date'){
                    inputDateMap[data[rec].Id] = today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate();
                    console.log('Date '+JSON.stringify(inputDateMap));
                }
                    else if((data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:Yes/No' ||  data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:Note' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Status_List'
                             || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'PulseRate_List' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Sweating_List' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'RunnyNoseOrTearing_List'
                             || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Restlessness_List' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'PupilSize_List'|| data[rec][nameSpace + 'Data_Entry_Type__c'] == 'GIUpset_List'
                             || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'BoneOrJoint_List' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:Patient awareness' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:Facial'
                             || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'TremorOutstretched_List' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'AnxietyOrIrritability_List' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:History' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:DischargeValues'
                             || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'GoosefleshSkin_List' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:FeedbackRating' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:ProblemRating' )&& data[rec][nameSpace + 'Picklist_Values__c']!=''){
                        helper.StaticPicklistValues(component,data[rec][nameSpace + 'Picklist_Values__c'] , data[rec][nameSpace + 'Data_Entry_Type__c']);
                        
                    }
            
            if(data[rec][nameSpace + 'style__c'] == 'Credit Card'){
                console.log('credit '+data[rec][nameSpace + 'style__c']);
                component.set("v.inputFirstCss", 'slds-size_3-of-12');
                component.set("v.inputSecondCss", 'slds-size_4-of-12');
                component.set("v.inputFirstCheckboxClass",'slds-col slds-size_3-of-12');
                component.set("v.inputSecondCheckboxClass",'slds-col slds-size_2-of-12');
                
            }
            else if(data[rec][nameSpace + 'style__c'] == 'Credit Card First'){
                component.set("v.inputFirstCss", 'slds-size_1-of-12');
                component.set("v.inputSecondCss", 'slds-size_9-of-12');
                counter = 1;
            }
                else if(data[rec][nameSpace + 'style__c'] == 'Pharmacy Credit Card'){
                    component.set("v.inputFirstCheckboxClass", 'slds-size_10-of-12');
                    component.set("v.inputSecondCheckboxClass", 'slds-size_2-of-12');              
                }
                    else if(data[rec][nameSpace + 'style__c'] == 'MATRIX' && isMatrixCompiled == false){
                        if(data[rec][nameSpace + 'Maximum_Column_in_each_Section__c']  > 5){
                            for(var i = 0 ; i < data[rec][nameSpace + 'Maximum_Column_in_each_Section__c'] ; i++){
                                if(i == 0){
                                    matrixCssList.push('slds-size_4-of-12 datetime_input_css textarea_form_element');
                                    styleCssList.push("font-size : 10px ; padding-top: 10px; padding-left : 10px ; width: 23% ");
                                }else{
                                    matrixCssList.push('slds-size_1-of-12 textarea_form_element');
                                    styleCssList.push("font-size : 10px ; padding-top: 10px; padding-left : 10px ; width: 15%");
                                }
                                
                            }  
                        }
                        else{
                            for(var i = 0 ; i < data[rec][nameSpace + 'Maximum_Column_in_each_Section__c'] ; i++){
                                if(i == 0){
                                    matrixCssList.push('slds-size_3-of-12 datetime_input_css textarea_form_element');
                                    styleCssList.push("padding-top: 10px; padding-left : 10px ");
                                }else{
                                    matrixCssList.push('slds-size_3-of-12 textarea_form_element');
                                    styleCssList.push(" padding-top: 10px; padding-left : 10px");
                                }
                                
                            }  
                        }
                        
                        isMatrixCompiled = true;
                    }
            
        }
        component.set('v.selectedValues',dataMap);
        component.set('v.inputDateSelectedValues',inputDateMap);
        component.set('v.inputDateTimeSelectedValues',inputDateTimeMap);
        component.set('v.inputTextAreaSelectedValues',InputTextareaMap);
        //component.set('v.parentinputSelectedValues',inputDataMap);
        //component.set('v.inputTextAreaSelectedValues',inputDataMap); 
        console.log('Map init  '+JSON.stringify(InputTextareaMap));
        // Ends
        console.log('data size '+data.length);
        var cls;
        var multiCheckBoxCls;
        var nameSpace = '' ;
        console.log('showDetail '+JSON.stringify(data));
        if(counter == 1){
            maxCols = 2; 
        }else{
            maxCols = data[0][nameSpace + 'Maximum_Column_in_each_Section__c'];
        }
        
        
        var listOfColumns = [];
        var listOfColumnWiseFields = [];
        var map = new Map();
        console.log('dfghfggggggggg '+JSON.stringify(map.size));
        var key ;
        for(var keys=1; keys<=maxCols; keys++){
            //For css end
            if(isMatrixCompiled == false){
                if(maxCols ==1 || maxCols == 3 ||maxCols == 2 || maxCols == 4 || maxCols== 6){
                    {
                        cls = jsonForCls[maxCols];
                    }       
                }
                else if(maxCols > 7){         
                    cls = 'slds-col slds-size_1-of-12';
                    
                }
                matrixCssList.push(cls);               
            }
            
            //For css end
            var arrayInside = [];
            var nameSpace = '' ; 
            for(var rec in data){            
                
                if(data[rec][nameSpace + 'Columns__c'] == keys){
                    
                    if(! map.has(keys)){                
                        arrayInside.push(data[rec]);                
                        map.set(keys,arrayInside);                
                    }else{               
                        map.get(keys).push(data[rec]);
                    }          
                }
                
            }
        }
        
        console.log('gfds'+map.keys());
        var index = 0;
        for(let key of map.keys()){		
            helper.doSort(map.get(key));
            array.push({'css': matrixCssList[index] ,'style': styleCssList[index], 'data' : map.get(key)});
            index++;
        }
        
        component.set('v.matrixCssList',matrixCssList);
        component.set("v.columnWiseData",JSON.parse(JSON.stringify(array)));
         var todayForDateTime = new Date();
        var colWiseData = component.get("v.columnWiseData");
        for(var rec in  colWiseData){
            var upperParent = colWiseData[rec].data;
            for(var inside in upperParent){
                if(upperParent[inside].ElixirSuite__Data_Entry_Type__c == 'Input:Date/Time'){
                      var dataMap = component.get("v.inputDateTimeselectedValues");
                        dataMap[upperParent[inside].Id] = todayForDateTime.toISOString();
                        component.set("v.inputDateTimeselectedValues",dataMap);
                }
            }
        }
    }
    
})