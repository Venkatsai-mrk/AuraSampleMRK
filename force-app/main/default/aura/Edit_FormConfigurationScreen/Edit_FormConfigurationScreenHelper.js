({
    fetchRecordInView : function(component, event, helper) {
        //  alert('rec id '+component.get("v.recordId"));
        var action = component.get("c.fetchRecordDataForEditScreen");
        action.setParams({
            recordNumericID: component.get("v.formRecordName") 
        });
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    var res = response.getReturnValue(); 
                    helper['populateAttributeContainer'](component, event, helper,res.mapOfContainer);
                    helper.setIsConsentAllFields(component, event, helper,JSON.parse(JSON.stringify(res)));
                    helper.setAccountChildlabelList(component, event, helper,res.accountChildObject);
                    helper.addInventory(component, event, helper,res.mapOfInventory);
                    helper.populateAllFields(component, event, helper,res.dataForSavedRecordType);
                    console.log('my edit res '+JSON.stringify(res));
                    console.log('my edit child '+JSON.stringify(res.allChildRelatedobjects));
                    component.set("v.formNameReflectedAsRecordType",res.allParentSections[0].ElixirSuite__Form__c);                 
                    var parentData = helper.arrangeDataAsParentChild(component, event, helper,res.allParentSections,res.allChildRelatedobjects);
                    console.log('parent data '+JSON.stringify(parentData));                
                    component.set("v.sectionData",parentData);
                    
                    // Iterate over parentData to and fetch field details of any section containing table
                    var parent=0;
                    var parentDataLength = parentData.length;
                    for (let i=0; i<parentDataLength; i++) {                        
                        if (parentData[i].enableTable) {
                            // This section has table in it, fetch it's field details
                            console.log('Section: ', i, 'ParentId: ',  parentData[i].parentID, 'enableTable: ', parentData[i].enableTable);
                            
                            var action = component.get("c.fetchRecorrdsForEachSection");
                            action.setParams({
                                parentID: parentData[i].parentID
                                
                            });
                            
                            action.setCallback(this, function(response) {
                                var state = response.getState();
                                if (state === "SUCCESS") {
                                    var allChilds = response.getReturnValue().allChildRelatedobjects;
                                    var parentSection = response.getReturnValue().allParentSections;
                                    
                                    if(parentSection[parent].ElixirSuite__Is_matrix__c){
                                        parentData[i]['table_fieldLst'] = helper.createTableMatrix(component, event, helper,allChilds);
                                        
                                        component.set("v.sectionData",parentData);
                                        console.log('parent data after for-loop'+JSON.stringify(parentData));
                                    }
                                    console.log("finished for ", i);
                                }
                                else {
                                    var errors = response.getError();
                                    if (errors) {
                                        console.log("Error message: " + errors[0].message);
                                    }
                                }
                            });
                            
                            $A.enqueueAction(action);
                        }
                    }
                    
                    
                }
                catch(e){
                    alert('error  '+e);
                    
                }
            }
            else if (state === "ERROR") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // log the error passed in to AuraHandledException
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        
        $A.enqueueAction(action);
        
    },
    
    setAccountChildlabelList  : function(component, event, helper,serverResponse){
        console.log('acct child '+JSON.stringify(serverResponse));
        var res = serverResponse;
        var acctChildRelation = [];
        for(var rec in res){
            if(rec=='Account'){ res[rec]='Id'}
            acctChildRelation.push({'label': rec, 'value': res[rec]+';'+rec});
        }
        console.log('acctChildRelation'+JSON.stringify(acctChildRelation));
        component.set("v.accountChildObjectLabel",acctChildRelation);   
    },
    fetchAllRecordTypes_MDTObject : function(component, event, helper,responseForMDTObject){
        
        var res = responseForMDTObject;
        console.log('my resp '+JSON.stringify(res));
        var recordTypesArr = [];
        var toiterate =  res.mapByRecordTypeLabelAndDeveloperName;
        for(var rec in toiterate){
            recordTypesArr.push({'label': rec, 'value': rec});
        }
        component.set("v.allRecordTypes",recordTypesArr); 
    },
    populateAllFields : function(component, event, helper,responseForEdit) {
        var res = responseForEdit;
        var dataTypeMapFromApex = res.dataTypeMap;
        var labelApiCombo = res.fieldApiNameAndLabel;
        var fieldApiAndObjectLabel = res.fieldsApiAndObjectLabelMap;
        console.log('object label and api  '+JSON.stringify(fieldApiAndObjectLabel));
        console.log('field api and label  '+JSON.stringify(res));
        console.log('dataTypeMapFromApex  '+JSON.stringify(dataTypeMapFromApex));
        var labelApiList = [];   
        for(var rec in labelApiCombo){
            labelApiList.push({'label': labelApiCombo[rec] + ' ('+rec+')', 'value':rec+';'+dataTypeMapFromApex[rec]+';'+labelApiCombo[rec]+
                               ';'+fieldApiAndObjectLabel[rec]});
        }
        console.log('--> '+JSON.stringify(labelApiList));
        component.set("v.AllFields",labelApiList); 
        component.set("v.AllFieldsNetInstanceCopy",JSON.parse(JSON.stringify(labelApiList))); 
        
    },
    createIsConsentFieldsArray :function(component, event, helper,parentSection) {
        let stringQuery = parentSection.ElixirSuite__Consent_Fields_Per_Section_Stringified__c;
        let mapOfObjAndFields = {};
        if(!$A.util.isUndefinedOrNull(stringQuery)){
            if(stringQuery){
                let arr = stringQuery.split('\n');
                arr.forEach( function(element) {
                    let entityQuery = element.split('.');
                    entityQuery.forEach( function() {
                        if(mapOfObjAndFields.hasOwnProperty(entityQuery[0])){
                            if(!mapOfObjAndFields[entityQuery[0]].includes(entityQuery[1])){
                                mapOfObjAndFields[entityQuery[0]].push(entityQuery[1]);
                            }
                        }
                        else {
                            mapOfObjAndFields[entityQuery[0]] = [];
                            mapOfObjAndFields[entityQuery[0]].push(entityQuery[1]);
                        }
                        
                    });
                });
            }            
        }
        //  alert('mapOfObjAndFields '+JSON.stringify(mapOfObjAndFields));
        let sObj = {'selectedArray' : helper.isConsent_createSelectedValueList(component, event, helper,mapOfObjAndFields),
                    'mapOfObjAndFields' : mapOfObjAndFields};
        
        return sObj;
    },
    isConsent_createSelectedValueList : function(component, event, helper,mapOfObjAndFields) {
        let markupInstance = component.get("v.isConsent_allFields");
        let arr = markupInstance.Account;
        let toReturn = [];
        if(mapOfObjAndFields.hasOwnProperty('Account') && mapOfObjAndFields.hasOwnProperty('User')){
            let selectedvalues = mapOfObjAndFields.Account;
            arr.forEach( function(element) {
                let api = element.value.split('.');
                if(selectedvalues.includes(api[1])){
                    element['selected'] = true;
                    toReturn.push(element.value);
                }
            });
        }
        else if(mapOfObjAndFields.hasOwnProperty('User')){
            let selectedvalues = mapOfObjAndFields.User;
            arr.forEach( function(element) {
                let api = element.value.split('.');
                if(selectedvalues.includes(api[1])){
                    element['selected'] = true;
                    toReturn.push(element.value);
                }
            }); 
        }
            else if(mapOfObjAndFields.hasOwnProperty('Account')){
                let selectedvalues = mapOfObjAndFields.Account;
                arr.forEach( function(element) {
                    let api = element.value.split('.');
                    if(selectedvalues.includes(api[1])){
                        element['selected'] = true;
                        toReturn.push(element.value);
                    }
                });
            }
        // alert('JSON STRINGIFY '+JSON.stringify(toReturn));
        return toReturn;
    },
    table_generateHeading : function(component, event, helper,heading) {
        var toRetArr = [];
        if(heading){
            let arr = heading.split(';');
            let i = 0, len = arr.length;
            while (i < len) {
                //   if(arr[i]){
                toRetArr.push({'heading' :arr[i] });
                //  }
                i++
            }            
        }
        else {
            toRetArr.push({'heading' :''}); 
        }
        return toRetArr;
    },
    defineDeleteButton : function(component, event, helper,fldLst){
        let lastElement_fldLst = fldLst[fldLst.length - 1];
        let lastElement_colLst = lastElement_fldLst.colLst[lastElement_fldLst.colLst.length-1];            
        for(let elm in fldLst){
            let colArr  = fldLst[elm].colLst;
            for(let elm_Child in colArr){
                colArr[elm_Child]['isLast'] = false;
            }           
        }
        if(fldLst.length!=1 && !$A.util.isUndefinedOrNull(lastElement_colLst)){
            lastElement_colLst['isLast'] = true;
        }
    },
    createModularMatrix: function(component, event, helper,allChildsForTable){
        helper.arrangeTableAsMatrix(component, event, helper,allChildsForTable); 
        let matrixArr = allChildsForTable;        
        var fldArr = [];
        let sObj = { 'colLst':[],'RowNumber' : ''};  
        for(let elm in matrixArr){ 
            sObj.colLst.push({'table_heading':'', 'table_fieldSelected':matrixArr[elm].ElixirSuite__Data_Type__c,
                              'ColNumber': matrixArr[elm].ElixirSuite__Column__c,'Id' : matrixArr[elm].Id,
                              'defaultLabel' : matrixArr[elm].ElixirSuite__Field_Label_Long__c,
                             }); 
            sObj.RowNumber = matrixArr[elm].ElixirSuite__Row__c;
        }
        fldArr.push(sObj);
        return fldArr;
    },
    createTableMatrix: function(component, event, helper,allChildsForTable){
        helper.arrangeTableAsMatrix(component, event, helper,allChildsForTable);
        let matrixArr = allChildsForTable;        
        var fldArr = [];
        let rowFlag = 1;
        let sObj = { 'colLst':[],'RowNumber' : ''};  
        for(let elm in matrixArr){ 
            console.log('MATRIX***'+JSON.stringify(matrixArr[elm].ElixirSuite__Row__c)+','+JSON.stringify(matrixArr[elm].ElixirSuite__Column__c));
            let fieldValue = matrixArr[elm].ElixirSuite__Field_Name__c+';'+matrixArr[elm].ElixirSuite__Data_Type__c+';'+
                matrixArr[elm].ElixirSuite__Default_Field_Label__c +';'+matrixArr[elm].ElixirSuite__Object_Name__c;
            console.log('## MatrixfieldValue'+fieldValue);
            if(matrixArr[elm].ElixirSuite__Row__c == rowFlag){
                sObj.colLst.push({'table_heading':'', 'table_fieldSelected':fieldValue,'ColNumber': matrixArr[elm].ElixirSuite__Column__c,
                                  'defaultLabel' : matrixArr[elm].ElixirSuite__Field_Label_Long__c,'Id' : matrixArr[elm].Id
                                 }); 
                sObj.RowNumber = matrixArr[elm].ElixirSuite__Row__c;
            }
            else {
                fldArr.push(sObj);
                sObj = { 'colLst':[],'RowNumber' : ''};               
                rowFlag = matrixArr[elm].ElixirSuite__Row__c;
                sObj.colLst.push({'table_heading':'', 'table_fieldSelected':fieldValue,'ColNumber': matrixArr[elm].ElixirSuite__Column__c,
                                  'defaultLabel' : matrixArr[elm].ElixirSuite__Field_Label_Long__c,'Id' : matrixArr[elm].Id
                                 }); 
                sObj.RowNumber = matrixArr[elm].ElixirSuite__Row__c;
            } 
            
        }  
        fldArr.push(sObj);
        helper.defineDeleteButton(component, event, helper,fldArr);
        return fldArr;
    },
    arrangeTableAsMatrix: function(component, event, helper,allChildsForTable){
        allChildsForTable.sort((a, b)=> {
            if (a.ElixirSuite__Row__c === b.ElixirSuite__Row__c){
            return a.ElixirSuite__Column__c < b.ElixirSuite__Column__c ? -1 : 1
        } else {
                               return a.ElixirSuite__Row__c < b.ElixirSuite__Row__c ? -1 : 1
                               }
                               });
        
    },
    arrangeDataAsParentChild : function(component, event, helper,parentSection,allChilds) {
        
        console.log('parent  '+JSON.stringify(parentSection));
        console.log('child & 567 '+JSON.stringify(allChilds)); 
        
        var mastrJSON = [];
        var idx = 0;        
        if(!$A.util.isEmpty(parentSection)) {   
            component.set("v.formCategory",parentSection[0].ElixirSuite__Form_Category__c);
            for (var parent in parentSection) { 
                var allFieldslst = [];
                if(parentSection[parent].ElixirSuite__Section_Number__c == 1){
                    component.set("v.enableTime",parentSection[parent].ElixirSuite__Is_Time_Enabled__c);
                }
                if(parentSection[parent].ElixirSuite__Form_Specific_Data__c){
                    var allFields = component.get("v.AllFields");
                    var allLookupFields = component.get("v.allLookupApi");
                    console.log('all fields '+JSON.stringify(component.get("v.AllFields")));
                    for(var rec in allFields){
                        var api = allFields[rec].value.split(';');
                        if(allLookupFields.includes(api[0])){allFieldslst.push(allFields[rec]) }
                        
                    }
                }
                else {
                    allFieldslst =  component.get("v.AllFieldsNetInstanceCopy");
                }
                if(!parentSection[parent].hasOwnProperty('ElixirSuite__Default_text__c')){
                    parentSection[parent]['ElixirSuite__Default_text__c'] = '';
                }
                if(!parentSection[parent].hasOwnProperty('ElixirSuite__Raw_Map_Query__c')){
                    parentSection[parent]['ElixirSuite__Raw_Map_Query__c'] = '{}';
                }
                if(!parentSection[parent].hasOwnProperty('ElixirSuite__Auto_text__c')){
                    parentSection[parent]['ElixirSuite__Auto_text__c'] = '';
                }
                if(!parentSection[parent].hasOwnProperty('ElixirSuite__Field_API_AutoText_Array__c')){
                    parentSection[parent]['ElixirSuite__Field_API_AutoText_Array__c'] = '[]';
                }
                if(!parentSection[parent].hasOwnProperty('ElixirSuite__Field_APIs_For_AutoText__c')){
                    parentSection[parent]['ElixirSuite__Field_APIs_For_AutoText__c'] = '';
                }
                if(!parentSection[parent].hasOwnProperty('ElixirSuite__Columns_Selected_For_Table__c')){
                    parentSection[parent]['ElixirSuite__Columns_Selected_For_Table__c'] = '';
                }
                if(!parentSection[parent].hasOwnProperty('ElixirSuite__Headings__c')){
                    parentSection[parent]['ElixirSuite__Headings__c'] = '';
                }
                let isConsentObjFieldsMap = {'selectedArray' : [],
                                             'mapOfObjAndFields' : {}};
                if(parentSection[parent].hasOwnProperty('ElixirSuite__Consent_Fields_Per_Section_Stringified__c')){
                    if(parentSection[parent].ElixirSuite__Consent_Fields_Per_Section_Stringified__c){
                        isConsentObjFieldsMap = helper.createIsConsentFieldsArray(component, event, helper,
                                                                                  JSON.parse(JSON.stringify(parentSection[parent]))); 
                        
                    }
                }
                else {
                    parentSection[parent]['ElixirSuite__Consent_Fields_Per_Section_Stringified__c'] = '';
                }
                
                
                
                
                var lstTypeSelectionOption = [{'label' : 'Field', 'value' : 'Field'},{'label' : 'File Upload', 'value' : 'File Upload'}];
                var typeOfUpload = [{'label' : 'Single', 'value' : 'Single'},{'label' : 'Multiple', 'value' : 'Multiple'}];//added by Monika Singh for File Upload, line 40-41
                let isConsent_ObjLst = [];
              
                
                if(!$A.util.isUndefinedOrNull(parentSection[parent].ElixirSuite__IS_CONSENT_Selected_Object__c) &&
                   parentSection[parent].ElixirSuite__IS_CONSENT_Selected_Object__c!='null'){
                    isConsent_ObjLst = JSON.parse(parentSection[parent].ElixirSuite__IS_CONSENT_Selected_Object__c); 
                }
                else {
                    parentSection[parent]['ElixirSuite__IS_CONSENT_Selected_Object__c'] = '[]';
                    isConsent_ObjLst = JSON.parse(parentSection[parent].ElixirSuite__IS_CONSENT_Selected_Object__c); 
                }
                
                
                let selectedObject = ''; 
                if((isConsent_ObjLst.includes('Account') && isConsent_ObjLst.includes('User')) ||
                   (isConsent_ObjLst.includes('Account'))){
                    selectedObject = 'Account'; 
                }
                else if(isConsent_ObjLst.includes('User')){
                    selectedObject = 'User'; 
                }
                
                var parentJSONSingleInstance = {
                    'parentID' : parentSection[parent].Id,
                    'serialNumber' : parentSection[parent].ElixirSuite__Section_Number__c.toString(),
                    'isConsentForm' : parentSection[parent].ElixirSuite__Is_Consent__c,
                    'defaultFiledLstVisibility' : true,
                    'consentTextValue' :  '',
                    'sectionName':  parentSection[parent].ElixirSuite__Section_Name_As_Rich_Text__c, 
                    'swapSectionVisibility': false,
                    'typeOfColumn':  parentSection[parent].ElixirSuite__Columns_In_Section__c.toString(),
                    'mapQuery' : JSON.parse(parentSection[parent].ElixirSuite__Raw_Map_Query__c),
                    'finalParentQueryForSection_One' : '',
                    'isFormSpecificData' : parentSection[parent].ElixirSuite__Form_Specific_Data__c,
                    'hasextCmp' : parentSection[parent].ElixirSuite__Section_As_Ext_Cmp__c,
                    'abilityForFormSpecificData' : !(parentSection[parent].ElixirSuite__Section_As_Ext_Cmp__c), 
                    'allFields' :  allFieldslst,
                    'wasExistingConsent' : false,
                    'enableAutoText' : parentSection[parent].ElixirSuite__Enable_Auto_text__c,                  
                    'hideSctionsForAutotext' :  parentSection[parent].ElixirSuite__Hide_Selections__c,
                    'autoTextValue' : parentSection[parent].ElixirSuite__Auto_text__c,
                    'allFieldAPIsArray' : JSON.parse(parentSection[parent].ElixirSuite__Field_API_AutoText_Array__c),
                    'allFieldAPIs' : parentSection[parent].ElixirSuite__Field_APIs_For_AutoText__c,  
                    'isMacro' : parentSection[parent].ElixirSuite__isFormMacro__c,
                    'freeTextSOQL' : parentSection[parent].ElixirSuite__Free_Text_SOQL__c,
                    'isConsent_SelectedObject' : selectedObject,
                    'isConsent_allFieldAPIs' :  component.get("v.isConsent_allFields").Account,
                    'isConsent_showFieldApi' : false,
                    'isConsent_showMultiSelectPicklist' : true,
                    'isConsent_selected_allFieldAPIs' :[],
                    'isConsent_lengthOfSelectedValues' : isConsentObjFieldsMap.selectedArray.length.toString(),
                    'isConsent_allFieldAPIStringified' : parentSection[parent].ElixirSuite__Consent_Fields_Per_Section_Stringified__c,
                    'isConsent_SelectedObject_Lst' : JSON.parse(parentSection[parent].ElixirSuite__IS_CONSENT_Selected_Object__c),
                    'isConsent_finalParentQueryForSection_One' : '',
                    'enableTable' : parentSection[parent].ElixirSuite__Is_matrix__c,
                    'enableModularTable' : parentSection[parent].ElixirSuite__Is_matrix__c,
                    'showHeading' : parentSection[parent].ElixirSuite__Show_Heading__c,
                    'addProblem' :parentSection[parent].ElixirSuite__Add_Problem__c,
                    'addProcedure' : parentSection[parent].ElixirSuite__Add_Procedure__c,
                    'enableProblemForNotes' :  parentSection[parent].ElixirSuite__Add_Notes__c,
                    'typeOfNote' :  parentSection[parent].ElixirSuite__Type_of_Note__c,
                    'table_rowDropDown' : ['1', '2','3','4', '5', '6'],   
                    'formComponentVal' : parentSection[parent].ElixirSuite__Select_Form_Component__c,
                  //  'formInventoryVal' : parentSection[parent].ElixirSuite__Default_Inventory_Type__c,
                    'staticFieldLabel' :  parentSection[parent].ElixirSuite__Static_file_name__c,
                    'formInventoryVal' : parentSection[parent].ElixirSuite__Default_Inventory_Type__c,
                    'formCheckbox' : parentSection[parent].ElixirSuite__Lot_Number__c,
                    'FieldsLst': [],
                };
                if(isConsentObjFieldsMap.selectedArray.length>0){
                    parentJSONSingleInstance.isConsent_showFieldApi = true;
                }
                if(parentJSONSingleInstance.isMacro){
                    parentJSONSingleInstance.isConsentForm = false;
                    parentJSONSingleInstance.defaultFiledLstVisibility = false;
                    
                }
                if(parentJSONSingleInstance.enableProblemForNotes){
                    parentJSONSingleInstance.defaultFiledLstVisibility = false;
                }
                //  parentJSONSingleInstance.isConsent_selected_allFieldAPIs = isConsentObjFieldsMap.selectedArray,
                mastrJSON.push(parentJSONSingleInstance);
                if(parentSection[parent].ElixirSuite__Is_Consent__c){
                    mastrJSON[parent].typeOfColumn = '1';
                    mastrJSON[parent].defaultFiledLstVisibility = false;
                    mastrJSON[parent].wasExistingConsent =  true;
                    if(!$A.util.isEmpty(allChilds)){
                        if(allChilds[0].ElixirSuite__Object_1_css__c==parentSection[parent].Id) {
                            mastrJSON[parent].consentTextValue = allChilds[0].ElixirSuite__Default_text__c;
                            mastrJSON[parent].FieldsLst.push({
                                'childID':allChilds[0].Id, 'noLabel' : allChilds[0].ElixirSuite__No_Label__c,
                                'isDefaultLabelActive' : false,'consentTextValue' : allChilds[0].ElixirSuite__Default_text__c,'defaultLabel' : '','selectedField' : '','RowNumber' : 1,'ColNumber': 1,'isMatrixAvailable':false,
                                'displayPicklistAsRadio' : false,'isPicklistAsRadio' : false,'displayMultiPicklistAsCheckbox' : false,'isMultiPicklistAsCheckbox' : false,
                                'isSwitchedToFormula' : false,'fieldsAfterFormula' : false,'switchFormulaEnabled': false,'selectedObjectForFormula': '','switchDecision':false,
                                'lookupApiName' : '','selectedFieldForFormulaMapping': '','fieldListForFormulaMapping':[],'typeOfUpload':typeOfUpload,
                                'typeSelectOption':lstTypeSelectionOption,'typeSelected':'Field','accountLookupFieldLst' : [], 'whereClause' : '', 'accountLookupAPI' : '',
                                'fileUploadButtonDefaultLabel':allChilds[0].ElixirSuite__IMG_Default_Button_Label__c,'fileName': allChilds[0].ElixirSuite__IMG_File_Name__c,
                                'typeOfUploadSelected' : allChilds[0].ElixirSuite__IMG_Type_of_Upload__c,
                                'recordTypeExists' : false, 'ObjectRecordTypes' : [], 'selectedRecordType' :'','isCommon' : false
                            }); 
                        } 
                    }
                    
                }
                else if(parentSection[parent].ElixirSuite__Is_matrix__c || parentSection[parent].ElixirSuite__Select_Form_Component__c == 'Enable Modular Table'){
                    mastrJSON[parent].consentTextValue = '';  
                    parentJSONSingleInstance['table_colSelected'] =  parentSection[parent].ElixirSuite__Columns_Selected_For_Table__c;
                    parentJSONSingleInstance['table_HeadingArr'] =  helper.table_generateHeading(component, event, helper,parentSection[parent].ElixirSuite__Headings__c);                   
                    parentJSONSingleInstance.isConsentForm = false;
                    parentJSONSingleInstance.isMacro = false;
                    parentJSONSingleInstance.defaultFiledLstVisibility = false;
                    parentJSONSingleInstance.sectionNameAbility = false;
                     parentJSONSingleInstance.FieldsLst.push({
                                'childID':'', 'noLabel' : false,
                                'isDefaultLabelActive' : false,'consentTextValue' : '','defaultLabel' : '','selectedField' : '','RowNumber' : 1,'ColNumber': 1,'isMatrixAvailable':false,
                                'displayPicklistAsRadio' : false,'isPicklistAsRadio' : false,'displayMultiPicklistAsCheckbox' : false,'isMultiPicklistAsCheckbox' : false,
                                'isSwitchedToFormula' : false,'fieldsAfterFormula' : false,'switchFormulaEnabled': false,'selectedObjectForFormula': '','switchDecision':false,
                                'lookupApiName' : '','selectedFieldForFormulaMapping': '','fieldListForFormulaMapping':[],'typeOfUpload':typeOfUpload,
                                'typeSelectOption':lstTypeSelectionOption,'typeSelected':'Field','accountLookupFieldLst' : [], 'whereClause' : '', 'accountLookupAPI' : '',
                                'fileUploadButtonDefaultLabel':'','fileName': '',
                                'typeOfUploadSelected' : '',
                                'recordTypeExists' : false, 'ObjectRecordTypes' : [], 'selectedRecordType' :'','isCommon' : false
                            }); 
                    let elmChildArr = [];
                    for(let elm in allChilds) {
                        if(allChilds[elm].ElixirSuite__Object_1_css__c==parentSection[parent].Id) {
                            elmChildArr.push(allChilds[elm]);
                        }
                    }
                    if(!$A.util.isEmpty(elmChildArr)){                      
                        if(parentSection[parent].ElixirSuite__Is_matrix__c){
                            parentJSONSingleInstance['table_fieldLst'] = helper.createTableMatrix(component, event, helper,elmChildArr);  
                            console.log('table field lst val '+JSON.stringify( parentJSONSingleInstance['table_fieldLst']));
                        }
                        if(parentSection[parent].ElixirSuite__Select_Form_Component__c == 'Enable Modular Table'){ 
                            parentJSONSingleInstance['table_fieldLst'] = helper.createModularMatrix(component, event, helper,elmChildArr); 
                        }                       
                    }
                    else{
                        parentJSONSingleInstance['table_fieldLst'] =  [{'colLst':[],'RowNumber':1,'table_heading':''}]; 
                    }
                }
                    else if(parentSection[parent].ElixirSuite__Add_Problem__c || parentSection[parent].ElixirSuite__Add_Procedure__c
                            || parentSection[parent].Add_Notes__c || parentSection[parent].ElixirSuite__Select_Form_Component__c == 'Enable Draw And Annotate' || parentSection[parent].ElixirSuite__Select_Form_Component__c == 'Enable Upload And Annotate'
                            || parentSection[parent].ElixirSuite__Select_Form_Component__c == 'Enable Inventory Order'
                            || parentSection[parent].ElixirSuite__Select_Form_Component__c == 'Enable SOQL'
                            || parentSection[parent].ElixirSuite__Select_Form_Component__c == 'Enable Prescription Order'
                            || parentSection[parent].ElixirSuite__Select_Form_Component__c == 'Enable Lab Order'
                            || parentSection[parent].ElixirSuite__Select_Form_Component__c == 'Enable Diagnoses'
                            || parentSection[parent].ElixirSuite__Select_Form_Component__c == 'Enable Medications List'){
                        mastrJSON[parent].typeOfColumn = '1';
                        mastrJSON[parent].defaultFiledLstVisibility = false;
                    }
                
                        else {
                            mastrJSON[parent].consentTextValue = '';
                            for(var rec in allChilds) {
                                if(allChilds[rec].ElixirSuite__Object_1_css__c==parentSection[parent].Id) {
                                    var matrixVisibilityToken = false;
                                    var radioVisible = false;
                                    var checkBoxVisible = false;
                                    var fieldValue = '';
                                    var label = '';
                                    var verticalAlignForPicklist = false;
                                    var verticalAlignForMultipickList = false;
                                    var displayPicklistAsRadio = false;
                                    var displayMultiPicklistAsCheckbox = false;
                                    if(allChilds[rec].ElixirSuite__Data_Type__c == 'PICKLIST'){
                                        displayPicklistAsRadio = true;
                                    }
                                    else if(allChilds[rec].ElixirSuite__Data_Type__c == 'MULTIPICKLIST'){
                                        displayMultiPicklistAsCheckbox = true;
                                    }
                                    if(parentSection[parent].ElixirSuite__Columns_In_Section__c.toString()=="2"){
                                        matrixVisibilityToken = true;
                                    }
                                    fieldValue = allChilds[rec].ElixirSuite__Field_Name__c+';'+allChilds[rec].ElixirSuite__Data_Type__c+';'+allChilds[rec].ElixirSuite__Default_Field_Label__c +';'+allChilds[rec].ElixirSuite__Object_Name__c;
                                    console.log('## fieldValue'+fieldValue);
                                    var fieldValue1;
                                   if(allChilds[rec].ElixirSuite__Field_Name__c == undefined){
                                        fieldValue1='';
                                        fieldValue=fieldValue1;
                                         console.log('fieldValue2'+fieldValue);
                                    }
                                    else{
                                        fieldValue1 = fieldValue;
                                        fieldValue=fieldValue1;
                                         console.log('fieldValue22else'+fieldValue);
                                    }
                                    if(allChilds[rec].ElixirSuite__Default_Label_Filled__c){
                                        label = allChilds[rec].ElixirSuite__Field_Label_Long__c;
                                        
                                    }
                                    if(!allChilds[rec].hasOwnProperty('ElixirSuite__Class__c')){
                                        allChilds[rec]['ElixirSuite__Class__c'] = '';
                                        
                                    }
                                    else {
                                        if(allChilds[rec].ElixirSuite__Class__c == 'MultiVertical' && allChilds[rec].ElixirSuite__Form_Data_Type__c== 'Radio'){
                                            verticalAlignForPicklist = true;
                                        }
                                        else if(allChilds[rec].ElixirSuite__Class__c == 'MultiVertical' && allChilds[rec].ElixirSuite__Form_Data_Type__c== 'Checkbox'){
                                            verticalAlignForMultipickList = true;
                                        }
                                        
                                    }
                                    
                                    if(allChilds[rec].ElixirSuite__Form_Data_Type__c == "Radio"){
                                        radioVisible = true;
                                    }
                                    else if(allChilds[rec].ElixirSuite__Form_Data_Type__c == 'Checkbox'){
                                        checkBoxVisible = true;
                                    }
                                    if(allChilds[rec].ElixirSuite__Formula_Map_Enabled__c == false){
                                        allChilds[rec]['ElixirSuite__Object_lookup_Api__c'] = '';
                                        allChilds[rec]['ElixirSuite__Map_field__c'] = '';
                                        allChilds[rec]['ElixirSuite__Object_Fields__c'] = '[]';
                                        allChilds[rec]['ElixirSuite__Account_Lookup_Fields__c'] = '[]';
                                    }
                                    if(!allChilds[rec].hasOwnProperty('ElixirSuite__Account_Lookup_Fields__c')){
                                        allChilds[rec]['ElixirSuite__Account_Lookup_Fields__c'] = '[]';
                                    }
                                    if(allChilds[rec].ElixirSuite__Is_RecordType_Selected__c == false){
                                        allChilds[rec]['ElixirSuite__Object_Record_Types__c'] = '[]';                                   
                                    }
                                    //('existing value '+allChilds[rec].ElixirSuite__Auto_Populate__c + '---- '+allChilds[rec].ElixirSuite__Is_Common_Engaged__c);
                                    var childIndividualInstance = {'childID':allChilds[rec].Id,'isDefaultLabelActive' : allChilds[rec].ElixirSuite__Default_Label_Filled__c,'defaultLabel' : label,'selectedField' :fieldValue ,
                                                                   'RowNumber' : allChilds[rec].ElixirSuite__Row__c.toString(),'ColNumber': allChilds[rec].ElixirSuite__Column__c.toString(),
                                                                   'isMatrixAvailable':matrixVisibilityToken,'verticalAlignForRadio' : verticalAlignForPicklist,'verticalAlignForMultiPicklist' : verticalAlignForMultipickList,
                                                                   'displayPicklistAsRadio' : displayPicklistAsRadio,'isPicklistAsRadio' : radioVisible,
                                                                   'displayMultiPicklistAsCheckbox' : displayMultiPicklistAsCheckbox,'isMultiPicklistAsCheckbox' : checkBoxVisible,
                                                                   'isSwitchedToFormula' : allChilds[rec].ElixirSuite__Formula_Map_Enabled__c,'fieldsAfterFormula' : allChilds[rec].ElixirSuite__Formula_Map_Enabled__c,'consentTextValue' : '',
                                                                   'switchFormulaEnabled': allChilds[rec].ElixirSuite__Formula_Map_Enabled__c,'selectedObjectForFormula':  allChilds[rec].ElixirSuite__Object_lookup_Api__c+';'+allChilds[rec].ElixirSuite__Map_object__c,'switchDecision': true,
                                                                   'lookupApiName' : allChilds[rec].ElixirSuite__Object_lookup_Api__c,'selectedFieldForFormulaMapping': allChilds[rec].ElixirSuite__Map_field__c,'fieldListForFormulaMapping': JSON.parse(allChilds[rec].ElixirSuite__Object_Fields__c),
                                                                   'recordTypeExists' : allChilds[rec].ElixirSuite__Is_RecordType_Selected__c, 'ObjectRecordTypes' : JSON.parse(allChilds[rec].ElixirSuite__Object_Record_Types__c), 'selectedRecordType' : allChilds[rec].ElixirSuite__Form_Data_Type__c,
                                                                   'isCommon' : allChilds[rec].ElixirSuite__Is_Common_Engaged__c,'autoPopulate' : allChilds[rec].ElixirSuite__Auto_Populate__c,'typeOfUpload':typeOfUpload,
                                                                   'typeSelectOption':lstTypeSelectionOption,'typeSelected':allChilds[rec].ElixirSuite__IMG_Type_of_Row__c,'accountLookupFieldLst' : JSON.parse(allChilds[rec].ElixirSuite__Account_Lookup_Fields__c), 'whereClause' :  allChilds[rec].ElixirSuite__WHERE_clause_per_field__c, 'accountLookupAPI' :  allChilds[rec].ElixirSuite__Account_Lookup_API__c,
                                                                   'fileUploadButtonDefaultLabel':allChilds[rec].ElixirSuite__IMG_Default_Button_Label__c,'fileName': allChilds[rec].ElixirSuite__IMG_File_Name__c,
                                                                   'typeOfUploadSelected' : allChilds[rec].ElixirSuite__IMG_Type_of_Upload__c,'noLabel' : allChilds[rec].ElixirSuite__No_Label__c,'showAutoPopulation' : false};
                                    mastrJSON[idx].FieldsLst.push(childIndividualInstance);
                                }
                            }  
                        }
                idx++;
                
            }
        }
        console.log('final 9000 '+JSON.stringify(mastrJSON));
        return mastrJSON;
    },
    doSort : function(array) {
        array.sort(function(a , b){
            var nameSpace = ''
            const bandA = a[nameSpace + 'serialNumber'];
            const bandB = b[nameSpace + 'serialNumber'];
            
            let comparison = 0;
            if (bandA > bandB) {
                comparison = 1;
            } else if (bandA < bandB) {
                comparison = -1;
            }
            return comparison;
        });
    },
    defaultColumnsSet : function(component) {
        var columnSet = [{'label' : '1 Column', 'value' : '1'},{'label' : '2 Column', 'value' : '2'}];
        component.set("v.selectedStatus",'1');
        component.set("v.columnTypes",columnSet);
        component.set("v.columnDefault","1 Column");
        component.set("v.sectionLstLength","[{'1'},{'2'}]");
        component.set("v.swapAbility",true);
        component.set("v.isConsent_allFields",{'Account' : [],'User' : []});
        component.set("v.ConsentObjArray",[{'label':'Account','value':'Account'},{'label':'User','value':'User'}]);
        var mapOfObjectAndcustomLabel = {'ElixirSuite__Dataset1__c' : 'Problem',
                                         'ElixirSuite__Prescription_Order__c' : 'Medication_List'};
        component.set("v.mapOfObject",mapOfObjectAndcustomLabel);
    },
    createObjectData: function(component) {        
        let lstTypeSelectionOption = [{'label' : 'Field', 'value' : 'Field'},{'label' : 'File Upload', 'value' : 'File Upload'}];
        let typeOfUpload = [{'label' : 'Single', 'value' : 'Single'},{'label' : 'Multiple', 'value' : 'Multiple'}]
        var RowItemList = component.get("v.sectionData");
        var check = component.get("v.myBool");
        var inventoryVal = component.get("v.invValue");
        RowItemList.push({
            'serialNumber' : '',
            'isConsentForm' : false,
            'defaultFiledLstVisibility' : true,
            'consentTextValue' : '',
            'sectionName': '',
            'swapSectionVisibility': false,
            'typeOfColumn': '1',
            'mapQuery' : {},
            'finalParentQueryForSection_One' : '',
            'mapQueryStringified' : '',
            'isFormSpecificData' : false,
            'hasextCmp' : false,
            'isMacro' : false,
            'abilityForFormSpecificData' : false,
            'wasExistingConsent' : false,
            'allFields' :  component.get("v.AllFieldsNetInstanceCopy"),
            'enableAutoText' : false,
            'hideSctionsForAutotext' : false,
            'autoTextValue' : '',
            'allFieldAPIsArray' : [],
            'allFieldAPIs' : '',            
            'isConsent_SelectedObject' : '',
            'isConsent_allFieldAPIs' :  component.get("v.isConsent_allFields_Copy").Account,
            'isConsent_showFieldApi' : false,
            'isConsent_showMultiSelectPicklist' : true,
            'isConsent_selected_allFieldAPIs' : [],          
            'isConsent_lengthOfSelectedValues' : '',
            'isConsent_allFieldAPIStringified' : '',
            'isConsent_SelectedObject_Lst' : [],
            'isConsent_finalParentQueryForSection_One' : '',
            'enableTable' : false,
            'showHeading' : false,
            'table_rowDropDown' : ['1', '2','3','4','5','6'],
            'table_colSelected' : '',
            'table_HeadingArr' : [{'heading' : ''}],
            'table_fieldLst' : [{'colLst':[{'table_heading':'', 'table_fieldSelected':'','ColNumber': 1,'defaultLabel' : ''}],'RowNumber':1}],
            'addProblem' :false,
            'addProcedure' : false,
            'enableProblemForNotes' : false,
            'typeOfNote' : '',
            'formComponentVal' : '',
            'formInventoryVal' : inventoryVal,
            'formCheckbox' : check,
            'staticFieldLabel' : '',
            'freeTextSOQL' : '',
            'FieldsLst': [{'isDefaultLabelActive' : false,'defaultLabel' : '','consentTextValue':'','selectedField' : '','RowNumber' : 1,'ColNumber': 1,'isMatrixAvailable':false,
                           'displayPicklistAsRadio' : false,'isPicklistAsRadio' : false,'verticalAlignForRadio' : false,'verticalAlignForMultiPicklist' : false,
                           'displayMultiPicklistAsCheckbox' : false,'isMultiPicklistAsCheckbox' : false,'switchDecision':false,
                           'isSwitchedToFormula' : false,'fieldsAfterFormula' : false,'switchFormulaEnabled': false,'accountLookupFieldLst' : [], 'whereClause' : '', 'accountLookupAPI' : '',
                           'selectedObjectForFormula': '',  'lookupApiName' : '','selectedFieldForFormulaMapping': '','fieldListForFormulaMapping':[],
                           'recordTypeExists' : false, 'ObjectRecordTypes' : [], 'selectedRecordType' : '','isCommon' : false,'autoPopulate' : false,
                           'typeSelected':'Field','fileUploadButtonDefaultLabel':'','fileName':'','typeOfUploadSelected':'Single',
                           'typeSelectOption':lstTypeSelectionOption,'typeOfUpload':typeOfUpload,'noLabel' : false,
                          }],
        });     
        var lstLength = RowItemList.length;
        if(!component.get("v.isSwapUsed")){
            component.set("v.sectionLength",JSON.parse(JSON.stringify(lstLength))); 
            var count = 0;
            for(var i=1;i<=lstLength;i++){
                RowItemList[count].serialNumber = i.toString();
                count++;
            } 
        }
        else {
            component.set("v.sectionLength",JSON.parse(JSON.stringify(lstLength))); 
            RowItemList[RowItemList.length - 1].serialNumber = RowItemList.length;
        }
        
        component.set("v.sectionData", RowItemList);
    },
    createObjectDataForFiledlst : function(component, event,index,isMatrix,typeOfColumn) {
        let lstTypeSelectionOption = [{'label' : 'Field', 'value' : 'Field'},{'label' : 'File Upload', 'value' : 'File Upload'}];
        let typeOfUpload = [{'label' : 'Single', 'value' : 'Single'},{'label' : 'Multiple', 'value' : 'Multiple'}]
        var RowItemList = component.get("v.sectionData");
        var filedArray = RowItemList[index].FieldsLst;
        var stateCounterone = 1;
        var stateCountertwo = 1;
        
        filedArray.push({
            
            'consentTextValue': '','isDefaultLabelActive' : false,'defaultLabel' : '','selectedField' : '','RowNumber' : '','ColNumber': '','isMatrixAvailable':isMatrix,
            'displayPicklistAsRadio' : false,'isPicklistAsRadio' : false,'displayMultiPicklistAsCheckbox' : false,'isMultiPicklistAsCheckbox' : false,
            'verticalAlignForRadio' : false,'verticalAlignForMultiPicklist' : false,
            'isSwitchedToFormula' : false,'fieldsAfterFormula' : false,'switchFormulaEnabled': false,'selectedObjectForFormula': '','switchDecision':false,
            'lookupApiName' : '','selectedFieldForFormulaMapping': '','fieldListForFormulaMapping':[],'accountLookupFieldLst' : [], 'whereClause' : '', 'accountLookupAPI' : '',
            'recordTypeExists' : false, 'ObjectRecordTypes' : [],'selectedRecordType' : '','isCommon' : false,'autoPopulate' : false,
            'typeSelected':'Field','fileUploadButtonDefaultLabel':'','fileName':'','typeOfUploadSelected':'Single',
            'typeSelectOption':lstTypeSelectionOption,'typeOfUpload':typeOfUpload,'noLabel' : false,'showAutoPopulation' : false
        });
        if(typeOfColumn == "2"){
            for (var i = 0; i < filedArray.length; i++) { 
                if(i % 2 == 0) {
                    filedArray[i].RowNumber = stateCounterone;
                    filedArray[i].ColNumber = stateCountertwo;
                    stateCountertwo++;
                }
                else {
                    filedArray[i].RowNumber = stateCounterone;
                    filedArray[i].ColNumber = stateCountertwo; 
                    stateCounterone++;
                    stateCountertwo = 1;
                }
            } 
        }
        else {
            for (let i = 0; i < filedArray.length; i++) { 
                filedArray[i].RowNumber = stateCounterone;              
                stateCounterone++;
            }
            
        }
        
        //  RowItemList[index].FieldsLst = filedArray;
        component.set("v.sectionData", RowItemList);
    }, 
    
    
    createSectionJSON: function(component, event,labelApiList) {
        let markupInstance = component.get("v.isConsent_allFields");
        let response = markupInstance.Account;
        let labelApiArr = [];
        for(var rec in response){
            labelApiArr.push({'value': 'Account.'+rec, 'label': response[rec]}); 
        }
        component.set("v.isConsent_AccountFields",JSON.parse(JSON.stringify(labelApiArr)));
        let lstTypeSelectionOption = [{'label' : 'Field', 'value' : 'Field'},{'label' : 'File Upload', 'value' : 'File Upload'}];
        let typeOfUpload = [{'label' : 'Single', 'value' : 'Single'},{'label' : 'Multiple', 'value' : 'Multiple'}]
        var RowItemList = component.get("v.sectionData");
        var check = component.get("v.myBool");
        var inventoryVal = component.get("v.invValue");
        RowItemList.push({
            'serialNumber' : '',
            'isConsentForm' : false,
            'defaultFiledLstVisibility' : true,
            'consentTextValue' : '',
            'sectionName': '',
            'swapSectionVisibility': false,
            'typeOfColumn': '',
            'mapQuery' : {},
            'finalParentQueryForSection_One' : '',
            'mapQueryStringified' : '',
            'isMacro' : false,
            'allFields' : labelApiList,
            'isFormSpecificData' : false,
            'hasextCmp' : false,
            'abilityForFormSpecificData' : false,
            'enableAutoText' : false,
            'hideSctionsForAutotext' : false,
            'autoTextValue' : '',
            'allFieldAPIsArray' : [],
            'allFieldAPIs' : '',
            'isConsent_SelectedObject' : '',
            'isConsent_allFieldAPIs' : labelApiArr,
            'isConsent_showFieldApi' : false,
            'isConsent_showMultiSelectPicklist' : true,
            'isConsent_selected_allFieldAPIs' : [],
            'isConsent_lengthOfSelectedValues' : '',
            'isConsent_allFieldAPIStringified' : '',
            'isConsent_SelectedObject_Lst' : [],           
            'isConsent_finalParentQueryForSection_One' : '',
            'enableTable' : false,
            'showHeading' : false,
            'table_rowDropDown' : ['1', '2','3','4','5','6'],
            'table_colSelected' : '',
            'table_HeadingArr' : [{'heading' : ''}],
            'addProblem' :false,
            'addProcedure' : false,
            'enableProblemForNotes' : false,
            'typeOfNote' : '',
            'formComponentVal' : '',
            'formInventoryVal' : inventoryVal,
            'formCheckbox' : check,
            'staticFieldLabel' : '',
            'freeTextSOQL' : '',
            'table_fieldLst' : [{'colLst':[{'table_heading':'', 'table_fieldSelected':'','ColNumber': 1,'defaultLabel' : ''}],'RowNumber':1}],
            'FieldsLst': [{'isDefaultLabelActive' : false,'defaultLabel' : '','selectedField' : '','RowNumber' : 1,'ColNumber': '','isMatrixAvailable':false,
                           'displayPicklistAsRadio' : false,'isPicklistAsRadio' : false,'verticalAlignForRadio' : false,'verticalAlignForMultiPicklist' : false,
                           'displayMultiPicklistAsCheckbox' : false,'isMultiPicklistAsCheckbox' : false,
                           'isSwitchedToFormula' : false,'fieldsAfterFormula' : false,'switchFormulaEnabled': false,'switchDecision':false,
                           'selectedObjectForFormula': '',  'lookupApiName' : '','selectedFieldForFormulaMapping': '','fieldListForFormulaMapping':[],
                           'recordTypeExists' : false, 'ObjectRecordTypes' : [],'selectedRecordType' : '','consentTextValue' : '','isCommon' : false,'autoPopulate' : false,
                           'typeSelected':'Field','fileUploadButtonDefaultLabel':'','fileName':'','typeOfUploadSelected':'Single','accountLookupFieldLst' : [], 'whereClause' : '', 'accountLookupAPI' : '',
                           'typeSelectOption':lstTypeSelectionOption,'typeOfUpload':typeOfUpload,'noLabel' : false, 'showAutoPopulation' : false}],
        });
        var lstLength = RowItemList.length;
        component.set("v.sectionLength",JSON.parse(JSON.stringify(lstLength))); 
        var count = 0;
        for(var i=1;i<=lstLength;i++){
            RowItemList[count].serialNumber = i.toString();
            count++;
        }
        component.set("v.sectionData",RowItemList);
    },
    utilityArrange : function(component, event,helper,index,filedArray) {
        var RowItemList = component.get("v.sectionData");
        var filedArray = RowItemList[index].FieldsLst;
        var stateCounterone = 1;
        var stateCountertwo = 1;
        for (var i = 0; i < filedArray.length; i++) { 
            if(i % 2 == 0) {
                filedArray[i].RowNumber = stateCounterone;
                filedArray[i].ColNumber = stateCountertwo;
                stateCountertwo++;
            }
            else {
                filedArray[i].RowNumber = stateCounterone;
                filedArray[i].ColNumber = stateCountertwo; 
                stateCounterone++;
                stateCountertwo = 1;
            }
        } 
    },
    checkHeaderEmpty : function(component) {
        var isEmpty = false;
        if($A.util.isUndefinedOrNull(component.get("v.formNameReflectedAsRecordType"))){
            isEmpty = true;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Failed!",
                "message": "Please select the form.",
                "type" : "warning"
            });
            toastEvent.fire();
        }
        return isEmpty;
    },
    configureObjectMatchingWindow : function(component, event,helper,dupObjarrange,allObjectApiLabelMap) {
        var dataArray = [];
        for(var rec in dupObjarrange){
            var apiName =  allObjectApiLabelMap[dupObjarrange[rec]];
            var label = dupObjarrange[rec];
            var labelApi = label + ' (' + apiName + ')';
            dataArray.push(labelApi);
        }
        component.set("v.allMatchingObjects",dataArray);
    },
    filterNewSectionRecordsToInsert : function(component, event,helper,chunk) {
        var arr = [];
        var childArr = [];
        var sectionData = JSON.parse(JSON.stringify(chunk));
        for(var rec in sectionData){
            if(!sectionData[rec].hasOwnProperty('parentID')){
                arr.push(sectionData[rec]);
            }
            
            
            
        }
        var toReturn = {'parentRecords' : arr,
                        'childRecords' : childArr};
        console.log('to return '+toReturn);
        return toReturn;
    },
    filterlookupFields : function(component, event, helper,parentJSON) {
        var allFields = component.get("v.AllFields");
        var allLookupFields = component.get("v.allLookupApi");
        var newCommonArray = [];
        for(var rec in allFields){
            var api = allFields[rec].value.split(';');
            if(allLookupFields.includes(api[0])){ newCommonArray.push(allFields[rec]) }
            
        }
        parentJSON.allFields = newCommonArray;
    },
    createListOfLookupApi : function(component) {
        var lstLkupApi = component.get("v.essentialLookupFields");
        var arrApi = [];
        for(var rec in lstLkupApi){
            if(lstLkupApi[rec].ElixirSuite__Lookup_Api__c.includes(';')){
                arrApi = lstLkupApi[rec].ElixirSuite__Lookup_Api__c.split(';');
            }
            else {
                arrApi.push(lstLkupApi[rec].ElixirSuite__Lookup_Api__c);
            }
        }
        component.set("v.allLookupApi",arrApi);
    },
    controlFormSpicificDataAbility : function(component, event,helper,selectedValue) {
        var includesApi = false;
        var allLookupFields = component.get("v.allLookupApi");
        if(allLookupFields.includes(selectedValue)){ includesApi = true }
        return includesApi;
    },
    fetchRecordTypesIfExists : function(component, event,helper,objectNameReceived,fieldList,
                                        upperSectionIndex,lowerFieldIndex,result) {
        var action = component.get("c.fetchobjectRecordTypes");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({
            objectName: objectNameReceived
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var res = response.getReturnValue();
                var parent = component.get("v.sectionData");
                if(!$A.util.isEmpty(res)){
                    
                    console.log('lokkup record types  '+JSON.stringify(res));
                    var recordTypesArr = [];
                    var toiterate =  res;
                    
                    for(var rec in toiterate){
                        recordTypesArr.push({'label': toiterate[rec], 'value': toiterate[rec]});
                    }
                    
                    
                    parent[upperSectionIndex].FieldsLst[lowerFieldIndex].recordTypeExists = true;
                    parent[upperSectionIndex].FieldsLst[lowerFieldIndex].ObjectRecordTypes = recordTypesArr;
                    component.set("v.sectionData",parent);
                }
                else {
                    var resArr = result.split(';');
                    var mapOfObject = component.get("v.mapOfObject");
                    parent[upperSectionIndex].FieldsLst[lowerFieldIndex].selectedRecordType =  mapOfObject[resArr[0]];                  
                    component.set("v.sectionData",parent);
                }
            }
            
        });
        
        $A.enqueueAction(action);
        return true;
    },
    globalFlagToast : function(component, event, helper,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":  message,
            "type" :type
        });
        toastEvent.fire();
    },      
    enableFreeTextSOQL : function(component, event, helper,index) { 
            
        var sectionLst = component.get("v.sectionData");
        sectionLst[index].isConsentForm = false;
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
        component.set("v.sectionData",sectionLst); 
    },
    removeDuplicateFields : function(component, event,helper,isConsent_mapOfObjFields) {
        Object.entries(isConsent_mapOfObjFields).map(entry => {
            let key = entry[0];
            if(key!='undefined'){
            let uniqueChars = [...new Set(isConsent_mapOfObjFields[key])];
            isConsent_mapOfObjFields[key] = uniqueChars;
            
        }               
                                                     });
    },
    buildQuery : function(component, event,helper) {
        var parentJSON = component.get("v.sectionData");
        var allSObjectQueryForParent = [];
        let isConsent_mapOfObjFields = {};
        for(let rec in parentJSON){
            let queryArray =  parentJSON[rec].mapQuery;
            if(!$A.util.isUndefinedOrNull(queryArray)){
                helper.removeDuplicateFields(component, event,helper,parentJSON[rec].mapQuery); 
                allSObjectQueryForParent.push(JSON.parse(JSON.stringify(parentJSON[rec].mapQuery)));    
                let finalQuerybuild= [];
                for(let element in queryArray){ 
                    var queryString = 'SELECT ';
                    let fieldsArray = queryArray[element];
                    if(!$A.util.isEmpty(fieldsArray)){
                        queryString+=fieldsArray.join(',');
                        queryString+=' FROM ';
                        let sObjAndLookupField = element.split(';');
                        queryString+=sObjAndLookupField[1]+'&'+sObjAndLookupField[0];
                        finalQuerybuild.push(queryString);
                    }
                }
                if(finalQuerybuild.length == 1){
                    let addSemicolon =  finalQuerybuild.toString();
                    parentJSON[rec].mapQueryStringified = addSemicolon + ';';
                    console.log('query string '+addSemicolon);
                }
                else {
                    parentJSON[rec].mapQueryStringified =  finalQuerybuild.join(';');
                    if(finalQuerybuild.join(';') == ''){
                        parentJSON[rec].mapQuery = {};
                    }
                    console.log('query string '+finalQuerybuild.join(';'));
                }
                console.log('obj '+parentJSON[rec].isConsent_allFieldAPIStringified);
                console.log('selected obj  '+parentJSON[rec].isConsent_SelectedObject);
                /**** ALSO BUILDING QUERY FOR IS CONSENT SECTION*******CAN BE MOVED TO ANOTHER HELPER***/
                let isConsent_fields = parentJSON[rec].isConsent_allFieldAPIStringified.split('\n');
                if(!$A.util.isUndefinedOrNull(isConsent_fields)){
                    isConsent_fields.forEach( function(element) {
                        let sObj = element.split('.');
                        if(sObj.length>=2){
                            if(isConsent_mapOfObjFields.hasOwnProperty(sObj[0])){
                                isConsent_mapOfObjFields[sObj[0]].push(sObj[1]);
                            }
                            else {
                                isConsent_mapOfObjFields[sObj[0]] = [];
                                isConsent_mapOfObjFields[sObj[0]].push(sObj[1]);
                            }
                        }
                    });
                }
            }
            /*******************************/ 
        }
        console.log('query string parent'+JSON.stringify(allSObjectQueryForParent));
        console.log('query isConsent_mapOfObjFields'+JSON.stringify(isConsent_mapOfObjFields));
        let isConsent_queryString = '';         
        try{
            helper.removeDuplicateFields(component, event,helper,isConsent_mapOfObjFields); 
            Object.entries(isConsent_mapOfObjFields).map(entry => {
                let key = entry[0];
                if(key!='undefined'){
                let isConsent_prefixSOQL = key+':';
                isConsent_prefixSOQL += 'SELECT ';
                isConsent_prefixSOQL+=isConsent_mapOfObjFields[key].join(',');
                isConsent_prefixSOQL+=' FROM '+key+';';
                isConsent_queryString+=isConsent_prefixSOQL;
            }               
                                                         });
            console.log('isConsent_queryString '+JSON.stringify(isConsent_queryString));
        }
        catch(e){
            alert('error '+e);
        }
        
        var obj = Object.fromEntries(helper.buildParentQuery(component, event,helper,allSObjectQueryForParent));
        if(parentJSON.length>0){
            for(let recordElement in parentJSON){
                if(parentJSON[recordElement].serialNumber == "1"){
                    parentJSON[recordElement].finalParentQueryForSection_One = helper.convertObjectToQuery(component, event,helper,obj); 
                    parentJSON[recordElement].isConsent_finalParentQueryForSection_One =  isConsent_queryString;
                }
            }
            
        }
        component.set("v.sectionData",parentJSON);
    },
    buildParentQuery : function(component, event,helper,allSObjectQueryForParent) {
        var mapOfsObjAndFields = new Map();
        for(let rec in allSObjectQueryForParent){
            let childsObj = allSObjectQueryForParent[rec];
            for(let childRec in childsObj){
                if(mapOfsObjAndFields.has(childRec)){
                    if(Array.isArray(childsObj[childRec])){
                        let sObjInstanceArr = mapOfsObjAndFields.get(childRec).concat(childsObj[childRec]);
                        mapOfsObjAndFields.set(childRec,[...new Set(sObjInstanceArr)]); 
                    }
                    else {
                        if(!mapOfsObjAndFields.get(childRec).includes(childsObj[childRec])){
                            mapOfsObjAndFields.get(childRec).push(childsObj[childRec]);
                        }
                    }
                }
                else {
                    mapOfsObjAndFields.set(childRec, [...new Set(childsObj[childRec])]);
                }  
            }
            
        }
        
        
        console.log('parent build '+mapOfsObjAndFields);  
        return mapOfsObjAndFields;
        
    },
    convertObjectToQuery : function(component, event,helper,queryArray){
        var finalQuerybuild= [];
        for(let element in queryArray){  
            var queryString = 'SELECT ';
            let fieldsArray = queryArray[element];
            if(!$A.util.isEmpty(fieldsArray)){
                queryString+=fieldsArray.join(',');
                queryString+=' FROM ';
                let sObjAndLookupField = element.split(';'); 
                queryString+=sObjAndLookupField[1]+'&'+sObjAndLookupField[0];
                finalQuerybuild.push(queryString);                    
            }
        }
        console.log('obj finalQuerybuild'+finalQuerybuild.join(';'));
        return finalQuerybuild.join(';');
    },
    removeHTMLTagsIfAny : function(component, event,helper,allApiArray) {
        for(let rec in allApiArray){
            // if(allApiArray[rec].startsWith('<')){
            allApiArray[rec] = helper.stringHTMLFilter(component, event,helper,allApiArray[rec]);
            //  }
        }
        return allApiArray; 
    },
    stringHTMLFilter : function(component, event,helper,html) {
        var regex = /(<([^>]+)>)/ig
        ,   body = html
        ,   result = body.replace(regex, "");
        return result;
        
    },
    checkEmptyString : function(component, event,helper,my_arr) {
        var isAllInstaceEmpty = true; 
        for(var i=0;i<my_arr.length;i++){
            if(my_arr[i] != "") {  
                isAllInstaceEmpty = false;
                break;
            }
        }
        return isAllInstaceEmpty;
    },
    setAllApiFieldsForAutotext : function(component, event,helper,fieldsArray,parentRecord) {
        var arr = [];
        for(let rec in fieldsArray){
            arr.push(fieldsArray[rec].selectedField.split(';')[0]);
        }
        parentRecord.allFieldAPIsArray = JSON.parse(JSON.stringify(arr));
        parentRecord.allFieldAPIs = arr.join(';');
        
    },
    removeApiFieldsForAutoText :  function(component, event,helper,deletedField,parentRecord) {
        var apiArray =  JSON.parse(JSON.stringify(parentRecord.allFieldAPIsArray));
        const index = apiArray.indexOf(deletedField.split(';')[0]);
        if (index > -1) {
            apiArray.splice(index, 1);
        }
        parentRecord.allFieldAPIsArray = JSON.parse(JSON.stringify(apiArray));
        parentRecord.allFieldAPIs = apiArray.join(';');
        
    },
    checkFieldsValidity : function(component, event,helper,mapOfAllApi,lowerCasedFieldApiArray) {
        if(!$A.util.isEmpty(lowerCasedFieldApiArray)){
            var dirtyFieldName = '';
            for(let rec in lowerCasedFieldApiArray){
                if(!mapOfAllApi.includes(lowerCasedFieldApiArray[rec])){
                    dirtyFieldName = lowerCasedFieldApiArray[rec]
                    break;
                }
            }
            
            if(dirtyFieldName){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "BAD FIELD",
                    "message": dirtyFieldName +" IS NOT A VALID FIELD",
                    "type" : "warning"
                });
                toastEvent.fire();
            }
            else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ALL FIELDS ARE VALID!",
                    "message": "ALL FIELDS ARE VALID!",
                    "type" : "success"
                });
                toastEvent.fire();
            }
        }
    },
    getAllselectedObjFields : function(component, event,helper,parentSectionData,upperSectionIndex,entityName) {
        var action = component.get("c.falseCallBack");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                parentSectionData[upperSectionIndex].isConsent_showMultiSelectPicklist = false;
                parentSectionData[upperSectionIndex].isConsent_selected_allFieldAPIs = [];
                component.set("v.sectionData",parentSectionData);
                let consentFields = parentSectionData[upperSectionIndex].isConsent_allFieldAPIStringified;
                let markupInstance = component.get("v.isConsent_allFields");
                let count = 0;
                if(consentFields){
                    let mapOfObjAndFields = helper.createEntityArray(component, event,helper,consentFields);  
                    if(mapOfObjAndFields.hasOwnProperty(entityName)){             
                        let arr = markupInstance[entityName];
                        let selectedvalues = mapOfObjAndFields[entityName];
                        
                        arr.forEach( function(element) {
                            let api = element.value.split('.');
                            if(selectedvalues.includes(api[1])){
                                element['selected'] = true;
                                count++;
                            }
                        });  
                    }
                }
                if(count>=1){
                    parentSectionData[upperSectionIndex].isConsent_showFieldApi = true; 
                }
                else {
                    parentSectionData[upperSectionIndex].isConsent_showFieldApi = false; 
                }
                parentSectionData[upperSectionIndex].isConsent_lengthOfSelectedValues = count.toString();
                parentSectionData[upperSectionIndex].isConsent_allFieldAPIs = markupInstance[entityName];
                parentSectionData[upperSectionIndex].isConsent_showMultiSelectPicklist = true;
                component.set("v.sectionData",parentSectionData);  
                
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
    createEntityArray :function(component, event, helper,consentFields_Stringified) {
        let stringQuery = consentFields_Stringified;
        let mapOfObjAndFields = {};
        if(!$A.util.isUndefinedOrNull(stringQuery)){
            if(stringQuery){
                let arr = stringQuery.split('\n');
                arr.forEach( function(element) {
                    let entityQuery = element.split('.');
                    entityQuery.forEach( function() {
                        if(mapOfObjAndFields.hasOwnProperty(entityQuery[0])){
                            mapOfObjAndFields[entityQuery[0]].push(entityQuery[1]);
                        }
                        else {
                            mapOfObjAndFields[entityQuery[0]] = [];
                            mapOfObjAndFields[entityQuery[0]].push(entityQuery[1]);
                        }
                        
                    });
                });
            }            
        }              
        return mapOfObjAndFields;
    },
    utilitySerialNumberArrange : function(component){
        var RowItemList = component.get("v.sectionData");
        var lstLength = RowItemList.length;
        if(!component.get("v.isSwapUsed")){
            component.set("v.sectionLength",JSON.parse(JSON.stringify(lstLength))); 
            var count = 0;
            for(var i=1;i<=lstLength;i++){
                RowItemList[count].serialNumber = i.toString();
                count++;
            } 
        }
        else {
            component.set("v.sectionLength",JSON.parse(JSON.stringify(lstLength))); 
            RowItemList[RowItemList.length - 1].serialNumber = RowItemList.length;
        }
        
        component.set("v.sectionData", RowItemList);
    },
    flagNoResult : function() {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "No field selected",
            "message":  "Please select a field!",
            "type" : "error"
        });
        toastEvent.fire();
    },
    returnFieldSObjInstance : function() {
        return {'table_heading':'', 'table_fieldSelected':';;;;','ColNumber': 1,'defaultLabel' : ''};      
    },
    arrangeHeadingCol : function(component, event,helper,parentSectionData,upperSectionIndex,result) {      
        if(parseInt(result)>parentSectionData[upperSectionIndex].table_HeadingArr.length){
            let len = JSON.parse(JSON.stringify((parseInt(result) - parentSectionData[upperSectionIndex].table_HeadingArr.length)));
            for(let i=1;i<=len;i++){
                parentSectionData[upperSectionIndex].table_HeadingArr.push({'heading' : ''});
            }
        }
        else{
            parentSectionData[upperSectionIndex].table_HeadingArr =  parentSectionData[upperSectionIndex].table_HeadingArr.slice(0, parseInt(result)); 
        }
    },
    tableMatrix_UtilityArrange : function(component, event,helper,parentSectionData,index) {
        var RowItemList =parentSectionData;
        var filedArray = RowItemList[index].table_fieldLst;
        
        for (var i = 1; i <= filedArray.length; i++) { 
            let indexParent = JSON.parse(JSON.stringify(i-1));
            filedArray[indexParent].RowNumber = i;
            for(let j=1;j<=filedArray[indexParent].colLst.length;j++){
                let indexChild = JSON.parse(JSON.stringify(j-1));
                filedArray[indexParent].colLst[indexChild].ColNumber = j; 
            }
        } 
    },
    createObjectDataForFiledlst_MatrixTable :  function(component, event,helper,index) {       
        var RowItemList = component.get("v.sectionData");
        var filedArray = RowItemList[index].table_fieldLst;
        let len = parseInt(RowItemList[index].table_colSelected);
        
        let toPushObj = {'colLst':[],'RowNumber':1};
        for(let i=1;i<=len;i++){
            toPushObj.colLst.push({'table_heading':'', 'table_fieldSelected':';;;;','ColNumber': 1,'defaultLabel' : ''});
        }
        filedArray.push(toPushObj);
        helper.defineDeleteButton(component, event,helper,filedArray);
        component.set("v.sectionData", RowItemList);        
    },
    divideArray :  function(component) {  
        const chunkSize = 1;
        let array = component.get("v.sectionData");
        for (let i = 0; i < array.length; i += chunkSize) {
            const chunk = array.slice(i, i + chunkSize);
            console.log('CHUNK ##  '+JSON.stringify(chunk));
        }
    },
    collectCellForDeletion : function(component, event, helper,tableFieldLstRecord) {
        let tableRecordsToDel = component.get("v.tableRecordsToDel");
        let arr = tableFieldLstRecord.colLst;
        for(let rec in arr){
            if(arr[rec].hasOwnProperty('Id')){
                tableRecordsToDel.push(arr[rec].Id);
            }
        }
        component.set("v.tableRecordsToDel",tableRecordsToDel);
    },
    setIsConsentAllFields  : function(component, event, helper,serverResponse){
        let markupInstance = component.get("v.isConsent_allFields");
        let labelApiArr_Account = [];
        let labelApiArr_User = [];
        let isConsent_AccountAllFields = serverResponse.isConsent_AllAccountFields;
        let isConsent_UserAllFields = serverResponse.isConsent_AllUserFields;
        Object.entries(isConsent_AccountAllFields).map(entry => {
            labelApiArr_Account.push({'label':entry[1], 'value': 'Account'+'.'+entry[0]});});
    markupInstance.Account = labelApiArr_Account;
    Object.entries(isConsent_UserAllFields).map(entry_User => {
    labelApiArr_User.push({'label':entry_User[1], 'value': 'User'+'.'+entry_User[0]});});
markupInstance.User = labelApiArr_User;
component.set("v.isConsent_allFields",markupInstance);
component.set("v.isConsent_allFields_Copy",JSON.parse(JSON.stringify(markupInstance))); 

},
    populateAttributeContainer : function(component, event,helper,mapOfComponent) {
        var arr = [];
        for(let obj in mapOfComponent){
            let sObj = {'label' : obj, 'value' : mapOfComponent[obj]};
            arr.push(sObj);
        }               
        component.set("v.attributeContainer",arr);
    },  
        offAllAttributes : function(component, event,helper,upperSectionIndex) { 
            var sectionLst = component.get("v.sectionData");
            sectionLst[upperSectionIndex].defaultFiledLstVisibility = false;
            sectionLst[upperSectionIndex].isMacro = false;
            sectionLst[upperSectionIndex].enableTable = false;
            sectionLst[upperSectionIndex].showHeading = false;
            sectionLst[upperSectionIndex].sectionNameAbility = false;
            sectionLst[upperSectionIndex].isConsentForm = false;
            sectionLst[upperSectionIndex].defaultFiledLstVisibility = false; 
            sectionLst[upperSectionIndex].isFormSpecificData = false;  
            sectionLst[upperSectionIndex].addProblem = false;
            sectionLst[upperSectionIndex].addProcedure = false;
            sectionLst[upperSectionIndex].enableProblemForNotes = false;
            sectionLst[upperSectionIndex].typeOfColumn = '';
            sectionLst[upperSectionIndex].FieldsLst = [];
            if($A.util.isEmpty(sectionLst[upperSectionIndex].FieldsLst)){
                sectionLst[upperSectionIndex].typeOfColumn = '1';
                helper.createObjectDataForFiledlst(component, event, upperSectionIndex,false,"1");  
            } 
            sectionLst[upperSectionIndex]['table_colSelected'] = '';
            component.set("v.sectionData",sectionLst);
        },
            handleMacroEnable : function(component, event, helper,upperSectionIndex) {
                try{
                    
                    
                    var sectionLst = component.get("v.sectionData");
                    //  if(event.getSource().get("v.checked")){
                    sectionLst[upperSectionIndex].isMacro = true;
                    sectionLst[upperSectionIndex].isConsentForm = false;
                    sectionLst[upperSectionIndex].defaultFiledLstVisibility = false;
                    sectionLst[upperSectionIndex].enableTable = false;
                    sectionLst[upperSectionIndex].showHeading = false;
                    sectionLst[upperSectionIndex].sectionNameAbility = true;
                    //    }
                    /*   else {
            sectionLst[upperSectionIndex].isConsentForm = true;
            sectionLst[upperSectionIndex].sectionNameAbility = false;
            
        }        */
                    component.set("v.sectionData",sectionLst);   
                }
                catch(e){
                    alert('error '+e);
                }
            },
            

                handleConsentConfig : function(component, event, helper,index) {
                    try{
                        var sectionLst = component.get("v.sectionData");
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
                        component.set("v.sectionData",sectionLst); 
                    }
                    catch(e){
                        alert('error '+e);
                    }
                },
                    activateSectionAsExternalComponent :  function(component, event, helper,index) {         
                        var parentSectionData = component.get("v.sectionData");     
                        var allFields = parentSectionData[index].allFields;
                        
                        var allLookupFields = component.get("v.allLookupApi");
                        
                        var newCommonArray = [];
                        
                        for(var rec in allFields){
                            var api = allFields[rec].value.split(';');
                            
                            if(allLookupFields.includes(api[0])){ newCommonArray.push(allFields[rec]) }
                            
                        }
                        parentSectionData[index].allFields = newCommonArray;
                        
                        parentSectionData[index].isFormSpecificData = true;
                        parentSectionData[index].defaultFiledLstVisibility = true; 
                        parentSectionData[index].FieldsLst = []; 
                        helper.createObjectDataForFiledlst(component, event, index,false,"1"); 
                        console.log('common aray'+JSON.stringify(newCommonArray));
                        component.set("v.sectionData",parentSectionData);
                    },
                        enableMatrixTable : function(component, event, helper,index) {
                            
                            var sectionLst = component.get("v.sectionData");
                            // if(result){
                            
                            sectionLst[index].enableTable = true;
                            sectionLst[index].showHeading = true;
                            sectionLst[index].isFormSpecificData = false;
                            sectionLst[index].addProblem = false;
                            sectionLst[index].addProcedure = false;
                            sectionLst[index].enableProblemForNotes = false;                
                            sectionLst[index].isConsentForm = false;
                            sectionLst[index].isMacro = false;
                            sectionLst[index].defaultFiledLstVisibility = false;
                            sectionLst[index].sectionNameAbility = false;
                            sectionLst[index].typeOfColumn = '1';
                            sectionLst[index]['table_HeadingArr']=[{'heading' : ''}];
                            sectionLst[index]['table_fieldLst']= [{'colLst':[{'table_heading':'', 'table_fieldSelected':';;;;','ColNumber': 1,'defaultLabel' : ''}],'RowNumber':1}];
                            /* }
    else {
        console.log('checkbox result '+result);
        if($A.util.isEmpty(sectionLst[index].FieldsLst)){
            sectionLst[index].typeOfColumn = '1';
            helper.createObjectDataForFiledlst(component, event, index,false,"1");  
        }    
        sectionLst[index]['table_colSelected'] = '';
        sectionLst[index].isConsentForm = false;
        sectionLst[index].defaultFiledLstVisibility = true; 
    }*/
                        component.set("v.sectionData",sectionLst); 
                    },
                        enableAddProblem :function(component, event, helper,index) {
                            let sectionLst = component.get("v.sectionData");
                            sectionLst[index].addProblem = true;     
                            sectionLst[index].FieldsLst = []; 
                            component.set("v.sectionData",sectionLst);  
                        },
                            enableProcedure:function(component, event, helper,index) {
                                let sectionLst = component.get("v.sectionData");
                                sectionLst[index].addProcedure = true;    
                                sectionLst[index].FieldsLst = []; 
                                component.set("v.sectionData",sectionLst);  
                            },
                                
                                enableProblemFromNotes :  function(component, event, helper,index) {     
                                    var sectionLst = component.get("v.sectionData");       
                                    sectionLst[index].enableProblemForNotes = true;
                                    sectionLst[index].isConsentForm = false;
                                    sectionLst[index].isMacro = false;
                                    sectionLst[index].defaultFiledLstVisibility = false;
                                    sectionLst[index].sectionNameAbility = false;
                                    component.set("v.sectionData",sectionLst); 
                                },
                                    enableDrawAndAnnotate : function() {  
                                    },
                                    //added by Anmol for LX3-5769
                                        AddPrescriptionOrder : function() {  
                                        },
                                            EnableLabOrder: function() {  
                                        },
                                            enableDiagnoses: function() {  
                                        },
                                            enableMedicationsList: function() {  
                                        },
                                            
                                            addInventory : function(component, event,helper,mapOfInventory) {
                                                var arr = [];  
                                                
                                                console.log('map Mahesh data '+JSON.stringify(mapOfInventory));
                                                //if(mapOfInventory != 0){
                                                for(let obj in mapOfInventory){
                                                    let sObj = {'label' : obj, 'value' : obj};
                                                    arr.push(sObj);
                                                    console.log('arr '+arr);
                                                    // } 
                                                    
                                                    component.set("v.addInventoryContainer",arr);
                                                } 
                                                
                                            },
                                                enableModularTable : function(component, event, helper,index) {  
                                                    var sectionLst = component.get("v.sectionData");
                                                    sectionLst[index].enableModularTable = true
                                                    sectionLst[index].showHeading = true;
                                                    sectionLst[index].isFormSpecificData = false;
                                                    sectionLst[index].addProblem = false;
                                                    sectionLst[index].addProcedure = false;
                                                    sectionLst[index].enableProblemForNotes = false;                
                                                    sectionLst[index].isConsentForm = false;
                                                    sectionLst[index].isMacro = false;
                                                    sectionLst[index].defaultFiledLstVisibility = false;
                                                    sectionLst[index].sectionNameAbility = false;
                                                    sectionLst[index].enableTable = false;
                                                    sectionLst[index].typeOfColumn = '1';
                                                    sectionLst[index]['table_HeadingArr']=[{'heading' : ''}];
                                                    sectionLst[index]['table_fieldLst']= [{'colLst':[{'table_heading':'', 'table_fieldSelected':'','ColNumber': 1,'defaultLabel' : ''}],'RowNumber':1}];
                                                    
                                                    component.set("v.sectionData",sectionLst); 
                                                },
                                                   /* onCheck: function(component, event) {
                                                        var checkCmp = component.find("checkbox");
                                                        var chCmp = checkCmp.get("v.value");
                                                        resultCmp = component.find("checkResult");
                                                        component.set("v.myBool",chCmp );
                                                        
                                                    },    */
                                                        enableUploadAndAnnotate : function() {  
                                                            
                                                        },

    showThisToast: function (component, event, helper, toastType, toastTitle, toastMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": toastTitle,
            "message": toastMessage,
            "type": toastType
        });
        toastEvent.fire();
    },

    fetchImageNamesInStaticResource: function (component) {
        let action = component.get("c.getAllImageNamesInStaticResource");

        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                console.log("all available images: ", response.getReturnValue());
                component.set("v.allImageNamesInStaticResource", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    validateAllStaticResourceValues: function (component, event, helper) {
        let allImagesInStaticResource = component.get("v.allImageNamesInStaticResource");
        let sectionData = component.get("v.sectionData");
        for (let section of sectionData) {
            if (section.formComponentVal == "Enable Draw And Annotate") {
                if (!section.staticFieldLabel) {
                    this.showThisToast(component, event, helper, "error", "Draw and Annotate",
                        `Please enter static resource file name in section ${section.serialNumber}`);
                    return false;
                }
                else if (!allImagesInStaticResource.includes(section.staticFieldLabel)) {
                    this.showThisToast(component, event, helper, "error", "Draw and Annotate",
                        `File name entered in section ${section.serialNumber} does not exist or is not an image`);
                    return false;
                }
            }
        }
        return true;
    },
   /*LX3-6208- Form template should not be update without selecting any field in any section. Added by Jothilakshmi*/
    customValidityForFields: function (component, event, helper) {
        var arrofApi = [];
        let sectionData = component.get("v.sectionData");
        for (let section of sectionData) {   
            if (!section.formComponentVal) {
                let arrayList = section.FieldsLst; 
                if (Array.isArray(arrayList)) {
                for(let arrlst of arrayList){
                    let arr = arrlst.selectedField.split(';');  
                    let selectType = arrlst.typeSelected;
                    if(selectType == 'Field'){
                        if(!$A.util.isEmpty(arr)){
                            arrofApi.push(arr[0]);
                            if(!arrlst.selectedField){
                                this.showThisToast(component, event, helper, "error", "Error!!",
                                                   `Please select the fields to update the form!!`);
                                return false;
                            } 
                        }    
                    }
                    else if(selectType == 'File Upload'){
                        let fileName = arrlst.fileName;
                        if(!fileName){
                            this.showThisToast(component, event, helper, "error", "Error!!",
                                               `Please fill the file name to update the form!!`);
                            return false;
                        } 
                    }    
            } 
        }   
        } 
        
    }
        component.set("v.arrofApi",arrofApi);
        return true;
    },
/* Ended*/ 
    validateFormConfiguration: function (component, event, helper) {
        // Validate that draw and annotate has static resource file name filled and it is image
        return this.validateAllStaticResourceValues(component, event, helper)
        && this.customValidityForFields(component,event,helper);
        // && this.anyOthervalidation(component,event,helper);
    },
        arrangeFieldNumber : function(component, event,helper,index,filedArray,typeOfColumn,deletedRowNumber,deletedColNumber) {
        console.log('filedArray Helper');
        if(typeOfColumn == "2"){
            for (var i = 0; i < filedArray.length; i++) { 
                if((filedArray[i].RowNumber > deletedRowNumber) || (filedArray[i].ColNumber > deletedColNumber && filedArray[i].RowNumber >= deletedRowNumber)) {
                 	if(i % 2 == 0) {
                    	filedArray[i].RowNumber--;
                    	filedArray[i].ColNumber++;
                	}
                	else {
                    	filedArray[i].RowNumber;
                    	filedArray[i].ColNumber--;
                	}   
                } 
            } 
        }
        else {
            for (let i = 0; i < filedArray.length; i++) { 
                if(filedArray[i].RowNumber > deletedRowNumber){
                    filedArray[i].RowNumber=filedArray[i].RowNumber-1;
                }
            }
            
        }
        component.set("v.sectionData", filedArray);
    },
    asyncValidations : function(component, event, helper) {
        helper.genericUpdate(component, event, helper); 
     /*   console.log('inside asyncValidations');
        var flag = true;
        component.find("Id_spinner").set("v.class" , 'slds-show');
        let action = component.get("c.getFields");
        action.setParams({
            allIncomingAPis: component.get("v.arrofApi")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                let controllingFieldLst = response.getReturnValue(); 
                console.log('controllingFieldLst'+JSON.stringify(controllingFieldLst));
                for(let rec in controllingFieldLst){ 
                    console.log('inside for arrlist')
                    if(!component.get("v.arrofApi").includes(controllingFieldLst[rec])){
                        this.showThisToast(component, event, helper, "error", "Error!!",
                                           `Please select the respective controlling field to save the form!!`);
                        flag = false;
                        break;
                        
                    }
                }
                if(flag){
                    console.log('Flag asyncValidations');
               //     helper.genericUpdate(component, event, helper); 
                }
            }
        });
        $A.enqueueAction(action);  */
    },
    genericUpdate: function(component, event, helper) {
        console.log('inside genericUpdate');
        const chunkSize = 3; 
        let array = component.get("v.sectionData");
        
        let callbackCount = 0;
        for (let i = 0; i < array.length; i += chunkSize) {
            var chunk = array.slice(i, i + chunkSize);
            console.log('CHUNK ##  '+JSON.stringify(chunk));
            var toSaveData = {"keysToSave":chunk };
            var toInsertNewSectiondata = {"keysToSave" : helper.filterNewSectionRecordsToInsert(component, event, helper,chunk).parentRecords};                        
            console.log('DATA TO update '+JSON.stringify(toSaveData));
            console.log('toInsertNewSectiondata '+JSON.stringify(toInsertNewSectiondata));
            //console.log('toInsertchildRecords '+JSON.stringify(toInsertchildRecords));
            var action = component.get("c.saveAfterEdit_FormconfigData");
            component.find("Id_spinner").set("v.class" , 'slds-show'); 
            component.set("v.disableAfterSave",true);
            action.setParams({
                formConfigurationDataToSave: JSON.stringify(toSaveData),
                recordTypeName : component.get("v.formNameReflectedAsRecordType"),
                formNewSectionsToInsert : JSON.stringify(toInsertNewSectiondata),
                /*  formNewChildRecordsToInsert : JSON.stringify(toSaveData),*/
                parentSectiondelList : component.get("v.parentSectionToDelete"),
                formCategoryFromJS : component.get("v.formCategory"),
                IstimeEnabled: component.get("v.enableTime"),
                tableRecordsToDel : component.get("v.tableRecordsToDel")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    callbackCount+=1;
                    console.log('callbackCount  '+callbackCount);
                    if(callbackCount >= parseInt(array.length/chunkSize)){
                        component.set("v.disableAfterSave",false);
                        component.find("Id_spinner").set("v.class" , 'slds-hide');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "FORMS UPDATED SUCCESSFULLY!",
                            "message": "Success!",
                            "type" : "success"
                        });
                        toastEvent.fire();
                        var appEvent = $A.get("e.c:FormsRefreshEvt");
                        appEvent.fire();
                        component.set("v.isOpen",false);
                    }
                }
                else{
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    component.set("v.disableAfterSave",false);
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
    checkAutoPopulation : function(component, event,helper,objectName,fieldName,upperSectionIndex,lowerFieldIndex) {
	        
		console.log('Inside checkAutoPopulation '+objectName + "  ---- "+fieldName + upperSectionIndex + '----- ' + lowerFieldIndex);
        //parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].showAutoPopulation = true;
         
        //console.log('sectionLst '+sectionLst);
       // console.log('sectionLst[index].FieldsLst '+sectionLst[index].FieldsLst);
        var action = component.get("c.checkReferenceForAutoPopulation");
        action.setParams({
            objectName: objectName,
            fieldName:fieldName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Inside checkAutoPopulate state'+state);
           
            if (state === "SUCCESS") {
                
                var res = response.getReturnValue();  
                var parentSectionData = component.get("v.sectionData");
                console.log('response in method '+res);
                 // console.log('parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].showAutoPopulation '+parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].showAutoPopulation);
            	parentSectionData[upperSectionIndex].FieldsLst[lowerFieldIndex].showAutoPopulation = res;   
            	component.set("v.sectionData",parentSectionData);
                //component.set("v.sectionData",parentSectionData); 
                 
                
            }
            
        });
        
        $A.enqueueAction(action);
    }

})