({
	helperMethod : function(component) {
		   component.set('v.mycolumns', [
            
            {
                label: 'Estimate RecordName',
                fieldName: 'linkName',
                type: 'button' ,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank' ,variant:'Base' }
            },
            
            
            {label: 'Patient Responsibility($)', fieldName: 'ElixirSuite__Patient_responsibility__c', type: 'currency'},
            {label: 'Insurer Responsibility($)', fieldName: 'ElixirSuite__Insurer_Responsibility__c', type: 'currency'},
            /*{label: 'In-Use', fieldName: 'Status__c ', type: 'text'},*/
            {fieldName: 'ElixirSuite__In_Use__c',label: "In-Use",type: "boolean",cellAttributes: {
                    iconName: {
                        fieldName: 'IconName'
                    },
                    iconPosition: "left"
                }},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric'
            }}
        ]);
        var patientId = component.get("v.patId");
         component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.BringData");
        action.setParams ({
            ids : patientId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
                if (state === "SUCCESS") {
                 component.find("Id_spinner").set("v.class" , 'slds-hide');
                console.log('form data '+JSON.stringify(response.getReturnValue()));                
                var records =response.getReturnValue();
                records.forEach(function(record){  
                    /*  if(!$A.util.isUndefinedOrNull(record.ElixirSuite__Patient_responsibility__c)){
                       record.ElixirSuite__Patient_responsibility__c = '$ ' +   record.ElixirSuite__Patient_responsibility__c
                    }
                    else {
                         record.ElixirSuite__Patient_responsibility__c = '$ 0'
                    }
                     if(!$A.util.isUndefinedOrNull(record.ElixirSuite__Insurer_Responsibility__c)){
                       record.ElixirSuite__Insurer_Responsibility__c = '$ ' +   record.ElixirSuite__Insurer_Responsibility__c
                    }
                    else {
                         record.ElixirSuite__Insurer_Responsibility__c = '$ 0'
                    }*/
                   /* if (record.In_Use__c) {
                        record.IconName = 'utility:check';
                    } else {
                        record.IconName = 'utility:close';
                    }*/
                    if (record.ElixirSuite__In_Use__c == false) {
                        record.IconName = 'utility:close';
                    }
                    //record.linkName = '/'+record.Id;
                    /*var rec =  record.Status__c;
                    record.Status__c = rec.valueOf();*/
                    
                });
                component.set("v.data", records);
                console.log('final ' + JSON.stringify(records));
                component.set("v.listDetails", records.formData);
                
            }
        });
        
        $A.enqueueAction(action);
	},
       computeDates : function(component, event, helper) {
        component.set("v.errorType",'');
        let startDate = component.get("v.Fdate");
        let endDate = component.get("v.Tdate");
        if($A.util.isUndefinedOrNull(startDate)){
            component.set("v.errorType",'Fdate');
            component.set("v.errorMsg",'From Date cannot be empty');
            return 1;
        }
        if($A.util.isUndefinedOrNull(endDate)){
            component.set("v.errorType",'Tdate');
            component.set("v.errorMsg",'To Date cannot be empty');
            return 1;
        }
        if(startDate>=endDate){  
            component.set("v.errorType",'Tdate');
            component.set("v.errorMsg",'To Date cannot less than From Date');
            return 1;
        }
    }
})