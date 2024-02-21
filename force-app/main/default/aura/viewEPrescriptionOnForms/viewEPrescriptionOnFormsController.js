({
    init : function(component, event, helper) {

        var accId = component.get("v.patientID");

        var action = component.get("c.fetchEPresc");
        console.log('accId***', accId);
        action.setParams({ 'accountId': accId });

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
                toAddCol.push({ label: 'Name', fieldName: 'Name', type: 'text' });
                toAddCol.push({ label: 'Drug Name ', fieldName: 'ElixirSuite__Drug_Name__c', type: 'text' });
                toAddCol.push({ label: 'Drug Info', fieldName: 'ElixirSuite__Reason_new__c', type: 'text' });
                
                toAddCol.push({ label: 'SIG', fieldName: 'ElixirSuite__Patient_SIG__c', type: 'text' });
                toAddCol.push({ label: 'Refills', fieldName: 'ElixirSuite__Refills__c', type: 'text' });
                toAddCol.push({ label: 'Status', fieldName: 'ElixirSuite__Status_NC__c', type: 'text' });
                
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
})
