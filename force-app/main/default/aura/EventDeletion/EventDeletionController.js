({
    deleteAllEventSeries: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.functionDelete");  // functionSeriesDelete
        let eventButton = event.getSource().get("v.name");
        action.setParams({
            "recordID": recordId,
            "eventButton": eventButton
        });
        console.log('techId========' + eventButton);
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //toast
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Success',
                    message: 'Events are deleted',
                    duration: ' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                // window.location.reload();
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/lightning/page/home"
                });
                urlEvent.fire();
            }
            else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: 'Events are not deleted.',
                    duration: ' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();

            }

        });

        $A.enqueueAction(action);
    },
    cancel: function (component, event, helper) {
        console.log('response3');
        window.location.reload();
    },

})