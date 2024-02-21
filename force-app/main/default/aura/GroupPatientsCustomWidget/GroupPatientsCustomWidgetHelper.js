({
	editRecord : function(component, event) {
        var row = event.getParam('row');
        var recordId = row.Id;
        $A.get("e.force:editRecord").setParams({"recordId": recordId}).fire();
    }, 
     deleteRecord : function(component, event) {
       
        var groupPatientRec = event.getParam('row');        
        var action = component.get("c.deleteGroupPatients");
        action.setParams({
            "groupPatientRrecord": groupPatientRec
        });
        action.setCallback(this, function(response) {
                      
            if (response.getState() === "SUCCESS" ) {
                var rows = component.get('v.groupPatientList');
                var rowIndex = rows.indexOf(groupPatientRec);
                rows.splice(rowIndex, 1);
                component.set('v.groupPatientList', rows);
                this.showToast("Success!","success","The record has been delete successfully.");
            }
            else{
                this.showToast("ERROR","error",JSON.stringify(response.getError())); 
            }
        });
        $A.enqueueAction(action);
    },
     showToast:function(title,type,message){
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({"title": title,"type": type,"message": message}).fire();
        }
        else{
            alert(message);
        }
    },
})