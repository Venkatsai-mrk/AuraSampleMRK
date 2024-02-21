({
	successToast : function() {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        type : "success",
        "title": "Success!",
        "message": "The record has been saved."
        });
    toastEvent.fire();
    },
    errorToast : function() {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        type : "error",
        "title": "Error!",
        "message": "Record can not be saved. Please try again"
        });
    toastEvent.fire();
    },
    //Anusha -start 28/10/22
    getVobAndCustomsettings : function(component,event,helper){
         var action = component.get("c.fetchDisplaySettings");
        action.setCallback(this, function(response) {
            console.log('response',response.getReturnValue());
            if(response.getReturnValue()=='CMS1500'){
                component.set("v.displayCMS1500Button",true);
                helper.getCMS1500Records(component,event,helper);
            }
            else if(response.getReturnValue()=='UB04'){
                component.set("v.displayUB04",true);
                helper.getUB04Records(component,event,helper);
            }else{
                component.set("v.showModal",true);
                component.set("v.displayCMS1500Button",true);
                component.set("v.displayUB04",true);
            }
            
                
        });
        $A.enqueueAction(action);
    },
    getCMS1500Records : function(component){
        var action = component.get("c.fetchRecords");
        action.setParams({
            accountId : component.get("v.patId"),
            recordtypeLabel : 'Primary',
            recName : 'CMS_1500'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                var payerLst = [];
                    payerLst =res.payerList;
                var vobLst = [];
                console.log('res',res);
                vobLst =res.vobList;
                
                if(payerLst.length == 1 && vobLst.length == 1){
                    component.set("v.isSingleVOB",true);
                }else{
                    component.set("v.isSingleVOB",false);
                }
                console.log('SingleVOB',component.get("v.isSingleVOB"));
                component.set('v.selectedVOBList', vobLst[0]);
               // var vlist = component.get('v.selectedVOBList');
                console.log('selectvob',component.get('v.selectedVOBList'));
                component.set("v.isCMS1500",true);
                component.set("v.isOpen",true);
                console.log('ks' , component.get("v.heading"));
                component.set("v.recordTypeId",res.recTypeid);
                console.log("recTypeid "+res.recTypeid);
                component.set("v.heading",'CMS-1500 Form');
            }
        });
        $A.enqueueAction(action);
    },
    getUB04Records: function(component){
        var action = component.get("c.fetchRecords");
        action.setParams({
            accountId : component.get("v.patId"),
            recordtypeLabel : 'Primary',
            recName : 'UB_04'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                var payerLst = res.payerList;
                var vobLst = [];
                
                vobLst =res.vobList;
                
                if(payerLst.length == 1 && vobLst.length == 1){
                    component.set("v.isSingleVOB",true);
                }else{
                    component.set("v.isSingleVOB",false);
                }
                component.set('v.selectedVOBList', vobLst[0]);
                component.set("v.isUB04",true);
                component.set("v.isOpen",true);
                component.set("v.recordTypeId",res.recTypeid);
                console.log("recTypeid "+res.recTypeid);
                component.set("v.heading",'UB-04 Form');
            }
        });
        $A.enqueueAction(action);
    }, //Anusha -End 28/10/22


})