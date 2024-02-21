({
    deleteSelectedHelper: function(component, event, helper, selectedIds) {
        
        var action = component.get( 'c.deleteAllForms' );
        component.find("Id_spinner").set("v.class" , 'slds-hide');
        action.setParams({
            "lstRecordId": selectedIds,
        });
        console.log("****Id****",selectedIds);
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                var actionbuttons=false;
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "RECORD DELETED SUCCESSFULLY",
                    "message": "Deletion Successfull."
                });
                toastEvent.fire();
                helper.initFunctionMovedToHelper(component, event, helper,actionbuttons);
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
    initFunctionMovedToHelper : function(component, event, helper,actionbuttons) {
        
        var action2 = component.get("c.fetchAllForms");
        action2.setParams({
            "category": '',
            "subCategory": '',
            "accountId": component.get("v.recordVal")
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                
                var data = response.getReturnValue();
                console.log('1st response '+JSON.stringify(component.get('v.recordVal')));
                component.set("v.accName",data);
                component.set('v.todayString', new Date().toISOString());
                var dataMap = {};
                component.set("v.parentSelectedValues",dataMap);
                var inputDataMap = {};
                component.set("v.inputSelectedValues",inputDataMap);
                var inputTextAreadataMap = {};
                component.set("v.inputTextAreaSelectedValues",inputTextAreadataMap);
                var inputDateTimedataMap = {};
                component.set("v.inputDateTimeselectedValues",inputDateTimedataMap);
                component.set("v.nameSpace" , data.nameSpace);
                var recId = component.get("v.recordVal");
                var actions = [
                    {label: 'Edit', name: 'EDIT' ,disabled:actionbuttons},
                    {label: 'Delete', name: 'DELETE',disabled:actionbuttons}
                ];
                var nameSpace = component.get('v.nameSpace') ; 
               
                var tableColumns = [
                    {
                        label: 'Form Name',
                        fieldName: 'Name',
                        type: 'button' ,typeAttributes:  {label: { fieldName: 'Name' }, target: '_blank' , name: 'recLink',variant:'Base' }
                    },
                    {
                        "label": "Status",
                        "fieldName": nameSpace + "Status__c",
                        "type": "picklist",
                        "cellAttributes": {
                            "class": {
                                "fieldName": "showClass"
                            }
                        }
                    },
                    /*  {
                "label": "Visit ID",
                "fieldName": "VisitName",
                "type": "Text"
                
            },*/
            {
                "label": "Approval Level 1",
                "fieldName": nameSpace + "Approval_Values1__c",
                
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
                "fieldName": nameSpace + "Approval_Values_2__c",
                
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
                "fieldName": nameSpace + "Approval_Values_3__c",
                
                "cellAttributes": {
                    "class": {
                        "fieldName": "showClass3"
                    },
                    "iconName": {
                        "fieldName": "displayIconName3"
                    }
                }
            },
            
            {	fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } } 
            
        ];
                component.set('v.mycolumns',tableColumns); 
                var action = component.get("c.bringData");
                component.find("Id_spinner").set("v.class" , 'slds-show');
                action.setParams({  
                    accountId : component.get("v.recordVal"),
                    category : component.get("v.categorized"),
                    subCategory : component.get("v.subCategorized")
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        
                        component.find("Id_spinner").set("v.class" , 'slds-hide');
                        
                        console.log('accountId' +recId);
                        console.log("success");
                        
                        var res = response.getReturnValue();
                        if($A.util.isEmpty(res.allForms)){
                            var cmpDiv = component.find('bodyDiv');
                            $A.util.addClass(cmpDiv, 'removeScroll');
                        }
                        else {
                            var cmpDiv = component.find('bodyDiv');
                            $A.util.removeClass(cmpDiv, 'removeScroll');
                        }
                        var allData = res.allForms;
                        component.set("v.accName",res.accName);
                        console.log('response '+JSON.stringify(response.getReturnValue()));
                        for(var key in allData){
                            debugger;
                            if(!$A.util.isUndefinedOrNull(allData[key][nameSpace+'Visit1__r'])){
                                allData[key]['VisitName']=allData[key][nameSpace+'Visit1__r']['Name'];
                            }
                            
                            if(!$A.util.isUndefinedOrNull(allData[key][nameSpace+'Approval_Values1__c'])){
                                allData[key][nameSpace+'Approval_Values1__c'] = allData[key][nameSpace+'Approval_Values1__c'].substring(0, allData[key][nameSpace+'Approval_Values1__c'].length - 1);
                            }
                            if(!$A.util.isUndefinedOrNull(allData[key][nameSpace+'Approval_Values_2__c'])){
                                allData[key][nameSpace+'Approval_Values_2__c'] = allData[key][nameSpace+'Approval_Values_2__c'].substring(0, allData[key][nameSpace+'Approval_Values_2__c'].length - 1);
                            }
                            if(!$A.util.isUndefinedOrNull(allData[key][nameSpace+'Approval_Values_3__c'])){
                                allData[key][nameSpace+'Approval_Values_3__c'] = allData[key][nameSpace+'Approval_Values_3__c'].substring(0, allData[key][nameSpace+'Approval_Values_3__c'].length - 1);
                            }   
                        }
                        allData.forEach(function(record){ 
                            if(record[nameSpace + 'Status__c'] == 'Open'){
                                
                                record.showClass = (record[nameSpace + 'Status__c'] == 'Open' ? 'redcolor' : 'blackcolor');
                            }
                            else if(record[nameSpace + 'Status__c'] == 'Completed') {
                                record.showClass = (record[nameSpace + 'Status__c'] == 'Completed' ? 'blackcolor' : 'redcolor');  
                            }
                                else if(record[nameSpace + 'Status__c'] == 'Under Review') {
                                    record.showClass = (record[nameSpace + 'Status__c'] == 'Under Review' ? 'greycolor' : 'blackcolor');  
                                }
                                    else if(record[nameSpace + 'Status__c'] == 'Ready for Review') {
                                        record.showClass = (record[nameSpace + 'Status__c'] == 'Ready for Review' ? 'bluecolor' : 'greycolor');    
                                    }
                        });
                        component.set("v.listDetails", JSON.parse(JSON.stringify(allData)));
                        var listDetails=component.get("v.listDetails");     
                        
                        allData.forEach(function(record){
                            
                            if(!$A.util.isUndefinedOrNull(record[nameSpace +'Approval_Values1__c'])){                           
                                record.showClass1 = (record[nameSpace+'Approval_Values1__c'].length>0 ? 'bluecolor' : 'close');
                                if(!$A.util.isUndefinedOrNull(record[nameSpace +'Signature_value_1__c'])){
                                    record.displayIconName1 ="utility:check";
                                    // record.displayIconName2 ="utility:close";
                                    // record.displayIconName3 ="utility:close";
                                }
                                else{
                                    record.displayIconName1 ="utility:close";
                                    // record.displayIconName2 ="utility:close";
                                    // record.displayIconName3 ="utility:close";
                                }
                            }
                            if(!$A.util.isUndefinedOrNull(record[nameSpace +'Approval_Values_2__c'])){                           
                                record.showClass2 = (record[nameSpace+'Approval_Values_2__c'].length>0 ? 'bluecolor' : 'close');
                                if(!$A.util.isUndefinedOrNull(record[nameSpace +'Signature_value_2__c'])){
                                    //  record.displayIconName1 ="utility:check";
                                    record.displayIconName2 ="utility:check";
                                    //   record.displayIconName3 ="utility:close";
                                }
                                else{
                                    // record.displayIconName1 ="utility:close";
                                    record.displayIconName2 ="utility:close";
                                    //  record.displayIconName3 ="utility:close";
                                }
                            }
                            if(!$A.util.isUndefinedOrNull(record[nameSpace +'Approval_Values_3__c'])){                           
                                record.showClass3 = (record[nameSpace+'Approval_Values_3__c'].length>0 ? 'bluecolor' : 'close');
                                if(!$A.util.isUndefinedOrNull(record[nameSpace +'Signature_value_3__c'])){
                                    //  record.displayIconName1 ="utility:check";
                                    //  record.displayIconName2 ="utility:close";
                                    record.displayIconName3 ="utility:check";
                                }
                                else{
                                    // record.displayIconName1 ="utility:close";
                                    // record.displayIconName2 ="utility:close";
                                    record.displayIconName3 ="utility:close";
                                }
                            }
                        });
                        component.set("v.listDetails", allData);
                        component.set("v.editScreen",false);
                        
                        
                    }else{
                        console.log("failure");
                    }
                });
                $A.enqueueAction(action);
            }
            
        });
        $A.enqueueAction(action2);
        
    },
    
    
    
})