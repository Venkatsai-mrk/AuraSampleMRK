({
    defaultColumnsSet : function(component) {
        component.set("v.ConsentObjArray",[{'label':'Account','value':'Account'},{'label':'User','value':'User'}]);
        component.set("v.columnDefault","1 Column");
        component.set("v.sectionLstLength","[{'1'},{'2'}]");
        component.set("v.swapAbility",true);
        var mapOfObjectAndcustomLabel = {'ElixirSuite__Dataset1__c' : 'Problem',
                                         'ElixirSuite__Prescription_Order__c' : 'Medication_List'};
        component.set("v.mapOfObject",mapOfObjectAndcustomLabel);
    },
    filterlookupFields : function(component, event, helper,parentJSON) {
        var allFields = component.get("v.AllFields");
        var allLookupFields = component.get("v.allLookupApi");
        var newCommonArray = [];
        for(var rec in allFields){
            var api = allFields[rec].value.split(';');
            if(allLookupFields.includes(api[0])){
                newCommonArray.push(allFields[rec]);
            }
            
        }
        parentJSON.allFields = newCommonArray;
        component.set("v.allFields_lookupApi",newCommonArray);
        component.set("v.AllFields", component.get("v.allFields_lookupApi")); 
        console.log('common aray '+JSON.stringify(newCommonArray));
    },
    createListOfLookupApi : function(component, event, helper,lstLkupApi) {
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
    globalFlagToast : function(component, event, helper,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":  message,
            "type" :type
        });
        toastEvent.fire();
    },
    createObjectData: function(component) {
        var RowItemList = component.get("v.sectionData");
        var check = component.get("v.myBool");
        var inventoryVal = component.get("v.invValue");
        var lstTypeSelectionOption = [{'label' : 'Field', 'value' : 'Field'},{'label' : 'File Upload', 'value' : 'File Upload'}];
        
        var typeOfUpload = [{'label' : 'Single', 'value' : 'Single'},{'label' : 'Multiple', 'value' : 'Multiple'}];//added by Monika Singh for File Upload, line 40-41
        RowItemList.push({
            'serialNumber' : '',
            'isConsentForm' : false,
            'defaultFiledLstVisibility' : true,
            'consentTextValue' : '',
            'sectionName': '',
            'sectionNameAbility' : false,
            'swapSectionVisibility': false,
            'typeOfColumn': '1',
            'mapQuery' : {},
            'finalParentQueryForSection_One' : '',
            'mapQueryStringified' : '',
            'allFields' :  component.get("v.AllFieldsNetInstanceCopy"),
            'isFormSpecificData' : false,
            'hasextCmp' : false,
            'enableAutoText' : false,
            'hideSctionsForAutotext' : false,
            'autoTextValue' : '',
            'abilityForFormSpecificData' : false,
            'allFieldAPIsArray' : [],
            'allFieldAPIs' : '',   
            'isMacro' : false,
            'isConsent_SelectedObject' : '',
            'isConsent_allFieldAPIs' :  component.get("v.isConsent_AccountFields"),
            'isConsent_selected_allFieldAPIs' : [],
            'isConsent_showFieldApi' : false,
            'isConsent_showMultiSelectPicklist' : true,
            'isConsent_finalParentQueryForSection_One' : '',
            'isConsent_allFieldAPIStringified' : '',
            'isConsent_SelectedObject_Lst' : [],
            'enableTable' : false,
            'enableModularTable' : false,
            'showHeading' : false,
            'table_rowDropDown' : ['1', '2','3','4','5','6'],
            'table_colSelected' : '',
            'table_HeadingArr' : [{'heading' : ''}],
            'table_fieldLst' : [{'colLst':[],'RowNumber':1,'table_heading':''}],
            'addProblem' : false,
            'addProcedure' : false,
            'enableProblemForNotes' : false,
            'formComponentVal' : '',
            'formInventoryVal' : inventoryVal,
            'formCheckbox' : check,
            'staticFieldLabel' : '',
            'typeOfNote' : '',
            'freeTextSOQL' : '',
            'FieldsLst': [{'isDefaultLabelActive' : false,'defaultLabel' : '','selectedField' : '','RowNumber' : 1,'ColNumber': 1,'isMatrixAvailable':false,
                           'displayPicklistAsRadio' : false,'isPicklistAsRadio' : false,'verticalAlignForRadio' : false,'verticalAlignForMultiPicklist' : false,
                           'displayMultiPicklistAsCheckbox' : false,'isMultiPicklistAsCheckbox' : false,'switchDecision':false,
                           'isSwitchedToFormula' : false,'fieldsAfterFormula' : false,'switchFormulaEnabled': false, 'typeOfUpload':typeOfUpload,
                           'typeSelectOption':lstTypeSelectionOption,'typeSelected':'Field',//added by Monika Singh for File Upload, line 61-62
                           'selectedObjectForFormula': '',  'lookupApiName' : '','selectedFieldForFormulaMapping': '','fieldListForFormulaMapping':[],'accountLookupFieldLst' : [], 'whereClause' : '', 'accountLookupAPI' : '',
                           'recordTypeExists' : false, 'ObjectRecordTypes' : [], 'selectedRecordType' : '','autoPopulate' : false,'isCommon' : false,'fileUploadButtonDefaultLabel':'','fileName':'','typeOfUploadSelected':'Single',
                           'noLabel' : false,'table_heading':'', 'table_fieldSelected':''}],//added by Monika Singh for File Upload
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
        console.log('RI LIST '+ component.get("v.sectionData"));
    },
    createObjectDataForFiledlst : function(component, event,index,isMatrix,typeOfColumn) {
        var lstTypeSelectionOption = [{'label' : 'Field', 'value' : 'Field'},{'label' : 'File Upload', 'value' : 'File Upload'}];
        var typeOfUpload = [{'label' : 'Single', 'value' : 'Single'},{'label' : 'Multiple', 'value' : 'Multiple'}];//added by Monika Singh for File Upload, line 40-41
        var RowItemList = component.get("v.sectionData");
        var filedArray = RowItemList[index].FieldsLst;
        var stateCounterone = 1;
        var stateCountertwo = 1;
        
        filedArray.push({
            
            'isDefaultLabelActive' : false,'defaultLabel' : '','selectedField' : '','RowNumber' : '','ColNumber': '','isMatrixAvailable':isMatrix,
            'displayPicklistAsRadio' : false,'isPicklistAsRadio' : false,'verticalAlignForRadio' : false,'verticalAlignForMultiPicklist' : false,'displayMultiPicklistAsCheckbox' : false,'isMultiPicklistAsCheckbox' : false,
            'isSwitchedToFormula' : false,'fieldsAfterFormula' : false,'switchFormulaEnabled': false,'selectedObjectForFormula': '','switchDecision':false,
            'lookupApiName' : '','selectedFieldForFormulaMapping': '','fieldListForFormulaMapping':[],'accountLookupFieldLst' : [], 'whereClause' : '', 'accountLookupAPI' : '',
            'recordTypeExists' : false, 'ObjectRecordTypes' : [],'selectedRecordType' : '','isCommon' : false,'autoPopulate' : false,'fileName': '','fileUploadButtonDefaultLabel' : '',
            'typeOfUpload':typeOfUpload,'typeSelected':'Field', 'noLabel' : false,'table_heading':'','table_fieldSelected' : '',
            'typeSelectOption':lstTypeSelectionOption,
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
    createObjectDataForFiledlst_MatrixTable :  function(component, event,index) {
        
        
        var RowItemList = component.get("v.sectionData");
        var filedArray = RowItemList[index].table_fieldLst;
        let len = parseInt(RowItemList[index].table_colSelected);
        
        let toPushObj = {'colLst':[],'RowNumber':1};
        for(let i=1;i<=len;i++){
            toPushObj.colLst.push({'table_heading':'', 'table_fieldSelected':'','ColNumber': 1,'defaultLabel' : ''});
        }
        filedArray.push(toPushObj);
        let lastElement_fldLst = filedArray[filedArray.length - 1];
        let lastElement_colLst = lastElement_fldLst.colLst[lastElement_fldLst.colLst.length-1];       
        for(let elm in filedArray){
            let colArr  = filedArray[elm].colLst;
            for(let elm_Child in colArr){
                colArr[elm_Child]['isLast'] = false;
            }           
        }
        if(filedArray.length!=1){
            lastElement_colLst['isLast'] = true;
        }
        component.set("v.sectionData", RowItemList);        
    },
    createSectionJSON: function(component, event, helper,labelApiList,response) {        
        let labelApiArr = [];
        for(var rec in response){
            labelApiArr.push({'value': 'Account.'+rec, 'label': response[rec]}); 
        }
        component.set("v.isConsent_AccountFields",JSON.parse(JSON.stringify(labelApiArr)));
        
        var RowItemList = component.get("v.sectionData");
        var check = component.get("v.myBool");
        var inventoryVal = component.get("v.invValue");
        let lstTypeSelectionOption = [{'label' : 'Field', 'value' : 'Field'},{'label' : 'File Upload', 'value' : 'File Upload'}];
        let typeOfUpload = [{'label' : 'Single', 'value' : 'Single'},{'label' : 'Multiple', 'value' : 'Multiple'}];//added by Monika Singh for File Upload, line 40-41
        RowItemList.push({ 
            'serialNumber' : '',
            'isConsentForm' : false,
            'defaultFiledLstVisibility' : true,
            'consentTextValue' : '',
            'sectionName': '',
            'sectionNameAbility' : false,
            'swapSectionVisibility': false,
            'typeOfColumn': '1',
            'mapQuery' : {},
            'finalParentQueryForSection_One' : '',
            'mapQueryStringified' : '',
            'allFields' : labelApiList,
            'isFormSpecificData' : false,
            'hasextCmp' : false,
            'isMacro' : false,
            'enableAutoText' : false,
            'hideSctionsForAutotext' : false,
            'autoTextValue' : '',
            'abilityForFormSpecificData' : false,
            'allFieldAPIsArray' : [],
            'allFieldAPIs' : '',  
            'isConsent_SelectedObject' : '',
            'isConsent_allFieldAPIs' : labelApiArr,
            'isConsent_showFieldApi' : false,
            'isConsent_showMultiSelectPicklist' : true,
            'isConsent_selected_allFieldAPIs' : [],
            'isConsent_allFieldAPIStringified' : '',
            'isConsent_SelectedObject_Lst' : [],
            'isConsent_finalParentQueryForSection_One' : '',
            'enableTable' : false,
            'enableModularTable' : false,
            'showHeading' : false,
            'table_rowDropDown' : ['1', '2','3','4','5','6'],
            'table_colSelected' : '',
            'table_HeadingArr' : [{'heading' : ''}],
            'table_fieldLst' : [{'colLst':[{'table_heading':'', 'table_fieldSelected':'','ColNumber': 1,'defaultLabel' : ''}],'RowNumber':1}],
            'addProblem' : false,
            'addProcedure' : false,
            'enableProblemForNotes' : false,
            'typeOfNote' : '',
            'formComponentVal' : '',
            'formInventoryVal' : inventoryVal,
            'formCheckbox' : check,
            'staticFieldLabel' : '',
            'freeTextSOQL' : '',
            'FieldsLst': [{'isDefaultLabelActive' : false,'defaultLabel' : '','selectedField' : '','RowNumber' : 1,'ColNumber': '','isMatrixAvailable':false,
                           'displayPicklistAsRadio' : false,'isPicklistAsRadio' : false,'verticalAlignForRadio' : false,'verticalAlignForMultiPicklist' : false,
                           'displayMultiPicklistAsCheckbox' : false,'isMultiPicklistAsCheckbox' : false, 'typeOfUpload':typeOfUpload,
                           'typeSelectOption':lstTypeSelectionOption, 'noLabel' : false,
                           'isSwitchedToFormula' : false,'fieldsAfterFormula' : false,'switchFormulaEnabled': false,'switchDecision':false, 'whereClause' : '', 'accountLookupAPI' : '',
                           'selectedObjectForFormula': '',  'lookupApiName' : '','selectedFieldForFormulaMapping': '','fieldListForFormulaMapping':[],'accountLookupFieldLst' : [],
                           'recordTypeExists' : false, 'ObjectRecordTypes' : [],'selectedRecordType' : '','isCommon' : false,'autoPopulate' : false,
                           'typeSelected':'Field','fileUploadButtonDefaultLabel':'','fileName':'','typeOfUploadSelected':'Single','table_heading':'',
                           'table_fieldSelected':''}], //Added by Monika Singh | 27th July 2021
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
    returnFieldSObjInstance : function() {
        return {'table_heading':'', 'table_fieldSelected':'','ColNumber': 1,'defaultLabel' : ''};      
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
            allSObjectQueryForParent.push(JSON.parse(JSON.stringify(parentJSON[rec].mapQuery)));          
            let finalQuerybuild= [];
            for(let element in queryArray){ // 
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
        
        console.log('obj '+JSON.stringify(obj));
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
                        mapOfsObjAndFields.set(childRec,sObjInstanceArr); 
                    }
                    else {
                        mapOfsObjAndFields.get(childRec).push(childsObj[childRec]);
                    }
                }
                else {
                    mapOfsObjAndFields.set(childRec,childsObj[childRec]);
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
        var apiArray = JSON.parse(JSON.stringify(parentRecord.allFieldAPIsArray));
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
        parentSectionData[upperSectionIndex].isConsent_showMultiSelectPicklist = false;
        parentSectionData[upperSectionIndex].isConsent_selected_allFieldAPIs = [];
        
        component.set("v.sectionData",parentSectionData);
        var action = component.get("c.fetchFieldsForSelectedObject");
        action.setParams({
            objectName: entityName
        });
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var res = response.getReturnValue();    
                var labelApiArr = [];
                for(var rec in res){
                    labelApiArr.push({'label': res[rec], 'value': entityName+'.'+rec});
                }
                parentSectionData[upperSectionIndex].isConsent_allFieldAPIs = labelApiArr;
                parentSectionData[upperSectionIndex].isConsent_showMultiSelectPicklist = true;
                component.set("v.sectionData",parentSectionData); 
                
                
            }
            
        });
        
        $A.enqueueAction(action);
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
    populateAttributeContainer : function(component, event,helper,mapOfComponent) {
        var arr = [];
        console.log('mapOfComponent'+JSON.stringify(mapOfComponent));
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
            if(allLookupFields.includes(api[0])){ newCommonArray.push(allFields[rec]); }
            
        }
        parentSectionData[index].allFields = newCommonArray;
        parentSectionData[index].isFormSpecificData = true;
        parentSectionData[index].defaultFiledLstVisibility = true;
        console.log('common aray '+JSON.stringify(newCommonArray));
        component.set("v.sectionData",parentSectionData);
    },
    enableMatrixTable : function(component, event, helper,index) {
        
        var sectionLst = component.get("v.sectionData");
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
        sectionLst[index]['table_fieldLst']= [{'colLst':[{'table_heading':'', 'table_fieldSelected':'','ColNumber': 1,'defaultLabel' : ''}],'RowNumber':1}];
        
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
    enableUploadAndAnnotate : function() {  
        
    },
    AddPrescriptionOrder : function() {  
    },
    EnableLabOrder: function() {  
                                        
    },
    addInventory : function() {  
    },
    enableDiagnoses : function() {  
    },
    enableMedicationsList : function() {  
    },
    /* addInventory : function(component, event,helper,mapOfInventory) {
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
        
    },   */
    
    
    /* onCheck: function(component, event) {
		 var checkCmp = component.find("checkbox");
        var chCmp = checkCmp.get("v.value");
		 resultCmp = component.find("checkResult");
		 //component.set("v.myBool",chCmp );

	 },*/
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
    showThisToast: function(component, event, helper, toastType, toastTitle, toastMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": toastTitle,
            "message": toastMessage,
            "type": toastType
        });
        toastEvent.fire();
    },
    
    fetchImageNamesInStaticResource : function(component) {
        let action = component.get("c.getAllImageNamesInStaticResource");
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
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
    /*LX3-5922- Form template should not be configured/Saved without selecting any field in any section. Added by  Jothilakshmi*/
    customValidityForFields: function (component, event, helper) {
        var arrofApi = [];
        let sectionData = component.get("v.sectionData");
        for (let section of sectionData) {   
            if (!section.formComponentVal) {
                let arrayList = section.FieldsLst; 
                for(let arrlst of arrayList){
                    let arr = arrlst.selectedField.split(';');  
                    let selectType = arrlst.typeSelected;
                    if(selectType == 'Field'){
                        if(!$A.util.isEmpty(arr)){
                            arrofApi.push(arr[0]);
                            if(!arrlst.selectedField){
                                this.showThisToast(component, event, helper, "error", "Error!!",
                                                   `Please select the fields to save the form!!`);
                                return false;
                            } 
                        }    
                    }
                    else if(selectType == 'File Upload'){
                        let fileName = arrlst.fileName;
                        if(!fileName){
                            this.showThisToast(component, event, helper, "error", "Error!!",
                                               `Please fill the file name to save the form!!`);
                            return false;
                        } 
                    }    
                }    
            } 
            
        }
        component.set("v.arrofApi",arrofApi);
        return true;
    },
    
    validateFormConfiguration: function(component, event, helper) { // static validations
        // Validate that draw and annotate has static resource file name filled and it is image
        return this.validateAllStaticResourceValues(component, event, helper)
        && this.customValidityForFields(component,event,helper) ;
        // && this.anyOthervalidation(component,event,helper)
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
        helper.genericSave(component, event, helper); 
        /*console.log('Inside asyncValidations');
        var flag = true;
        component.find("Id_spinner").set("v.class" , 'slds-show');
        console.log('Before method call');
        let action = component.get("c.getFields");
        console.log('After method call:', action);
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
                  
                }
            }
        });
        $A.enqueueAction(action);  */
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
    },
    genericSave: function(component) {
        console.log('Inside genericSave');
        var toSaveData = {"keysToSave":component.get("v.sectionData")};
        console.log('DATA TO SAVE '+JSON.stringify(toSaveData));                
        var action = component.get("c.saveFormconfigData");
        //  alert('meg new save');
        component.find("Id_spinner").set("v.class" , 'slds-show');
        component.set("v.disableAfterSave",true);
        action.setParams({
            formConfigurationDataToSave: JSON.stringify(toSaveData),
            recordTypeName : component.get("v.formNameReflectedAsRecordType"),
            formCategoryFromJS : component.get("v.formCategory"),
            IstimeEnabled: component.get("v.enableTime"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.disableAfterSave",false);
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "FORMS CREATED SUCCESSFULLY!",
                    "message": "Success!",
                    "type" : "success"
                });
                toastEvent.fire();
                component.set("v.isOpen",false);
            }
            else{
                component.set("v.disableAfterSave",false);
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
            
        });
        
        $A.enqueueAction(action);
        component.set("v.disableAfterSave",false);
        
    }
})