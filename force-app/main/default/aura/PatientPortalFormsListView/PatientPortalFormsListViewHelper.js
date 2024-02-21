({
   
    deleteSelectedHelper: function(component, event, helper, selectedIds) {
        
        var action = component.get( 'c.deleteAllForms' );
        action.setParams({
            "lstRecordId": selectedIds,
        });
        console.log("****Id****",selectedIds);
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                /*var actionbuttons=false;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Deletion Successful!",
                    "message": "Form has been successfully deleted"
                });
                toastEvent.fire();
                helper.initFunctionMovedToHelper(component, event, helper,actionbuttons);
                */
                console.log('delete status',response.getReturnValue());
                var status = response.getReturnValue();
                //nithin
                if(status.formValue == true){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Warning",
                        "title": "Error Message",
                        "message": "You cannot delete this Forms/Notes. Please contact your administrator "
                    });
                    toastEvent.fire();
                }
                else{
                    var actionbuttons=false;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "title": "Deletion Successful!",
                        "message": "Form is successfully deleted"
                    });
                    toastEvent.fire();
                    helper.initFunctionMovedToHelper(component, event, helper,actionbuttons);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
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
    
    getCustomFormsHelper : function(component, event, helper, actionType) {
        return new Promise(function(resolve) {
            var flag = false;
            var action = component.get('c.getCustomForms');
            action.setParams({
                "actionType": actionType,
            });
            action.setCallback(this, function(response) {
                var state = response.getReturnValue();
                if(!$A.util.isEmpty(state)){
                    component.set("v.customFormCmp", state);
                    flag = true;
                }
                console.log('Data from ===',JSON.stringify(state));
                resolve(flag);
            });
            $A.enqueueAction(action);
        });
    },
    
    initFunctionMovedToHelper : function(component, event, helper) {
        var columns = event.getParam("columns");
        const displayIcons = {"1" : "displayIconName1",
                              "2" : "displayIconName2",
                              "3" : "displayIconName3",
                              "4" : "displayIconName4", 
                              "5" : "displayIconName5"};
        const showContent = {"1" : "content1",
                             "2" : "content2",
                             "3" : "content3",
                             "4" : "content4", 
                             "5" : "content5"};
        var action2 = component.get("c.fetchAllForms");
        action2.setParams({
            "category": component.get("v.categorized"),
            "subCategory": '',
            "accountId": component.get("v.recordVal")
        });
        console.log(component.get("v.categorized")+'category');
        action2.setCallback(this, function(response) {

            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.accName",data.accName);
                component.set("v.sendFormsAbility",data.isSendPortalButtonEnabled); 
                var action = component.get("c.bringDataForpatientPortalUser");
                component.find("Id_spinner").set("v.class" , 'slds-show');
                console.log('after spinner'+  component.get("v.recordVal")+'-->'+ component.get("v.subCategorized"));
                action.setParams({  
                    accountId : component.get("v.recordVal"),
                    category : component.get("v.categorized"),
                    subCategory : component.get("v.subCategorized")
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var res = response.getReturnValue();
                        if($A.util.isUndefinedOrNull(columns)){
                            // Bring dynamic columns here
                            let receivedColumns = [];
                            console.log('hjkl'+JSON.stringify(res[0]));
                            try{
                                receivedColumns = res[0]['columns'];
                                tableColumns.forEach(function(column){ 
                                    if(receivedColumns.includes(column.fieldName)){
                                        columnsToShow.push(column);
                                    }        
                                });
                                columnsToShow = [nameOfForm,...columnsToShow,dateOfCreation,actionToShow];
                            }
                            catch(e){
                                columnsToShow = [nameOfForm, dateOfCreation, actionToShow];
                            }
                            console.log('columns '+columnsToShow);
                           // component.set('v.mycolumns',columnsToShow); 
                        }
                        component.find("Id_spinner").set("v.class" , 'slds-hide');
                        console.log('accountId' +recId);
                        console.log("success");      
                        res.forEach(function(record){ 
                            if(record['status'] == 'Open'){
                                record.showClass = 'redcolor';
                            }else if(record['status'] == 'In Progress'){
                                record.showClass = 'bluecolor';  
                            }else if(record['status'] == 'Completed') {
                                record.showClass = 'greencolor';    
                            }
                            
                            let approvedLevelsCount = record.approvedLevelsCount;
                            let defaultLevelCount = record.defaultLevelCount;
                            console.log('defaultLevelCount '+defaultLevelCount);
                            console.log('approvedValues '+approvedLevelsCount);
                            if(approvedLevelsCount == 0 && record.status == 'Completed'){
                                for(let level=1;level<6;level++){
                                    let iconName = displayIcons[level];
                                    let content = showContent[level];
                                    if(level<=defaultLevelCount){
                                        record[iconName] = "utility:check";
                                    }else{
                                        record[content] = "NA";
                                    }
                                }
                            }else{
                                for(let level=1;level<6;level++){
                                    let iconName = displayIcons[level];
                                    let content = showContent[level];
                                    if(level<=approvedLevelsCount){
                                        record[iconName] = "utility:check";
                                    }else if(level<=defaultLevelCount){
                                        record[iconName] = "utility:close";
                                    }else{
                                        record[content] = "NA";
                                    }
                                }
                            }
                        });
                        var sortedRes = this.listDataSorting(res);
                        console.log('c2' +JSON.stringify(sortedRes));
                        var customCategory = component.get("v.customCategory");
                        if(!$A.util.isEmpty(customCategory)){
                            sortedRes =  helper.filterByCategoryIfrequiered(component, event, helper,sortedRes,customCategory);
                        }
                       
                        component.set("v.listDetails", sortedRes);
                        component.set("v.editScreen",false); 
                        component.set("v.cloneScreen",false); 
                    }else{
                        component.find("Id_spinner").set("v.class" , 'slds-show'); 
                        console.log("failure");
                    }
                });
                $A.enqueueAction(action);
            }
            else{
                console.log("failure" , response.getError());
            }
        });
        $A.enqueueAction(action2);
        component.set('v.todayString', new Date().toISOString());
        var recId = component.get("v.recordVal");
        var actions = [
            {label: 'Submit to Provider', name: 'STP',disabled:false},
        ];
        const tableColumns = [
            {
                label: 'Note Name',
                fieldName: 'formName',
                type: 'button' ,typeAttributes:  {label: { fieldName: 'formName' }, target: '_blank' , name: 'recLink',variant:'Base' }
            },
            {
                "label": "Category",
                "fieldName": 'formCategory',
                "type": "picklist"
            },
            {
                "label": "Status",
                "fieldName": 'status',
                "type": "String",
                "cellAttributes": {
                    "class": {
                        "fieldName": "showClass1"
                    }
                }
            },
            {
                "label": "Created By",
                "fieldName": "CreatedBy",
                "type": "Text"
                
            },
            {
                "label": "Approval Level 1",          
                "fieldName" : "content1",     
                "cellAttributes": {
                    "class": {
                        "fieldName": "showClass1"
                    },
                    "iconName": {
                        "fieldName": "displayIconName1"
                    }
                }
            },
            {
                "label": "Approval Level 2",   
                "fieldName" : "content2",                
                "cellAttributes": {
                    "class": {
                        "fieldName": "showClass2"
                    },
                    "iconName": {
                        "fieldName": "displayIconName2"
                    }
                }
            },
            {
                "label": "Approval Level 3",        
                "fieldName" : "content3",           
                "cellAttributes": {
                    "class": {
                        "fieldName": "showClass3"
                    },
                    "iconName": {
                        "fieldName": "displayIconName3"
                    }
                }
            },
            {
                "label": "Approval Level 4",      
                "fieldName" : "content4",             
                "cellAttributes": {
                    "class": {
                        "fieldName": "showClass4"
                    },
                    "iconName": {
                        "fieldName": "displayIconName4"
                    }
                }
            },
            {
                "label": "Approval Level 5", 
                "fieldName" : "content5",                  
                "cellAttributes": {
                    "class": {
                        "fieldName": "showClass5"
                    },
                    "iconName": {
                        "fieldName": "displayIconName5"
                    }
                }
            },
            { label: 'Created Date', fieldName: 'CreatedDate', type: 'date',typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric',  
                hour: '2-digit',  
                minute: '2-digit',  
                second: '2-digit',  
                hour12: true}}   
        ];
        var nameOfForm =   {
            label: 'Note Name',
            fieldName: 'formName',
            type: 'button' ,typeAttributes:  {label: { fieldName: 'formName' }, target: '_blank' , name: 'recLink',variant:'Base' }
        };
        var dateOfCreation = { label: 'Last Modified Date', fieldName: 'CreatedDate', type: 'date',typeAttributes: {  
            day: 'numeric',  
            month: 'short',  
            year: 'numeric',  
            hour: '2-digit',  
            minute: '2-digit',  
            second: '2-digit',  
            hour12: true}
                             };
        var actionToShow = { fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } };
        var columnsToShow = [
            {
                label: 'Note Name',
                fieldName: 'formName',
                type: 'button' ,typeAttributes:  {label: { fieldName: 'formName' }, target: '_blank' , name: 'recLink',variant:'Base' }
            },
            {
                label: 'Category',
                fieldName: 'formCategory',
                
            },
            {
                label: 'Status',
                fieldName: 'status',
                
            },
            { label: 'Last Modified Date', fieldName: 'CreatedDate', type: 'date',typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric',  
                hour: '2-digit',  
                minute: '2-digit',  
                second: '2-digit',  
                hour12: true}
                                 },
            //{ fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } }
        ];
        component.set('v.mycolumns',columnsToShow); 
       
      
    },
    filterByCategoryIfrequiered: function(component, event, helper,sortedRes,customCategory){
        var filteredForms = [];
        sortedRes.forEach(function(element) {
            if(customCategory.includes(element.formCategory)){
                filteredForms.push(element);
            }           
        });
        return filteredForms;
    },
    listDataSorting : function(response) {
        var fname = 'CreatedDate';
         var sortDirection ='desc';
        // var reverse = sortDirection !== 'asc';
       // const lowercase = (x) => (x+'').toLowerCase();
        return (response.sort((this.sortBy(fname, sortDirection === 'asc' ? 1 : -1))));
     },
    
     sortBy: function(field, reverse, primer) {
         console.log('Primer '+ primer);
         var key = primer
             ? function(x) {
                 return primer(x[field]);
             }  
         : function(x) {
             return x[field];
             };
         return function(a, b) {
             a = key(a);
             b = key(b);
             return reverse * ((a > b) - (b > a));
         };
     },
  
     submitFormToProvider: function(component, event, helper,formUniqueID,formName){
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.submitFormToEHRFromPortal");
        console.log('formUniqueID while submit to provider action'+formUniqueID);
        console.log('formName while submit to provider action '+formName);
        action.setParams({ formUniqueID :formUniqueID, formName : formName});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state '+state);
            var result = response.getReturnValue();
            console.log('result '+result);
            if (state === "SUCCESS") {
                if(result==false){
                    console.log('result is false '+result);
                    component.find("Id_spinner").set("v.class" , 'slds-hide');  
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Form sucessfully submitted to provider!", 
                        "message": " ",
                        "type" : "success"
                    });
                    toastEvent.fire();
                    helper.initFunctionMovedToHelper(component, event, helper,false); 
                }
                else{
                    component.find("Id_spinner").set("v.class" , 'slds-hide');  
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Signature requiered before submitting to provider!",
                        "message": "Please sign the form before you submit it to provider.",
                        "type" : "error"
                    });
                    toastEvent.fire();
                    helper.initFunctionMovedToHelper(component, event, helper,false); 
                }
                 
            }
            else {
                console.log("failure for submitFormToProvider");
            }
        });
        $A.enqueueAction(action);
    },
    submitSelectedFormsToProviders: function(component, event, helper,formattedSelectedRows){
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.submitSelectedFormsToEHRFromPortal");
        action.setParams({ wrappedData: formattedSelectedRows});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state '+state);
            var result = response.getReturnValue();
            console.log('result '+result);
            if (state === "SUCCESS") {
                    console.log('result is false '+result);
                    component.find("Id_spinner").set("v.class" , 'slds-hide');  
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Form sucessfully submitted to provider!", 
                        "message": " ",
                        "type" : "success"
                    });
                    toastEvent.fire();
                    helper.initFunctionMovedToHelper(component, event, helper,false); 
                 
            }
            else {
                console.log("failure for submitFormToProvider");
            }
        });
        $A.enqueueAction(action);
    }

})