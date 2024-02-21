({
    doInit: function(component, event, helper) {
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
    handleRowAction : function(component, event, helper) {
        
        
        var action = event.getParam('action');
        console.log(action.name);
        var row = event.getParam('row');
        component.set("v.RowId",row.Id);
        console.log('row is 99 '+JSON.stringify(row.Id));
        
        
        switch (action.name) {
                
                
            case 'recLink':
                component.set("v.editScreen",true);
                component.set("v.editAbility",true);
                break;
            case 'EDIT':
                component.set("v.editScreen",true);
                component.set("v.editAbility",false);
                break;   
            case 'Delete' : 
                component.set("v.showConfirmDialog",true);   
        }
    },
    handleConfirmDialogYes :  function(component, event, helper) {
        // component.set('v.IsSpinner',true);
        var row  = component.get("v.RowId");        
        console.log('row to del '+JSON.stringify(row));
        var selectedIds = [];
        selectedIds.push(row);       
        helper.deleteSelectedHelper(component, event, helper,selectedIds);
     },
    handleConfirmDialogNo:function(component, event, helper) {
        component.set("v.showConfirmDialog",false);
        
    }
})