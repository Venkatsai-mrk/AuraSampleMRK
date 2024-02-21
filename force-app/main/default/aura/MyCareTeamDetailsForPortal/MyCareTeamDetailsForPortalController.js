({
    doInit : function(component) {
        var action = component.get('c.getAccountTeamMembers');
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state+' state for care team details');
            if(state === 'SUCCESS'){
                var resp = response.getReturnValue();
                if(!$A.util.isUndefinedOrNull(resp)){
                console.log(JSON.stringify(resp)+' resp of care team details');

                resp.sort(function(a, b) {
                    var labelA = a.label.toUpperCase(); // Convert labels to uppercase for comparison
                    var labelB = b.label.toUpperCase(); // Convert labels to uppercase for comparison
                    if (labelA < labelB) {
                      return -1;
                    }
                    if (labelA > labelB) {
                      return 1;
                    }
                    return 0;
                  });
                
                  console.log(JSON.stringify(resp));

                component.set("v.teamMembers", resp);
                }
            }
        });
        $A.enqueueAction(action);

        var action1 = component.get("c.isEnableAppointment");

        action1.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isEnableAppointment", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(action1);
    },
    composeMessageToCareTeamMember : function(component, event, helper) {
        var action = component.get("c.getCustomSetting");
            action.setCallback(this, function(response){
            var resp=response.getReturnValue();
            console.log("resp: " + JSON.stringify(resp));
            var messagingSettings=resp.ElixirSuite__Disable_Messaging_buttons_from_portal__c;
            let savedItems = [];
                console.log("savedItems: " + JSON.stringify(savedItems));
                if (messagingSettings) {
                    savedItems = messagingSettings.split(';').map(function(item) {
                        return item.trim();
                    });
                
                    console.log("savedItems: " + JSON.stringify(savedItems));
                }
            if(savedItems.includes('New') ){
                helper.showToast(component, "Messaging disabled", "You do not have permission to send messages .", "error");
                component.set("v.openComposeMessage",false);
        		component.set("v.composeMsgFromCareTeam",false);
                }
                else{
                    var memberDetails = event.getSource().get("v.name");
        			component.set("v.openComposeMessage",true);
        			component.set("v.composeMsgFromCareTeam",true);
        			console.log('memberValue '+JSON.stringify(memberDetails));
        			component.set("v.careTeamDetails",memberDetails);
                }
   			 });
			$A.enqueueAction(action);
        
    },
    scheduleAppontmentWithCareTeamMember : function(component, event) {
        var pracId;
        console.log('inside scheduleAppontmentWithCareTeamMember '+JSON.stringify(event.getSource().get("v.name").value));
        var contactId = event.getSource().get("v.name").value;//here we are getting contact id
        var action = component.get("c.getPractitionerUser");
        action.setParams({ 
            "contactId": contactId
                         });      

        action.setCallback(this,function(response) {

            var state = response.getState();
            if (state === "SUCCESS") {
                pracId = response.getReturnValue();      
                console.log('pracId-- '+pracId);
                var url = "/" + 'showavailabilityappointment'; 
                url += "?key=" + pracId +';fromMct';
                var navigateEvent = $A.get("e.force:navigateToURL"); 
                navigateEvent.setParams({ "url": url, "isredirect": true }); 
                navigateEvent.fire();
             }
            

        });
        $A.enqueueAction(action);
        
    }
})