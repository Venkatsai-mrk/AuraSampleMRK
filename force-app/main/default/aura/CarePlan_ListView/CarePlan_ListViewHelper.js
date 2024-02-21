({
    initCopy : function(component, event, helper,deleteKey) {
        //  console.log('received for deltion');
        var action = component.get("c.CareplanRecords");
        action.setParams({  
            accountId : component.get("v.recordVal") ,
        });
        
        /*var actions = [
            {label: 'Delete', name: 'DELETE'}
        ];
        */
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                //  var nameSpace = response.getReturnValue().nameSpace;
                
                
         /*       component.set('v.mycolumns', [
                    { label: 'Care Plan Name', fieldName: 'ElixirSuite__Treatment_Plan_Name__c', type:'button' ,typeAttributes:  {label: { fieldName: 'ElixirSuite__Treatment_Plan_Name__c' }, target: '_blank' , name: 'recLink',variant:'Base' } },
                    { label: 'Status', fieldName: 'ElixirSuite__Status__c', type: 'text', "cellAttributes": { "class": { "fieldName": "showClass" }  } },
                    
                    
                    /*     {label: 'LastModified Date', fieldName: 'LastModifiedDate', type: 'date', typeAttributes: {  
                        day: 'numeric',  
                        month: 'short',  
                        year: 'numeric',  
                        hour: '2-digit',  
                        minute: '2-digit',  
                        second: '2-digit',  
                        hour12: true}},*/
                   
                   /* {	fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } }
                   
               ]);*/
              /*     var tableColumns = component.get('v.mycolumns');
                   tableColumns.push({ label: 'Start Date', fieldName:'ElixirSuite__Start_Date__c', type: 'Date',typeAttributes:{ month: "2-digit", day: "2-digit" } });
                   tableColumns.push({ label: 'End Date', fieldName: 'ElixirSuite__End_Date__c', type: 'Date',typeAttributes:{ month: "2-digit", day: "2-digit" } });
                   component.set('v.mycolumns',tableColumns);*/
                   
            
            
            if(deleteKey == 'isDeleted'){
                $A.get('e.force:refreshView').fire();
                //component.set("v.listDetails", listDetails);
                component.set("v.selectedRowsCount" , 0);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "success",
                    "title": "Success!",
                    "message": "The record has been deleted successfully."
                });
                toastEvent.fire(); 
                
            }
        }else{
                           console.log("failure");
    }
});
$A.enqueueAction(action);

},
    fetchColumns:function(component, event){
        //var nameSpace = 'ElixirSuite__'
        console.log('inside helper');
        var columns = event.getParam("columns");
        console.log('careplanlistColumns: '+columns)
        const displayIcons = {"1" : "displayIconName1",
                              "2" : "displayIconName2",
                              "3" : "displayIconName3",
                              "4" : "displayIconName4", 
                              "5" : "displayIconName5"};
        /*const showClasses = {"1" : "showClass1",
                             "2" : "showClass2",
                             "3" : "showClass3",
                             "4" : "showClass4", 
                             "5" : "showClass5"};*/
        const showContent = {"1" : "content1",
                             "2" : "content2",
                             "3" : "content3",
                             "4" : "content4", 
                             "5" : "content5"};
        
        const tableColumns = [
            {
                label: 'Care Plan Name',
                fieldName: 'carePlanName',
                type: 'button' ,typeAttributes:  {label: { fieldName: 'carePlanName' }, target: '_blank' , name: '',variant:'Base' }
            },
            {
                label: 'Status',
                fieldName: 'carePlanStatus',
                type: 'text'
                
            },{
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
            }
        ];
        console.log('tableColumns ',JSON.stringify(tableColumns));
        console.log('recordVal', component.get("v.recordVal"));
         var nameOfOrder =   {
            label: 'Care Plan Name',
            fieldName: 'carePlanName',
            type: 'button' ,typeAttributes:  {label: { fieldName: 'carePlanName' }, target: '_blank' , name: '',variant:'Base' }
        };
        /*var prescStatus = {
                label: 'Status',
                fieldName: 'carePlanStatus',
                type: 'text'
                
            };
            */ 
        console.log('before setting columns');
        var columnsToShow = [];	
        console.log('columns === ', columns);
        if(!$A.util.isUndefinedOrNull(columns)){
            tableColumns.forEach(function(column){ 
                if(columns.includes(column.fieldName)){
                    columnsToShow.push(column);
                }        
            });
            columnsToShow = [nameOfOrder,...columnsToShow];
            console.log('columnsToShow'+JSON.stringify(columnsToShow));
            component.set('v.carePlancolumns',columnsToShow); 
        }
        
        var action = component.get("c.fetchCarePlan");
        action.setParams({ accountId : component.get("v.recordVal") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response.getState();', state);
            if (state === "SUCCESS") {
                var res =response.getReturnValue();
                console.log('response for records ', res);
                if($A.util.isUndefinedOrNull(columns)){
                        // Bring dynamic columns here
                        let receivedColumns = [];
                        console.log('hjkl'+JSON.stringify(res));
                        try{
                            receivedColumns = res[0]['columns'];
                            tableColumns.forEach(function(column){ 
                                if(receivedColumns.includes(column.fieldName)){
                                    console.log('this includes the names');
                                    columnsToShow.push(column);
                                }        
                            });
                            columnsToShow = [nameOfOrder,...columnsToShow];
                        }
                        catch(e){
                            columnsToShow = [nameOfOrder];
                        }
                        console.log('columns '+JSON.stringify(columnsToShow));
                        component.set('v.carePlancolumns',columnsToShow); 
                    }
                //component.find("Id_spinner").set("v.class" , 'slds-hide');
                
                res.forEach(function(record){ 
                    record['isActive']= false;
                    if(typeof record.presId != 'undefined'){
                        if(record['presStatus'] == 'Approved'){
                            record.showClass1 = (record['presStatus'] == 'Open' ? 'open' : 'close');
                            record.isActive=true;
                        }
                    }
                        let approvedLevelsCount = record.approvedLevelsCount;
                        let defaultLevelCount = record.defaultLevelCount;
                        console.log('defaultLevelCount '+defaultLevelCount);
                        console.log('approvedValues '+approvedLevelsCount);
                            for(let level=1;level<4;level++){
                                let iconName = displayIcons[level];
                                //let classToShow = showClasses[level];
                                let content = showContent[level];
                                if(level<=approvedLevelsCount){
                                    record[iconName] = "utility:check";
                                }else if(level<=defaultLevelCount){
                                    record[iconName] = "utility:close";
                                }else{
                                    record[content] = "NA";
                                }
                            }
                        
                    });
                component.set("v.careplanlistDetails", res);
            }
          });
        	
	 $A.enqueueAction(action);
       },
})