({
    myAction : function(component, event, helper) {
        console.log('PATIENT PERSON CARD'); 
        component.set("v.loaded",true);
        
        //  helper.fetchUserDetails(component, event, helper);
        var action2 = component.get("c.getUserInfo");
        var res;
        
        action2.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Current userinfo : '+state)
            if (state === "SUCCESS") {  
                res = response.getReturnValue();
                console.log('RESP for getUSerInfo '+JSON.stringify(res));
                console.log('res.Profile.Name '+res.Profile.Name);
                console.log('res.IsPortalEnabled' +res.IsPortalEnabled);
                if(res.Profile.Name !== "System Administrator"){
                    component.set("v.deceasedButtonVisbility",false);
                }
                else {
                    component.set("v.deceasedButtonVisbility",true);
                }
            }
            
            if(res.IsPortalEnabled){
                component.set("v.portalUser",res.IsPortalEnabled);
                var portalAccountId = res.AccountId;
                component.set("v.portalAccountId",portalAccountId);
                helper.patientWrapperHelper(component, event, helper,portalAccountId);
                
            }
            else {
                  helper.patientWrapperHelper(component, event, helper,component.get("v.recordId"));
            }
        });
     
        // helper.fetchCommunityUserDetails(component, event, helper);
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
        
        var action3 = component.get('c.LicensBasdPermission');
        action3.setParams({
        });
        
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                
                var wrapList = response.getReturnValue();
                component.set("v.Ehr",wrapList.isEhr);
                component.set("v.Billing",wrapList.isRcm);
                component.set("v.ContactCentr",wrapList.isContactCenter);
                component.set("v.patientPortal",wrapList.isPatientPortal);
            }
        });
        
        $A.enqueueAction(action2);
        $A.enqueueAction(action3);
        
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
    
    handleUploadFinished : function (component) {
        
        var isPortalUser = component.get("v.portalUser");
        var accId;
        if(isPortalUser){
            console.log('portalAccountId : '+component.get("v.portalAccountId"));
            accId =  component.get("v.portalAccountId");
        }
        else{
            accId = component.get("v.recordId")
        }
        var action = component.get("c.handlingAfterUpload");
        action.setParams({
            "accountId": accId
        });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if(state=="SUCCESS"){
                var e=component.get("c.myAction");
                $A.enqueueAction(e);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                         console.log("Error message: " + 
                              errors[0].message);
                    }
                } else {
                     console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
        var e =component.getEvent("refreshView");
        e.setParams({ "componentName": "PatientCard_test"});
        e.fire();
        
    },
    
    OpenElixirBillingSummary :function(component){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"c:BillingSummaryforEHR",
            componentAttributes: {
                recordId1 : component.get("v.recordId"),
                ehrLicense : component.get("v.Ehr"),
                billingLicense :   component.get("v.Billing"),
                contactcenterLicense : component.get("v.ContactCentr")
            }
        });
        evt.fire();
    },
    handleClick : function (component) {
        component.set("v.Alerts",true); 
    },
    OpenBillingApp : function (component) {
        var nagigateLightning = component.find('navigate');
        var pageReference = {
            type: "c__app",
            attributes: {
                appTarget: "Elixir_RCM",
            }
        };
        nagigateLightning.navigate(pageReference);
    },
    revertDeceased : function (component) {
         component.set("v.loaded",false);
        var action = component.get("c.revertPatientDeceased");
        action.setParams({
            "accountId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 component.set("v.loaded",true);
                if(response.getReturnValue()){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "PATIENT DECEASED ALREADY UN-CHECKED",
                        "message":  "No changes requiered!",
                        "type" : "info"
                    });
                    toastEvent.fire();
                }
                else {
                    $A.get('e.force:refreshView').fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "PATIENT DECEASED UN-CHECKED",
                        "message":  "All changes reverted!",
                        "type" : "success"
                    });
                    toastEvent.fire();
                }
            }
            
        });
        
        $A.enqueueAction(action);
    }
})