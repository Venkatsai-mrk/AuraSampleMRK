({
    fetchCareEpisodeDetails: function (component, event, helper) {
        
        var action = component.get("c.getCareEpisodeDetails");
        
        action.setParams({
            'careId' : component.get("v.recordId")
        });
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            console.log('fetchCareEpisodeDetails***',state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result fetchCareEpisodeDetails1***upd1',result);
                component.set("v.careBillingProvider",result.billingProvider);
                component.set("v.careServiceProvider",result.serviceProvider);
                component.set("v.careRenderingProvider",result.renderingProvider);
                component.set('v.selectedVOBList',result.patientVob);
                component.set('v.patientId',result.patientRecId);
                component.set('v.preAuthNum',result.preAuthNumber);
                
                component.set('v.VobList',result.vobList);
                component.set('v.payerList',result.payerList);
                component.set("v.recordTypeId",result.recTypeid);
                component.set('v.isCMS1500',true);
                var insLst = component.get("v.selectedVOBList");
                console.log('insLst****lengthupd4',insLst.length);
                if(insLst.length == 0){
                    component.set('v.isSingleVOB',true);
                    component.set('v.isOpen',true);
                }
        }
            else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            this.globalFlagToast(component, event, helper,errors[0].message,' ','error');
                        }
                    }
                }
            });
        $A.enqueueAction(action);
        
    },
    
    globalFlagToast : function(cmp, event, helper,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":  message,
            "type" :type
        });
        toastEvent.fire();
    }
})