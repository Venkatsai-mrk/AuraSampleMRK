({
	init : function(component, event, helper) {
		 helper.createTableData(component, event, helper);
	},
    mapRecord : function(component, event, helper) {
        
        var index = event.getSource().get("v.tabindex");
        event.getSource().set("v.label",'Mapped');
        
       
        var AllRowsList= component.get("v.claimlineList");
        
        AllRowsList[index].eraLineId = component.get("v.eralineId");
        //  AllRowsList[index].disabled = true;
        component.set("v.selectedIndex", index);
        component.set("v.claimlineList", AllRowsList);
        component.set("v.isOpenMap",false);
        component.set("v.selectedClaimLineId",AllRowsList[index].id);
        console.log('claimlineList', component.get("v.claimlineList"));
        
        
        var compEvent = component.getEvent("ClaimLineComponentEvent");

        compEvent.setParams({"ClaimLineId" : component.get("v.selectedClaimLineId"),
                             "MapIndex": component.get("v.eraLineSelectedIndex")
                            });
        compEvent.fire();
	},
    openPop : function(component, event, helper){
        component.set("v.isOpenMap",true);
    },
    cancelWindow : function(component, event, helper) {
        
		var claimlineList = component.get("v.claimlineList");
        var index = component.set("v.selectedIndex");
        //for(let i=0; i<claimlineList.length; i++){
        //    claimlineList[i].eraLineId = '';
        //}
        // claimlineList[index].eraLineId = '';
        
        //component.set("v.claimlineList", claimlineList);
        console.log('claimlineList', component.get("v.claimlineList"));
        component.set("v.isOpenMap",false);	
    },
    closeWindow : function(component, event, helper) {
        
        component.set("v.isOpenClaimLine",false);	
    }
    
})