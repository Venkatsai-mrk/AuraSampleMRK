({
    doInit : function(component, event, helper) { 
        console.log('patient id edit  '+JSON.stringify(component.get("v.problemDiagnosesData")));   
        console.log('previous inint'+JSON.stringify(component.get("v.inputSelectedValues")));
        var currentIndex = component.get("v.currentIndex");
        console.log('index '+currentIndex);
        helper.helperInit(component , event , helper);
        
        component.set('v.runScroll',true);  
        
    },
    handleVitalSigns :  function(component , event ,helper){
        component.set("v.openVitalSign",true);
    },
    handleGlucoselog : function(component , event ,helper){
        component.set("v.openGlucoseLog",true);
    },
    handleCloseGlucose: function(component , event ,helper){
        component.set("v.openGlucoseLog",false);
    },
    handleGlucoseDataEvent : function(component , event ,helper){
        
        console.log('getdata for glucose '+JSON.stringify(component.get("v.allergyData")));
        var glucoseDataRecord = event.getParam("glucoseData");
        console.log('event value returned '+JSON.stringify(glucoseDataRecord));
        var buffer  = component.get("v.glucoseData");
        console.log('getdata after buffer glucose '+JSON.stringify(buffer.data));
        buffer.hasValue = true;
        for(var rec in glucoseDataRecord){
            buffer.data.push(glucoseDataRecord[rec]);
        }
        
        component.set("v.glucoseData",buffer);
        component.set("v.openGlucoseLog",false);
        console.log('set value '+JSON.stringify(component.get("v.glucoseData")));
    },
    ToggleValues	:	function(component, event, helper) {
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
    TextValues :	function(component, event, helper) {
        
        var name = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        console.log('values '+value);
        console.log('name '+name); 
        var array = name.split('$');
        var Id = array[0];
        var type = array[1];
        if( type == 'Text'){
            var dataMap = component.get("v.inputSelectedValues");
            console.log('Json 00'+JSON.stringify(dataMap));
            
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
        var name = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        console.log('values '+value);
        console.log('name '+name); 
        var array = name.split('$');
        var Id = array[0];
        var upperIndex = array[1];
        var dataMap = component.get("v.selectedValues");
        console.log('Json '+JSON.stringify(dataMap));
        
        dataMap[Id] = value;
      
        //handling Radio button functionality
        var columnWiseData = component.get("v.columnWiseData");
        for(var column in columnWiseData){
            console.log('if' + JSON.stringify(columnWiseData[column].data));
            for(var inside in columnWiseData[column].data){
                if(columnWiseData[column].data[inside]['ElixirSuite__Data_Entry_Type__c'] == 'Multi checkbox Left' && columnWiseData[column].data[inside].Id != Id){
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
    dateTimeValues	:	function(component, event, helper) {
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
        console.log('add a');
        component.set("v.openAddAllergy",true);
        
        console.log('patient id  value '+component.get("v.patientID"));
        console.log('reset value '+component.get("v.openAddAllergy"));
    },
    handleCloseAllergy : function(component, event, helper) {
        component.set("v.openAddAllergy",false);
    },
    addMultipleNotes : function(component, event, helper)  {
        component.set("v.isNotesSectionVisibleHere",true); 
    },
    handleNoteAddition : function(component , event ,helper){
        var currentNote = component.get("v.currentCreatedNote"); 
        var toUse = {'data' : currentNote ,
                     'isEditable': true ,
                     'ElixirSuite__Note__c':currentNote};
        var notesList =   component.get("v.allCreateNotes");
        var i;
        for(i = 0; i < notesList.length; i++){
            notesList[i].data = notesList[i]['ElixirSuite__Note__c'];
            delete notesList[i].key1;
        }
        notesList.push(toUse);
        console.log(JSON.stringify(notesList)+"notesList11");
        component.set("v.allCreateNotes",notesList);
        component.set("v.isNotesListVisible",true);
        component.set("v.currentCreatedNote",'');
    },
    handleAllergyData : function(component, event, helper)  {
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
    handleBlurNotes :  function(component , event ,helper){
        debugger;
        var currentIndexNotes = component.get("v.totalCurrentIndexForNotes");
        var notesList =   component.get("v.allCreateNotes");
        var i;
        for(i = 0; i < notesList.length; i++){
            notesList[i].data = notesList[i]['ElixirSuite__Note__c'];
            delete notesList[i].key1;
        }
        //  notesList[currentIndexNotes].data =  event.getSource().get("v.value");
        // notesList[currentIndexNotes].isEditable  = true;
        console.log(JSON.stringify(notesList)+"notesList11");
        component.set("v.allCreateNotes",notesList);
    },
    handleMedication :  function(component, event, helper)  {
        component.set("v.openUpdateMedication",true);
    },
    handleCloseMedication :  function(component, event, helper)  {
        component.set("v.openUpdateMedication",false);
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
    handleMedicationDataEvent : function(component, event, helper)  {
        var buffer  = component.get("v.medicationData");
        buffer.hasValue=true;
        var jsonList = event.getParam("jsonList");
        console.log('JSON LIST RECEIVED '+JSON.stringify(jsonList));
        
        var allData  = [];
        allData.push(jsonList.jsonListForTaper);
        allData.push(jsonList.jsonListForPRN);
        allData.push(jsonList.jsonListForAOrder);
        
        
     
        var selectedUser = event.getParam("selectedUser");
        var selectedVia = event.getParam("selectedVia");
        for (var j=0;j<allData.length;j++) {
            for(var i=0;i<allData[j].length;i++) {
                var obj = {};
                obj[ 'ElixirSuite__Frequency__c'] = allData[j][i].Days[0].textMessage;
                obj[ 'ElixirSuite__Type__c'] = allData[j][i].types;
                obj[ 'ElixirSuite__Drug_Name__c'] = allData[j][i].medicationName;
                obj[ 'ElixirSuite__Route_New__c'] = allData[j][i].Route;
                obj[ 'ElixirSuite__Reason_new__c'] = allData[j][i].reasonLabel;
                buffer.data.push(obj);
                
            }
            
        }
        
        component.set("v.medicationData",buffer);
        console.log('buffer data after set ' +JSON.stringify( component.get("v.medicationData")));
        
    },
    handleAddProblems :  function(component , event ,helper){
        console.log('add problems handler data  '+JSON.stringify(component.get("v.problemDiagnosesData").data));
        var problemExists  = component.get("v.problemDiagnosesData").data;        
        component.set("v.existingProblems",component.get("v.problemDiagnosesData")); 
        component.set("v.openListOfProblems",true);
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
        console.log('checkhasvalue data '+JSON.stringify(checkHasValue.data));  
        component.set("v.problemDiagnosesData",checkHasValue);
        component.set("v.problemDiagnosesData.data",component.get("v.problemDiagnosesData").data);
        //  $A.get('e.force:refreshView').fire();
        console.log('getdata for problem '+JSON.stringify(component.get("v.problemDiagnosesData").data));          
        component.set("v.openListOfProblems",false);
        component.set("v.showDefaultProcedureNotification",true);        
        
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
    
})