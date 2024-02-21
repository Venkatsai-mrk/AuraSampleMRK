({
	openNew : function(component, event, helper) {
		component.set("v.isOpen",true);
	},
    refresh : function(component, event, helper) {
        component.set("v.isOpen",false);
        component.set("v.isOpen",true);
    }
})