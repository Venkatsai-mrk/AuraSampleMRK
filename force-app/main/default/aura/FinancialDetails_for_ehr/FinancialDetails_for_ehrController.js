({
    init : function(component, event, helper) {
        
        var acctId = component.get("v.patientId");
        console.log('Financial recordId***',component.get("v.recordId"));
        if(acctId == null){
            acctId = component.get("v.recordId");
        }
      //  component.set("v.patientId" , acctId);
        component.set("v.firstCall" , true);
        
        var action = component.get("c.getAllData");
        action.setParams({ accountId :  acctId});        
        action.setCallback(this, function (response){
            
            var state = response.getState(); 
            if (state === "SUCCESS") {  
                var data = response.getReturnValue();
                console.log(data);
                component.set("v.vobInfo" , data.vobData);
                component.set("v.vobResultInfo" , data.vobResultData);
                component.set("v.secondCall" , true);
                component.set("v.patientData" ,data.patData );
                var patientData = data.patData;
                console.log('name***',patientData.Name);
                console.log('outstanding***',patientData.ElixirSuite__Outstanding_Amount__c);
                if(patientData.ElixirSuite__Outstanding_Amount__c == null || patientData.ElixirSuite__Outstanding_Amount__c == 0){
                    component.set("v.isOutstanding" ,false);
                }
                else{
                    component.set("v.isOutstanding" ,true);
                }
                component.set("v.totalInsuranceResp" ,data.totalInsuranceResp );
                //  console.log('dbhw' , component.get(v.patientData));
                var radioButtonVal = component.get("v.optVal");
                if(radioButtonVal =='Claims'){
                    component.set("v.claimView",true);
                    component.set("v.payHistory",false);
                    component.set("v.cocEstimates",false);
                    component.set("v.paySchedule",false);
                }
            }
        });
        var action3 = component.get('c.LicensBasdPermission');
        action3.setParams({
        });
        
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                
                var wrapList = response.getReturnValue();
                component.set("v.Ehr",wrapList.isEhr);
                component.set("v.Billing",wrapList.isRcm);
                component.set("v.ContactCentr",wrapList.isContactCenter);
            }
        });
        $A.enqueueAction(action);
        $A.enqueueAction(action3);
    },
    
    handleClick: function(component, event, helper){
        component.set("v.paymentSched" , true);
    },
    VfpageCall: function(component, event, helper){
        var id = event.srcElement.id
        console.log(id);
        //var myId = event.getSource().get('v.name');
        //console.log(myId);
        /*var vfUrl = 'https://billingdevelopment-dev-ed--c.ap17.visual.force.com/apex/VerifyInsurance?Id='+id;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": vfUrl
        });
        urlEvent.fire();*/
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:VOBIntegration",
            componentAttributes: {
                recordId : id
            }
        });
        evt.fire();
    },
   
    ShowToast: function(component, event, helper){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Warning',
            message: 'Your Insurance Verification is pending. Please verify the insurance and perform the COC.',
            duration:' 5000',
            key: 'info_alt',
            type: 'warning',
            mode: 'sticky'
        });
        toastEvent.fire();
    }
})