({
	doInit : function(component, event, helper) {
        
        var recId = component.get("v.recordId");
        console.log('newclaimoncareepisode6***',recId);
	},
    
    handleNew : function(component, event, helper) {
        helper.fetchCareEpisodeDetails(component, event, helper);//added by Anmol
    }
})