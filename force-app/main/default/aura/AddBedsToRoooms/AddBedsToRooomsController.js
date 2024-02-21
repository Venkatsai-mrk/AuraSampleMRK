({
    doAction: function(component,event,helper){
        component.set("v.isOpen", true);
        
    },
	handleSuccess:function(component,event,helper){
        
         $A.get("e.force:closeQuickAction").fire();
          component.set("v.isOpen", false);
        $A.get('e.force:refreshView').fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Successful",
            "type" : "success",
            "message": "Beds have been added successfully!"
        });
        toastEvent.fire();
       
       
        
    }, 
    cancel:function(component,event,helper){
         component.set("v.isOpen", false);
    },
   
})