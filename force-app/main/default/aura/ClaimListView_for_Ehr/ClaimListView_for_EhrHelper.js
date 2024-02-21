({
    //Added by Pratiksha
    fetchAccountName:function(component, event, helper){
        var action = component.get("c.fetchAccountName");
           action.setParams({ accountId : component.get("v.patId") });
           action.setCallback(this, function(response) {
               var state = response.getState();
               if (state === "SUCCESS") {
   
                   console.log('Patient name  data '+JSON.stringify(response.getReturnValue()));                
                   var records =response.getReturnValue();
                   component.set("v.accName", records);
   
               }
   
            });
   
           $A.enqueueAction(action);
       },
    //End
    computeDates : function(component, event, helper) {
        component.set("v.errorType",'');
        let startDate = component.get("v.Fdate");
        let endDate = component.get("v.Tdate");
        if($A.util.isUndefinedOrNull(startDate)){
            component.set("v.errorType",'Fdate');
            component.set("v.errorMsg",'From Date cannot be empty');
            return 1;
        }
        if($A.util.isUndefinedOrNull(endDate)){
            component.set("v.errorType",'Tdate');
            component.set("v.errorMsg",'To Date cannot be empty');
            return 1;
        }
        if(startDate>=endDate){  
            component.set("v.errorType",'Tdate');
            component.set("v.errorMsg",'To Date cannot less than From Date');
            return 1;
        }
    }
})