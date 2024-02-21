({
    showToast : function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
  
    fetchPortalMessageSetting: function(component, event, helper){
        var action = component.get('c.wrappedData');
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(JSON.stringify(response.getReturnValue())+' response');
            if(state === 'SUCCESS'){
                var resp = response.getReturnValue();
                
                component.set("v.patientID",resp.accId);
                
                var isComposeFromCareTeam = component.get("v.composeMsgFromCareTeam");
                console.log('isComposeFromCareTeam: '+isComposeFromCareTeam);

                if(isComposeFromCareTeam){
                    var Opts = [];
                    component.set("v.defaultOption",component.get("v.careTeamDetails").value); 
                    console.log('careTeamDetails: '+component.get("v.careTeamDetails"));
                    Opts.push(component.get("v.careTeamDetails"));
                    console.log('opts: '+Opts);
                    component.set("v.teamMembers",Opts );
                }else{
                    component.set("v.defaultOption", resp.defaultValueSelected);
                    component.set("v.teamMembers", resp.options);
                }
                console.log('careTeamDetails in compose message portal'+JSON.stringify(component.get("v.careTeamDetails")));
                console.log('defaultOption '+component.get("v.defaultOption"));
                
                
            }
        });
        $A.enqueueAction(action);
    }
})