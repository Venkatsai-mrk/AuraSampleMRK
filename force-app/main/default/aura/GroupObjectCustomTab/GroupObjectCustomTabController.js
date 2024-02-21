({
	doInit : function(cmp, event, helper) {
		
        var action = cmp.get("c.getURL");
        
        action.setCallback(this,function(resp)
       	{
            if(resp.getState() =='SUCCESS')
            {
            	console.log('resp.getReturnValue() : ' + resp.getReturnValue());
            	if(resp.getReturnValue() != null)
                {
                   
                    if(cmp.get("v.Environment") === 'Visualforce'){
                       
                        window.parent.location.href = resp.getReturnValue();
                        
                    }else{
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": resp.getReturnValue()
                        });
                        urlEvent.fire();
                    }
                    
                    
                	
                }
            }
        });
        $A.enqueueAction(action);
        
	}
})