({
    deleteSelectedHelper: function(component, event, helper, selectedIds) {
        
        var action = component.get( 'c.deleteAllEvent' );
        action.setParams({
            "lstRecordId": selectedIds,
        });
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "title": "RECORD DELETED SUCCESSFULLY!",
                    "message": "Deletion Successfull!"
                });
                toastEvent.fire();
                
                // component.set("v.isOpen", false);
             helper.doInitReplica(component, event, helper);
               component.set("v.showConfirmDialog", false);  
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
     doInitReplica: function(component, event, helper) {
        // component.set("v.LabOrders",true);     
        var action = component.get("c.fetchNotesListViewData");
        action.setParams({
            acoountId: component.get("v.patientID")
        });       
        component.set("v.loaded",false);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",true);
                try{
                    var nameSpace = 'ElixirSuite__';
                    var actions = [
                        {label: 'Edit', name: 'EDIT'},
                        {label: 'Delete', name: 'Delete'}, 
                        
                    ];
                        component.set('v.mycolumns', [
                        
                        {
                        label: 'Note Name',
                        fieldName: 'NameCombined',
                        type: 'button',
                        typeAttributes: {
                        label: {
                        fieldName: 'NameCombined'
                        },
                        target: '_blank',
                        name: 'recLink',
                        variant: 'Base'
                        }
                        },
                        {label: 'Created Date', fieldName: 'CreatedDate',type: 'date',sortable:true,
                        typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true}},
                        {	fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } }
                    ]);
                    console.log('form data ' + JSON.stringify(response.getReturnValue()));
                    let ntsArr = response.getReturnValue().ntsArr;
                    let relatedEventArr = response.getReturnValue().relatedEventArr;
                    let mapOfIdAndEvent = {};
                    for (let rec in relatedEventArr) {
                        mapOfIdAndEvent[relatedEventArr[rec].Id] = relatedEventArr[rec];
                    }
                    const monthNames = ["January", "February", "March", "April", "May", "June",
                                        "July", "August", "September", "October", "November", "December"
                                       ];
                    let finalNtsLst = [];
                    for (let rec in ntsArr) {
                        let ntSObj = mapOfIdAndEvent[ntsArr[rec].ElixirSuite__EventId__c];
                        if(!$A.util.isUndefinedOrNull(ntSObj)){
                            var dateObj = new Date(ntSObj.StartDateTime);
                            var month = dateObj.getUTCMonth() + 1; //months from 1-12
                            var day = dateObj.getUTCDate();
                            var year = dateObj.getUTCFullYear();                            
                            let newdate = monthNames[dateObj.getMonth()] +' '+ day +', '+year;                   
                           ntsArr[rec]['NameCombined'] = ntSObj.Subject +' - '+ newdate;  
                            finalNtsLst.push(ntsArr[rec]);
                        }
                    }
                     console.log('finalNtsLst ' + JSON.stringify(finalNtsLst));
                    component.set("v.data",finalNtsLst);
                }
                catch(e){
                    alert(e)
                }
                
            }
        });
        
        $A.enqueueAction(action);
        
        
        
        
    },
})