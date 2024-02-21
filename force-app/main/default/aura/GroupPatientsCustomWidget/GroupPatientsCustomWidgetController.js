({
	doInit : function(cmp, event, helper) {
        var nameSpace='ElixirSuite__';
        
        var actions = [
            {label: 'Edit', name: 'edit'},
            {label: 'Delete', name: 'delete'}
        ];
        cmp.set('v.column', [
			{
                label: 'Group Patient Name',
                fieldName: 'linkName',
                type: 'url' ,typeAttributes: {label: { fieldName: 'Name' }, target: '_blank' }
            },
            {label: 'Group Name', fieldName: nameSpace+'Group_Name__c', type : 'text'},
            {label: 'Criteria Based Addition?', fieldName: nameSpace+'Criteria_Based_Addition__c', type: 'text'},
            {type: 'action', typeAttributes: { rowActions: actions } }
        ]);
        
		var action = cmp.get("c.getGroupPatients");
        action.setParams({
            accountId : cmp.get("v.recordId")
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
                        record.ElixirSuite__Group_Name__c = record.ElixirSuite__Group_Name__r.Name;
                        console.log('record',record.ElixirSuite__Group_Name__r.Name);
                         console.log('record',record.ElixirSuite__Group_Name__c);
                   
                    });
                    
                //component.set("v.data", records);
                	cmp.set("v.groupPatientList",records);
        			console.log('allData : ' + JSON.stringify(records));
                }
            }
        });
        $A.enqueueAction(action);
	},
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        switch (action.name) {
            case 'edit':
                helper.editRecord(component, event);
                break;
            case 'delete':
                helper.deleteRecord(component, event);
                break;
        }
    }
})