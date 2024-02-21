({
    doInit : function(cmp, event, helper) {
        if(cmp.get("v.isResult") == true){
            console.log('VOB Integration 6');
            cmp.set("v.loaded",false);
            
            if($A.util.isUndefinedOrNull(cmp.get("v.recordId"))){
                var pageRef = cmp.get("v.pageReference");
                var state = pageRef.state; // state holds any query params
                if(!$A.util.isUndefinedOrNull(state.ElixirSuite__recordId)){
                    var getRecordId = state.ElixirSuite__recordId;
                    console.log('getRecordId@@'+getRecordId);
                    cmp.set("v.recordId",getRecordId);
                    cmp.set("v.isDetailButton",state.ElixirSuite__isDetailButton);
                }
            }
            var action = cmp.get("c.checkValidDetails");
            action.setParams({
                'vobId' : cmp.get("v.recordId")
            });
            action.setCallback(this,function(resp){
                if(resp.getState() == 'SUCCESS')
                {
                    if(resp.getReturnValue() != null)
                    {
                        
                        var mapVobFields = new Map();
                        cmp.set("v.loaded",true);
                        var wrapRes = resp.getReturnValue();
                        cmp.set("v.benefitTypeCode",wrapRes.vob.ElixirSuite__Benefit__c);
                        if(wrapRes.msgState=='Success'){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success",
                                "message": 'Patient verified!',
                                "type" : "success",
                                "mode" : "dismissible"
                            });
                            toastEvent.fire();
                            
                            setTimeout($A.getCallback(function() {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "RESULT WILL BE ATTACHED IN ATTACHMENTS OF INSURANCE!",
                                    "message": "Response PDF will be attached in the ATTACHMENTS section of the Insurance in a while",
                                    "type" : "info"
                                });
                                toastEvent.fire();
                            }), 500);
                            if(cmp.get("v.isDetailButton")){
                                var workspaceAPI =cmp.find("workspace");
                                workspaceAPI.getFocusedTabInfo().then(function(response) {
                                    var focusedTabId = response.tabId;
                                    workspaceAPI.closeTab({tabId: focusedTabId});
                                })
                                .catch(function(error){
                                    console.log(error);
                                });
                                cmp.find("navigationService").navigate({
                                    "type": "standard__recordPage",
                                    "attributes": {
                                        "recordId": cmp.get("v.recordId"),
                                        "objectApiName": "ElixirSuite__VOB__c",
                                        "actionName": "view"
                                    }
                                });
                                 var cmpEvent = cmp.getEvent("FiringSelectedId");
                                cmpEvent.fire();
                                $A.get("e.force:closeQuickAction").fire();
                              
                            }
                            var cmpEvent = cmp.getEvent("IntegCmpEvent"); 
                            cmpEvent.setParams({"IntegrationOpen" : true}); 
                            cmpEvent.fire();
                        }
                        if(wrapRes.msgState=='Error'){
                            cmp.set("v.loaded",true); 
                            cmp.set("v.VOB",wrapRes.vob);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error",
                                "message": wrapRes.msgStr,
                                "type" : "error",
                                "mode" : "dismissible"
                            });
                            toastEvent.fire();
                            var cmpEvent = cmp.getEvent("IntegCmpEvent"); 
                            cmpEvent.setParams({"IntegrationOpen" : true}); 
                            cmpEvent.fire();
                            if(cmp.get("v.isDetailButton")){
                                var workspaceAPI =cmp.find("workspace");
                               
                                workspaceAPI.getFocusedTabInfo().then(function(response) {
                                    var focusedTabId = response.tabId;
                                    workspaceAPI.closeTab({tabId: focusedTabId});
                                })
                                .catch(function(error){
                                    console.log(error);
                                });
                                cmp.find("navigationService").navigate({
                                    "type": "standard__recordPage",
                                    "attributes": {
                                        "recordId": cmp.get("v.recordId"),
                                        "objectApiName": "ElixirSuite__VOB__c",
                                        "actionName": "view"
                                    }
                                });
                                  var cmpEvent = cmp.getEvent("FiringSelectedId");
                                cmpEvent.fire();
                                $A.get("e.force:closeQuickAction").fire();
                                
                            }
                            return;
                        }
                        var isActive = false;
                        var result = new Map();
                        console.log('check33');
                        if(!$A.util.isUndefinedOrNull(resp.getReturnValue().jsonResp)){
                            mapVobFields = resp.getReturnValue().vobFieldsMap;
                            var obj = JSON.parse(resp.getReturnValue().jsonResp);
                            console.log('obj--',JSON.stringify(obj));
                            helper.init(cmp,helper,mapVobFields,obj);
                        }
                    }
                }
            });
            cmp.set("v.isResult", false);
            $A.enqueueAction(action);
        }
        
    } ,
    closeObjectMatchingInfoWindow : function(cmp, event, helper) {
        cmp.set("v.objectMatchingInfo",false);
    }
    
})