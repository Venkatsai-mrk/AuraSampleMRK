({
    setFlySyncDataForPageOne : function(component, event, helper) {
        helper.setDiagnosisKeys(component, event, helper);
        helper.setProcedureKeys(component, event, helper);
        let chartSummaryOptions = component.get("v.chartSummaryOptions");
       /* for(let rec in chartSummaryOptions){
            if(chartSummaryOptions[rec].label ==='Procedure Codes'){
                chartSummaryOptions[rec].entityData = component.get("v.patientProcedureLst");
                
            }
            else if(chartSummaryOptions[rec].label ==='Diagnosis Codes'){
                chartSummaryOptions[rec].entityData = component.get("v.patientDiagnosisLst");
                console.log('setFlySyncDataForPageOne() chartSummaryOptions patientDiagnosisLst - '+JSON.stringify(chartSummaryOptions[rec].entityData ));
            }
        }*/
        component.set("v.accountName",component.get("v.accountName")); 
        component.set("v.userName",component.get("v.userName")); 
        component.set("v.contactName",component.get("v.contactName")); 
        component.set("v.patientDiagnosisLst",component.get("v.patientDiagnosisLst"));
        component.set("v.patientProcedureLst",component.get("v.patientProcedureLst"));            
        console.log('setFlySyncDataForPageOne() patientProcedureLst - '+JSON.stringify(component.get("v.patientProcedureLst") ));
        console.log('setFlySyncDataForPageOne()  patientDiagnosisLst - '+JSON.stringify(component.get("v.patientDiagnosisLst")));
        component.set("v.referralRecord",component.get("v.referralRecord"));
        component.set("v.chartSummaryOptions",chartSummaryOptions);
        component.set("v.files",component.get("v.files"));
    },
    setDiagnosisKeys : function(component, event, helper) {
        let diagnosisLst =  component.get("v.patientDiagnosisLst") ;
        diagnosisLst.forEach(function(element, index) {
            element['column_1'] = element.ElixirSuite__Diagnosis_Code_and_Name__c;
            element['column_2'] = element.ElixirSuite__Code_Description1__c;
            element['column_3'] = element.ElixirSuite__Version__c;
            element['column_4'] = element.CreatedDate;
        });  
        component.set("v.patientDiagnosisLst",diagnosisLst) ;
    },
    setProcedureKeys : function(component, event, helper) {
        let procedureLst =  component.get("v.patientProcedureLst") ;
        procedureLst.forEach(function(element, index) {
            element['column_1'] = element.Name;
            element['column_2'] = element.ElixirSuite__Code_Description__c;
            element['column_3'] = element.ElixirSuite__Code_Category__c;
            element['column_4'] = element.CreatedDate;
        });  
        component.set("v.patientProcedureLst",procedureLst) ;
    },
    setFlySyncDataForPageTwo : function(component, event, helper) {
        component.set("v.patientDiagnosisLst",component.get("v.patientDiagnosisLst"));
        component.set("v.patientProcedureLst",component.get("v.patientProcedureLst"));            
        component.set("v.referralRecord",component.get("v.referralRecord"));
        component.set("v.chartSummaryOptions",component.get("v.chartSummaryOptions"));
        component.set("v.patientVOBDetails",component.get("v.patientVOBDetails"));
        component.set("v.patientInfo",component.get("v.patientInfo")); 
        component.set("v.files",component.get("v.files"));
    }
})