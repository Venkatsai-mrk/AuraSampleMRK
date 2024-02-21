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
    
    getFormExpiry: function(component, event, helper, selectedFormName) {
        return new Promise(function(resolve, reject) {
            console.log('From helper function', selectedFormName);
            var action = component.get('c.checkExpiry');
            action.setParams({
                'formName': selectedFormName
            });
            action.setCallback(this, function(response) {
               /* var state = response.getReturnValue();
                console.log('Form is expired?', state);
                resolve(state);*/
                var state = response.getState();
            if (state === 'SUCCESS') {
                var isExpired = response.getReturnValue();
                console.log('Form is expired?', isExpired);
                resolve(isExpired);
            } else {
                var errorMessage = 'Error occurred: ' + response.getError()[0].message;
                console.error(errorMessage);
                reject(errorMessage);
            }
            });
            $A.enqueueAction(action);
        });
    },

    getCustomFormsHelper : function(component, event, helper, actionType) {
        return new Promise(function(resolve, reject) {
           /* var flag = false;*/
            var action = component.get('c.getCustomForms');
            action.setParams({
                "actionType": actionType,
            });
            action.setCallback(this, function(response) {
                /*var state = response.getReturnValue();
                if(state.length>0){
                    component.set("v.customFormCmp", state);
                    flag = true;
                }
                console.log(JSON.stringify(state));
                resolve(flag);*/
                var state = response.getState();
            if (state === 'SUCCESS') {
                var customForms = response.getReturnValue();
                if (customForms.length > 0) {
                    component.set("v.customFormCmp", customForms);
                }
                console.log(JSON.stringify(customForms));
                resolve(customForms);
            } else {
                var errorMessage = 'Error occurred: ' + response.getError()[0].message;
                console.error(errorMessage);
                reject(errorMessage);
            }
            });
            $A.enqueueAction(action);
        });
    },

    
    initFunctionMovedToHelper : function(component, event, helper,actionbuttons) {
        var columns = event.getParam("columns");
        const displayIcons = {"1" : "displayIconName1",
                              "2" : "displayIconName2",
                              "3" : "displayIconName3",
                              "4" : "displayIconName4", 
                              "5" : "displayIconName5"};
        const showClasses = {"1" : "showClass1",
                             "2" : "showClass2",
                             "3" : "showClass3",
                             "4" : "showClass4", 
                             "5" : "showClass5"};
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
            }
            else{
                console.log("failure" , response.getError());
            }
        });
        $A.enqueueAction(action2);
        component.set('v.todayString', new Date().toISOString());
        var recId = component.get("v.recordVal");
        var actions = [
            {label: 'Edit', name: 'EDIT' ,disabled:actionbuttons},
            {label: 'Delete', name: 'DELETE',disabled:actionbuttons},
            {label: 'Clone', name: 'CLONE',disabled:actionbuttons}
        ];
       /* var nameSpace = '' ; */
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
                "label": "Care Episode",
                "fieldName": 'careEpisode',
                "type": 'button', "typeAttributes":
                { "label": { "fieldName": 'careEpisodeName'}, "title": 'Click to edit Care Episode', 
                "variant":'base', 
                "name": 'edit_care', 
                "iconName": 'utility:edit', 
                "class": 'slds-align_absolute-center'}
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
        var dateOfCreation = { label: 'Created Date', fieldName: 'CreatedDate', type: 'date',typeAttributes: {  
            day: 'numeric',  
            month: 'short',  
            year: 'numeric',  
            hour: '2-digit',  
            minute: '2-digit',  
            second: '2-digit',  
            hour12: true}
                             };
        var actionToShow = { fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } };
        var columnsToShow = [];
        if(!$A.util.isUndefinedOrNull(columns)){
            tableColumns.forEach(function(column){ 
                if(columns.includes(column.fieldName)){
                    columnsToShow.push(column);
                }        
            });

            // setting dynamic columns before last 2 columns
            helper.setDynamicColumns(component, event, helper, -2);
            columnsToShow = [nameOfForm,...columnsToShow,dateOfCreation,actionToShow];
            component.set('v.mycolumns',columnsToShow); 
        }
        var action = component.get("c.bringData");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        console.log('after spinner'+ component.get("v.categorized")+'-->'+ component.get("v.subCategorized"));
        action.setParams({  
            accountId : component.get("v.recordVal"),
            category : component.get("v.categorized"),
             subCategory : component.get("v.subCategorized")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
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

                            // setting dynamic columns before last 2 columns
                            helper.setDynamicColumns(component, event, helper, -2);
                            columnsToShow = [nameOfForm,...columnsToShow,dateOfCreation,actionToShow];
                        }
                        catch(e){
                            // setting dynamic columns before last 2 columns
                            helper.setDynamicColumns(component, event, helper, -2);
                            columnsToShow = [nameOfForm, dateOfCreation, actionToShow];
                        }
                        console.log('columns '+columnsToShow);
                        component.set('v.mycolumns',columnsToShow); 
                    }
                    // Will hide spinner in callback of setDynamicColumnsData()
                    // component.find("Id_spinner").set("v.class" , 'slds-hide');
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
                                let classToShow = showClasses[level];
                                console.log('classToShow' +classToShow);
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
                                let classToShow = showClasses[level];
                                console.log('classToShow' +classToShow);
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
                    // setDynamicColumnsData merges static columns data with dynamic column data
                    // so calling it once static columns are set
                    helper.setDynamicColumnsData(component, event, helper);
                    component.set("v.editScreen",false); 
                    component.set("v.cloneScreen",false); 
                                    }
                catch(e){
                    alert(e);
                }
               
            }else{
                component.find("Id_spinner").set("v.class" , 'slds-show'); 
                console.log("failure");
            }
        });
        $A.enqueueAction(action);
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

     setDynamicColumns: function(component, event, helper, insertDynamicColumnsAtIndex) {
        let action = component.get("c.queryDynamicFormColumns");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let currentColumns = component.get("v.mycolumns");
                
                let dynamicColumns = [];
                let uniqueFieldNames = new Set();
                response.getReturnValue().forEach((i) => {
                    // Add any formatting attributes here
                    let column = i;

                    // using api_name + data_type as uniqueness as two fields with same api may have different data type
                    // and data with different type will fail to render properly in same column 
                    if (uniqueFieldNames.has(column.fieldName + column.type)) {
                        return;
                    }
                    else {
                        uniqueFieldNames.add(column.fieldName + column.type);
                    }

                    if (column.type === "date") {
                        column["typeAttributes"] = {"day":"numeric", "month":"short", "year":"numeric"};
                        
                    }
                    if (column.type == "date-time") {
                        // data table uses 'date' for date-time data too
                        column.type = "date";
                        column["typeAttributes"] = {"day":"numeric", "month":"short", "year":"numeric", "hour":"2-digit", "minute":"2-digit", "hour12":"true"}
                    }

                    dynamicColumns.push(column);

                });

                currentColumns.splice(insertDynamicColumnsAtIndex, 0, ...dynamicColumns);
                console.log(currentColumns);

                component.set("v.mycolumns", currentColumns);
            }
            else if (state === "INCOMPLETE") {
                console.log(`Failed to query dynamic columns. reason- state is INCOMPLETE`)
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Failed to query dynamic columns. Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    setDynamicColumnsData: function(component, event, helper) {
        console.log('setDynamicColumnsData');
        let action = component.get("c.queryDynamicFormColumnData");

        action.setParams({
            accountId : component.get("v.recordVal")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                let dynamicColumnsData = response.getReturnValue();
                let currentListDetails = component.get('v.listDetails');
                let mergedListDetails = [];
                for (let listItem of currentListDetails) {
                    // merge all properties of dynamicColumnData in listItem with same form unique id
                    // any duplicate properties of dynamicColumnData will be overidden by original listItem. 
                    let dynamicColumnDataWithSameFormId = dynamicColumnsData[listItem.formId];
                    
                    if (!dynamicColumnDataWithSameFormId) {
                        mergedListDetails.push(listItem);
                    }
                    else {
                        Object.assign(dynamicColumnDataWithSameFormId, listItem);

                        mergedListDetails.push(dynamicColumnDataWithSameFormId);
                    }
                }   

                component.set("v.listDetails", mergedListDetails);
                component.find("Id_spinner").set("v.class" , 'slds-hide');
            }
            else if (state === "INCOMPLETE") {
                console.log(`Failed query dynamic column data. reason- state is INCOMPLETE`)
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Failed query dynamic column data. Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);


    }


})