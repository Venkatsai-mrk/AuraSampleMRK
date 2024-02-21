({
    createPhysicalAnalysis : function(component) {
        var nameSpace = 'ElixirSuite__';
        var createObject = {};
        createObject['Name'] = '';
        createObject[nameSpace + 'Appearance__c'] = '';
        createObject[nameSpace + 'Bacteria__c'] = '';
        createObject[nameSpace + 'Bilrubin__c'] = '';
        createObject[nameSpace + 'Casts__c'] = '';
        createObject[nameSpace + 'Comments__c'] = '';
        createObject[nameSpace + 'Crystal__c'] = '';
        createObject[nameSpace + 'Examined_By__c'] = '';
        createObject[nameSpace + 'Notes__c'] = '';
        createObject[nameSpace + 'Examined_Datetime__c'] = '';
        createObject[nameSpace + 'Glucose__c'] = '';
        createObject[nameSpace + 'Leukocyte__c'] = '';
        createObject[nameSpace + 'Lab_Name__c'] = '';
        createObject[nameSpace + 'Mucus__c'] = '';
        createObject[nameSpace + 'PH__c'] = '';
        createObject[nameSpace + 'Picklist__c'] = '';
        createObject[nameSpace + 'Puss_Cells_W_B_C__c'] = '';
        createObject[nameSpace + 'Protein__c'] = '';
        createObject[nameSpace + 'Bacteria__c'] = '';
        createObject[nameSpace + 'Bilrubin__c'] = '';
        createObject[nameSpace + 'Casts__c'] = '';
        createObject[nameSpace + 'Comments__c'] = '';
        createObject[nameSpace + 'Red_Cells_R_B_C__c'] = '';
        createObject[nameSpace + 'Specific_Gravity__c'] = '';
        createObject[nameSpace + 'Schistosoma_Eggs__c'] = '';
        createObject[nameSpace + 'Specimen_Status__c'] = '';
        createObject[nameSpace + 'Spermatozoa__c'] = '';
        createObject[nameSpace + 'Trichomonas__c'] = '';
        createObject[nameSpace + 'Status__c'] = '';
        createObject[nameSpace + 'UA_Sample_Details__c'] = '';
        createObject[nameSpace + 'Urobilinogen__c'] = '';
        createObject[nameSpace + 'Type__c'] = '';
        createObject[nameSpace + 'Bilesalt__c'] = '';
        createObject[nameSpace + 'Yeast_Cells__c'] = ''; 
        createObject[nameSpace + 'Epithelial_Cells__c '] = ''; 
        createObject[nameSpace + 'Colour__c'] = ''; 
        component.set("v.physicalSampleAnalysis", createObject);
    },
    createLabDetails  : function(component) {
        var nameSpace = 'ElixirSuite__';
        var createObject = {};
        createObject[nameSpace + 'Name'] = '';
        createObject[nameSpace + 'Name_of_container__c'] = '';
        createObject[nameSpace + 'Account__c'] = '';
        createObject[nameSpace + 'Additives_if_Any__c'] = '';
        createObject[nameSpace + 'Collection_Datetime__c'] = '';
        createObject[nameSpace + 'ContainerSize__c'] = '';
        createObject[nameSpace + 'Comments__c'] = '';
        createObject[nameSpace + 'ContainerType__c'] = '';
        createObject[nameSpace + 'Container_Description__c'] = '';
        createObject[nameSpace + 'Lab_Code__c'] = '';
        createObject[nameSpace + 'Lab_Name__c'] = '';
        createObject[nameSpace + 'Lab_Location__c'] = '';
        createObject[nameSpace + 'Notes__c'] = '';
        createObject[nameSpace + 'Order_By__c'] = '';
        createObject[nameSpace + 'Order_to__c'] = '';
        createObject[nameSpace + 'Specimen_Collector__c'] = '';
        createObject[nameSpace + 'Specimen_Condition__c'] = '';
        createObject[nameSpace + 'Specimen_Quantity__c'] = '';
        createObject[nameSpace + 'Status__c'] = '';
        createObject[nameSpace + 'Laboratory_Analysis_Date__c'] = '';
        createObject[nameSpace + 'Physical_Analysis_Date__c'] = '';
        createObject[nameSpace + 'Analysis_Result__c'] = '';
        createObject[nameSpace + 'Specimen_Status__c'] = '';
        component.set("v.physicalLabDetails", createObject);
    },
    createLabAnalysis : function(component) {
        var nameSpace = 'ElixirSuite__' ;
        var createObject = {};
        createObject['Name'] = '';
        createObject[nameSpace + 'Appearance__c'] = '';
        createObject[nameSpace + 'Bacteria__c'] = '';
        createObject[nameSpace + 'Bilrubin__c'] = '';
        createObject[nameSpace + 'Casts__c'] = '';
        createObject[nameSpace + 'Comments__c'] = '';
        createObject[nameSpace + 'Crystal__c'] = '';
        createObject[nameSpace + 'Examined_By__c'] = '';
        createObject[nameSpace + 'Notes__c'] = '';
        createObject[nameSpace + 'Lab_Sample_Examined_Datetime__c'] = '';
        createObject[nameSpace + 'Ketone__c'] = '';
        createObject[nameSpace + 'Glucose__c'] = '';
        createObject[nameSpace + 'Leukocyte__c'] = '';
        createObject[nameSpace + 'Lab_Name__c'] = '';
        createObject[nameSpace + 'Mucus__c'] = '';
        createObject[nameSpace + 'PH__c'] = '';
        createObject[nameSpace + 'Picklist__c'] = '';
        createObject[nameSpace + 'Puss_Cells_W_B_C__c'] = '';
        createObject[nameSpace + 'Protein__c'] = '';
        createObject[nameSpace + 'Bacteria__c'] = '';
        createObject[nameSpace + 'Bilrubin__c'] = '';
        createObject[nameSpace + 'Casts__c'] = '';
        createObject[nameSpace + 'Comments__c'] = '';
        createObject[nameSpace + 'Red_Cells_R_B_C__c'] = '';
        createObject[nameSpace + 'Specific_Gravity__c'] = '';
        createObject[nameSpace + 'Schistosoma_Eggs__c'] = '';
        createObject[nameSpace + 'Specimen_Status__c'] = '';
        createObject[nameSpace + 'Spermatozoa__c'] = '';
        createObject[nameSpace + 'Trichomonas__c'] = '';
        createObject[nameSpace + 'Status__c'] = '';
        createObject[nameSpace + 'UA_Sample_Details__c'] = '';
        createObject[nameSpace + 'Urobilinogen__c'] = '';
        createObject[nameSpace + 'Type__c'] = '';
        createObject[nameSpace + 'Bilesalt__c'] = '';
        createObject[nameSpace + 'Yeast_Cells__c'] = ''; 
        createObject[nameSpace + 'Epithelial_Cells__c '] = ''; 
        createObject[nameSpace + 'Colour__c'] = ''; 
        component.set("v.labSampleAnalysis", createObject);
    },
    helperFun : function(component,event,secId) {
        var acc = component.find(secId);
              for(var cmp in acc) { 
              $A.util.toggleClass(acc[cmp], 'slds-show');  
              $A.util.toggleClass(acc[cmp], 'slds-hide');  
         }
      }
})