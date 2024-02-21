({
    init: function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Medication Name', fieldName: 'ElixirSuite__Drug_Name__c', type: 'text'},
            {label: 'Reason', fieldName: 'ElixirSuite__Reason_new__c', type: 'text'},
            {label: 'Days', fieldName: 'ElixirSuite__Number_of_Times_Days_Weeks__c', type: 'text'},
            {label: 'Route', fieldName: 'ElixirSuite__Route_New__c', type: 'text'},
            {label: 'Dosage', fieldName: 'ElixirSuite__Dosage_Form__c', type: 'text'},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes:{
                year: "numeric",
                month: "short",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            }},
            {label: 'Created By', fieldName: 'createdByName', type: 'text'},
            {label: 'Modified Date', fieldName: 'LastModifiedDate', type: 'date', typeAttributes:{
                year: "numeric",
                month: "short",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            }}
        ]);
        
        helper.fetchPrescriptionOrders(component, event, helper); 
    }
})