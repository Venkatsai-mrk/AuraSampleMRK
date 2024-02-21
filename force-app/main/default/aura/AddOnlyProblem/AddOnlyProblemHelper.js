({
	createObjectData : function(component, event) {
console.log('@@@@',component.get("v.problemList"));
        var RowItemList = component.get("v.problemList");
        if($A.util.isEmpty(RowItemList)){
            RowItemList.push({
                'sobjectType': 'ElixirSuite__Dataset1__c',
                'ProblemId': '',
                'ProblemDescription':'',
                'ProblemName': '',
                'SNOMEDCTCode': '',
                'ProblemType': '',
                'Status':'Active',
                'DateOnset':new Date(),
                'EndDate':new Date(),
                'Notes':'',
                'ElixirSuite__Account__c' : component.get("v.patientID"),
                'IsPatientProblem': false,
                'ExistingProblemId': ''
            });
            
            component.set("v.problemList", RowItemList);
        }
    },
    createObjectDataOnNewRow : function(component, event) {
		var RowItemList = component.get("v.problemList");
        RowItemList.push({
            'sobjectType': 'ElixirSuite__Dataset1__c',
            'ProblemId': '',
            'ProblemDescription':'',
            'ProblemName': '',
            'SNOMEDCTCode': '',
            'ProblemType': '',
            'Status':'Active',
            'DateOnset':new Date(),
            'EndDate':new Date(),
            'Notes':'',
            'ElixirSuite__Account__c' : component.get("v.patientID"),
            'IsPatientProblem': false,
            'ExistingProblemId': ''
        });
             
        component.set("v.problemList", RowItemList);
	}
})