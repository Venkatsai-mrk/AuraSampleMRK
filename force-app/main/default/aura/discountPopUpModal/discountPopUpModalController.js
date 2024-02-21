({
    myAction : function(component, event, helper) {
     component.set("v.DisAmt",null); 
     component.set("v.DisType",'Amount');   
    },
	closePopUp : function(component, event, helper) {
		component.set("v.isModalOpen",false);
	},
    AddDiscount : function(component, event, helper) {
        if(component.get("v.DisAmt")<0){
            return;
        }
        component.set("v.returnVal", false);
        if(component.get("v.DisType")=='Amount' && (parseFloat(component.get("v.DisAmt")) <= component.get("v.maxAmountforDiscount"))){
            component.set("v.returnVal", true);
        }
        if(component.get("v.DisType")=='Percentage' && (parseFloat(component.get("v.DisAmt")) <= component.get("v.maxPercentageforDiscount"))){
           component.set("v.returnVal", true);
        }
        if(component.get("v.returnVal") == true){
        var compEvent = component.getEvent("discountEvent");
        compEvent.setParams({
            "inputValue" : component.get("v.DisAmt"), 
            "type" : component.get("v.DisType"),
        });
        compEvent.fire();
        component.set("v.isModalOpen",false);
        }
	},
    disTypeChange: function(component, event, helper) {
      component.set("v.DisAmt",null); 
    },
    fireErrorToast : function(errorMessage){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: errorMessage,
            type: 'Error',
            mode: 'pester'
        });
        toastEvent.fire();
    }
})