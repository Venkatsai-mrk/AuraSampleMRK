({
    buildWrapper : function(component, event, helper) {
        let approvalUnitArr = []
        approvalUnitArr.push({'label': 'Care Plan', 'value': 'CarePlan'});
        approvalUnitArr.push({'label': 'Prescription', 'value': 'Prescription'});
        approvalUnitArr.push({'label': 'Lab Order', 'value': 'LabOrder'});      
        component.set("v.allApprovalUnits",approvalUnitArr);
    }
})