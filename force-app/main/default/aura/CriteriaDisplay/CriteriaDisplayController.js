({
	init : function(component, event, helper) {
		
        helper.createTableData(component, event, helper);
	},
    editDeleteRecord : function(component, event, helper) {
        var rowToDelete = event.getParam('row');
        var actionName = event.getParam('action').name;
        
        
        component.set("v.recordToDelete",rowToDelete);
       component.set("v.criteriaRecordId",event.getParam('row').Id);
        if(actionName === 'Edit'){
            
           helper.criteriaEditHandler(component, event, helper);
           
        }else{
            component.set("v.isModalOpen",true);
        }
	},
    deleteCriteria : function(component, event, helper) {
		
        helper.criteriaDeleteHandler(component, event, helper);
	},
    closeModel: function(component, event, helper) {
        
        component.set("v.isModalOpen", false);
    },
    
    createNewCriteria : function(component, event, helper){
        component.set("v.isModalOpenForNewRecord", true);
       
        var res;
        component.set("v.ageValue",res);
        component.set("v.admitDateValue",res);
        component.set("v.admitEndDateValue",res);
        component.set("v.EmptyCriteriaVal",true);
        component.set("v.selectedLookupTypeCriteriaValue",'');
        component.set("v.selectedAccountLookUpRecords",[]);
        component.set("v.selectedCareTeamLookUpRecords",[]);
        component.set("v.selectedLocationLookUpRecords",[]);
        component.set("v.selectedLOCLookUpRecords",[]);
        component.set("v.parentValue",res);
        component.set("v.childValue",['--- None ---']);
        component.set("v.title",'New Criteria');
        component.set("v.selectedOperator",res);
        component.set("v.selectedCriteriaType",res);
        component.set("v.criteriaRecordId",res);
        component.set("v.SelectedRecords",[]);
        component.set("v.disabledChildField" , true);
         component.set("v.disabledParent" , false);
        
    }
    
    
})