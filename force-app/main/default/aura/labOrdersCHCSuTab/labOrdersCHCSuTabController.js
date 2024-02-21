({
    init: function(component, event, helper) {      
        try{
        var action=component.get("c.getAccountId");
        action.setCallback(this,function(response){
            if (response.getState() == "SUCCESS"){               
                if(response.getReturnValue()!=''){
                    component.set("v.crecordId",response.getReturnValue());
                }
                else{
                    console.log('Else PArt');
                     var pageReference = component.get("v.pageReference");
        // alert(JSON.stringify(pageReference));
        var rId = pageReference.state.c__crecordId;
        if(rId != null && rId != ''){
            component.set("v.crecordId", rId);
        }
                    console.log('crecordId=='+component.get("v.crecordId"));
        var workspaceAPI = component.find("workspace");
        workspaceAPI.focusTab().then(function(response) {
                var focusedTabId = response.tabId;
                //  alert(focusedTabId);
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: "Lab Orders"
                });
            })
            .catch(function(error) {
                console.log('Lab order sub tab error'+error);
            });
                }
            }
        });
            $A.enqueueAction(action);
        }
        catch (e){
            console.log('e==='+e);
        }

        /** var evt = $A.get("e.force:navigateToComponent");
          evt.setParams({
              componentDef:"c:tableForLabOrder",
              componentAttributes: {
                  patientID : component.get("v.recordId"),
                  nameSpace : ''
              }
          });
          evt.fire();**/
        /**var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          mode: "sticky",
          message: "This is a subtab"
        });
        toastEvent.fire();**/
    },
    handleNewButtonClose: function(component, event) {


        var CloseClicked = event.getParam('close');
        component.set('v.message', 'Close Clicked');


        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
               // alert(focusedTabId);
               // console.log('focused ID '+focusedTabId);
                workspaceAPI.closeTab({ tabId: focusedTabId });
            })
            .catch(function(error) {
                console.log(error);
            });
    },
})