({
    doinit : function(component, event, helper) {
        var initial=false;
         component.set("v.isOpen",true);
        component.set("v.searchString", "");
         helper.myAction(component, event, helper,initial);
    }, 
    claimTypeChange : function(component, event, helper) {
        
        component.set("v.VobList", []);
        component.set("v.selectedRows", []);
        component.set("v.selectedPayer", {} );
        component.set("v.SelectRecordName",null);
         component.set("v.searchString", "");
        var ser = component.get("v.searchString");
        console.log('sss',ser);
        
         var selectedClaimType= event.getSource().get('v.value');
        console.log('selectedClaimType',selectedClaimType);
         component.set("v.headerLabel", selectedClaimType);
        var initial=true;
        helper.myAction(component, event, helper,initial);
    },
    cancelWindow : function(component, event, helper){
        component.set("v.isOpen",false);
        
        component.set("v.displayTable", false);
        component.set("v.headerLabel", 'Primary');
        component.set("v.VobList", []);
        component.set("v.selectedRows", []);
        component.set("v.selectedPayer", {} );
        component.set("v.SelectRecordName",null);
        component.set("v.searchString", "");
        var compEvent = component.getEvent("cancelEvent"); //Anusha 29/10/22
        compEvent.fire(); //Anusha 29/10/22
       //component.set("v.isCMS1500",true); 
    },
    handleComponentEvent : function(component, event, helper) {
       // component = component.find("partnerTable");
		 //var selectedList = event.getParam("selectedRowList");  
       // component.set("v.selectedRows", selectedList);
        
	},
    rowSelectionHandle: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        cmp.set('v.selectedVOBList', selectedRows);
        console.log('selectedVOBList',cmp.get('v.selectedVOBList'));
    },
    proceedNext : function(component, event, helper){
        console.log('VobList-',component.get('v.VobList').length);
        var SelectRecordName = component.get('v.SelectRecordName');
        console.log('SelectRecordName-',SelectRecordName);
        if ($A.util.isUndefinedOrNull(SelectRecordName) || $A.util.isEmpty(SelectRecordName)){
             var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "PLEASE SELECT INSURANCE",
                 "message": " ",
                "type" : "error"
            });
            toastEvent.fire();
        }
        else{
        component.set("v.isOpen",false);
       component.set("v.isCMS1500",true);
        }
        
    },
     handleSort: function(component,event,helper){
        var sortBy = event.getParam("fieldName");       
        var sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        
        helper.sortData(component,sortBy,sortDirection);
    },
})