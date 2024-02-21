({
    /***Nikhil-----****/
    checkCareEpisodehelper:function(component , event , helper,patientId){        
        var action = component.get("c.checkCareEpisode");    
        action.setParams({
            "patientId":patientId
        });
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                var returnval=response.getReturnValue();
              
                if(returnval==true){          
                    component.set("v.careModal",true);
                }else{                   
                  component.set("v.medicationListView",true);                  
                  /*var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                             componentDef:"c:ElixirHC_MedicationComponent",
                             componentAttributes:{
                                 backPage:true,
                              }
                           });
                       evt.fire();*/
                }
            }
        });
        $A.enqueueAction(action);
    },
    //Added by Ashwini
    fetchAccountName:function(component){
        var action = component.get("c.fetchAccountName");
           action.setParams({ accountId : component.get("v.recordVal") });
           action.setCallback(this, function(response) {
               var state = response.getState();
               if (state === "SUCCESS") {
                   
                   console.log('Patient name  data '+JSON.stringify(response.getReturnValue()));                
                   var records =response.getReturnValue();
                   component.set("v.accName", records);
                   
               }
           
            });
           
           $A.enqueueAction(action);
       },
    
    //Added by Himanshu
    fetchColumns:function(component, event){
        console.log('inside helper');
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
        
        const tableColumns = [
            {
                label: 'Order Name',
                fieldName: 'presName',
                type: 'button' ,typeAttributes:  {label: { fieldName: 'presName' }, target: '_blank' , name: '',variant:'Base' }
            },
            {
                label: 'Status',
                fieldName: 'presStatus',
                type: 'text'
                
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
            {label: 'LastModified Date', fieldName: 'lastModifiedDate', type: 'date', typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric',  
                hour: '2-digit',  
                minute: '2-digit',  
                second: '2-digit',  
                hour12: true}},  
            {type: "button", typeAttributes: {  name: 'Edit', title: 'Edit', disabled: { fieldName: 'isActive' },
                                              value: 'edit', iconName: 'utility:edit',variant:'Base' },"cellAttributes": { "class": { "fieldName": "showClass4" }}}
        ];
        console.log('tableColumns ',tableColumns);
        console.log('recordVal', component.get("v.recordVal"));
        var nameOfOrder =   {
            label: 'Order Name',
            fieldName: 'presName',
            type: 'button' ,typeAttributes:  {label: { fieldName: 'presName' }, target: '_blank' , name: '',variant:'Base' }
        };
        
        
        var dateOfLastModified = {label: 'LastModified Date', fieldName: 'lastModifiedDate', type: 'date', typeAttributes: {  
            day: 'numeric',  
            month: 'short',  
            year: 'numeric',  
            hour: '2-digit',  
            minute: '2-digit',  
            second: '2-digit',  
            hour12: true}};  
        
        var editButton = {type: "button", typeAttributes: {  name: 'Edit', title: 'Edit', disabled: { fieldName: 'isActive' },
                value: 'edit', iconName: 'utility:edit',variant:'Base' },"cellAttributes": { "class": { "fieldName": "showClass1" }}};
        
        
        console.log('before setting columns');
        var columnsToShow = [];	
        console.log('columns === ', columns);
        if(!$A.util.isUndefinedOrNull(columns)){
            tableColumns.forEach(function(column){ 
                if(columns.includes(column.fieldName)){
                    columnsToShow.push(column);
                }        
            });
            columnsToShow = [nameOfOrder,...columnsToShow,dateOfLastModified,editButton];
            component.set('v.Orderscolumns',columnsToShow); 
        }
        
        var action = component.get("c.fetchPrescription");
        action.setParams({ accountId : component.get("v.recordVal") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response.getState();', response.getState());
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
                            columnsToShow = [nameOfOrder,...columnsToShow,dateOfLastModified,editButton];
                        }
                        catch(e){
                            columnsToShow = [nameOfOrder, dateOfLastModified,editButton];
                        }
                        console.log('columns '+JSON.stringify(columnsToShow));
                        component.set('v.Orderscolumns',columnsToShow); 
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
                    /*if(record['status'] == 'Open'){
                            record.showClass = 'redcolor';
                        }else if(record['status'] == 'In Progress'){
                            record.showClass = 'bluecolor';  
                        }else if(record['status'] == 'Completed') {
                            record.showClass = 'greencolor';
                        }*/
                        
                        let approvedLevelsCount = record.approvedLevelsCount;
                        let defaultLevelCount = record.defaultLevelCount;
                        console.log('defaultLevelCount '+defaultLevelCount);
                        console.log('approvedValues '+approvedLevelsCount);
                            for(let level=1;level<4;level++){
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
                        
                    });
                component.set("v.OrderlistDetails", res);
            }
            
        });
        
           $A.enqueueAction(action);
       },
	sortData: function (cmp, helper, fieldName, sortDirection) {
        var data = cmp.get("v.allData");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.allData", data);
        helper.buildData(cmp, helper);
    },
    fetchNspc: function (component) {
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
    //for selecting order of sorting
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    setTime: function(cmp){
        var currentTime = cmp.get("v.time");
        cmp.set("v.time", (currentTime+1));
     },
    deleteSelectedHelper: function(component, event, helper, selectedIds) {

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
    }
})