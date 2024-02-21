({
    doInit : function(component, event, helper) {
        helper.fetchImageNamesInStaticResource(component);
        helper.defaultColumnsSet(component, event, helper);
        var action = component.get("c.fetchAllRecordTypesOnMDTObject");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var res = response.getReturnValue();
                helper['populateAttributeContainer'](component, event, helper,res.mapOfContainer);
                console.log('my resp '+JSON.stringify(res));
                if(res.noObjectAvailable){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "NO OBJECTS DEFINED IN CUSTOM META-DATA!",
                        "message": "Please define objects first!",
                        "type" : "error"
                    });
                    toastEvent.fire();
                }
                else {
                    
                    var recordTypesArr = [];
                    var toiterate =  res.mapByRecordTypeLabelAndDeveloperName;
                    component.set("v.mapOfRecTypeAndApi",JSON.parse(JSON.stringify(toiterate)));  
                    if(Object.keys(toiterate).length === 0 && toiterate.constructor === Object){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ALL FORMS ARE ALREADY CREATED!",
                            "message": "Please define new forms first!",
                            "type" : "error"
                        });
                        toastEvent.fire();
                    }
                    else {
                        for(var rec in toiterate){
                            recordTypesArr.push({'label': rec, 'value': rec});
                        }
                        helper.createListOfLookupApi(component, event, helper,res.lookupApiToInclude);
                        component.set("v.allRecordTypes",recordTypesArr);  
                    }
                }
                
            }
            
        });
        
        $A.enqueueAction(action);
        
    },
    
    onCheck: function(component, event) {
        console.log('first inside oncheck****');
        //  var checkCmp = component.find("checkbox");
        var chCmp = event.getSource().get("v.checked");
        // resultCmp = component.find("checkResult");
        //console.log('inside oncheck****',chCmp);
        component.set("v.myBool",chCmp );
        
    },
    
    handleRecordTypeSelection : function(component, event, helper) {
        component.set("v.sectionData",[]);
        var mapOfRecType = component.get("v.mapOfRecTypeAndApi");
        component.set("v.selectedRecordtype",event.getParam("value"));
        console.log('# event '+JSON.stringify(event.getParam("value")));
        var recTypeApi = mapOfRecType[event.getParam("value")];
        // debugger ;
        
        var formCategory = recTypeApi.split("_").pop();
        component.set("v.formCategory",formCategory);          
        
        var action = component.get("c.fetchAllFieldsForSelectedRecordType");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({
            selectedRecordTypeFuzzy: event.getParam("value"),
            recordTypeName : component.get("v.formNameReflectedAsRecordType")   
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    var res = response.getReturnValue();
                    var dataTypeMapFromApex = response.getReturnValue().dataTypeMap;
                    var labelApiCombo = res.fieldApiNameAndLabel;
                    var fieldApiAndObjectLabel = res.fieldsApiAndObjectLabelMap;
                    var labelApiList = [];   
                    for(var rec in labelApiCombo){
                        labelApiList.push({'label': labelApiCombo[rec] + ' ('+rec+')', 'value':rec+';'+dataTypeMapFromApex[rec]+';'+labelApiCombo[rec]+
                                           ';'+fieldApiAndObjectLabel[rec]});
                    }
                    component.set("v.AllFields",labelApiList);
                    component.set("v.AllFieldsNetInstanceCopy",JSON.parse(JSON.stringify(labelApiList)));
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "MATCH INFO",
                        "message": "Matching objects found "+res.objectMatchCount,
                        "type" : "info"
                    });
                    toastEvent.fire();
                    component.set("v.swapAbility",true);
                    helper.createSectionJSON(component, event, helper,labelApiList,res.accountFieldApiMap);
                    var columnSet = [{'label' : '1 Column', 'value' : '1'},{'label' : '2 Column', 'value' : '2'}];
                    component.set("v.selectedStatus",'1');
                    component.set("v.columnTypes",columnSet);
                    component.set("v.afterRecordTypeSelection",true);
                    if(res.objectMatchCount>1){
                        helper.configureObjectMatchingWindow(component, event, helper, res.duplicateObjects,res.schemaObjectApiAndLabelMap);
                        component.set("v.objectMatchingInfo",true); 
                    }
                    
                }
                catch(e){
                    alert(e);
                }
                
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
        
    },
    addNewRow: function(component, event, helper) { 
        helper.createObjectData(component, event);
        var lengthIteration = component.get("v.sectionData");
        var indexArratoPush = [];
        for(var i=1;i<=lengthIteration.length;i++){
            var instanceIndex = JSON.parse(JSON.stringify(i));
            indexArratoPush.push(instanceIndex);
        }
        component.set("v.GoToSectionData",indexArratoPush); 
        component.set("v.swapAbility",false);
    },
    addNewRowForFieldList : function(component, event, helper) { 
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;        
        var sectionData = component.get("v.sectionData");
        var isMatrix = false;
        var typeOfColumn = sectionData[index].typeOfColumn;
        if(typeOfColumn == "2"){
            isMatrix = true;
            
        }
        helper.createObjectDataForFiledlst(component, event,index,isMatrix,typeOfColumn);
    },
    removeDeletedRow: function(component, event) {
        try{
            var ctarget = event.currentTarget;
            var index = ctarget.dataset.value;
            var AllRowsList = component.get("v.sectionData");
            AllRowsList.splice(index, 1);
            if(AllRowsList.length==1){
                component.set("v.swapAbility",true);
            }
            component.set("v.sectionLength",JSON.parse(JSON.stringify(AllRowsList.length))); 
            var indexArratoPush = [];
            for(var i=1;i<=AllRowsList.length;i++){
                var instanceIndex = JSON.parse(JSON.stringify(i));
                indexArratoPush.push(instanceIndex);
            }
            component.set("v.GoToSectionData",indexArratoPush); 
            let RowItemList =  AllRowsList;
            var lstLength = RowItemList.length;
        if(!component.get("v.isSwapUsed")){
            component.set("v.sectionLength",JSON.parse(JSON.stringify(lstLength))); 
            var count = 0;
            for(let i=1;i<=lstLength;i++){
                RowItemList[count].serialNumber = i.toString();
                count++;
            } 
        }
        else {
            component.set("v.sectionLength",JSON.parse(JSON.stringify(lstLength))); 
            RowItemList[RowItemList.length - 1].serialNumber = RowItemList.length;
        }
            component.set("v.sectionData", AllRowsList);
        }
        catch(e){
            alert('error '+e);
        }
    },
    removeDeletedRowFieldList : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        var parentSectionData = component.get("v.sectionData");
        var array = index.split('$');
        var upperSectionIndex = array[0];
        var lowerFieldIndex = array[1];
        var fieldsArray =  parentSectionData[upperSectionIndex].FieldsLst;
        helper.removeApiFieldsForAutoText(component, event, helper,
                                          JSON.parse(JSON.stringify(parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].selectedField)),
                                          parentSectionData[upperSectionIndex]);
        if(parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].switchDecision){
            var selectedField =  parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].selectedFieldForFormulaMapping; 
            var selectedObjectForField =  parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].selectedObjectForFormula; 
            var mapQuery = parentSectionData[upperSectionIndex].mapQuery;      
            
            var fieldsArr = mapQuery[selectedObjectForField];
            if(!$A.util.isUndefinedOrNull(fieldsArr)){
                if(fieldsArr.includes(selectedField)){
                    const index = fieldsArr.indexOf(selectedField);
                    if (index > -1) {
                        fieldsArr.splice(index, 1);
                    }
                }
                mapQuery[selectedObjectForField] = fieldsArr;
            }
            
            
        }
        var AllRowsList = fieldsArray;
        var filedArray =parentSectionData[upperSectionIndex].FieldsLst;
        var typeOfColumn = parentSectionData[upperSectionIndex].typeOfColumn;
        var deletedRowNumber = parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].RowNumber;
        var deletedColNumber = parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].ColNumber;
        helper.arrangeFieldNumber(component, event,helper,index,filedArray,typeOfColumn,deletedRowNumber,deletedColNumber);
        
        AllRowsList.splice(lowerFieldIndex, 1);
        component.set("v.sectionData", parentSectionData);
    },
    handlecolumnChange : function(component, event, helper) {
        //   alert('12 '+event.getSource().get("v.name")); 
        var index =  event.getSource().get("v.name");  
        var result = event.getSource().get("v.value");  
        var sectionLst = component.get("v.sectionData");
        var fieldList = sectionLst[index].FieldsLst;
        if(result=='2'){
            for(var rec in fieldList){
                fieldList[rec].isMatrixAvailable = true;
            }
            helper.utilityArrange(component, event, helper,index,fieldList);
        }
        else {
            var count = 1;
            for(let rec in fieldList){
                fieldList[rec].isMatrixAvailable = false;
                fieldList[rec].RowNumber = count;
                count++;
            }
        }
        component.set("v.sectionData",sectionLst);
        
    },
    swtichSectionTo : function(component, event) {
        
        
        
        var index =  event.getSource().get("v.name"); 
        component.set("v.swapSectionIndex",index);  
        component.set("v.currentSection",parseInt(JSON.parse(JSON.stringify(index)))+1);  
        //Get all available sections
        var allIndexAvailableForSection = component.get("v.sectionData");
        var arayLength = allIndexAvailableForSection.length;
        var indexArratoPush = [];
        for(var i=1;i<=arayLength;i++){
            var instanceIndex = JSON.parse(JSON.stringify(i));
            indexArratoPush.push(instanceIndex);
        }
        /* if(indexArratoPush.includes(hardIndex)){
            const indexToSplice = indexArratoPush.indexOf(hardIndex);
            indexArratoPush = indexArratoPush.splice(indexToSplice, 1);
        }*/
        component.set("v.allAvailableSections",indexArratoPush); 
        
        //Re-arrange indexes
        var sectionLst = component.get("v.sectionData");
        sectionLst[index].swapSectionVisibility = true;
        component.set("v.sectionData",sectionLst); 
        
        
    },
    handleConfirmDialogNo : function(component) {
        var openIndex =  component.get("v.swapSectionIndex"); 
        var sectionLst = component.get("v.sectionData");
        sectionLst[openIndex].swapSectionVisibility = false;
        component.set("v.sectionData",sectionLst); 
    },
    handleConfirmDialogYes : function(component) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var sectionLst = component.get("v.sectionData");
        var currentIndex = parseInt(component.get("v.swapSectionIndex"));
        var swapToindex = parseInt(component.get("v.swapsectionToWhatIndex"));
        var swapToindex = swapToindex - 1 ; 
        var b = JSON.parse(JSON.stringify(sectionLst[currentIndex]));
        sectionLst[currentIndex] = JSON.parse(JSON.stringify(sectionLst[swapToindex]));
        sectionLst[swapToindex] = b;
        //   component.set("v.sectionData",sectionLst);
        
        // Close the modal after swap
        //  var sectionLst = component.get("v.sectionData");
        sectionLst[swapToindex].swapSectionVisibility = false;
        component.set("v.sectionData",sectionLst); 
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "SECTIONS SWAPPED SUCCESSFULLY!",
            "message": "Data swapped",
            "type" : "success"
        });
        toastEvent.fire();
        component.set("v.isSwapUsed",true);  
        component.find("Id_spinner").set("v.class" , 'slds-hide');
    },
    handleSetActiveSection : function(component, event) {
        component.find("accordion").set('v.activeSectionName', event.getSource().get("v.value"));
    },
    handleNext : function(component, event, helper) {
        var parentEmptyCheck = helper.checkHeaderEmpty(component, event, helper);
        if(!parentEmptyCheck){
         
            var footerButtonsValid = true;
            if(footerButtonsValid == false){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Failed!",
                    "message": "Please fill all the mandatory fields.",
                    "type" : "warning"
                });
                toastEvent.fire();
            }
            else {
                helper.buildQuery(component, event, helper);
                if (helper.validateFormConfiguration(component, event, helper)) {
                 helper.asyncValidations(component, event, helper); // generic save methos inside this method
                }     
            }
        }
    },
    cancelModal : function(component) {
        component.set("v.isOpen",false);
    },
    closeObjectMatchingInfoWindow : function(component) {
        component.set("v.objectMatchingInfo",false); 
    },
    handleConsentConfig : function(component, event, helper) {
        try{
            var index =  event.getSource().get("v.name");  
            var result = event.getSource().get("v.checked");
            var sectionLst = component.get("v.sectionData");
            if(result){
                console.log('checkbox result '+result);
                sectionLst[index].isConsentForm = true;
                sectionLst[index].defaultFiledLstVisibility = false;
                sectionLst[index].enableTable = false;
                sectionLst[index].showHeading = false;
                sectionLst[index].isMacro = false;
                sectionLst[index].typeOfColumn = '1';
                sectionLst[index].mapQuery = {};
                sectionLst[index].FieldsLst = [];
                sectionLst[index].isFormSpecificData = false;
                sectionLst[index].addProblem = false;
                sectionLst[index].addProcedure = false;
                sectionLst[index].enableProblemForNotes = false; 
                helper.createObjectDataForFiledlst(component, event,index,false,'1');
            }
            
            component.set("v.sectionData",sectionLst); 
            
            
            
        }
        catch(e){
            alert('error '+e);
        }
    },
    checkSOQLValidation :  function(component, event, helper) {
        try{
            let val = event.getSource().get("v.value").toLowerCase();
            if(val){
                const commaCount = val.split(',').length - 1;
                
                if(!val.startsWith('select')){
                    
                    helper.globalFlagToast(component, event, helper,'Query should start with SELECT!', ' ','warning');
                }
                else if(commaCount > 4){
                    
                    helper.globalFlagToast(component, event, helper,'Not more than 5 fields are allowed in SOQL!', ' ','warning');
                }
                
            }
            
        }
        catch(e){
            alert(e);
        }
    },
    handleFormComponentChange : function(component, event, helper) {
        try{
            var index =  event.getSource().get("v.name"); 
            var upperSectionIndex = index;            
            helper.offAllAttributes(component, event, helper,upperSectionIndex);
            let mapOfPicklistAndFunction = {'Enable Templates For Notes':'handleMacroEnable',
                                            'Enable Consent' : 'handleConsentConfig',
                                            'Form Specific Data' : 'activateSectionAsExternalComponent',
                                            'Enable Table' : 'enableMatrixTable',
                                            'Enable Problems' : 'enableAddProblem',
                                            'Enable Diagnoses' : 'enableDiagnoses',
                                            'Enable Procedure' : 'enableProcedure',
                                            'Enable Modular Table' : 'enableModularTable',
                                            'Enable Notes for Medical Coding' : 'enableProblemFromNotes', 
                                            'Enable Draw And Annotate' : 'enableDrawAndAnnotate',
                                            'Enable Upload And Annotate' : 'enableUploadAndAnnotate',
                                            'Enable SOQL' : 'enableFreeTextSOQL',
                                            'Enable Inventory Order' : 'addInventory',
                                            'Enable Prescription Order' : 'AddPrescriptionOrder',
                                            'Enable Lab Order' : 'EnableLabOrder',
                                            'Enable Medications List' : 'enableMedicationsList',
                                           };
            let value =  event.getSource().get("v.value");  
            if(value){
                let helperName = mapOfPicklistAndFunction[value];         
                helper[helperName](component, event, helper,index);  
            }
            else {
                helper.offAllAttributes(component, event, helper,upperSectionIndex);
                let sectionLst = component.get("v.sectionData");
                sectionLst[upperSectionIndex].defaultFiledLstVisibility = true;
                sectionLst[upperSectionIndex].typeOfColumn = '1';
                sectionLst[upperSectionIndex].FieldsLst = [];
                helper.createObjectDataForFiledlst(component, event, upperSectionIndex,false,"1"); 
                component.set("v.sectionData",sectionLst);            
            }
            
            
            
            
        }
        catch(e){
            alert('error '+e);
        }
        
    },
    
    isConsent_fetchFields : function(component, event, helper) {
        var index =  event.getSource().get("v.name");          
        var array = index.split('$');
        var upperSectionIndex = array[0];
        var val = event.getSource().get("v.value"); 
        
        helper.getAllselectedObjFields(component, event, helper, component.get("v.sectionData"),upperSectionIndex,val);
    },
    openDefaultTextBox :  function(component, event, helper) {
        try{
            var index =  event.getSource().get("v.name");  
            var val = event.getSource().get("v.value"); 
            var parentSectionData = component.get("v.sectionData");
            var array = index.split('$');
            var upperSectionIndex = array[0];
            var lowerFieldIndex = array[1];
            
            // Open picklist as radio checkbox
            var arrayVal = val.split(';');
            // Checkbox ability based on type of field
            if(helper.controlFormSpicificDataAbility(component, event, helper,arrayVal[0])){
                parentSectionData[upperSectionIndex].abilityForFormSpecificData = false;  
                parentSectionData[upperSectionIndex].hasextCmp = true;  
                // parentSectionData[upperSectionIndex].isFormSpecificData = true;
                helper.fetchRecordTypesIfExists(component, event, helper,arrayVal[0],parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex],
                                                upperSectionIndex,lowerFieldIndex,val);
                
                
                helper.filterlookupFields(component, event, helper, parentSectionData[upperSectionIndex]);
                
                
            }
            else {
                parentSectionData[upperSectionIndex].hasextCmp = false; 
                parentSectionData[upperSectionIndex].abilityForFormSpecificData = true;  
            }
            if(arrayVal[1] == 'REFERENCE'){
                helper.checkAutoPopulation(component, event, helper,arrayVal[3],arrayVal[0],upperSectionIndex,lowerFieldIndex);
                
            }
            else{
                parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].showAutoPopulation = false;
            }
            
            if(arrayVal[1] == 'PICKLIST'){
                parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].displayPicklistAsRadio = true;   
            }
            // Open picklist as radio MULTIPICKLIST
            else if(arrayVal[1] == 'MULTIPICKLIST'){
                parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].displayMultiPicklistAsCheckbox = true; 
            }
                else {
                    parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].displayPicklistAsRadio = false;  
                    parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].displayMultiPicklistAsCheckbox = false; 
                }
            console.log(JSON.stringify(val));
            // Open default label textbox
            if(parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].switchFormulaEnabled == false){
                parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].isDefaultLabelActive = true;    
            }
            // open switch 
            parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].switchDecision = true; 
            helper.setAllApiFieldsForAutotext(component,event,helper,
                                              JSON.parse(JSON.stringify(parentSectionData[upperSectionIndex].FieldsLst)), 
                                              parentSectionData[upperSectionIndex]);
            component.set("v.sectionData", parentSectionData);
            console.log('after set '+JSON.stringify(component.get("v.sectionData")));
        }catch(e){
            alert('exception '+e);
        }
        
        
        
    },
    enableFormulaMapping : function(component, event) {
        var index =  event.getSource().get("v.name");  
        var parentSectionData = component.get("v.sectionData");
        var result = event.getSource().get("v.checked");
        var array = index.split('$');
        var upperSectionIndex = array[0];
        var lowerFieldIndex = array[1];
        if(result){
            parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].isSwitchedToFormula = true;  
            parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].isDefaultLabelActive = false;  
            parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].selectedObjectForFormula = '';
        }
        else {
            parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].isSwitchedToFormula = false;
            parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].fieldsAfterFormula = false; 
            parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].isDefaultLabelActive = true;  
            /* LOGIC TO REMOVE RECORD FROM ARRAY OF MAP IF FORMULA IS DISABLED**/
            var formulaFieldSelected =  parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].selectedFieldForFormulaMapping;
            var selectedObjectForFormula = parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].selectedObjectForFormula;
            if(!$A.util.isUndefinedOrNull(formulaFieldSelected)){
                var mapQuery  = parentSectionData[upperSectionIndex].mapQuery;
                var fieldsArray = mapQuery[selectedObjectForFormula];
                if(!$A.util.isEmpty(fieldsArray)){
                    const index = fieldsArray.indexOf(formulaFieldSelected);
                    if (index > -1) {
                        fieldsArray.splice(index, 1);
                    } 
                }
            }
            
            /* ***************************************************************************************/
            //  component.set("v.accountChildObjectLabel",[]); 
        }
        component.set("v.sectionData",parentSectionData); 
        if($A.util.isEmpty(component.get("v.accountChildObjectLabel"))){
            if(result){
                
                var action = component.get("c.fetchAccountAndRelatedChildObject");
                component.find("Id_spinner").set("v.class" , 'slds-show');
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.find("Id_spinner").set("v.class" , 'slds-hide');
                        var res = response.getReturnValue(); 
                        var acctChildRelation = [];
                        for(var rec in res){
                            if(rec=='Account'){ res[rec]='Id'}
                            acctChildRelation.push({'label': rec, 'value': res[rec]+';'+rec});
                        }
                        console.log('acctChildRelation'+JSON.stringify(acctChildRelation));
                        component.set("v.accountChildObjectLabel",acctChildRelation); 
                        
                    }
                    
                });
                
                $A.enqueueAction(action);
            }
        }
        
        
    },
    openFieldsForSelectedObject : function(component, event) {
        try{
            var index =  event.getSource().get("v.name");  
            var parentSectionData = component.get("v.sectionData");
            var toSplitValue = event.getSource().get("v.value");
            var getFieldApiAndObjectName = toSplitValue.split(';');  
            var result = getFieldApiAndObjectName[1];
            var array = index.split('$');
            var upperSectionIndex = array[0];
            var lowerFieldIndex = array[1];
            parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].lookupApiName = getFieldApiAndObjectName[0]; 
            //   if($A.util.isEmpty(component.get("v.accountChildObjectFields"))){
            var action = component.get("c.fetchFormulaRelatedInfo");
            action.setParams({
                objectName: result
            });
            component.find("Id_spinner").set("v.class" , 'slds-show');
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    var res = response.getReturnValue().labelApicombo;    
                    var labelApiArr = [];
                    for(var rec in res){
                        labelApiArr.push({'label': res[rec], 'value': rec});
                    }
                    component.set("v.accountChildObjectFields",labelApiArr); 
                    parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].fieldListForFormulaMapping = labelApiArr;
                    parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].accountLookupFieldLst = response.getReturnValue().accountRelatedLookupAPIs;
                    parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].fieldsAfterFormula = true; 
                    component.set("v.sectionData",parentSectionData);
                    console.log('object field account'+JSON.stringify(res));
                }
                
            });
            
            $A.enqueueAction(action);
            //  }
            //  parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].fieldsAfterFormula = true; 
            component.set("v.sectionData",parentSectionData);
        }
        
        catch(e){
            alert(e);
        }
        
    },
    afterFiledSelection : function(component, event) { 
        var index =  event.getSource().get("v.name");  
        var parentSectionData = component.get("v.sectionData");
        var result = event.getSource().get("v.value");
        var array = index.split('$');
        var upperSectionIndex = array[0];
        var lowerFieldIndex = array[1];
        component.set("v.fieldLstIndex",lowerFieldIndex);
        var fieldList = parentSectionData[upperSectionIndex].FieldsLst;
        var arr = [];
        
        var selectedObject = parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].selectedObjectForFormula;
        var selectedField = parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].selectedFieldForFormulaMapping;
        var mapOfquery = parentSectionData[upperSectionIndex].mapQuery;
        var queryVar = {};
        if($A.util.isUndefinedOrNull(mapOfquery)){
            var arr = [];
            arr.push(selectedField);
            queryVar[selectedObject] = arr;  
            parentSectionData[upperSectionIndex].mapQuery = queryVar;
        }
        else {
            if(mapOfquery.hasOwnProperty(fieldList[lowerFieldIndex].selectedObjectForFormula)){
                var arr = mapOfquery[fieldList[lowerFieldIndex].selectedObjectForFormula];
                if(!arr.includes(result)){
                    arr.push(result);
                }
                mapOfquery[fieldList[lowerFieldIndex].selectedObjectForFormula] = arr;                
            }
            else {
                var arr = [];
                arr.push(result);
                mapOfquery[fieldList[lowerFieldIndex].selectedObjectForFormula] = arr;
            }
            parentSectionData[upperSectionIndex].mapQuery = mapOfquery; 
        }
        
        component.set("v.sectionData",parentSectionData);
        console.log('map Of Query '+JSON.stringify(parentSectionData[upperSectionIndex].mapQuery));
        console.log('final #999'+JSON.stringify(component.get("v.sectionData")));
    },
    activateSectionAsExternalComponent :  function(component, event) { 
        var index =  event.getSource().get("v.name"); 
        var parentSectionData = component.get("v.sectionData");
        
        if(event.getSource().get("v.checked")){
            var allFields = parentSectionData[index].allFields;
            var allLookupFields = component.get("v.allLookupApi");
            var newCommonArray = [];
            for(var rec in allFields){
                var api = allFields[rec].value.split(';');
                if(allLookupFields.includes(api[0])){ newCommonArray.push(allFields[rec]); }
                
            }
            parentSectionData[index].allFields = newCommonArray;
            console.log('common aray '+JSON.stringify(newCommonArray));
        }
        /* else {
            parentSectionData[index].allFields = component.get("v.AllFieldsNetInstanceCopy");
            
        }*/
        component.set("v.sectionData",parentSectionData);
    },
    
    
    handletableColumnChange :  function(component, event, helper) {
        try{
            let index =  event.getSource().get("v.name");  
            let parentSectionData = component.get("v.sectionData");
            let result = event.getSource().get("v.value");
            let array = index.split('$');
            let upperSectionIndex = array[0];
            let fldLst = parentSectionData[upperSectionIndex].table_fieldLst;
            helper.arrangeHeadingCol(component, event,helper,parentSectionData,upperSectionIndex,result); 
            for(let rec in fldLst){
                if(parseInt(result)>fldLst[rec].colLst.length){
                    let len = JSON.parse(JSON.stringify((parseInt(result) - fldLst[rec].colLst.length)));
                    for(let i=1;i<=len;i++){
                        fldLst[rec].colLst.push(helper.returnFieldSObjInstance(component, event,helper));
                    }
                }
                else{
                    fldLst[rec].colLst = 
                        fldLst[rec].colLst.slice(0, parseInt(result)); 
                }
            }
            let lastElement_fldLst = fldLst[fldLst.length - 1];
            let lastElement_colLst = lastElement_fldLst.colLst[lastElement_fldLst.colLst.length-1];
            
            for(let elm in fldLst){
                let colArr  = fldLst[elm].colLst;
                for(let elm_Child in colArr){
                    colArr[elm_Child]['isLast'] = false;
                }           
            }
            if(fldLst.length!=1){
                lastElement_colLst['isLast'] = true;
            }
            helper.tableMatrix_UtilityArrange(component, event,helper,parentSectionData,upperSectionIndex);            
            component.set("v.sectionData",parentSectionData);
        }
        catch(e){
            alert('error '+e);
        }
    },
    clearHeading : function(component, event) {
        let parentSectionData = component.get("v.sectionData");
        let upperSectionIndex = event.getSource().get("v.name").split('$')[0];
        
        let tableHeadingArr = parentSectionData[upperSectionIndex].table_HeadingArr;
        
        for (let i in tableHeadingArr) {
            tableHeadingArr[i].heading = '';
        }
        
        component.set("v.sectionData", parentSectionData);
    },
    removeDeletedRowForTable :  function(component, event) {
        try{
            var ctarget = event.currentTarget;
            var index = ctarget.dataset.value; 
            let parentSectionData = component.get("v.sectionData");
            let array = index.split('$');
            let upperSectionIndex = array[0];
            let secData = parentSectionData[upperSectionIndex];
            secData.table_fieldLst.pop();
            let lastElement_fldLst = secData.table_fieldLst[secData.table_fieldLst.length - 1];
            let lastElement_colLst = lastElement_fldLst.colLst[lastElement_fldLst.colLst.length-1];
            let fldLst = secData.table_fieldLst;
            for(let elm in fldLst){
                let colArr  = fldLst[elm].colLst;
                for(let elm_Child in colArr){
                    colArr[elm_Child]['isLast'] = false;
                }           
            }
            if(fldLst.length!=1){
                lastElement_colLst['isLast'] = true;
            }
            component.set("v.sectionData",parentSectionData); 
        }
        catch(e){
            alert(e);
        }
    },
    addNewRowForMatrixTable :  function(component, event, helper) {
        try{
            var ctarget = event.currentTarget;
            var index = ctarget.dataset.value;        
            var sectionData = component.get("v.sectionData");
            var isMatrix = false;
            var typeOfColumn = sectionData[index].typeOfColumn;
            helper.createObjectDataForFiledlst_MatrixTable(component, event,index,isMatrix,typeOfColumn);            
            helper.tableMatrix_UtilityArrange(component, event,helper,sectionData,index);
            component.set("v.sectionData",sectionData);
            console.log('completed');
        }
        catch(e){
            alert('error '+e);
        }
    },
    enaleAutoTextGeneration  : function(component, event) {
        var index =  event.getSource().get("v.name");  
        var result = event.getSource().get("v.checked");
        var sectionLst = component.get("v.sectionData");
        sectionLst[index].enableAutoText = result;
        
        component.set("v.sectionData",sectionLst); 
    },
    checkValidityForFieldsApi : function(component, event, helper) {
        try {
            var value = event.getSource().get("v.value");
            if(value.includes('$')){
                var allcommonWordsContainer = value.split('$');
                var allApiArray = [];
                for(let rec in allcommonWordsContainer){
                    
                    if(allcommonWordsContainer[rec].includes('[') && allcommonWordsContainer[rec].includes(']')){
                        var commulativeString = JSON.parse(JSON.stringify(allcommonWordsContainer[rec]));
                        var result = commulativeString.substring(
                            commulativeString.lastIndexOf("[") + 1, 
                            commulativeString.lastIndexOf("]")
                        );			 
                        
                        if(result.includes('*')){
                            allApiArray = allApiArray.concat(result.split('*')); 
                        }
                        else if(result.includes('+')){
                            allApiArray =  allApiArray.concat(result.split('+')); 
                        }
                            else if(result.includes('@')){
                                allApiArray =  allApiArray.concat(result.split('@')); 
                            }
                                else {
                                    allApiArray.push(result);
                                }
                        
                    }
                }
                
                console.log('api arrays '+allApiArray);
                
                var filtered = allApiArray.filter(function (el) {
                    return el != null;
                }); // remove undefined records
                filtered = filtered.filter(item => item); // remove empty strings
                const filteredArray = helper.removeHTMLTagsIfAny(component, event, helper,filtered); // remove html tags
                var lowerCasedFieldApiArray = filteredArray.map(filteredArray => filteredArray.toLowerCase()); // to lower case
                
                
                if($A.util.isEmpty(component.get("v.allAPIFieldsForAutoText"))){
                    var action = component.get("c.doesFieldExist");
                    component.find("Id_spinner").set("v.class" , 'slds-show');
                    
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            component.find("Id_spinner").set("v.class" , 'slds-hide');                    
                            var res = response.getReturnValue();
                            console.log('my fields valid resp  '+JSON.stringify(res));
                            var mapApiStringified = JSON.stringify(res).toLowerCase();
                            var mapOfAllApi = JSON.parse(mapApiStringified);
                            component.set("v.allAPIFieldsForAutoText",mapOfAllApi)
                            helper.checkFieldsValidity(component, event,helper,mapOfAllApi,lowerCasedFieldApiArray);
                            
                        }
                        else {
                            
                            component.find("Id_spinner").set("v.class" , 'slds-hide');     
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "ERROR OCCURRED!",
                                "message": "ERROR OCCURRED!",
                                "type" : "error"
                            });
                            toastEvent.fire();
                        }
                        
                    });
                    
                    $A.enqueueAction(action);
                }
                else { 
                    helper.checkFieldsValidity(component, event,helper,component.get("v.allAPIFieldsForAutoText"),lowerCasedFieldApiArray);
                }
            }
        }
        catch(e){
            alert('error '+e);
        }
    },
    isConsent_generateListOfApi :  function(component, event, helper) {
        try{
            var index =  event.getSource().get("v.name");  
            var parentSectionData = component.get("v.sectionData");
            var array = index.split('$');
            var upperSectionIndex = array[0];
            
            const selectedOptions =  parentSectionData[upperSectionIndex].isConsent_selected_allFieldAPIs;
            if($A.util.isEmpty(selectedOptions)){
                helper.flagNoResult(component, event, helper);
                parentSectionData[upperSectionIndex].isConsent_showFieldApi = false;
            }
            else {
                let arr = [];
                for(let rec in selectedOptions){
                    arr.push(selectedOptions[rec]);
                }
                let existingFields = parentSectionData[upperSectionIndex].isConsent_allFieldAPIStringified;
                existingFields = existingFields.split("\n");
                existingFields = existingFields.concat(arr);
                let uniqueChars = [...new Set(existingFields)];
                for(let obj in uniqueChars){
                    let splitArr = uniqueChars[obj].split('.');
                    if(splitArr.includes('Account')){
                        if(!parentSectionData[upperSectionIndex].isConsent_SelectedObject_Lst.includes('Account')){
                            parentSectionData[upperSectionIndex].isConsent_SelectedObject_Lst.push('Account');
                        }
                    }
                    if(splitArr.includes('User')){
                        if(!parentSectionData[upperSectionIndex].isConsent_SelectedObject_Lst.includes('User')){
                            parentSectionData[upperSectionIndex].isConsent_SelectedObject_Lst.push('User');
                        }
                    }
                }
                parentSectionData[upperSectionIndex].isConsent_allFieldAPIStringified =  uniqueChars.join('\n');
                parentSectionData[upperSectionIndex].isConsent_showFieldApi = true;
                
            }
            component.set("v.sectionData",parentSectionData);
            console.log('selected '+JSON.stringify(selectedOptions));
        }
        catch(e){
            alert('error '+e);
        }
    },
    moveSectionUp : function(component, event, helper){
        let arr = component.get("v.sectionData");
        let targetindex =  parseInt(event.getSource().get("v.name"));  
        if(targetindex!=0){
            let destinationIndex = targetindex - 1;
            [arr[targetindex], arr[destinationIndex]] = [arr[destinationIndex], arr[targetindex]];
            [arr[targetindex].serialNumber, arr[destinationIndex].serialNumber] = [arr[destinationIndex].serialNumber, arr[targetindex].serialNumber];
        }
        else{
            helper.globalFlagToast(component, event, helper,'CANNOT GO UP NOW!', 'You are on the top!','error'); 
        }
        component.set("v.sectionData",arr);
    },
    moveSectionDown : function(component, event, helper){
        let arr = component.get("v.sectionData");
        let targetindex =  parseInt(event.getSource().get("v.name"));  
        if(!((targetindex+1) == arr.length)){
            let destinationIndex = targetindex + 1; 
            [arr[targetindex], arr[destinationIndex]] = [arr[destinationIndex], arr[targetindex]];
            [arr[targetindex].serialNumber, arr[destinationIndex].serialNumber] = [arr[destinationIndex].serialNumber, arr[targetindex].serialNumber];
        }
        else {
            helper.globalFlagToast(component, event, helper,'CANNOT GO DOWN NOW!', 'You are on the last!','error'); 
        } 
        component.set("v.sectionData",arr); 
    }
})