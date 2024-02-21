({
    doInit : function(component, event, helper) {
      //  console.log('the code is'  ,  component.get("v.pwCode"));
        /* var action = component.get("c.getEmail");
        action.setParams({  
            recordId : component.get("v.patId"),
            formId   : component.get("v.recId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                 var data = response.getReturnValue();
                console.log('the data is' , data.cEmail);
                console.log('the data is' , data.code);
                component.set("v.result" , data.cEmail);
                component.set("v.pwCode" , data.code);
    }
             });
        $A.enqueueAction(action);*/
    },
    hideExampleModal : function(component, event, helper) {
        component.set("v.isActive",false);  
    },
    otpMethod : function(component, event, helper){  
        var newComment = component.get("v.comment");
        var action1 = component.get("c.newVal");
        action1.setParams({  
           veriCode : component.get("v.OTPVal"), // value which is added in the box
            OrderId   : component.get("v.recId"), // form id
            verCode  : component.get("v.pwCode"), // passsword code
            patientId : component.get("v.patId") 
          //  comment : component.get("v.comment")  //notes taken by signer
        });
        action1.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var allData = response.getReturnValue();
                console.log('map values' , allData.attachmentId);
                var cmpEvent = component.getEvent("OTPMatchCmpEvent"); 
                cmpEvent.setParams({
                    "attachementId" : allData.attachmentId,
                    "signComment"  : component.get("v.comment"),
                    "dateToday" : allData.datesNow 
                   // "isActive" : true
                }); 
                cmpEvent.fire(); 
                component.set("v.isActive",false);  
                
            }
            else if(state ==="ERROR"){
                var m = confirm("The Verification Code entered is incorrect. Please check it again or click cancel to go back to the form.");
                console.log('Failure');
            }
        });        
        $A.enqueueAction(action1);
        
    },
     
})