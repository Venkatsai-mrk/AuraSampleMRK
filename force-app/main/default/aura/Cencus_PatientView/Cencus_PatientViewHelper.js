({
    
    /*
     * this function will build table data
     * based on current page selection
     * */
    buildData : function(component, helper,apiLabelMap,apiLabelMapConfig,apiOrderMap) {
        try{
            var data = [];
            var pageNumber = component.get("v.currentPageNumber");
            var pageSize = component.get("v.pageSize");
            var allData = component.get("v.PatientData");
            console.log('0909'+ JSON.stringify(allData));
            var x = (pageNumber-1)*pageSize;
            var y = (pageNumber-1)*pageSize;
            var excludeApiArr = ['RecordTypeId']; 
            component.set("v.offset", y);
            //creating data-table data
            for(; x<(pageNumber)*pageSize; x++){

                if(allData[x]){
                    for(let sObj in excludeApiArr){
                        let keyToDel = excludeApiArr[sObj];
                        delete allData[x][keyToDel];
                    }                   
                    data.push(allData[x]);                 
                }
            }
            console.log('kkk'+data);
            component.set("v.Patient_Name", data);
            component.set("v.dataLength", data.length);
            helper.generateDynamicPatientBoard(component,helper,apiLabelMap,apiLabelMapConfig,apiOrderMap);
            helper.generatePageList(component, pageNumber);
        }
        catch(e){
            console.log('error '+e);
        }
    },

    /*
     * this function generate page list
     * */
    generateDynamicPatientBoard : function(component, helper,apiLabelMap,apiLabelMapConfig,apiOrderMap){
        let exculdeApiArray = ['Id','Name','ElixirSuite__Treatment_Center__c','ElixirSuite__Profile_Picture__c',
                               'ElixirSuite__House__c','ElixirSuite__Rooms__c'];

        let boardData = component.get("v.Patient_Name");
        for(let item in boardData){
            let parentSobj = {'dynamicRec' : [],'Contacts' :[]};
            let sObjRec = boardData[item];
            let recArr = [];
            let configArr = JSON.parse(JSON.stringify(exculdeApiArray.concat(Object.keys(apiLabelMapConfig))));
            for(let child in sObjRec){
                if(child!='Contacts'){
                    let prefixLabel = '';
                    let sObj = {'fieldLabel' : '','fieldValue' : '','fieldApi':''};                
                    if(apiLabelMap.hasOwnProperty(child)){
                        if(child == 'ElixirSuite__Bed__c'){
                            helper.createProperty(component, helper,sObjRec);
                            sObj = {'fieldLabel' : apiLabelMap[child],'fieldApi':child,
                                    'fieldValue_LV_1' : sObjRec['ElixirSuite__Treatment_Center__r']['ElixirSuite__Treatment_center_Name__c']+
                                    ' | '+ sObjRec['ElixirSuite__House__r']['Name'],
                                    'fieldValue_LV_2':sObjRec['ElixirSuite__Rooms__r']['Name']+
                                    ' | '+ sObjRec['ElixirSuite__Bed__r']['ElixirSuite__Formula_Name__c']};    
                        }
                        else{
                            sObj = {'fieldLabel' : apiLabelMap[child],'fieldValue' : sObjRec[child],'fieldApi':child}; 
                        }
                    }

                    if(configArr.includes(child)){
                        const index = configArr.indexOf(child);
                        if (index > -1) {
                            configArr.splice(index, 1); 
                        }

                    }
                    if(!exculdeApiArray.includes(child)){
                        recArr.push(sObj);
                    }
                    console.log('recArr '+JSON.stringify(recArr));
                }
            }
            helper.addNonValueFields(component, helper,configArr,recArr,exculdeApiArray,
                                     apiLabelMap);
            let orderArr = [];
            for(let recsObj in recArr){

                let obj = {'fieldLabel' : recArr[recsObj].fieldLabel,'order' : apiOrderMap[recArr[recsObj].fieldLabel],
                           'fieldValue' : recArr[recsObj].fieldValue,'fieldApi':recArr[recsObj].fieldApi,
                           'fieldValue_LV_1' :  recArr[recsObj]['fieldValue_LV_1'] , 'fieldValue_LV_2' :  recArr[recsObj]['fieldValue_LV_2']
                          };
                if(!$A.util.isUndefinedOrNull(obj.fieldValue)){
                    if (obj.fieldValue.toString().endsWith('000Z')) { 
                        let today = obj.fieldValue;
                        today =  new Date();
                        var dd = String(today.getDate()).padStart(2, '0');
                        var mm = String(today.getMonth() + 1).padStart(2, '0'); 
                        var yyyy = today.getFullYear();        
                        today = yyyy+'-'+dd + '-' + mm;
                        obj.fieldValue=   today;
                    }
                }
                if(obj.fieldLabel){
                    orderArr.push(obj);
                }
            }
            orderArr.sort(function(a, b) {
                return parseFloat(a.order) - parseFloat(b.order);
            });

            parentSobj.dynamicRec = orderArr;
            parentSobj.Contacts = boardData[item].Contacts;
            boardData[item]['dynamicKey'] = parentSobj;
        }

        component.set("v.Patient_Name",boardData);
         console.log('Patient_Name '+JSON.stringify(component.get("v.Patient_Name"))); 

    },
    createProperty :  function(component, helper,sObjRec){
        if(!sObjRec.hasOwnProperty('ElixirSuite__Treatment_Center__r')){
            sObjRec['ElixirSuite__Treatment_Center__r'] = {'ElixirSuite__Treatment_center_Name__c' : ''};
        }
        if(!sObjRec.hasOwnProperty('ElixirSuite__House__r')){
            sObjRec['ElixirSuite__House__r'] = {'Name' : ''};
        }
        if(!sObjRec.hasOwnProperty('ElixirSuite__Rooms__r')){
            sObjRec['ElixirSuite__Rooms__r'] = {'Name' : ''};
        }
        if(!sObjRec.hasOwnProperty('ElixirSuite__Bed__r')){
            sObjRec['ElixirSuite__Bed__r'] = {'ElixirSuite__Formula_Name__c' : ''};
        }
    },
    addNonValueFields : function(component, helper,configArr,recArr,exculdeApiArray,
                                 apiLabelMap){
        let exculdeApiArray_param = ['Id','Name','ElixirSuite__Age__c','ElixirSuite__DOB__c','ElixirSuite__MRN_Number_New__c',
                                     'ElixirSuite__Gender__c'];
        for(let rec in configArr){
            if(!exculdeApiArray.includes(configArr[rec])){
                recArr.push({'fieldLabel' : apiLabelMap[configArr[rec]],'fieldValue' : ''});
            }
        }
    },
    generatePageList : function(component, pageNumber){
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        if(totalPages > 1){
            if(totalPages < 10){
                var counter = 2;
                for(; counter < (totalPages); counter++){
                    pageList.push(counter);
                } 
            } else{
                if(pageNumber < 5){
                    pageList.push(2, 3, 4, 5, 6);
                } else{
                    if(pageNumber>(totalPages-5)){
                        pageList.push(totalPages-5, totalPages-4, totalPages-3, totalPages-2, totalPages-1);
                    } else{
                        pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
    },
    setButtonColorForPatientsInReview: function(component, event ,helper) {
        component.set("v.cssClass_AllPatients",''); 
        component.set("v.cssClass_CurrentPatients",''); 
        component.set("v.cssClass_PatientsInReview",'elemtRed'); 
        component.set("v.cssClass_DischargedPatients",''); 
    },
    setButtonColorForCurrentPatients : function(component, event ,helper) {
        component.set("v.cssClass_CurrentPatients",'elemtRed'); 
        component.set("v.cssClass_PatientsInReview",''); 
        component.set("v.cssClass_DischargedPatients",''); 
        component.set("v.cssClass_AllPatients",''); 
    },
    setButtonColorForDischargedPatients : function(component, event ,helper) {
        component.set("v.cssClass_DischargedPatients",'elemtRed'); 
        component.set("v.cssClass_CurrentPatients",''); 
        component.set("v.cssClass_PatientsInReview",'');       
        component.set("v.cssClass_AllPatients",''); 
    },
    buildDataWrapper : function(component, event ,helper) {
        let FilterByArr = [{'label' : 'Gender' , 'value' : 'Gender'},
                           {'label' : 'Level Of Care' , 'value' : 'Level Of Care'},  
                           {'label' : 'Primary Care Physician' , 'value' : 'Primary Care Physician'},
                           {'label' : 'Location' , 'value' : 'Location'},
                           {'label' : 'MRN' , 'value' : 'MRN'},
                           // {'label' : 'ICD' , 'value' : 'ICD'},
                           {'label' : 'Bed Details' , 'value' : 'Bed Number'},

                          ];
                           component.set("v.FilterByArr",FilterByArr);
                           let filterByToFilterMap = {'Gender' : [{'label' : 'Male','value': 'Male'},
                           {'label' : 'Female','value': 'Female'}],
            'MRN' : 'MRN',
                'ICD' : 'ICD',
                    'Bed Number' : 'Bed Number',
                        'Primary Care Physician' : 'Primary Care Physician',
                            'Level Of Care' : '',
                                'Location' : ''};
    let searchMap = {'MRN' : 'MRN',
    'ICD' : 'ICD',
    'Bed Number' : 'Bed Number',
    'Primary Care Physician' : 'Primary Care Physician'};
 component.set("v.searchMap",searchMap);
component.set("v.filterByToFilterMap",filterByToFilterMap);
},
    checkToDateValidity : function(component, event, helper,value,childIndex) { 
        var isValid = true;
        var endDateCmp = component.find('toFilter');
        var endDate = value;
        var today = new Date();        
        var dte = new Date(endDate);
        if(Array.isArray(endDateCmp)){            
            if((dte.setDate(dte.getDate()) >today)){
                endDateCmp[childIndex].setCustomValidity("Future date not allowed");
                isValid = false;
            } 
            else {
                endDateCmp[childIndex].setCustomValidity("");

            }
            endDateCmp[childIndex].reportValidity(); 
        }
        else {
            var endDate = endDateCmp.get('v.value');
            var today = component.get("v.fromDate");
            today = new Date(today);
            var dte = new Date(endDate);
            if((dte.setDate(dte.getDate()) <today)){
                endDateCmp.setCustomValidity("To date cannot be less than from date");
                isValid = false;
                component.set("v.showResultAvailable",true);
            }
            else {
                endDateCmp.setCustomValidity("");
                component.set("v.showResultAvailable",false);
            }
            endDateCmp.reportValidity();  
        }
        return isValid;
    },
        doInitReplica : function(component, event, helper,param) {

            helper.buildDataWrapper(component, event ,helper);
            component.set('v.currentButtonVal' ,'All Patients' );
            component.set("v.loaded",false);
            var action = component.get("c.patientCardMethod");
            action.setParams({
                'buttonType' : param,
                'flagOnInit' : false
            });
            action.setCallback(component, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    component.set("v.loaded",true);
                    var data = response.getReturnValue();
                    component.set("v.PatientData",data.pat);
                    component.set("v.PatientDataCopy",JSON.parse(JSON.stringify(data.pat)));
                    component.set("v.totalAcc",data.TotalAcc);
                    component.set("v.totalAccReview",data.TotalAcc1);
                    component.set("v.totalAccCurrent",data.TotalAcc2);
                    component.set("v.totalAccDischarged",data.TotalAcc3);
                    var allData= data.pat;
                    component.set("v.totalPages", Math.ceil(allData.length/component.get("v.pageSize")));     
                    console.log('page'+component.get("v.totalPages"));
                    component.set("v.currentPageNumber",1);
                    helper.buildData(component, helper);
                    for(var recdata in allData){
                        var today = new Date();
                        var birthDate = new Date(allData[recdata].ElixirSuite__DOB__c);
                        var age = today.getFullYear() - birthDate.getFullYear();
                        var m = today.getMonth() - birthDate.getMonth();
                        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
                            age = age - 1;
                        }   
                        if (!isNaN(age)) {
                            allData[recdata].Contacts['Age']= age +' years';
                        }
                    }
                }
                else if (state === "ERROR") {
                    $A.log("callback error", state);
                }
            });
            var action2 = component.get("c.LicensBasdPermission");
            action2.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    var wrapList = response.getReturnValue();
                    component.set("v.Ehr",wrapList.isEhr);
                    component.set("v.Billing",wrapList.isRcm);
                    component.set("v.ContactCentr",wrapList.isContactCenter);
                }
            });
            $A.enqueueAction(action2);
            $A.enqueueAction(action);
        },
            flagNoRecordsForFilter : function(component, event, helper) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "NO RECORDS FOUND!",
                    "message": "No records present for the specified filter!",
                    "type" : "error"
                });
                toastEvent.fire();
            },
                validate_From_To_Values : function(component, event, helper) {
                    let isFilled = true;
                    if(!component.get("v.fromDate")){
                        isFilled = false;
                        let inputCmp = component.find("fromFilter"); 
                        inputCmp.setCustomValidity("Field required!"); 
                        inputCmp.reportValidity(); 
                    }
                    else {
                        let inputCmp = component.find("fromFilter"); 
                        inputCmp.setCustomValidity(""); 
                        inputCmp.reportValidity(); 
                    }




                    if(!component.get("v.toDate")){
                        isFilled = false;
                        let inputCmp_To = component.find("toFilter"); 
                        inputCmp_To.setCustomValidity("Field required!"); 
                        inputCmp_To.reportValidity(); 
                    }
                    else {
                        let inputCmp_To = component.find("toFilter"); 
                        inputCmp_To.setCustomValidity(""); 
                        inputCmp_To.reportValidity(); 
                    }
                    if(isFilled == false){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "PLEASE FILL REQUIERED FIELDS",
                            "message": "Fill required fields",
                            "type" : "error"
                        });
                        toastEvent.fire();
                    }
                    return isFilled;
                },
                    validateCombinedFilter : function(component, event, helper) {

                        let isFilled = true;

                        if(component.get("v.filterValue")){

                            /* let inputCmp = component.find("combinedFilterValidate"); 
            inputCmp.setCustomValidity(""); 
            inputCmp.reportValidity(); */
                        }
                        else {
                            isFilled = false;
                            /* 
            let inputCmp_combinedFilter = component.find("combinedFilterValidate"); 
            inputCmp_combinedFilter.setCustomValidity("Field requiered!"); 
            inputCmp_combinedFilter.reportValidity(); */
                        }
                        if(isFilled == false){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "PLEASE FILL VALUE FOR FILTER",
                                "message": "Fill required fields",
                                "type" : "error"
                            });
                            toastEvent.fire();
                        }
                        return isFilled;
                    },
                        validateData : function(component, event, helper) {
                            let isValid_1 = true;
                            let isValid_2 = true;
                            let isValid = true;
                            isValid_1 = helper.validate_From_To_Values(component, event, helper);
                            if(isValid_1){
                                isValid_2 = helper.validateCombinedFilter(component, event, helper);   
                            }

                            if(isValid_1 && isValid_2){
                                isValid = true;
                            }
                            else {
                                isValid =false;
                            }
                            return isValid;
                        },
                            fetchSerachResult : function(component, event, helper) {

                                console.log('isCombinedFilterUsed'+ component.get("v.isCombinedFilterUsed"));
                                console.log('doubleFilterValue'+ component.get("v.doubleFilterValue"));
                                console.log('filterValue'+ component.get("v.filterValue"));
                                console.log('isFilterByDateUsed'+ component.get("v.isFilterByDateUsed"));

                                component.set("v.loaded",false);
                                var action = component.get("c.filterForPatientTile");
                                action.setParams({
                                    fromDate: component.get("v.fromDate"),
                                    toDate : component.get("v.toDate"),
                                    isFilterByDateUsed:component.get("v.isFilterByDateUsed"),
                                    isCombinedFilterUsed : component.get("v.isCombinedFilterUsed"),
                                    doubleFilterValue : component.get("v.doubleFilterValue"),
                                    filterValue : component.get("v.filterValue"),
                                    filterByDate : component.get("v.filterByDate"),
                                });
                                action.setCallback(this, function(response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") {  
                                        component.set("v.loaded",true);
                                        console.log('resp JSON STRINGIFY '+JSON.stringify(response.getReturnValue().toReturnAllRecords));
                                        console.log('Query Found '+JSON.stringify(response.getReturnValue().query));
                                        if($A.util.isEmpty(response.getReturnValue().toReturnAllRecords)){
                                            helper.flagNoRecordsForFilter(component, event, helper);
                                            component.set("v.Patient_Name",[]);
                                            component.set("v.totalAcc",0);
                                            component.set("v.totalAccReview",0);
                                            component.set("v.totalAccCurrent",0);
                                            component.set("v.totalAccDischarged",0);
                                        }
                                        else {

                                            var data = response.getReturnValue();
                                            component.set("v.PatientData",data.toReturnAllRecords);
                                            component.set("v.PatientDataCopy",JSON.parse(JSON.stringify(data.toReturnAllRecords)));
                                            component.set("v.totalAcc",data.TotalAcc);
                                            component.set("v.totalAccReview",data.TotalAcc1);
                                            component.set("v.totalAccCurrent",data.TotalAcc2);
                                            component.set("v.totalAccDischarged",data.TotalAcc3);
                                            var allData= data.toReturnAllRecords;
                                            component.set("v.totalPages", Math.ceil(allData.length/component.get("v.pageSize")));     
                                            console.log('page'+component.get("v.totalPages"));
                                            component.set("v.currentPageNumber",1);
                                            helper.buildData(component, helper,data.apiLabelMap,data.apiLabelMapConfig,data.apiOrderMap);

                                            for(var recdata in allData){
                                                var today = new Date();
                                                var birthDate = new Date(allData[recdata].ElixirSuite__DOB__c);
                                                var age = today.getFullYear() - birthDate.getFullYear();
                                                var m = today.getMonth() - birthDate.getMonth();
                                                if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
                                                    age = age - 1;
                                                }   
                                                if (!isNaN(age)) {
                                                    allData[recdata].Contacts['Age']= age +' years';
                                                }
                                            }

                                        }
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
                            },
                                emptySearchAttributes:   function(component, event, helper) {
                                    component.set("v.filterByDate",''); 
                                    component.set("v.fromDate",''); 
                                    component.set("v.toDate",''); 
                                    component.set("v.doubleFilterValue",''); 
                                    component.set("v.filterValue",'');  
                                    component.set("v.isFilterByDateUsed",false); 
                                    component.set("v.isCombinedFilterUsed",false); 
                                    try{
                                        let inputCmp = component.find("fromFilter"); 
                                        inputCmp.setCustomValidity(""); 
                                        inputCmp.reportValidity(); 

                                        let inputCmp_To = component.find("toFilter"); 
                                        inputCmp_To.setCustomValidity(""); 
                                        inputCmp_To.reportValidity(); 
                                    }
                                    catch(e){
                                        console.log('Error '+JSON.stringify(e));
                                    }

                                },
                                    sortingNotification : function(component, event, helper,param) {
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            "title": "SORTED ON THE BASIS OF "+param+"!",
                                            "message": "Success!",
                                            "type" : "success"
                                        });
                                        toastEvent.fire();
                                    },
                                        falseCallback : function(component, event, helper,param) {
                                            component.set("v.loaded",false);
                                            var action = component.get("c.failingCallback");                                        
                                            action.setCallback(this, function(response) {
                                                var state = response.getState();
                                                if (state === "SUCCESS") {  
                                                    component.set("v.loaded",true);
                                                    helper.sortingNotification(component, event, helper,param);
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
                                        }

})