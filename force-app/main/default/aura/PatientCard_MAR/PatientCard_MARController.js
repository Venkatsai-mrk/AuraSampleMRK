({
    myAction : function(component, event, helper) {
    
    /*       var licenseAction = component.get("c.checkEMRLicense");
        var licenseavailable = false;
        //alert(component.find("licensecheck".document.getElement.text()));
       // var divtext = component.find("licensecheck");
        //alert(divtext.innerHTML);
        //alert(document.getElementById("aman").innerHTML);
        //console.log(divtext);
        licenseAction.setCallback(component,function(response){
            if(response.getState() === "SUCCESS"){
            licenseavailable = response.getReturnValue();          */
            
           //alert("licenseavailable==========="+licenseavailable);
          // if(licenseavailable){
          console.log('meghna');
                    var action = component.get("c.patientCardMethod");
                    //action.setStorable();
                   
                    action.setParams({
                        "accountId": component.get("v.recordId")
                    });
                    
                    action.setCallback(component, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS"){
                            var data = response.getReturnValue();
                            component.set("v.Patient_Name", data);
                            component.set("v.allergyData" , data.allegsPat);
                            component.set("v.problemData" , data.problemsPat);
                            console.log('data is', component.get("v.Patient_Name"));
                        }
                        else if (state === "ERROR") {
                            $A.log("callback error", state);
                        }
                    });
                    $A.enqueueAction(action);
                /*}
                else{
                    component.set("v.place","This functionality is part of EMR. Please get in touch with Mirketa if you are interested in EMR.");
                  //  divtext.innerHTML="This functionality is part of EMR. Please get in touch with Mirketa if you are interested in EMR.";
                }
               
            }
        }); 
        $A.enqueueAction(licenseAction); */
    },
    
        /*
       	var licenseAction = component.get("c.checkEMRLicense");
        var is_license_available = false;
        licenseAction.setCallback(component,function(response){
            if(response.getState() === "SUCCESS"){
                is_license_available = response.getReturnValue();
                component.set("v.licenseAvailable",is_license_available);
                
                if(is_license_available){
                    var action = component.get("c.patientCardMethod");
                    //action.setStorable();
                    
                    action.setParams({
                        "accountId": component.get("v.recordId")
                    });
                    
                    action.setCallback(component, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS"){
                            var data = response.getReturnValue();
                            component.set("v.Patient_Name", data);
                        }
                        else if (state === "ERROR") {
                            $A.log("callback error", state);
                        }
                    });
                    $A.enqueueAction(action);
                }
                
            }
        });
        $A.enqueueAction(licenseAction);
       
        if(is_license_available == "true"){
            console.log("I'm Here!");
            var action = component.get("c.patientCardMethod");
            //action.setStorable();
            
            action.setParams({
                "accountId": component.get("v.recordId")
            });
            
            action.setCallback(component, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    var data = response.getReturnValue();
                    component.set("v.Patient_Name", data);
                }
                else if (state === "ERROR") {
                    $A.log("callback error", state);
                }
            });
            $A.enqueueAction(action);
        }
    },*/
   
    handleUploadFinished : function (component, event,helper) {
         var action = component.get("c.handlingAfterUpload");
       action.setParams({
            "accountId": component.get("v.recordId")
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
       var e =component.getEvent("refreshView");
       e.setParams({ "componentName": "PatientCard_test"});
      e.fire();
       
    },
   
})