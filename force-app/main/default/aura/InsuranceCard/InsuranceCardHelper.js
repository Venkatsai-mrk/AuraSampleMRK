({
	fetchInsuanceType : function(component, event) {
		var acctId = component.get("v.recordId");
		var act = component.get('c.fetchInsuanceType');
		act.setParams({ acctId : acctId});
		act.setCallback(this,function(response){
			var resWrap = response.getReturnValue();
            var res = resWrap.insuranceTypes;
			if(res != null && res != ''){
			var options=[];
			 for(var i=0;i<res.length;i++){
				options[i]={'label':res[i],'value':res[i]};
			}
		
			component.set("v.insuranceOptions",options);
			component.set("v.selectedValue",options[0].value); 
			this.fetchInsuranceList(component, event,resWrap.insuranceListMap);
			}
		},'SUCCESS');
		$A.enqueueAction(act);
		
	},
	fetchInsuranceList : function(component, event, insuranceListMap) {
			var res = insuranceListMap;
			var options=[];
			if(JSON.stringify(res) == "{}"){
				component.set('v.autoAccdpayerNameOptions',options);
				component.set('v.idPairMap',res);
				component.set('v.selectedValue1',null);
				this.payerSelectedHelper(component, event);
			}else{
			for(var key in res){
				options.push({'label':key,'value':key});
			}
			component.set('v.autoAccdpayerNameOptions',options);
			component.set('v.idPairMap',res);
			component.set('v.selectedValue1',options[0].value);
			this.payerSelectedHelper(component, event);
			}
	},
	payerSelectedHelper : function(component){
		var vobMap = component.get('v.idPairMap');
		var selectedPayer = component.get('v.selectedValue1');
		var idPairList = vobMap[selectedPayer];
		var idPairOptions = [];
		if(idPairList != null){
		for(var i=0;i<idPairList.length;i++){
				idPairOptions.push({'label':idPairList[i],'value':idPairList[i]});
			}
		component.set('v.policyNumberOptions',idPairOptions);
		component.set('v.selectedValue2',idPairOptions[0].value);
		this.policySelectedHelper(component);
		}else{
		component.set('v.policyNumberOptions',idPairOptions);
		component.set('v.selectedValue2',null);
		this.policySelectedHelper(component);   
		}
	},
	policySelectedHelper : function(component){
		var acctId = component.get("v.recordId");
		var recordTypeName = component.get('v.selectedValue'); 
		var field = this.fetchIdField(recordTypeName);
		var selectedPayer = component.get('v.selectedValue1');
		var idPair = component.get('v.selectedValue2');
		var act = component.get('c.fetchVOBData');
		if(acctId != null && recordTypeName != null && field != null &&  selectedPayer != null && idPair != null){
		act.setParams({ recordTypeName :  recordTypeName, acctId : acctId, fieldName: field, policyNo:idPair, payerName:selectedPayer});
		act.setCallback(this,function(response){
			var res = response.getReturnValue();
			component.set("v.vobInfo" , res);
			
		},'SUCCESS');
		$A.enqueueAction(act);
		}else{
		   component.set("v.vobInfo" , null); 
		}
	},

	fetchIdField : function(recordTypeName){
		if(recordTypeName=='Auto-accident' || recordTypeName=='Primary Insurance' || recordTypeName=='Secondary Insurance' || recordTypeName=='Tertiary Insurance' || recordTypeName=='Durable Medical Equipment'){
			return 'ElixirSuite__Member_Id__c';
		}
		if(recordTypeName=='Workers Comp'){
			return 'ElixirSuite__Group_Number__c';
		}
	}
})