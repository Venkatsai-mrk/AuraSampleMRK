({
    doInit : function(component, event, helper) {
        if(event.getSource().get("v.name") == 'All Patients'){
            component.set("v.cssClass_AllPatients",'elemtRed'); 
            component.set("v.cssClass_PatientsInReview",''); 
            component.set("v.cssClass_CurrentPatients",''); 
            component.set("v.cssClass_DischargedPatients",''); 
            component.set("v.AdmitDate_Order",'DEF');
            component.set("v.DischargeDate_Order",'DEF');
        }
        helper.buildDataWrapper(component, event ,helper);
        helper.emptySearchAttributes(component, event ,helper);
        component.set('v.currentButtonVal' ,'All Patients' );
        component.set('v.enableDateSearchFilter' ,true);
        component.set('v.AdmitDate_Order' ,'DEF');
        component.set('v.DischargeDate_Order' ,'DEF');
        var action = component.get("c.patientCardMethod");
        action.setParams({
            'buttonType' : 'All Patients',
            'flagOnInit' : true
        });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                try{
                    component.set("v.loaded",true);
                    var data = response.getReturnValue();
                    component.set("v.initResponseData",JSON.parse(JSON.stringify(data)));
                    component.set("v.PatientData",data.pat);
                    component.set("v.PatientDataCopy",JSON.parse(JSON.stringify(data.pat)));
                    component.set("v.totalAcc",data.TotalAcc);
                    component.set("v.totalAccReview",data.TotalAcc1);
                    component.set("v.totalAccCurrent",data.TotalAcc2);
                    component.set("v.totalAccDischarged",data.TotalAcc3);
                     component.set("v.isProfilePicAllowed",data.isProfilePicAllowed); 

                    let loopArr = data.fieldsArr;
                    let arr = [];
                    for(let rec in loopArr){
                        arr.push({'label':loopArr[rec].ElixirSuite__Field_Label_Long__c,
                                  'api' : loopArr[rec].ElixirSuite__Field_Api__c});
                    }

                    console.log('root '+JSON.stringify(arr));
                    component.set("v.fieldsArr",arr);
                    var allData= data.pat;
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
                        //    allData[recdata]['Contacts']['Age']= age +' years';
                        }
                    }
                }
                catch(e){
                    alert(e);
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
    accDetails : function(component, event) {
        var AccId =event.getSource().get("v.value");

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/r/Account/"+AccId+"/view"
        });
        urlEvent.fire();
    },
    onNext : function(component, event, helper) {      
        let data = component.get("v.initResponseData");
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        component.set("v.AdmitDate_Order",'DEF');
        component.set("v.DischargeDate_Order",'DEF');
        helper.buildData(component, helper,data.apiLabelMap,data.apiLabelMapConfig,data.apiOrderMap);
    },

    onPrev : function(component, event, helper) {   
        let data = component.get("v.initResponseData");
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        component.set("v.AdmitDate_Order",'DEF');
        component.set("v.DischargeDate_Order",'DEF');
        helper.buildData(component, helper,data.apiLabelMap,data.apiLabelMapConfig,data.apiOrderMap);
    },

    processMe : function(component, event, helper) {
        let data = component.get("v.initResponseData");
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component, helper,data.apiLabelMap,data.apiLabelMapConfig,data.apiOrderMap);
    },

    onFirst : function(component, event, helper) {   
        let data = component.get("v.initResponseData");
        component.set("v.currentPageNumber", 1);
        component.set("v.AdmitDate_Order",'DEF');
        component.set("v.DischargeDate_Order",'DEF');
        helper.buildData(component, helper,data.apiLabelMap,data.apiLabelMapConfig,data.apiOrderMap);
    },

    onLast : function(component, event, helper) {      
        let data = component.get("v.initResponseData");
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        component.set("v.AdmitDate_Order",'DEF');
        component.set("v.DischargeDate_Order",'DEF');
        helper.buildData(component, helper,data.apiLabelMap,data.apiLabelMapConfig,data.apiOrderMap);
    },
    handleClickButtonReview: function(component, event,helper) {
        let data = component.get("v.initResponseData");
        helper.setButtonColorForPatientsInReview(component, event,helper);
        component.set("v.AdmitDate_Order",'DEF');
        component.set("v.DischargeDate_Order",'DEF');
        var butType = event.getSource().get("v.name");
        component.set('v.currentButtonVal' ,butType );
        var action = component.get("c.patientCardMethod");
        action.setParams({
            "buttonType" : butType
        });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var data = response.getReturnValue();
                console.log('data is person card ', data.pat1);
                component.set("v.PatientData",data.pat1);
                component.set("v.PatientDataCopy",JSON.parse(JSON.stringify(data.pat1))); 
                var allData= data.pat1;
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
            else if (state === "ERROR") {
                $A.log("callback error", state);
            }
        });
        $A.enqueueAction(action);
    },

    handleClickButtonCurrent: function(component, event,helper) {
        let data = component.get("v.initResponseData");
        helper.setButtonColorForCurrentPatients(component, event,helper);
        component.set("v.AdmitDate_Order",'DEF');
        component.set("v.DischargeDate_Order",'DEF');
        var butType = event.getSource().get("v.name");
        component.set('v.currentButtonVal' ,butType );
        var action = component.get("c.patientCardMethod");
        action.setParams({
            "buttonType" : butType
        });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var data = response.getReturnValue();

                console.log('data is person card ', data.pat2);
                component.set("v.PatientData",data.pat2);
                component.set("v.PatientDataCopy",JSON.parse(JSON.stringify(data.pat2)));
                var allData= data.pat2;
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
                       // allData[recdata].Contacts['Age']= age +' years';
                    }
                }
            }
            else if (state === "ERROR") {
                $A.log("callback error", state);
            }
        });
        $A.enqueueAction(action);
    },

    handleClickButtonDischarged: function(component, event,helper) {
        let data = component.get("v.initResponseData");
        helper.setButtonColorForDischargedPatients(component, event,helper);
        component.set("v.AdmitDate_Order",'DEF');
        component.set("v.DischargeDate_Order",'DEF');
        var butType = event.getSource().get("v.name");
        component.set('v.currentButtonVal' ,butType );
        var action = component.get("c.patientCardMethod");
        action.setParams({
            "buttonType" : butType
        });
        action.setCallback(component, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS"){
                var data = response.getReturnValue();

                console.log('data is person card ', data.pat3);
                component.set("v.PatientData",data.pat3);
                component.set("v.PatientDataCopy",JSON.parse(JSON.stringify(data.pat3)));
                var allData= data.pat3;
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
            else if (state === "ERROR") {
                $A.log("callback error", state);
            }
        });
        $A.enqueueAction(action);
    },

    searchKeyChange: function(component, event,helper) {
        try{
            let data = component.get("v.initResponseData");
            var searchKey = component.find("searchKey").get("v.value");
            console.log('searchKey:::::'+searchKey);
            var allData = JSON.parse(JSON.stringify(component.get("v.PatientDataCopy")));
            var fillData = allData.filter(function(dat) {
                return (dat['Name'].toLowerCase()).startsWith(searchKey.toLowerCase());
            });
            component.set("v.PatientData", fillData);
            console.log('455'+component.get("v.PatientData"));
            component.set("v.totalPages", Math.ceil(fillData.length/component.get("v.pageSize")));     
            console.log('page'+component.get("v.totalPages"));
            component.set("v.currentPageNumber",1);
            helper.buildData(component, helper,data.apiLabelMap,data.apiLabelMapConfig,data.apiOrderMap);
            for(var recdata in fillData){
                var today = new Date();
                var birthDate = new Date(fillData[recdata].ElixirSuite__DOB__c);
                var age = today.getFullYear() - birthDate.getFullYear();
                var m = today.getMonth() - birthDate.getMonth();
                if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
                    age = age - 1;
                }   

                if (!$A.util.isUndefinedOrNull(age)) {
                    fillData[recdata].Contacts['Age']= age;
                }
            }
        }
        catch(e){

        }

        /*  var action = component.get("c.getSearchAccount");
        action.setParams({
            "searchKey": searchKey,
            'currentVal':  component.get('v.currentButtonVal')
        });
        action.setCallback(this, function(a) {
            
            var allData=  a.getReturnValue();
            console.log('123 '+allData);     
            console.log('455'+component.get("v.PatientData"));
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
                    allData[recdata].Contacts['Age']= age;
                }
            }
            
        });
        $A.enqueueAction(action);*/
    },
    navLead : function(component, event, helper) {        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/o/Lead/list"
        });
        urlEvent.fire();
    },
    navAccount : function(component, event, helper) {        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/o/Account/list"
        });
        urlEvent.fire();
    },
    dateFilter :  function(component, event, helper) {
        if(event.getSource().get("v.value")){
            component.set("v.enableDateSearchFilter",false); 
            component.set("v.isFilterByDateUsed",true); 
            component.set("v.showResultAvailable",false);  
        }
        else {
            component.set("v.fromDate",'');
            component.set("v.toDate",'');
            component.set("v.enableDateSearchFilter",true);
            component.set("v.isFilterByDateUsed",false);
            if(component.get("v.isCombinedFilterUsed")){

            }
            else {
                component.set("v.showResultAvailable",true);  
            }
        }
    },
    parentFilter : function(component, event, helper) { 
        component.set("v.filterValue",'');
        let val = event.getSource().get("v.value");  
        let filterByToFilterMap = component.get("v.filterByToFilterMap");
        let searchMap = component.get("v.searchMap"); 

        if(event.getSource().get("v.value")){
            component.set("v.isCombinedFilterUsed",true); 
            component.set("v.showResultAvailable",false);  
        }
        else {
            component.set("v.isCombinedFilterUsed",false);
            if(component.get("v.isFilterByDateUsed")){

            }
            else {
                component.set("v.showResultAvailable",true);  
            }
        }
        if(event.getSource().get("v.value")){
            if(filterByToFilterMap[val]){
                if(searchMap[val]){
                    component.set("v.searchOrDropdownSwap",false);  
                }
                else {
                    component.set("v.searchOrDropdownSwap",true);  
                    component.set("v.FilterChildOptions",filterByToFilterMap[val]); 
                }
            }
            else {
                component.set("v.searchOrDropdownSwap",true);  
                component.set("v.loaded",false);
                component.set("v.doubleFilterValue",val); 
                var action = component.get("c.serachResultForFilter");
                action.setParams({
                    key: val
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {  
                        component.set("v.loaded",true);
                        console.log('JSON STRINGIFY '+JSON.stringify(response.getReturnValue()));
                        let resp = response.getReturnValue();
                        let arr = [];
                        if(val=='Level Of Care'){
                            for(let rec in resp){
                                arr.push({'label':resp[rec].ElixirSuite__Program_Name__c,'value' : resp[rec].Id});
                            }   
                        }
                        else{
                            for(let rec in resp){
                                arr.push({'label':resp[rec].Name,'value' : resp[rec].Id});
                            }
                        }
                        component.set("v.FilterChildOptions",arr); 
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
        }
    },
    sortByAdmitDate : function(component, event, helper) { 
        if(component.get("v.AdmitDate_Order") == 'DEF'){  // SORT IN ASC
            function custom_sort(a, b) {
                return new Date(a.ElixirSuite__Admit_Date__c).getTime() - new Date(b.ElixirSuite__Admit_Date__c).getTime();
            }
            let validRecords = [];
            let invalidRecords = [];
            var arr = component.get("v.Patient_Name");       
            arr.forEach(function(element, index) {
                if(element.hasOwnProperty('ElixirSuite__Admit_Date__c')){
                    validRecords.push(element);
                }
                else {
                    invalidRecords.push(element); 
                }
            });  
            validRecords.sort(custom_sort);
            validRecords = validRecords.concat(invalidRecords);
            component.set("v.Patient_Name",validRecords);
            component.set("v.AdmitDate_Order",'ASC');
        }

        else if(component.get("v.AdmitDate_Order") == 'ASC'){
            component.set("v.AdmitDate_Order",'DSC');  
            var arr = component.get("v.Patient_Name");  
            let validRecords = [];
            let invalidRecords = [];

            arr.forEach(function(element, index) {
                if(element.hasOwnProperty('ElixirSuite__Admit_Date__c')){
                    validRecords.push(element);
                }
                else {
                    invalidRecords.push(element); 
                }
            });
            validRecords.reverse();
            validRecords = validRecords.concat(invalidRecords);
            component.set("v.Patient_Name",validRecords);
        }
            else if(component.get("v.AdmitDate_Order") == 'DSC'){
                function custom_sort(a, b) {
                    return new Date(a.ElixirSuite__Admit_Date__c).getTime() - new Date(b.ElixirSuite__Admit_Date__c).getTime();
                }
                var arr = component.get("v.Patient_Name");  
                let validRecords = [];
                let invalidRecords = [];

                arr.forEach(function(element, index) {
                    if(element.hasOwnProperty('ElixirSuite__Admit_Date__c')){
                        validRecords.push(element);
                    }
                    else {
                        invalidRecords.push(element); 
                    }
                });
                validRecords.sort(custom_sort);
                validRecords = validRecords.concat(invalidRecords);
                component.set("v.Patient_Name",validRecords);
                component.set("v.AdmitDate_Order",'ASC');
            }
        component.set("v.DischargeDate_Order",'DEF');
        helper.falseCallback(component, event, helper,'ADMIT DATE'); 

    },
    sortByDischargeDate : function(component, event, helper) { 
        if(component.get("v.DischargeDate_Order") == 'DEF'){  // SORT IN ASC
            function custom_sort(a, b) {
                return new Date(a.ElixirSuite__dischargeDateNew__c).getTime() - new Date(b.ElixirSuite__dischargeDateNew__c).getTime();
            }
            var arr = component.get("v.Patient_Name");  
            let validRecords = [];
            let invalidRecords = [];

            arr.forEach(function(element, index) {
                if(element.hasOwnProperty('ElixirSuite__dischargeDateNew__c')){
                    validRecords.push(element);
                }
                else {
                    invalidRecords.push(element); 
                }
            });

            validRecords.sort(custom_sort);
            validRecords = validRecords.concat(invalidRecords);
            component.set("v.Patient_Name",validRecords);
            component.set("v.DischargeDate_Order",'ASC');
        }
        else if(component.get("v.DischargeDate_Order") == 'ASC'){
            component.set("v.DischargeDate_Order",'DSC');  
            var arr = component.get("v.Patient_Name");  
            let validRecords = [];
            let invalidRecords = [];

            arr.forEach(function(element, index) {
                if(element.hasOwnProperty('ElixirSuite__dischargeDateNew__c')){
                    validRecords.push(element);
                }
                else {
                    invalidRecords.push(element); 
                }
            });

            validRecords.reverse();
            validRecords = validRecords.concat(invalidRecords);


            component.set("v.Patient_Name",validRecords);
        }
            else if(component.get("v.DischargeDate_Order") == 'DSC'){
                function custom_sort(a, b) {
                    return new Date(a.ElixirSuite__dischargeDateNew__c).getTime() - new Date(b.ElixirSuite__dischargeDateNew__c).getTime();
                }
                var arr = component.get("v.Patient_Name");    
                let validRecords = [];
                let invalidRecords = [];

                arr.forEach(function(element, index) {
                    if(element.hasOwnProperty('ElixirSuite__dischargeDateNew__c')){
                        validRecords.push(element);
                    }
                    else {
                        invalidRecords.push(element); 
                    }
                });

                validRecords.sort(custom_sort);
                validRecords = validRecords.concat(invalidRecords);
                component.set("v.Patient_Name",validRecords);
                component.set("v.DischargeDate_Order",'ASC');
            }
        component.set("v.AdmitDate_Order",'DEF');
        helper.falseCallback(component, event, helper,'DISCHARGE DATE'); 
    },
    fetchData_Combined : function(component, event, helper) { 

        if(component.get("v.isFilterByDateUsed") && component.get("v.isCombinedFilterUsed")){
            if(helper.validateData(component,event,helper)){
                helper.fetchSerachResult(component,event,helper); 
            }
        }
        else {
            if(component.get("v.isFilterByDateUsed")){
                if(helper.validate_From_To_Values(component,event,helper)){
                    helper.fetchSerachResult(component,event,helper); 
                } 
            }
            else if(component.get("v.isCombinedFilterUsed")){
                try{
                    if(helper.validateCombinedFilter(component,event,helper)){
                        helper.fetchSerachResult(component,event,helper); 
                    }
                }
                catch(e){
                    alert('error '+e);
                }
            } 
        }


    },
    checkValidity_FromDate : function(component, event, helper) { 
        helper.checkToDateValidity(component, event, helper);
    },
    clearAllFilter : function(component, event, helper) { 

       
    }
   
})