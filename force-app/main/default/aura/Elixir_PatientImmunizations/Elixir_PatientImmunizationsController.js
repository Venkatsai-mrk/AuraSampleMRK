({
	doInit : function(component, event, helper) {
		helper.createTable(component,event);
	},
    Save:function(component,event,helper){
        console.log('lst'+ JSON.stringify(component.get("v.VaccineList")));
        helper.dataSave(component,event,helper);
    },                        
    handleCancel:function(component,event,helper){
        
        var url = component.get("v.url");
        sforce.one.navigateToURL(url);
        //Sfdc.canvas.publisher.publish({ name: "publisher.close", payload:{ refresh: "true" }});
 },
    
    addNewRow: function(component, event, helper) {
        
        helper.createRow(component,event);
    },
    
    removeDeletedRow: function(component, event, helper) {
        
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        
        var AllRowsList = component.get("v.VaccineList");
        AllRowsList.splice(index, 1);
        
        component.set("v.VaccineList", AllRowsList);
    },
})