({ 
    init : function(component, event, helper) {
        
        var acctId = component.get("v.recordId");
        component.set("v.patientId" , acctId);
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
                if(data.vobData!=null && data.vobData.length > 0){
                    component.set("v.verifyInsurance" , true);
                    component.set("v.billingSummary" , true);
                    component.set("v.vobRec" , data.vobData[0].Id);
                    console.log( "vobRec",data.vobData[0].Id);
                }
              //  component.set("v.secondCall" , true);
                component.set("v.patientData" ,data.patData );
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
   /* handleClickPastEstimate:function(component, event, helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:Past_Estimates_for_EHR",
            componentAttributes: {
                patId : component.get("v.recordId")
            }
        });
        evt.fire();  
    },
    handleClickViewPaymentSchedule:function(component, event, helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:View_Payment_Schedule_for_EHR",
            componentAttributes: {
                patId : component.get("v.recordId")
            }
        });
        evt.fire();
        
    },
    handleClickVerifyInsurance: function(component, event, helper){
        
        //  var id = event.srcElement.id;
        var vobRecId= component.get("v.vobRec");
        console.log(vobRecId);
        
        if(vobRecId){
        component.set("v.vobInteg" , true);  
        }
       
      */
        
       // component.set("v.vobInteg" , false);
     /*   var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:VOBIntegration",
            componentAttributes: {
                recordId : id
            }
        });
        evt.fire();*/
 //   },
    
   /* OpenElixirBillingSummary :function(component,event,helper){
      debugger;
      var evt = $A.get("e.force:navigateToComponent");
      evt.setParams({
          componentDef:"c:BillingSummaryforEHR",
          componentAttributes: {
              recordId1 : component.get("v.recordId"),
          }
      });
      evt.fire();
  },
    
    parentComponentEvent :function(component,event,helper){
        
        component.set("v.vobInteg" , false);
        window.location.href();
    },*/
})