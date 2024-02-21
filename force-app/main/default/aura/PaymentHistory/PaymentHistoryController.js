({
    doInit : function(component) {
        
        var nameSpace='ElixirSuite__';
        component.set("v.Fdate",null);
        component.set("v.Tdate",null);
        component.set("v.errorType",'');
        component.set('v.selectedRows', "");
        component.set("v.showPrintButton",false);
        
        /* var actions = [
           
            {label: 'DELETE', name: 'DELETE'},
            
        ];*/
        
        component.set('v.mycolumns', [
            
            {
                label: 'Transaction Number',
                fieldName: 'linkName',
                type: 'url' ,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank' ,variant:'Base' }
            },
            //{label: 'Payment Allocation', fieldName:  nameSpace+ 'Payment_Type__c', type: 'text'},
            //{label: 'Payment Type', fieldName:   'Payment_By__c', type: 'text'},
            {label: 'Transaction Date', fieldName: nameSpace+'Transaction_Date__c', type: 'date', typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric',  
              }},
            {label: 'Received From', fieldName:  nameSpace+ 'Payment_Received_By__c', type: 'text'},
            {label: 'Amount Received ($)', fieldName:  nameSpace+ 'Total_Amount_Paid__c', type: 'currency'},
            //{label : 'Interest/Late Filling Charges',fieldName:'ElixirSuite__Interest_Late_Filling_Charges__c'} //Commented by Anusha LX3-5610
            // {	fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } }
        
        ]);
        var patientId = component.get("v.patId");
        var action = component.get("c.BringData");
        action.setParams ({
            ids : patientId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().transactions;
                records.forEach(function(record){
                    record['linkName'] = '/'+record.Id;
                    if(record['ElixirSuite__Total_Amount_Paid__c']!=null && record['ElixirSuite__Interest_Late_Filling_Charges__c']){//Anusha -start-LX3-5610
                        record['ElixirSuite__Total_Amount_Paid__c']+=record['ElixirSuite__Interest_Late_Filling_Charges__c']
                    }//Anusha -end-LX3-5610
                });
                component.set("v.data", records);
                console.log('final ' + JSON.stringify(records));
                component.set("v.listDetails", records.formData);
                component.set("v.totalCount",response.getReturnValue().totalCount);
                
            }
        });
        
        $A.enqueueAction(action);
        
        
        
    },
    LoadViewAll : function(component) {
        
        /* var actions = [
           
            {label: 'DELETE', name: 'DELETE'},
            
        ];*/
        var nameSpace ='ElixirSuite__';
        component.set('v.mycolumns', [
            
            {
                label: 'Transaction Number',
                fieldName: 'linkName',
                type: 'url' ,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank' ,variant:'Base' }
            },
            {label: 'Transaction Date', fieldName: nameSpace+'Transaction_Date__c', type: 'date', typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric',  
                }},
          //  {label: 'Payment Allocation', fieldName:   nameSpace+'Payment_Type__c', type: 'text'},
          //  {label: 'Payment Type', fieldName:  nameSpace+ 'Payment_By__c', type: 'text'},
           /* {label: 'Transaction Date', fieldName: nameSpace+'Transaction_Date__c', type: 'date', typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric',  
                hour: '2-digit',  
                minute: '2-digit',  
                second: '2-digit',  
                hour12: true}},*/
            //Replaced 'Payment_By__c' with 'Payment_Received_By__c' in 'recieved From' filed Name by Anusha
            {label: 'Received From', fieldName:   nameSpace+'Payment_Received_By__c', type: 'text'},
            {label: 'Amount Received ($)', fieldName:   nameSpace+'Total_Amount_Paid__c', type: 'currency'},
            //{label : 'Interest/Late Filling Charges',fieldName:'ElixirSuite__Interest_Late_Filling_Charges__c'} //Added by Anusha -04/10/22 //Commented by Anusha-LX3-5610
            // {	fieldName: 'Actions',type: 'action', typeAttributes: { rowActions: actions } }
            
            
            
            
        ]);
        var patientId = component.get("v.patId");
        var action = component.get("c.BringDataViewAll");
        action.setParams ({
            ids : patientId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().transactions;
                records.forEach(function(record){
                    record['linkName'] = '/'+record.Id;
                    if(record['ElixirSuite__Total_Amount_Paid__c']!=null && record['ElixirSuite__Interest_Late_Filling_Charges__c']){//Anusha -start-LX3-5610
                        record['ElixirSuite__Total_Amount_Paid__c']+=record['ElixirSuite__Interest_Late_Filling_Charges__c']
                    }//Anusha -end-LX3-5610
                });
                component.set("v.data", records);
                component.set("v.listDetails", records.formData);
                component.set("v.totalCount",response.getReturnValue().totalCount);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    
    selectedRows : function(component, event) {
        console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));        
        console.log('all rows '+  JSON.stringify(component.get('v.selectedRows')));        
        component.set("v.selectedLabOrders",event.getParam('selectedRows'));
        
        //  var selectedRows = component.get('v.selectedRows');
        var selectedRows =  event.getParam('selectedRows');
               
        
        if(selectedRows.length==1) 
        {
            
            component.set("v.showDeleteButton",true);
            component.set("v.showPrintButton",true);
          
        }
        else {
            
            component.set("v.showDeleteButton",false);
            component.set("v.showPrintButton",false);
            
        }
        
    },
    handleRowAction : function(component, event) {
        
        var recId = event.getParam('row').Id;
        alert(recId);
        component.set("v.selectedRow",recId);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": 'lightning/r/ElixirSuite__Master_Transaction__c/'+recId+'/view'
        });
        urlEvent.fire();
        
    },
    
    updateSelectedText : function(component, event){
        
        var selectedRows = event.getParam('selectedRows');
        
      //  var arrToIterate = JSON.parse(JSON.stringify(selectedRows));
        component.set("v.selectedRowsCount" ,selectedRows.length );
        let obj =[] ; 
        
        if(selectedRows.length==1) 
        {  
           
            if((selectedRows[0].ElixirSuite__Reason_Of_Payment__c == 'Applied Payment') && (selectedRows[0].ElixirSuite__Transactions__r[0].ElixirSuite__Payment_Received_By__c =='Patient')){
                
                component.set("v.showPrintButton",true); 
                component.set("v.showPdfButton",true);
            }else{
                
                component.set("v.showPrintButton",false); 
            component.set("v.showPdfButton",true);
            }
            
        }	
        else {	
            component.set("v.showPrintButton",false); 
            component.set("v.showPdfButton",true);
        }
      
        for (var i = 0; i < selectedRows.length; i++)
        {            
            obj.push({Name:selectedRows[i].Name});   
        }
     
        //component.set("v.selectedRowsDetails" ,JSON.stringify(obj) );
        component.set("v.selectedRowsList" ,event.getParam('selectedRows') );
        
    },
    exportAsPDF :  function (component) {
        
        //var recordId=component.get("v.recordId");
    
        var selectedRows = component.get("v.selectedRowsList");	
        
        console.log('for exportPDF row selected is '+JSON.stringify(selectedRows));                	
         
        var caseId=selectedRows[0].Id;
        var url = '/apex/ElixirSuite__PrintReceiptPdf?tranId='+caseId;
       
        if(selectedRows[0].ElixirSuite__Transactions__r[0].ElixirSuite__Payment_Received_By__c=='Patient'){
            var newWindow;	
            newWindow = window.open(url);	
            newWindow.focus();	
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "Warning",
                "title": "Warning!",
                "message": "Please Select Record Received From Patient!"
            });
            toastEvent.fire();
        }
    },
    
    handleConfirmDialogNo:function(component) {
        component.set("v.showConfirmDialog",false);
        
    },
    handleConfirmDialogYes :  function(component) {
        // alert(component.get("v.RowId"));
        var action = component.get("");
        action.setParams({ recordToDelete : component.get("v.RowId") });
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
                component.set("v.isOpen", false);
                $A.get('e.force:refreshView').fire();
                //  component.set("v.data",res);
            }
        }); 
        
        $A.enqueueAction(action);
        
        
        
        
    },
    sendSelectedClaimId: function (component) {
        var selectedRows = component.get("v.selectedLabOrders");
        console.log('Lab Order Id'+JSON.stringify(selectedRows));
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].Id);
        }
        console.log('claim IDs'+selectedIds);
        var action = component.get("c.generateXML");
        action.setParams({ claimIds : selectedIds });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                
            }
        });
        $A.enqueueAction(action);
        
    },
    deleteSelectedRows: function (component) {
        var selectedRows = component.get("v.selectedLabOrders");
        console.log('Lab Order Id'+JSON.stringify(selectedRows));
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].Id);
        }
        //helper.deleteSelectedHelper(component, event, selectedIds);
    },
    updateSelectedRows: function (component) {
        var selectedRows = component.get("v.selectedLabOrders");
        console.log('Lab Order Id'+JSON.stringify(selectedRows));
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].Id);
        }
        //helper.updateSelectedHelper(component, event, selectedIds);
    },
    createClaim : function() {
        var recordEvent=$A.get("e.force:createRecord");
        recordEvent.setParams({
            "entityApiName": "ElixirSuite__Claim__c",
            "defaultFieldValues":{
                
            }
        });
        recordEvent.fire();
    },
    FilteredData1 : function(component, event, helper) {
        let flag = helper.computeDates(component);
        if(flag == 1){
            return;
        }
        component.set("v.viewAllBool", false);
        component.set("v.viewAllBoolgo", true);
        var patientId = component.get("v.patId");
        var action = component.get("c.BringFilterData");
        
        action.setParams({fromDate:component.get("v.Fdate"),
                          toDate:component.get("v.Tdate"),
                          ids : patientId
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().transactions;
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                component.set("v.data", records);
                console.log('final ' + JSON.stringify(records));
                component.set("v.listDetails", records.formData);
                component.set("v.totalCount",response.getReturnValue().totalCount);
            }
        });
        
        $A.enqueueAction(action);
    },
    checkDates : function(component, event, helper){
        helper.computeDates(component, event, helper);
    },
    
    FilteredViewAll : function(component) {
        var patientId = component.get("v.patId");
        
        var action = component.get("c.BringFilterDataViewAll");
        
        action.setParams({fromDate:component.get("v.Fdate"),
                          toDate:component.get("v.Tdate"),
                          ids : patientId
                         });     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().transactions;
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                    if(record['ElixirSuite__Total_Amount_Paid__c']!=null && record['ElixirSuite__Interest_Late_Filling_Charges__c']){//Anusha -start-LX3-5610
                        record['ElixirSuite__Total_Amount_Paid__c']+=record['ElixirSuite__Interest_Late_Filling_Charges__c']
                    }//Anusha -end-LX3-5610
                });
                component.set("v.data", records);
                console.log('final ' + JSON.stringify(records));
                component.set("v.listDetails", records.formData);
                component.set("v.totalCount",response.getReturnValue().totalCount);
            }
        });
        
        $A.enqueueAction(action);
    },
    openPopUp : function(component){
        component.set("v.isClaimList",true);  
        console.log('bwjf' , component.get("v.isClaimList"));
    },
    
})