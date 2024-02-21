({
    myAction : function(component) {
        var acctPatId = component.get("v.patId");
        var action = component.get("c.getAllData");
        action.setParams({ accountId :  acctPatId});        
        action.setCallback(this, function (response){
            var state = response.getState(); 
            if (state === "SUCCESS") {  
                var data = response.getReturnValue();
                component.set("v.Patient_Name", data.patData);
                 /* Added for Patient Card Configuration */
                 var labelmap = data.getlabelsforFields;
                var conts = data.getTileConfigFieldsOrder;
                var custs = [];
                    for ( var key in conts ) {
                        if(key !='Id')
                          custs.push({value:conts[key], key:labelmap[key]});
                    }
                    component.set("v.TileConfigFieldsInOrder", custs);
            }
        });
        $A.enqueueAction(action);
    },
    handleUploadFinished : function (component) {
         var action = component.get("c.handlingAfterUpload");
       action.setParams({
            "accountId": component.get("v.patId")
        });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if(state=="SUCCESS"){
             var e=component.get("c.myAction");
                $A.enqueueAction(e);
            }
        });
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
       
    },
    handleClick : function (component) {
       component.set("v.Alerts",true); 
    }
})