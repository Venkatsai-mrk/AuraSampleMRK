({
    myAction : function(component, event, helper) {
        var action = component.get("c.patientWrapperMethod");
        component.set("v.licenseAvailable", true);
        
        action.setParams({
            "oppId": component.get("v.recordId")
        });
        
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var Wrapperdata = response.getReturnValue();
                var data = Wrapperdata.patient;
                component.set("v.Patient_Name", data);
                console.log('data 3is', component.get("v.Patient_Name"));
                console.log('data 3ids test',data);
                
                var today = new Date();
                var birthDate = new Date(data.ElixirSuite__Patient_s_DOB__c);
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
                
				var fname = data['ElixirSuite__Patient_First_Name__c'];
                var mname = data['ElixirSuite__Patient_Middle_Name__c'];
                var lname =data['ElixirSuite__Patient_Last_Name__c'];

                if(fname != undefined){
                    data['FullName'] = fname; 
                }
                else{
                    data['FullName'] ='';
                }
                if(mname != undefined){
                    data['FullName'] = data['FullName']+' '+mname; 
                }
                if(lname != undefined){
                    data['FullName'] = data['FullName']+' '+lname;
                }


                //===== Added for Pateint Card Configuration ===
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
                $A.log("callback error", state);
            }
        });
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
            }
        });

       

        $A.enqueueAction(action);
        $A.enqueueAction(action3);
    },
    
   
    handleUploadFinished : function (component, event,helper) {
         var action = component.get("c.handlingAfterUpload");
       action.setParams({
            "oppId": component.get("v.recordId")
        });
        
        action.setCallback(component, function(response) {
            var state = response.getState();
            if(state=="SUCCESS"){
             var e=component.get("c.myAction");
                $A.enqueueAction(e);
            }
        });
        $A.enqueueAction(action);
       
        
       
    },
   
})