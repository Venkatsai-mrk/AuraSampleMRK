({
	doInit : function(component, event, helper) {
		component.set('v.columns', [
            {label: 'Credit Transaction', fieldName: 'Name', type: 'text', sortable :true },
            {label: 'Credit Type', fieldName: 'ElixirSuite__Reason_Of_Payment__c', type: 'text', sortable :true},
            {label: 'Remaining Amount', fieldName: 'ElixirSuite__Total_Remaining_Unallocated_Amount__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
            {label: 'Original Amount Credited', fieldName: 'ElixirSuite__Total_Unallocated_Amount__c', type : 'currency', sortable :true,cellAttributes: { alignment: 'left' }},
            {label: 'Credit Issue Date', fieldName: 'ElixirSuite__Transaction_Date__c', type: 'date', sortable :true, typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric'  
                }},
            {label: 'Credit Reference Number', fieldName: 'ElixirSuite__Reference_Number__c', type : 'text', sortable :true},
            
        ]);
        console.log('Credit1','Inside');
		var action = component.get("c.fetchCreditData");
           action.setParams({ accountId : component.get("v.recordId") });
           action.setCallback(this, function(response) {
               var state = response.getState();
               if (state === "SUCCESS") {
                   console.log('Credit',response.getReturnValue());
                   var rowList = response.getReturnValue();
            		let patientCredit = [];
                    let unallocated = [];
                   if(rowList.length > 0){
                       component.set("v.disableCreditTable", true);
            			for(var recdata in response.getReturnValue()){
            				if(rowList[recdata].ElixirSuite__Mode_of_Payment__c == 'Patient Credit'){
                                rowList[recdata]['ElixirSuite__Reason_Of_Payment__c'] = 'Patient Credit';
                                patientCredit.push(rowList[recdata]);
                            }else{
                                 unallocated.push(rowList[recdata]);
                            }
            			}
            			const combinedList = patientCredit.concat(unallocated);
             			console.log('combinedList',combinedList);
            			component.set("v.creditData", combinedList);
                   }
               }
           
            });
           
           $A.enqueueAction(action);
       },
       
       handleSort: function(component,event,helper){
        var sortBy = event.getParam("fieldName");       
        var sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        
        helper.sortData(component,sortBy,sortDirection);
    },
       handleCredit : function(component, event, helper) {
        var selectedRows =  event.getParam('selectedRows'); 
           console.log('selectedRows1122',selectedRows);
        var cmpEvent = component.getEvent("changehandlerEvent");
        cmpEvent.setParams( { "recordList" :  selectedRows} );
        cmpEvent.fire();
       }
})