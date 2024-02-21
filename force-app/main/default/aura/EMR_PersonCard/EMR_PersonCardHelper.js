({
  /*  fetchUserDetails : function(component, event, helper) {
        console.log('PATIENT CARD');
        var action = component.get("c.getUserInfo");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('fetchUserDetails '+state);
            if (state === "SUCCESS") {  
                var res = response.getReturnValue();
                console.log('RESP '+JSON.stringify(res));
                console.log('res.Profile.Name '+res.Profile.Name);
                if(res.Profile.Name !== "System Administrator"){
                    component.set("v.deceasedButtonVisbility",false);
                }
                else {
                    component.set("v.deceasedButtonVisbility",true);
                }
            }
        });
        
        
    },*/
    patientWrapperHelper : function(component, event, helper,accId) {
        var action = component.get("c.patientWrapperMethod");
        //action.setStorable();
        component.set("v.licenseAvailable", true);
        //alert('++ '+component.get("v.recordId"));
        action.setParams({
            "accountId": accId
        });
        
        action.setCallback(component, function(response) {           
            var state = response.getState();
            console.log('patientWrapperHelper State' + state);
            if (state === "SUCCESS"){
                var Wrapperdata = response.getReturnValue();
                console.log('patientWrapperHelper response: '+Wrapperdata);
                console.log('Wrapperdata: '+Wrapperdata);
                var data = Wrapperdata.patient;
                console.log('Person card data: '+JSON.stringify(data));
                component.set("v.Patient_Name", data);
                if(data.ElixirSuite__Deceased__c){
                    component.set("v.deceasedButtonVisbilityWithCB",true);
                }
                else {
                    component.set("v.deceasedButtonVisbilityWithCB",false);
                }
                //Calculate age
                var today = new Date();
                var birthDate = new Date(data.ElixirSuite__DOB__c);
                var age = today.getFullYear() - birthDate.getFullYear();
                var m = today.getMonth() - birthDate.getMonth();
                if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
                    age = age - 1;
                }   
                
                data['Age']= age ;
                if(isNaN(data['Age'])){
                    data['Age'] = ' ';
                }
                else{
                    data['Age'] = data['Age'] + ' years';
                }
                
                //=========================Added==================
                var labelmap = Wrapperdata.getlabelsforFields;
                var conts = Wrapperdata.getTileConfigFieldsOrder;
                var custs = [];
                console.log('**Anubhav const'+conts);
                for ( var key in conts ) {
                    if(key !='Id')
                        custs.push({value:conts[key], key:labelmap[key]});
                }
                component.set("v.TileConfigFieldsInOrder", custs);
                
            }
            else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
        });
        $A.enqueueAction(action);
    }
})