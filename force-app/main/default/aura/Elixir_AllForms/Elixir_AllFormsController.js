({
	myAction : function(component, event, helper) {   
        console.log('inti');
        //alert(JSON.stringify(component.get("v.accName")));
        var action = component.get("c.fetchAllForms");
       // alert(component.get("v.categorized"));
        action.setParams({
                "category": component.get("v.categorized"),
                "subCategory": '',
                "accountId": component.get("v.patientID")
            });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            component.set("v.accName",data);
            var res = data.forms;
           // component.set('v.accName',data.accName);
            
            console.log('accname '+component.get('v.patientID'));
            var state = response.getState();
            if (state === "SUCCESS") {
                var a = res;
                var b = [];


                for (var i = 0; i < res.length; i++) {
                    console.log('inside for');
                    b[i] = {
                        'label': res[i]['Name'],
                        'value': res[i]['Id']
                    };

                }
  
                component.set("v.options", b);

            }

        });

        $A.enqueueAction(action);
	
	},
    
    handleChange: function(component, event, helper) {
        
        component.set("v.RecordId",event.getParam("value"));
         //component.set("v.formName",event.getParam("label"));
         console.log('label value >'+event.getSource().get("v.name"));
         console.log('HANDLE CHANGE>'+event.getSource().get("v.value"));
   
    
       
    },
    navigateToSpecificForm : function(component, event, helper) {
      // alert(component.get("v.RecordId"));
        if(component.get("v.RecordId") == undefined){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Notification!",
                "type": 'info',
                "message": 'PLEASE SELECT FORM TYPE!'
            });
            toastEvent.fire();
            
        }
        else {
            
            component.set("v.openForm",true);
           
        }        
        
    },
    
    closeModal : function(component, event, helper) {
        console.log('inside close modal');
        component.set("v.isOpen",false);
    }
   
})