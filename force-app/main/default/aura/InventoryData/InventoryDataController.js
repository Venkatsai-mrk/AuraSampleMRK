({
	myAction : function(component, event, helper) {
        
        
         var lw = component.get("v.inValue");
                    console.log('getValueFromLwc child',JSON.stringify(lw));
        
         if(lw.length==0){
                        component.set("v.checkTableSizeZero",true);
                    }
        
        for(var i=0;i<lw.length;i++){
            
            if(lw[i].Lot==null){
                lw[i].Lot = 'N/A';
            }
            
        }
        component.set("v.inValue",lw);
        
        //component.set("v.inValue",JSON.stringify(lw));
		
	}
})