({
    init : function(component, event, helper) {
        var acctId = component.get("v.patientId" );
        if($A.util.isUndefinedOrNull(acctId)){
            acctId = component.get("v.recordId");
        }else{
        component.set("v.recordId" , acctId);
        }
        component.set("v.isResult", false);
        helper.fetchInsuanceType(component, event);
    },
   
    VfpageCall: function(component, event){
        var id = event.srcElement.id;
        console.log(id);
        component.set("v.srcId", id);
        component.set("v.isResult", true);
        component.set("v.isResult", false);
    },
  
    handelPayerName: function(component, event, helper){
        helper.payerSelectedHelper(component, event);
    },
    fetchInsuranceDetails : function(component, event, helper){
    	var acctId = component.get("v.recordId");
		var recordTypeName = component.get('v.selectedValue'); 
		var field = helper.fetchIdField(recordTypeName);
		var act = component.get('c.fetchInsuranceList');
		act.setParams({ recordTypeName :  recordTypeName, acctId : acctId, fieldName: field});
		act.setCallback(this,function(response){
			var res = response.getReturnValue();
             var options=[];
			if(JSON.stringify(res) == "{}"){
				component.set('v.autoAccdpayerNameOptions',options);
				component.set('v.idPairMap',res);
				component.set('v.selectedValue1',null);
				helper.payerSelectedHelper(component, event);
			}else{
			for(var key in res){
				options.push({'label':key,'value':key});
			}
			component.set('v.autoAccdpayerNameOptions',options);
			component.set('v.idPairMap',res);
			component.set('v.selectedValue1',options[0].value);
			helper.payerSelectedHelper(component, event);
			}
			
		},'SUCCESS');
		$A.enqueueAction(act);    
    },
    handelPolicyNo : function(component, event, helper){
    	helper.policySelectedHelper(component);    
    }
})