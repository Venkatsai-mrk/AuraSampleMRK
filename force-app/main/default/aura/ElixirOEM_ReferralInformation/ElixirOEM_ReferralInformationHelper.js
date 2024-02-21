({
    uploadHelper: function(component,f) {
       	component.set("v.showLoadingSpinner", true);
       	var file = f;
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.showLoadingSpinner", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }

        // Convert file content in Base64
        var objFileReader = new FileReader();
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            self.uploadProcess(component, file, fileContents);
        });

        objFileReader.readAsDataURL(file);
    },
    showMessage : function(message,isSuccess) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": isSuccess?"Success!":"Error!",
            "type":isSuccess?"success":"error",
            "message": message
        });
        toastEvent.fire();
    },
    setDefaultJSON : function(component) {
   
        let csOptions = [
            {'label' : 'Vitals','isOpen' : false,'disabled' : false,'entityData' : [],'col_1': 'Temperature','col_2': 'Pulse','col_3': 'Blood Pressure','col_4': 'BMI'},
            {'label' : 'Diagnosis Codes','isOpen' : false,'disabled' : false,'entityData' : [],'col_1': 'Diagnosis Code','col_2': 'Description','col_3': 'ICD Version'},
            {'label' : 'Allergies','isOpen' : false,'disabled' : false,'entityData' : [],'col_1': 'Allergy Name','col_2': 'Reaction','col_3': 'Severity','col_4': 'Notes'},
            {'label' : 'Procedure Codes','isOpen' : false,'disabled' : false,'entityData' : [],'col_1': ' Procedure Code','col_2': 'Description','col_3': 'Code Category'},
            {'label' : 'Problems','isOpen' : false,'disabled' : false,'entityData' : [],'col_1': 'Problem','col_2': 'SNOMED CT Code','col_3': 'Problem Type','col_4': 'Date Onset'},
            {'label' : 'Medications','isOpen' : false,'disabled' : false,'entityData' : [],'col_1': 'Medication Name','col_2': 'Reason','col_3': 'Route','col_4': 'Days'},
            {'label' : 'Notes','isOpen' : false,'disabled' : false,'entityData' : [],'col_1': 'Note Name','col_2': 'Category','col_3': 'Created By'}, 
            {'label' : 'Lab Results','isOpen' : false,'disabled' : false,'entityData' : [],'col_1': 'Lab Order','col_2': 'Medical Test','col_3': 'Status'}];
        
        component.set("v.chartSummaryOptions",csOptions);       
    },
    setDefaultData : function() {
        
    },
    setDefaultChartEntities : function(component, event, helper,response) {        
        helper.addBooleanKeys(component, event, helper,response.vitalData);
        helper.addBooleanKeys(component, event, helper,response.allergyData);
        helper.addBooleanKeys(component, event, helper,response.patientProblems);
        helper.addBooleanKeys(component, event, helper,response.patientMedicationOrder);
        console.log('setDefaultChartEntities '+JSON.stringify( response));
        let chartSummaryOptions = component.get("v.chartSummaryOptions"); 
        for(let rec in chartSummaryOptions){
            if(chartSummaryOptions[rec].label ==='Vitals'){
                chartSummaryOptions[rec].entityData = response.vitalData;
            }
            else if(chartSummaryOptions[rec].label ==='Allergies'){
                chartSummaryOptions[rec].entityData = response.allergyData;
            }           
                else if(chartSummaryOptions[rec].label ==='Problems'){
                    chartSummaryOptions[rec].entityData = response.patientProblems;
                }
                    else if(chartSummaryOptions[rec].label ==='Medications'){
                        chartSummaryOptions[rec].entityData = response.patientMedicationOrder;
                    }                       
        }
        component.set("v.chartSummaryOptions",chartSummaryOptions);         
    },
    addBooleanKeys :  function(component, event, helper,res) { 
        res.forEach(function(element) {
            element['isSelected'] = false;
        });   
        return res;
    },
    arrangelstvalueAsForms : function(component, event, helper,res) { 
        res.forEach(function(record){ 
            record['Id'] = record.formId;
            record['Name'] = record.formName;
            record['isSelected'] = false; 
              record['column_1'] = record.formName; 
              record['column_2'] = record.formCategory; 
              record['column_3'] = record.CreatedBy; 
             // record['column_4'] = record.CreatedDate; 
        });
        return res;
    }
})