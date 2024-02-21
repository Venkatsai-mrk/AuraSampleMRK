({
	doInit : function(component) {
        var action = component.get('c.getMessagesFromPatientChart');
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state+' state for messages');
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('result '+JSON.stringify(result));
                if (!$A.util.isUndefinedOrNull(result)) {
                   component.set("v.Messages",result); 
                }
                for(var i = 0; i < result.length; i++) {
                    result[i].ElixirSuite__Subject__c = result[i].ElixirSuite__Subject__c.substring(0, 25)+' ';
                }

                component.set("v.messagesFromPatientChart", result);
            }
        });
        $A.enqueueAction(action);
		
	},
    handleReadMoreClick : function(component, event) {
        console.log('handleReadMoreClick');
        var messageId = event.currentTarget.dataset.messageid;

        var action = component.get('c.updateMessageViewStatus');
        action.setParams({
            "messageRecordId" : messageId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state+' state for messages');
            if(state === 'SUCCESS'){
                console.log('Successfully updated message status');
            }
        });
        $A.enqueueAction(action);
        component.set("v.isFromNewMessages",true);
        console.log('messageId '+messageId);
        component.set("v.messageRecordId",messageId);
        component.set("v.viewMessage",true);
        let navService = component.find("navigationService");
        let pageReference = {
        type: "standard__webPage",
        attributes: {
            url: "/message-subject/" + messageId
        }
        }
        navService.navigate(pageReference);
        
        
},
hideModalBox : function(component) {
    component.set("v.viewMessage",false);
    $A.get('e.force:refreshView').fire();
},
handleMoreMessagesOClick : function(component) {
    console.log('handleMoreMessagesOClick called');
    var action = component.get("c.getListViews");
    action.setCallback(this, function(response){
        var state = response.getState();
        console.log('state '+state);
        if (state === "SUCCESS") {
            var listviews = response.getReturnValue();
            var navService = component.find("navigationService");
    var pageReference = {
    type: 'standard__objectPage',
    attributes: {
        objectApiName: 'ElixirSuite__Message_Subject__c',
        actionName: 'list'
    },
    state: {
        filterName: listviews[0].Id
    }
    };
    navService.generateUrl(pageReference).then(function(url) {
        window.location.href = url;
    });
            
        }
    });
    $A.enqueueAction(action);
    
}
})