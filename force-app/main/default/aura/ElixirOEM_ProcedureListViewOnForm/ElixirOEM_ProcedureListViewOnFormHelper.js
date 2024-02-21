({
    
    sortData: function (component, fieldName, sortDirection) {
        var fname = fieldName;
        var data = component.get("v.listDetails");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortByfield(fieldName, reverse))
        component.set("v.listDetails", data);
    },
    
    sortDataHist: function (component, fieldName, sortDirection) {
        var fname = fieldName;
        var data = component.get("v.listDetailsHistorical");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortByfield(fieldName, reverse))
        component.set("v.listDetailsHistorical", data);
    },
    
    sortByfield: function (field, reverse) {
        var key = function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    fetchNspc: function (component, event, helper) {
        var action = component.get("c.fetchNameSpace");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.orgWideValidNamespace",response.getReturnValue());
            }
            else {
                console.log("failure for namespace");
            }
        });
    },
    
    setTime: function(cmp,helper){
        var currentTime = cmp.get("v.time");
        cmp.set("v.time", (currentTime+1));
    },
    deleteSelectedHelper: function(component, event, helper, selectedIds) {
        fetchRelatedDiag
        var action = component.get( 'c.deleteAllOrder' );
        action.setParams({
            "lstRecordId": selectedIds,
        });
        alert("****Id****",selectedIds);
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "title": "RECORD(S) DELETED SUCCESSFULLY!",
                    "message": "Deletion Successfull!"
                });
                toastEvent.fire();
                
                // component.set("v.isOpen", false);
                $A.get('e.force:refreshView').fire();
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
    fetchRecDiag: function(component, event, helper, recId,column) {
        
        var action = component.get( 'c.fetchRelatedDiag' );
        action.setParams({
            "recId": recId,
        });
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {  
                alert('sucess in diagnosis'+JSON.stringify(response.getReturnValue()));
                column['diagnosisData'] = helper.setDiagnosisData(component, event, helper,response.getReturnValue());
                component.set("v.listDetails", resp);
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
    setDiagnosisData :  function(component, event, helper,res) {
        if(!$A.util.isEmpty(res)){
            let idArr = [];
            res.forEach((element) => {  
                idArr.push({'diagnosis'  : element.ElixirSuite__ICD_Codes__r.Name,
                'description' : element.ElixirSuite__Description__c,
                'notes' : element.ElixirSuite__Notes__c,'Id' :  element.ElixirSuite__ICD_Codes__c}); 
        });
        return idArr;
    }
    else {
    return [];
}
 }, 
 deleteSelectedRecordRecord : function(component, event, helper) {
    var action = component.get("c.deleteRecord");
    action.setParams({  
        recId : component.get("v.RowId") ,
    });
    action.setCallback(this, function(response){
        var state = response.getState();
        if (state === "SUCCESS") {
            helper.doiInitReplica(component, event, helper);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "Success",
                "title": "RECORD DELETED SUCCESSFULLY!",
                "message": "Deletion Successfull!"
            });
            toastEvent.fire();
        }else{
            console.log("failure");
        }
    });
    $A.enqueueAction(action);
},
    
    getDetails : function(component,event,helper){       
        var action = component.get("c.procedureListHistorical");
        action.setParams({  
            accountId : component.get("v.recordVal")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                    let csColumnsHist  = response.getReturnValue().columns;
                    let resp = response.getReturnValue().lstOfHistoricalProcedures;
                    resp.forEach(function(column){                    
                        column['procedureName'] = column.Name; //proc code/name 
                        column['procDesc'] = column.ElixirSuite__Code_Description__c;
                        column['modifier1']= column.ElixirSuite__modifier_1__c;
                        column['modifier2']= column.ElixirSuite__modifier_2__c;
                        column['modifier3']= column.ElixirSuite__modifier_3__c;
                        column['modifier4']= column.ElixirSuite__modifier_4__c;
                        column['diagCode']= ' ';
                        column['procStart']= column.ElixirSuite__From_Date_of_Service__c;
                        column['procEnd']= column.ElixirSuite__To_Date_of_Service__c;
                        column['duration']= column.ElixirSuite__Days_Units__c;
                        column['placeOfService']= column.ElixirSuite__Place_Of_Service_Picklist__c;
                        if(column.ElixirSuite__Claim__c !== undefined)
                            column['claimName']= column.ElixirSuite__Claim__r.Name;  
                        var column2 = [];
                        column2 = column.ElixirSuite__Procedure_Diagnosis__r ;
                        if(!$A.util.isUndefinedOrNull(column2)){
                            column2.forEach(function(col2){
                                if(column['diagCode'] === ' ')
                                    column['diagCode']= col2.ElixirSuite__ICD_Codes__r.Name;  
                                else{
                                    column['diagCode']= column['diagCode'] + ', ' + col2.ElixirSuite__ICD_Codes__r.Name; 
                                }
                            });
                        }
                        //column['CreatedBy']= column.CreatedBy.Name;    
                    });
                    component.set('v.mycolumnsHistorical', [                        
                        { label: 'Procedure Code', fieldName: 'procedureName', type:'button' ,typeAttributes:  {label: { fieldName: 'procedureName' }, target: '_blank',name:'recLink',variant:'Base' } },
                        { label: 'Procedure Description', fieldName: 'procDesc', type: 'text'},   
                        
                        
                    ]);
                        
                        let mapOfApiAndLabel = 
                        {"modifier1" :"Modifier 1",
                        "modifier2" :"Modifier 2",
                        "modifier3" :"Modifier 3",
                        "modifier4" :"Modifier 4",
                        "diagCode" : "Diagnosis Codes",
                        "procStart" :"Procedure Start Date/Time",
                        "procEnd" :"Procedure End Date/Time",
                        "duration" :"Date Onset",
                        "placeOfService" :"Place Of Service",
                        "claimName" :"Claim Number",
                        //   "CreatedBy" :"Created By",
                        };
                        let toAddCol = component.get('v.mycolumnsHistorical');
                        if(!$A.util.isUndefinedOrNull(csColumnsHist)){
                        let csColArr = csColumnsHist.split(';');                      
                        if(csColumnsHist){
                        for(let recSObj in csColArr){
                        if(csColArr[recSObj] == 'procStart' || csColArr[recSObj] == 'procEnd'){
                        toAddCol.push({label: mapOfApiAndLabel[csColArr[recSObj]], fieldName: csColArr[recSObj],type: 'date',
                                       typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true}});
                        
                    }
                    else{
                        toAddCol.push({ label: mapOfApiAndLabel[csColArr[recSObj]], 
                                       fieldName: csColArr[recSObj], type: 'text'}); 
                    }
                }
            }
        }
                           toAddCol.push({label: 'Created Date', fieldName: 'CreatedDate',type: 'date',sortable:true,
                           typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true}});
        /*  toAddCol.push( { label: 'Created By ', fieldName: 'createdBy', type: 'text'});
        toAddCol.push({label: 'LastModifiedDate', fieldName: 'LastModifiedDate',type: 'date',
                       typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true}});
        */
     //  toAddCol.push({	fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } }); 
     component.set('v.mycolumnsHistorical',toAddCol); 
     
     component.set("v.listDetailsHistorical", resp);
     //  component.set("v.loaded",true);
 }
catch(e){
    alert('getDetails'+ e);
}
// component.set("v.loaded",true);


}
else
{
    console.log("failure");
}
});
$A.enqueueAction(action);
}
})