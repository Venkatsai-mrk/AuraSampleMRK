({
    myAction : function(component, event, helper) {
        
        var csColumns = event.getParam("columns");
        var finColumnsApi = event.getParam("finalColumnsApi");
        var finColumnsLabel = event.getParam("finalColumnsLabel");
        console.log('csColumns***',csColumns);
        console.log('finColumnsApi***',finColumnsApi);
        console.log('finColumnsLabel***',finColumnsLabel);
        var recId = component.get("v.recordId");
        if(recId != undefined){
            console.log('line13upd1***');
            component.set("v.recordVal",recId);
        }
        helper.fetchAccountName(component, event, helper) ;
        var recordId = component.get( "v.recordVal" );
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            
            var focusedTabId = response.tabId;
            var issubTab = response.isSubtab;
            
            if(issubTab)
            {
                workspaceAPI.getTabInfo(
                    { tabId:focusedTabId}
                ).then(function(response1){
                    
                    
                });
                workspaceAPI.setTabLabel({
                    
                    label: "Care Episode"
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                    
                });
                workspaceAPI.setTabLabel({
                    label: "Care Episode"
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:note",
                iconAlt: "note"
            });
        })
        
        console.log('in init' , component.get("v.newVisit"));
        component.set("v.loaded",false);
        var action = component.get("c.visitRecords");
        action.setParams({  
            accountId : component.get("v.recordVal") ,
        });
        var actions = [
            {label: 'Edit', name: 'EDIT'},
            {label: 'Delete', name: 'DELETE'}
        ];
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.loaded",true);
                var nameSpace = 'ElixirSuite__';
                
                let mapOfLabelAndApi = {
                    "account": "AccountName",
                    "admDate": "ElixirSuite__Admit_Date__c",
                    "provider": "careEpisodeLocation",
                    "discDate": "ElixirSuite__Discharge_Date__c",
                    "location": "ElixirSuite__Location__c",
                    "locAdd": "ElixirSuite__Location_Address__c",
                    "perEnd": "ElixirSuite__Visit_End__c",
                    "perStart": "ElixirSuite__Visit_Start__c",
                    "prior": "ElixirSuite__Priority__c",
                    "reason": "ElixirSuite__Reason__c",
                    "status": "ElixirSuite__Status__c",
                    "authNum": "ElixirSuite__Pre_Authorization_Number__c",
                    "days": "ElixirSuite__Days__c",
"parentCareEpisode":"parentCareEpisodeName"
                };
                
                let mapOfValueAndLabel = {
                    "account": "Account",
                    "admDate": "Admit Date",
                    "provider": "Care Episode Location",
                    "discDate": "Discharge Date",
                    "location": "Location",
                    "locAdd": "Location Address",
                    "perEnd": "Period End",
                    "perStart": "Period Start",
                    "prior": "Priority",
                    "reason": "Reason",
                    "status": "Status",
                    "authNum": "Pre Authorization Number",
                    "days": "Days",
"parentCareEpisode":"Parent Care Episode"
                };
                
                let toAddCol = [];
                
                toAddCol.push({ label: 'Care Episode Name', fieldName: 'linkName', type:'button' ,typeAttributes:  {label: { fieldName: 'Name' }, target: '_blank',name:'recLink',variant:'Base' } });
                
                toAddCol.push({ label: 'LastModified Date', fieldName: 'LastModifiedDate', type: 'date', typeAttributes: {  
                    day: 'numeric',  
                    month: 'short',  
                    year: 'numeric',  
                    hour: '2-digit',  
                    minute: '2-digit',  
                    second: '2-digit',  
                    hour12: true}});
                
                
                
                console.log('line 110***',csColumns);
                
                if(csColumns!=null){
                    console.log('line 113');
                    component.set('v.parentColumns', csColumns);
                }
                if(csColumns==null){
                    console.log('line 117');
                    csColumns = component.get('v.parentColumns');
                }
                
                if (!$A.util.isUndefinedOrNull(csColumns)) {
                    console.log('inside 112***',csColumns);
                    // let csColArr = csColumns.split(',');
                    
                    const allTextColumns = ["account", "admDate", "provider", "discDate", "location", "locAdd", "perEnd", "perStart", "prior", "reason", "status", "authNum","days","parentCareEpisode"];
                    if (csColumns) {
                        console.log('inside 117');
                        for (var i=0;i<csColumns.length;i++) {
                            console.log('inside 115',csColumns[i]);
                            if (allTextColumns.includes(csColumns[i])) {
                                console.log('ifall label 3');
                                console.log('field Value****' + csColumns[i]);
                                if(csColumns[i] == 'status'){
                                    
                                    toAddCol.push({
                                        label: mapOfValueAndLabel[csColumns[i]],
                                        fieldName: mapOfLabelAndApi[csColumns[i]], type: 'text',
                                        "cellAttributes": { "class": { "fieldName": "showClass" }  }
                                    });
                                    
                                }
                                else if(csColumns[i] == 'account'){
                                    toAddCol.push({
                                        label: mapOfValueAndLabel[csColumns[i]],
                                        fieldName: mapOfLabelAndApi[csColumns[i]], type: 'text'
                                    });
                                }
                                    else if(csColumns[i] == 'discDate'){
                                        toAddCol.push({
                                            label: mapOfValueAndLabel[csColumns[i]],
                                            fieldName: mapOfLabelAndApi[csColumns[i]], type: 'date', typeAttributes: {  
                                                day: 'numeric',  
                                                month: 'short',  
                                                year: 'numeric',  
                                                hour: '2-digit',  
                                                minute: '2-digit',  
                                                second: '2-digit',  
                                                hour12: true}
                                        });
                                    }
                                
                                        else if(csColumns[i] == 'perEnd'){
                                            toAddCol.push({
                                                label: mapOfValueAndLabel[csColumns[i]],
                                                fieldName: mapOfLabelAndApi[csColumns[i]], type: 'date', typeAttributes: {  
                                                    day: 'numeric',  
                                                    month: 'short',  
                                                    year: 'numeric',  
                                                    hour: '2-digit',  
                                                    minute: '2-digit',  
                                                    second: '2-digit',  
                                                    hour12: true}
                                            });
                                        }
                                            else if(csColumns[i] == 'perStart'){
                                                toAddCol.push({
                                                    label: mapOfValueAndLabel[csColumns[i]],
                                                    fieldName: mapOfLabelAndApi[csColumns[i]], type: 'date', typeAttributes: {  
                                                        day: 'numeric',  
                                                        month: 'short',  
                                                        year: 'numeric',  
                                                        hour: '2-digit',  
                                                        minute: '2-digit',  
                                                        second: '2-digit',  
                                                        hour12: true}
                                                });
                                            }
                                                else{
                                                    toAddCol.push({
                                                        label: mapOfValueAndLabel[csColumns[i]],
                                                        fieldName: mapOfLabelAndApi[csColumns[i]], type: 'text'
                                                    });
                                                }
                            }
                            else{
                                console.log('line 186');
                                for(var j=0;j<finColumnsApi.length;j++){
                                    console.log('line 188',finColumnsApi[j]);
                                    if(finColumnsApi[j]==csColumns[i]){
                                        toAddCol.push({
                                            label: finColumnsLabel[j],
                                            fieldName: finColumnsApi[j], type: 'text'
                                        });
                                    }
                                }
                            }
                        }
                    }
                }
                
                toAddCol.push({	fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } });
                
                component.set('v.mycolumns', toAddCol);
                var allData = response.getReturnValue().listOfencounter;
                
                allData.forEach(function(column){
                    
                    if(!$A.util.isUndefinedOrNull(column.ElixirSuite__Account__r)){
                        console.log('line208**',column.ElixirSuite__Account__r.Name);
                        column['AccountName']= column.ElixirSuite__Account__r.Name;
                    }
                    
                    if(!$A.util.isUndefinedOrNull(column.ElixirSuite__Care_Episode_Location__r)){
                        console.log('line214**',column.ElixirSuite__Care_Episode_Location__r.Name);
                        column['careEpisodeLocation']= column.ElixirSuite__Care_Episode_Location__r.Name;
                    }
if(!$A.util.isUndefinedOrNull(column.ElixirSuite__Parent_Care_Episode__r)){
                        column['parentCareEpisodeName']= column.ElixirSuite__Parent_Care_Episode__r.Name;
                    }
                    
                });
                
                console.log('dc',nameSpace);
                allData.forEach(function(record){ 
                    if(typeof record.Id != 'undefined'){
                        if(record[nameSpace+'Status__c'] == 'Active'){
                            console.log('dh', record[nameSpace+'Status__c']);
                            record.showClass = (record[nameSpace+'Status__c'] == 'Open' ? 'open' : 'close');
                        }
                        else if(record[nameSpace+'Status__c'] == 'Closed'){
                            record.showClass = (record[nameSpace+'Status__c']  === 'Completed' ? 'close' : 'open');
                        }
                            else if(record[nameSpace+'Status__c'] == 'Reopened'){
                                console.log('dh', record[nameSpace+'Status__c']);
                                record.showClass = (record[nameSpace+'Status__c'] == 'Open' ? 'open' : 'reopen');
                            }
                                else if(record[nameSpace+'Status__c'] == 'On Hold'){
                                    record.showClass = (record[nameSpace+'Status__c']  === 'Completed' ? 'open' : 'onHold');
                                }
                        if(record[nameSpace+'Claim_Status__c'] == 'Yes'){
                            record.showClass1 = (record[nameSpace+'Status__c']  == 'Open' ? 'open' : 'close');
                        }
                        else if(record[nameSpace+'Claim_Status__c'] == 'No'){
                            record.showClass1 = (record[nameSpace+'Status__c']  === 'Completed' ? 'close' : 'open');
                        }
                        // set the record link with record id  
                        record.linkName = '/'+record.Id;   
                    }
                });    
                console.log('response '+JSON.stringify(response.getReturnValue()));
                component.set("v.listDetails", allData);
            }else{
                console.log("failure",response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    openNewCarePlanModal : function(component, event, helper) {
        //   component.set("v.newVisit", true);  
        component.set("v.loaded",false);
      var action = component.get("c.generateAutoNumber");    
        action.setParams({
            patientID:  component.get("v.recordVal")
            
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                   component.set("v.loaded",true);
                var createRecordEvent = $A.get('e.force:createRecord');
                if ( createRecordEvent ) {
                    createRecordEvent.setParams({
                        'entityApiName': 'ElixirSuite__Visits__c',
                        'defaultFieldValues': {
                            'ElixirSuite__Account__c' : component.get("v.recordVal"),
                            'ElixirSuite__Status__c' : 'Active', 
                            'Name' : response.getReturnValue().accName+"'"+'s'+' Visit - '+response.getReturnValue().countRecords
                        }
                    });
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info',
                        message: 'This Visit is considered until the new one is created.',
                        duration:' 6000',
                        key: 'info_alt',
                        type: 'info',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    createRecordEvent.fire();
                    
                    console.log("Visit creation not supported"+component.get("v.newVisit"));
                } else {
                    alert("Visit creation not supported");
                }
                
            }
        });           
        $A.enqueueAction(action);  
    },
    updateSelectedText : function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedRowsCount" ,selectedRows.length );
        let obj =[] ; 
        if(selectedRows.length>=1) {
            component.set("v.selectedRow",selectedRows[0].Id);
            component.set("v.showDeleteButton",true);    
        }else {
            component.set("v.selectedRow",[]);
            component.set("v.showDeleteButton",false);            
        }
        for (var i = 0; i < selectedRows.length; i++){       
            obj.push({Name:selectedRows[i].Name});   
        }
        
        component.set("v.selectedRowsList" ,event.getParam('selectedRows') );  
        console.log('v.selectedRowsList', component.get("v.selectedRowsList"));
        
        if (component.get("v.selectedRowsList").length>=1) {
            component.set("v.showGenerateChartButton",true);
            component.set("v.showGenerateSuperbill",true);  //Added by Anmol for LX3-8141 
        }
        else {
            component.set("v.showGenerateChartButton",false);
            component.set("v.showGenerateSuperbill",false); //Added by Anmol for LX3-8141
        }
    },
    //Added by Ashwini
    navToListView: function(component, event, helper) {
        // Sets the route to /lightning/o/Account/home
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/o/Account/home'
        });
        urlEvent.fire();
        },
        navToAccRecord: function(component, event, helper) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordVal")
            });
            navEvt.fire();
        },
    handleRowAction : function(component, event, helper) {
        
        var action = event.getParam('action');
        var row = event.getParam('row'); 
        var recId = row.Id;
        var id = event.getParams().row["Id"];
        var status = event.getParams().row["Status"];
        component.set("v.selectedRow",id);
        switch (action.name) {
            case 'recLink' :    
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": id,
                    "slideDevName": "Client Detail"
                });
                navEvt.fire();
                
                break;
                
            case 'EDIT':
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": recId
                });
                
                editRecordEvent.fire();
                break;     
                
            case 'DELETE':
                component.set('v.allRecordId',event.getParams().row["Id"] );
                component.set("v.showConfirmDialog",true);
                //alert('Are you sure you want to delete this item?');
                /*console.log(event.getParams().row["Id"]);
                action.setParams({ encounterId : event.getParams().row["Id"] });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {        
                        $A.get('e.force:refreshView').fire();
                    }
                });
                $A.enqueueAction(action);*/
                break;     
        }
        
    },
    selectedRows : function(component, event, helper) {
        console.log('selected rows'+ JSON.stringify(event.getParam('selectedRows')));
        
        console.log('all rows '+  JSON.stringify(component.get('v.selectedRows')));
        
        component.set("v.selectedLabOrders",event.getParam('selectedRows'));
        var selectedRows =  event.getParam('selectedRows');
        if(selectedRows.length>=1) 
        {
            component.set("v.showDeleteButton",true); 
        }
        else {
            component.set("v.showDeleteButton",false); 
        }
        /*    if (selectedRows.length==1) 
        {
            component.set("v.showGenerateChartButton",true); 
        }
        else {
            component.set("v.showGenerateChartButton",false); 
          
        }*/
        
    }, 
    deleteButton : function(component , helper , event){
       var rowsList = component.get('v.selectedRowsList');
        var setOfIds = [];
        for(var row in rowsList){
            setOfIds.push(rowsList[row].Id);
        }
        component.set('v.allRecordId',setOfIds);
        component.set("v.showConfirmDialog",true);   
    },
    
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.openCareplan", false);
    },
    
    handleClickChart: function(component, event, helper){
        
        
        // alert(''+component.get("v.recordVal"));
        
        //alert('Rows:'+component.get('v.selectedRow'));
        
        component.set("v.patientChart" , true);
    },
    
    //Added by Anmol for LX3-8141
    handleClickSuperbill: function(component, event, helper){
        console.log('handleClickSuperbill***',JSON.stringify(component.get("v.selectedRowsList")));
        console.log('handleClickSuperbill***recordval',component.get("v.recordVal"));
        
        var lstCare = component.get("v.selectedRowsList");
        var ids=new Array();
        for (var i= 0 ; i < lstCare.length ; i++){
            ids.push(lstCare[i].Id);
        }
        
        var patientId = component.get("v.recordVal");
        
        if(patientId!=null && ids!=null){
            helper.genSuperBill(component, patientId,ids);
        }
    },
    //End by Anmol for LX3-8141
    
    closeModel: function(component, event, helper) {
        component.set("v.patientChart", false);
    },
    
    
    handleConfirmDialogNo:function(component, event, helper) {
        component.set("v.showConfirmDialog",false);
        Console.log("showConfirmDialog :"+showConfirmDialog);
    },
    handleConfirmDialogYes:function(component, event, helper) {
        var allIds = component.get('v.allRecordId');
        var action = component.get('c.deleteAllVisit');
        action.setParams({
            lstRecordId : allIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {    
                component.set("v.showConfirmDialog",false);
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "title": "Success",
                    "message": "Record is deleted Successfully!"
                 });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);  
        
    }
})