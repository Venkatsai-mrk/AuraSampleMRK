({
	doInit : function(component, event, helper) {
        if(component.get("v.callClaimSubmit") == true){
        var strIds = component.get("v.claimIds").toString();
       console.log('aaaaaaaa'+strIds);
        component.set("v.formedClaimIds",strIds);
        var arr = [];
        arr = strIds.split(',');
        var action = component.get("c.updateClaims");
        action.setParams({
            claimLst : component.get("v.claimIds")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
          var res = response.getReturnValue();
          console.log(state);
          if(state === "SUCCESS"){      
          //window.setTimeout($A.getCallback(function() {
              helper.fireToast('SUCCESS',res);
              helper.viewName(component);
              //helper.duplicateChecker(component); 
          //}), 5000);
          }else if (state === "ERROR") {
              var errors = response.getError();
              if (errors) {
                  if (errors[0] && errors[0].message) {
                      helper.fireToast('ERROR',errors[0].message);
                      helper.viewName(component); 
                      
                  }
              }
          }
      });
      $A.enqueueAction(action);  
        }
    },
    
})