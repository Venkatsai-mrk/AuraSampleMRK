({
    doInit : function(component, event, helper) {
        
        helper.fetchAccountName(component, event, helper) ;
           var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            // var focusedTabId = response.tabId;
            // console.log('afcresponse',response);
            var focusedTabId = response.tabId;
            var issubTab = response.isSubtab;
            // console.log('afctab',focusedTabId);
            if(issubTab)
            {
                workspaceAPI.getTabInfo(
                    { tabId:focusedTabId}
                ).then(function(response1){
                    
                    //  console.log('afctabinfo',response1);
                });
                workspaceAPI.setTabLabel({
                    
                    label: "Payment Schedule"
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                    //  console.log('afctabinfo',response1);
                });
                workspaceAPI.setTabLabel({
                    label: "Payment Schedule"
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:trending",
                iconAlt: "Payment Schedule"
            });
        })
        
        
        var action3 = component.get('c.LicensBasdPermission');
        action3.setParams({
        });
        
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                
                var wrapList = response.getReturnValue();
                component.set("v.Ehr",wrapList.isEhr);
                component.set("v.Billing",wrapList.isRcm);
                component.set("v.ContactCentr",wrapList.isContactCenter);
            }
        });
        $A.enqueueAction(action3);
        component.set("v.Fdate",null);
        component.set("v.Tdate",null);
        component.set("v.errorType",'');
        var patientId = component.get("v.patId");
        var action = component.get("c.BringData");
        action.setParams ({
            ids : patientId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().payments;
                records.forEach(function(record){
                    record['linkName'] = '/'+record.Id;
                });
                component.set("v.data", records);
                component.set("v.totalCount",response.getReturnValue().totalCount);
                component.set("v.listDetails", records.formData);
                
            }
        });
        
        $A.enqueueAction(action);
          var actions = [
            { label: 'Delete', name: 'delete' } ];
        
        component.set('v.mycolumns', [
            
            {
            label: 'Payment Schedule Name',
            fieldName: 'linkName',
            type: 'url' ,typeAttributes: {label: { fieldName: 'Name' }, target: '_self'  ,variant:'Base'}
            },
            
            {label: 'Frequency', fieldName:'ElixirSuite__Pay_Frequency__c', type: 'text'},
            {label: 'Installment Amount', fieldName:   'ElixirSuite__Installment_Amount__c', type: 'currency', cellAttributes: {
            alignment: 'center'
        }},
            {label: 'Total Amount', fieldName: 'ElixirSuite__Net_Balance__c', type: 'currency', cellAttributes: {
            alignment: 'center'
        }},
            {label: 'Status', fieldName: 'ElixirSuite__Payment_Status__c', type: 'text'},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: {  
                                                                            day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric'
                                                                             }}, 
            { type: 'action', typeAttributes: { rowActions: actions }}
        ]);
 
    },
    
    LoadViewAll : function(component, event, helper) {
        var actions = [
            { label: 'Delete', name: 'delete' } ];

 
            component.set('v.mycolumns', [
            
            {
            label: 'Payment ScheduleName',
            fieldName: 'linkName',
            type: 'url' ,typeAttributes: {label: { fieldName: 'Name' }, target: '_self' ,variant:'Base'}
            },
            
            {label: 'Frequency', fieldName:'ElixirSuite__Pay_Frequency__c', type: 'text'},
            {label: 'Installment Amount', fieldName:   'ElixirSuite__Installment_Amount__c', type: 'currency', cellAttributes: {
            alignment: 'center'
        }},
            {label: 'Total Amount', fieldName: 'ElixirSuite__Net_Balance__c', type: 'currency', cellAttributes: {
            alignment: 'center'
        }},
            {label: 'Status', fieldName: 'ElixirSuite__Payment_Status__c', type: 'text'},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: {  
                                                                            day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric'
                                                                             }},
                { type: 'action', typeAttributes: { rowActions: actions } }
        ]);
        var patientId = component.get("v.patId");
        //console.log('Patient Id is:'+patientId);
        var action = component.get("c.BringDataViewAll");
        action.setParams ({
            ids : patientId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue().payments;
                records.forEach(function(record){
                    record['linkName'] = '/'+record.Id;
                });
                component.set("v.data", records);
                component.set("v.totalCount",response.getReturnValue().totalCount);
                component.set("v.listDetails", records.formData);
                
            }
        });
        
        $A.enqueueAction(action);
    
    },
    //Added by Pratiksha
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
                "recordId": component.get("v.patId")
            });
            navEvt.fire();
        },
    //End
    
    selectedRows : function(component, event, helper) {
        console.log('seleceted rows'+ JSON.stringify(event.getParam('selectedRows')));        
        console.log('all rows '+  JSON.stringify(component.get('v.selectedRows')));        
        component.set("v.selectedLabOrders",event.getParam('selectedRows'));
        //  var selectedRows = component.get('v.selectedRows');
        var selectedRows =  event.getParam('selectedRows');
        if(selectedRows.length>=1) 
        {
            component.set("v.showDeleteButton",true); 
        }
        else {
            component.set("v.showDeleteButton",false); 
        }
        
    },
    handleRowAction : function(component, event, helper) {
         var action = event.getParam( 'action' );
        var recId = event.getParam('row').Id;
        var urlEvent = $A.get("e.force:navigateToURL");
          switch ( action.name ) {
            case 'delete':
                var action1 = component.get("c.deleteSchedule");
                  action1.setParams({
                      "toDelete": recId 
                  });
                 $A.enqueueAction(action1);
                $A.enqueueAction(component.get('c.doInit'));
                break;
              default:
                   urlEvent.setParams({
            "url": 'lightning/r/ElixirSuite__Payment_Schedule__c/'+recId+'/view'
        });
        urlEvent.fire();
        }
    },
    
    handleConfirmDialogNo:function(component, event, helper) {
        component.set("v.showConfirmDialog",false);
        
    },
    handleConfirmDialogYes :  function(component, event, helper) {
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
    sendSelectedClaimId: function (component, event, helper) {
        var selectedRows = component.get("v.selectedLabOrders");
        console.log('Lab Order Id'+JSON.stringify(selectedRows));
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].Id);
        }
        console.log('claim IDs'+selectedIds);
        var action = cmp.get("c.generateXML");
        action.setParams({ claimIds : selectedIds });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                
            }
        });
        $A.enqueueAction(action);
        
    },
    deleteSelectedRows: function (component, event, helper) {
        var selectedRows = component.get("v.selectedLabOrders");
        console.log('Lab Order Id'+JSON.stringify(selectedRows));
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].Id);
        }
        //helper.deleteSelectedHelper(component, event, selectedIds);
    },
    updateSelectedRows: function (component, event, helper) {
        var selectedRows = component.get("v.selectedLabOrders");
        console.log('Lab Order Id'+JSON.stringify(selectedRows));
        var selectedIds = [];
        for (var i = 0; i < selectedRows.length; i++) {
            selectedIds.push(selectedRows[i].Id);
        }
        //helper.updateSelectedHelper(component, event, selectedIds);
    },
    createClaim : function(component, event, helper) {
        var recordEvent=$A.get("e.force:createRecord");
        recordEvent.setParams({
            "entityApiName": "ElixirSuite__Claim__c",
            "defaultFieldValues":{
                
            }
        });
        recordEvent.fire();
    },
    FilteredData1 : function(component, event, helper) {
        let flag = helper.computeDates(component, event, helper);
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
                var records =response.getReturnValue().payments;
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                component.set("v.data", records);
                component.set("v.totalCount",response.getReturnValue().totalCount);
                component.set("v.listDetails", records.formData);
                
            }
        });
        
        $A.enqueueAction(action);
    },
      checkDates : function(component, event, helper){
        helper.computeDates(component, event, helper);
    },
        FilteredViewAll : function(component, event, helper) {
        
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
                var records =response.getReturnValue().payments;
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                component.set("v.data", records);
                component.set("v.totalCount",response.getReturnValue().totalCount);
                component.set("v.listDetails", records.formData);
                
            }
        });
        
        $A.enqueueAction(action);
    },
    openPopUp : function(component,event){
        component.set("v.isClaimList",true);  
        console.log('bwjf' , component.get("v.isClaimList"));
    },
    opennew:function(component,event){
         component.set("v.NewPaySchedule",true);
       component.get("v.patientID")
      /* var action = component.get("c.paymentschedule");
    action.setParams({
      patientId:component.get("v.patId")
    });
    action.setCallback(this, function(response) {
      if (response.getState() === "SUCCESS") {
        var returnval = response.getReturnValue();
        if(returnval==true){          
          component.set("v.careModal",true);
           component.set("v.heading" , 'Payment Schedule');
             component.set("v.patId");
        }  
          else {
              
          var evt = $A.get("e.force:navigateToComponent");
          evt.setParams({
            componentDef: "c:PaymentScheduleForEHRCmp",
              componentAttributes: {
              recordId: component.get("v.patId"),
              isOpen:true
                  }
          });
          evt.fire();
        }
      }
    });
    $A.enqueueAction(action); */
    }
    
})