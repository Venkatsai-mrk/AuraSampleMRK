({
	doInit : function(component, event, helper) {
        
        var recId = component.get("v.recordId");
        console.log('newprocedureoncareepisode9***',recId);
        	},
    handleNew : function(component, event, helper) {
        helper.fetchPatientDetails(component, event, helper);//added by Anmol
    }
})