({
	doInit : function(cmp, event, helper) {
        var nameSpace='ElixirSuite__';
        cmp.set('v.column', [
			{
                label: 'ERA Name',
                fieldName: 'linkName',
                type: 'url' ,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank' }
            },
            {label: 'Total Charge', fieldName: nameSpace+'Total_Charge__c', type : 'currency'},
            {label: 'Amount Paid', fieldName: nameSpace+'Total_Paid__c', type: 'currency'}
        ]);
		var action = cmp.get("c.fetchOriginalERA");
        action.setParams({
            claimId : cmp.get("v.recordId")
        });
        action.setCallback(this,function(resp)
       	{
            if(resp.getState() =='SUCCESS')
            {
            	console.log('resp.getReturnValue() : ' + resp.getReturnValue());
            	if(resp.getReturnValue() != null)
                {
                    /*var allData =resp.getReturnValue();
            		for(var recdata in resp.getReturnValue())
            		{
                        allData[recdata]['Name']  = allData[recdata].Name;
                        allData[recdata]['recordName'] = '/'+allData[recdata].Id;
                		
                    }*/
                    var records =resp.getReturnValue();
                    records.forEach(function(record){
                    	record.linkName = '/'+record.Id;
                    
                    });
                //component.set("v.data", records);
                	cmp.set("v.ERALst",records);
        			console.log('allData : ' + JSON.stringify(records));
                }
            }
        });
        $A.enqueueAction(action);
	}
})