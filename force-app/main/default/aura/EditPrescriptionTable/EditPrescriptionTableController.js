({


    /*  var action = component.get("c.buildPresc");
        var accId = component.get("v.patientID");
        var addLst = component.get("v.addedLst");
         var addValues = [];
             /*   for(var i=0;i<addLst.length;i++){
                    
                    console.log('inside for loop');
                    console.log('inside for loop*',addLst[i].medicationName);
                                  
                    var singleObj = {};
                    singleObj['ElixirSuite__Drug_Name__c'] = addLst[i].medicationName;
                    singleObj['ElixirSuite__Reason_new__c'] = addLst[i].reasonLabel;
                    singleObj['ElixirSuite__Route_New__c'] = addLst[i].Route;
                    singleObj['req'] = addLst[i].ElixirSuite__Units_Procured__c;
                    singleObj['rid'] = addLst[i].Id;
                   
                    singleObj['modetype'] = 'Normal';
                                  
                    addValues.push(singleObj);
                    
                }
        action.setParams({ 'accountId' :accId});
        
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log('result from buildPresc '+result);
            var state = response.getState();
            console.log('STATE ',state);
            if (state === "SUCCESS") {
                console.log('inside success buildPresc',result);
                console.log('inside success length buildPresc',result.length);
                
                component.set("v.data",result);
                
            }
            helper.setColumns(component);
            
        });
        
      //  component.set("v.loaded",false);
        var action = component.get("c.buildPresc");
        action.setParams({  
            accountId : component.get("v.patientID") ,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
              //  component.set("v.loaded",true);
                console.log('res '+JSON.stringify(response.getReturnValue()));
                let csColumns  = response.getReturnValue().columns;
                console.log('Childselectedvalues'+ csColumns);
                let resp = response.getReturnValue().lstOfAllProblemPerAccount;
                console.log('Response'+ resp);
                resp.forEach(function(column){            
                    column['medicationName'] = column.ElixirSuite__Drug_Name__c;
                    column['reasonLabel']= column.ElixirSuite__Reason_new__c;
                    column['Route'] = column.ElixirSuite__Route_New__c;
                    column['CreatedBy']= column.CreatedBy.Name;
                    column['startDate']= column.CreatedDate;
                    column['startDate']= column.LastModifiedDate;     
                });               
                let mapOfApiAndLabel =  {//"medicationName" :"Medication Name",
                                         "reasonLabel" :"Reason",
                                         "Route" :"Route",
                                         //"CreatedBy" :"Created By",
                                         //"startDate" :"Created Date",
                                         //"startDate" :"Modified Date",
                                        };
                console.log('mahi'+mapOfApiAndLabel.ProblemName)
                let toAddCol = [];
                if(!$A.util.isUndefinedOrNull(csColumns)){
                    let csColArr = csColumns.split(';'); 
                    console.log('ABC'+csColArr);
                    const allTextColumns = ["reasonLabel","Route"];
                    if(csColumns){
                        for(let recSObj in csColArr){
                            console.log('csColArr[recSObj]'+csColArr[recSObj]);
                            console.log('recSObj'+recSObj);
                            if(allTextColumns.includes(csColArr[recSObj])){
                                toAddCol.push({ label: mapOfApiAndLabel[csColArr[recSObj]],
                                               fieldName: csColArr[recSObj], type: 'text'});
                                console.log('sachin2');
                            }
                        }
                    }
                }
                toAddCol.push( { label: 'Medication Name ', fieldName: 'medicationName', type: 'text'});
                toAddCol.push({label: 'Created Date', fieldName: 'CreatedDate',type: 'date',sortable:true,
                               typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true}});
                toAddCol.push( { label: 'Created By ', fieldName: 'createdBy', type: 'text'});
                toAddCol.push({label: 'Modified Date', fieldName: 'LastModifiedDate',type: 'date',
                               typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true}});
                component.set('v.columns',toAddCol); 
                
                console.log('response '+JSON.stringify(response.getReturnValue()));
                component.set("v.data", resp);
                console.log('shiva'+resp);
              //  component.set("v.loaded",true);
                
            }else{
                console.log("failure");
            }
        });
        $A.enqueueAction(action);

 $A.enqueueAction(action);*/
    init: function (component, event, helper) {
        try {
            const items = [
                { "value": "ElixirSuite__Reason_new__c", "label": "Reason" },
                { "value": "ElixirSuite__Route_New__c", "label": "Route" }
            ];
            component.set("v.tempOptions", items);
            // console.log("options parent",component.get("v.options"));
            var accId = component.get("v.patientID");
            var formId = component.get("v.formId");
            console.log('formId****', formId);
            var action = component.get("c.buildPresc");
            console.log('accId***', accId);
            action.setParams({ 'accountId': accId, 'formUniqueId': formId });

            action.setCallback(this, function (response) {
                var result = response.getReturnValue();
                let toAddCol = [];
                var state = response.getState();
                if (state === "SUCCESS") {
                    let csColumns = response.getReturnValue().columns;
                    let resp = response.getReturnValue().lstOfAllProblemPerAccount;
                    if (resp.length == 0) {
                        component.set("v.checkTableSizeZero", true);
                    }
                    if (resp.length > 10) {
                        component.set("v.checkTableSize", true);
                    }

                    for (var i = 0; i < resp.length; i++) {
                        var row = resp[i];
                        if (row.CreatedBy) {
                            row.CreatedBy = row.CreatedBy.Name;
                        }
                    }
                    resp.forEach(function (column) {
                        column['reasonLabel'] = column.ElixirSuite__Reason_new__c;
                        column['Route'] = column.ElixirSuite__Route_New__c;
                    });
                    let mapOfApiAndLabel = {
                        "ElixirSuite__Reason_new__c": "Reason",
                        "ElixirSuite__Route_New__c": "Route",
                    };
                    console.log('ifall label 0');
                    toAddCol.push({ label: 'Medication Name ', fieldName: 'ElixirSuite__Drug_Name__c', type: 'text' });
                    toAddCol.push({
                        label: 'Created Date', fieldName: 'CreatedDate', type: 'date', sortable: true,
                        typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true }
                    });
                    toAddCol.push({ label: 'Created By ', fieldName: 'CreatedBy', type: 'text' });
                    toAddCol.push({
                        label: 'Modified Date', fieldName: 'LastModifiedDate', type: 'date',
                        typeAttributes: { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true }
                    });
                    if (!$A.util.isUndefinedOrNull(csColumns)) {
                        let csColArr = csColumns.split(';');
                        console.log('ifall label 1');
                        const allTextColumns = ["ElixirSuite__Reason_new__c", "ElixirSuite__Route_New__c"];
                        if (csColumns) {
                            console.log('ifall label 2');
                            for (let recSObj in csColArr) {
                                if (allTextColumns.includes(csColArr[recSObj])) {
                                    console.log('ifall label 3');
                                    console.log('ifall label ' + mapOfApiAndLabel[csColArr[recSObj]]);
                                    console.log('ifall field ' + [csColArr[recSObj]]);
                                    toAddCol.push({
                                        label: mapOfApiAndLabel[csColArr[recSObj]],
                                        fieldName: csColArr[recSObj], type: 'text'
                                    });
                                }
                            }
                        }
                    }
                    component.set('v.columns', toAddCol);
                    component.set("v.data", resp);

                }
                else {
                    console.log("failure");
                }
            });
            $A.enqueueAction(action);
        }
        catch (e) {
            alert('error ' + e);
        }
    },

    handlePrescDataEvent: function (component, event, helper) {

        console.log('inside handlePrescDataEvent');
        component.set("v.checkTableSizeZero", false);
        var jsonList = event.getParam("jsonList");
        //  var addValues = [];
        var findata = component.get("v.data");
        for (var i = 0; i < jsonList.length; i++) {

            console.log('inside for loop');
            console.log('inside for loop*', jsonList[i].medicationName);

            var singleObj = {};
            singleObj['ElixirSuite__Drug_Name__c'] = jsonList[i].medicationName;
            singleObj['ElixirSuite__Reason_new__c'] = jsonList[i].reasonLabel;
            singleObj['ElixirSuite__Route_New__c'] = jsonList[i].Route;
            singleObj['CreatedBy'] = jsonList[i].Name;
            singleObj['CreatedDate'] = jsonList[i].startDate;
            singleObj['LastModifiedDate'] = jsonList[i].startDate;


            findata.push(singleObj);

        }

        // findata.push(addValues);
        console.log('findata****', findata);
        component.set("v.data", findata);
    },

    handleSort: function (component, event, helper) {
        helper.handleSort(component, event);
    },
    showOptions: function (cmp) {
        cmp.set("v.showOptions", true);
    }
})