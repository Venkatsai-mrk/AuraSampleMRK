({
	createObjectData : function(component, event,icdVal) {
		var RowItemList = component.get("v.diagnosisList");
if($A.util.isEmpty(RowItemList)){
        RowItemList.push({
            'sobjectType': 'ElixirSuite__ICD_Codes__c',
            'ICDId': '',
            'ICDCode':'',
            'ICDDescription': '',
            'ICDVersion': icdVal,
            'DiagnosisType': '',
            'DateDiagnoses':new Date(),
            'Notes':'',
            'ElixirSuite__Account__c' : component.get("v.patientID"),
            'SelectedRecord':'',
            'IsPatientDiagnosis': false
            });  
            component.set("v.diagnosisList", RowItemList);
        }
    },
    createObjectDataOnNewRow : function(component, event,icdVal) {
        var RowItemList = component.get("v.diagnosisList");
            RowItemList.push({
                'sobjectType': 'ElixirSuite__ICD_Codes__c',
                'ICDId': '',
                'ICDCode':'',
                'ICDDescription': '',
                'ICDVersion': icdVal,
                'DiagnosisType': '',
                'DateDiagnoses':new Date(),
                'Notes':'',
                'ElixirSuite__Account__c' : component.get("v.patientID"),
                'SelectedRecord':'',
                'IsPatientDiagnosis': false
        });  
        component.set("v.diagnosisList", RowItemList);
	}
})