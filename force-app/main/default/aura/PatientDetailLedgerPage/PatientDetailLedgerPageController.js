({
    init : function(component) {
        var acctId = component.get("v.recordId");
        component.set("v.patientId" , acctId);
        component.set("v.firstCall" , true);
        component.set("v.isResult", false);
         component.set("v.secondCall" , true);
        var action = component.get("c.getAllData");
        action.setParams({ accountId :  acctId});        
        action.setCallback(this, function (response){
            
            var state = response.getState(); 
            if (state === "SUCCESS") {  
                var data = response.getReturnValue();
                console.log('++++',data);
                //component.set("v.vobInfo" , data.vobData);
                component.set("v.vobResultInfo" , data.vobResultData);
                component.set("v.secondCall" , true);
                component.set("v.patientData" ,data.patData );
                component.set("v.totalInsuranceResp" ,data.totalInsuranceResp );
                //  console.log('dbhw' , component.get(v.patientData));
                var radioButtonVal = component.get("v.optVal");
                if(radioButtonVal =='Claims'){
                    component.set("v.claimView",true);
                    component.set("v.procedureView", false);
                    component.set("v.payHistory",false);
                    component.set("v.cocEstimates",false);
                    component.set("v.paySchedule",false);
                }
            }
        });
        var action3 = component.get('c.licensBasdPermission');
        action3.setParams({
        });
        
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                
                var wrapList = response.getReturnValue();
                component.set("v.Ehr",wrapList.isEhr);
                component.set("v.Billing",wrapList.isRcm);
                component.set("v.ContactCentr",wrapList.isContactCenter);
if (!wrapList.isEhr && !wrapList.isContactCenter && wrapList.isRcm) {
    					component.set("v.licenseAvailable", true);
				}
            }
        });
        $A.enqueueAction(action);
        $A.enqueueAction(action3);
    },
    
    handleClick: function(component){
        component.set("v.paymentSched" , true);
    },
    VfpageCallNotNeeded: function(component, event){
        var id = event.srcElement.id
        console.log(id);
      
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:VOBIntegration",
            componentAttributes: {
                recordId : id
            }
        });
        evt.fire();
    },
    
    VfpageCall: function(component, event){
        var id = event.srcElement.id;
        console.log(id);
        component.set("v.srcId", id);
        component.set("v.isResult", true);
    },
    
    handleClickPatStatement: function(component){
        component.set("v.patStatement" , true);
    },
    handleClickCoC: function(component){
        component.set("v.COCalculator" , true);
    },
   /* handleClickPaymentPosting: function(component, event, helper){
        component.set("v.payPosting" , true);
    },*/
    handleClickCollectPayment: function(component){
        var action = component.get("c.getPaymentSetting");
        action.setCallback(this, function(response){
            var resp=response.getReturnValue();
            console.log('resp.ElixirSuite__Square_Payment__c'+resp.ElixirSuite__Square_Payment__c);
             console.log('resp.ElixirSuite__Elixir_Payment__c'+resp.ElixirSuite__Elixir_Payment__c);
            if(resp.ElixirSuite__Square_Payment__c == true && resp.ElixirSuite__Elixir_Payment__c ==true){
                component.set("v.collectPayment" , false);
                component.set("v.payPosting" , true);
                }
             if(resp.ElixirSuite__Square_Payment__c == true && resp.ElixirSuite__Elixir_Payment__c ==false){
                component.set("v.collectPayment" , true);
                component.set("v.payPosting" , false);
                }
            if(resp.ElixirSuite__Square_Payment__c == false && resp.ElixirSuite__Elixir_Payment__c ==true){
                component.set("v.collectPayment" , false);
                component.set("v.payPosting" , true);
            }
            });
		$A.enqueueAction(action);
         
    },
    viewPaymentSchedule: function(component){
        window.scrollTo(0,0);
        component.set("v.optVal" , "Show Payment Schedule");
        component.set("v.claimView",false);
        component.set("v.procedureView", false);
        component.set("v.payHistory",false);
        component.set("v.cocEstimates",false);
        component.set("v.paySchedule",true);
    },
    handleChange: function (cmp, event) {
        var changeValue = event.getParam("value");
        if(changeValue =='Claims'){
            cmp.set("v.claimView",true);
            cmp.set("v.procedureView", false);
            cmp.set("v.payHistory",false);
            cmp.set("v.cocEstimates",false);
            cmp.set("v.paySchedule",false);
        }
        if(changeValue =='Show Payment History'){
            cmp.set("v.claimView",false);
            cmp.set("v.payHistory",true);
            cmp.set("v.cocEstimates",false);
            cmp.set("v.paySchedule",false);
            cmp.set("v.procedureView", false);
        }
        if(changeValue =='Cost of Care Calculation Estimate'){
            cmp.set("v.claimView",false);
            cmp.set("v.payHistory",false);
            cmp.set("v.cocEstimates",true);
            cmp.set("v.paySchedule",false);
            cmp.set("v.procedureView", false);
        }
        if(changeValue =='Show Payment Schedule'){
            cmp.set("v.claimView",false);
            cmp.set("v.payHistory",false);
            cmp.set("v.cocEstimates",false);
            cmp.set("v.paySchedule",true);
            cmp.set("v.procedureView", false);
        }
        if(changeValue =='Procedures'){
            cmp.set("v.claimView",false);
            cmp.set("v.payHistory",false);
            cmp.set("v.cocEstimates",false);
            cmp.set("v.paySchedule",false);
            cmp.set("v.procedureView", true);
        }
    } ,
    ShowToast: function(){
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
    },
  
})