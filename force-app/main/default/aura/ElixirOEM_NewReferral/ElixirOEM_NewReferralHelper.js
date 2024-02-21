({
    initPayload : function(component, event, helper) {
        try{
            component.set("v.loaded",false);
            var action = component.get("c.referralInitPayload");
            action.setParams({
                "accountId" :  component.get("v.accountId")
            });
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") {  
                    component.set("v.loaded",true);
                    let result =  response.getReturnValue();
                    let patientICDs = result.patientICDs;
                    let patientProcedureLst = result.patientProcedureLst;
                    let patientInfo = result.patientInfo;
                    let loggedInUserDetail = result.loggedInUserDetail;
                    console.log('In initPayload()  Logged In User - ');
                    
                    component.set("v.userId",loggedInUserDetail.Id);
                     component.set("v.userName",loggedInUserDetail.Name);  
                    component.set("v.referralRecord.ElixirSuite__User__c",loggedInUserDetail.Name); 
                    
                    console.log('loggedInUserDetail.Id '+loggedInUserDetail.Id);
                    console.log('loggedInUserDetail.Name '+loggedInUserDetail.Name);
                    
                    var refRecord =  component.get("v.referralRecord");                  
            
                    //Care Team Member
                    refRecord.ElixirSuite__User__c = loggedInUserDetail.Id;
                    refRecord.ElixirSuite__Phone_CTM__c = loggedInUserDetail.Phone;
                    refRecord.ElixirSuite__Email_CTM__c = loggedInUserDetail.Email;
                    
                     component.set("v.referralRecord",refRecord);
                    console.log('refRecord User '+refRecord.ElixirSuite__User__c );
                    
                    if(!$A.util.isEmpty(patientInfo)){
                        component.set("v.patientInfo",patientInfo[0]);    
                    }
                    console.log('result '+JSON.stringify(result));
                    patientICDs.forEach( function(element, index) {
                        element['isSelected'] = false;
                    });
                    component.set("v.patientDiagnosisLst",patientICDs);   
                    patientProcedureLst.forEach( function(element, index) {
                        element['isSelected'] = false;
                    });
                    component.set("v.patientProcedureLst",patientProcedureLst);   
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            
                        }
                    } else {  
                        
                    }
                }
                component.set("v.LoadingText", false);
            });
            $A.enqueueAction(action);
            
            //Action for Location
         console.log('Location Provider action calling');
            var locationaction1 = component.get("c.fetchAccountProvider");       
            locationaction1.setParams({
                "accountId" :  component.get("v.accountId")
            });
			locationaction1.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") {                     
                    try{
                        let result =  response.getReturnValue();               
                        if(!$A.util.isEmpty(result)){
                            var refRecord =  component.get("v.referralRecord");
                            refRecord.ElixirSuite__Provider__c = result[0].Id;
                            component.set("v.locationName",result[0].Name);
                            component.set("v.referralRecord",refRecord);
                          
                            
                            console.log('After setting Location Provider '+refRecord);
                            console.log('Ref Location Provider '+component.get("v.referralRecord"));
                            console.log('Ref Location Provider1 ID Name '+result[0].Id + ' - '+result[0].Name ); 
                            //component.set("v.selectRecordName",result[0].Name);//ElixirSuite__Provider__c
                            //component.set("v.selectRecordId",result[0].Id);
        }
        }
                    catch(e)
                    {
                        console.log('error is '+e)
                    }
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
        
                        }
                    } else {  
                        
                    }
                }       
            });
            $A.enqueueAction(locationaction1);
            
        }
        catch( e)
        {
            console.log('Error '+e);
        }
    },
       
    setDefaultJSON :  function(component, event, helper) {
        component.set("v.referralRecord",{ 
            'sobjectType': 'ElixirSuite__Referral__c', 
            'ElixirSuite__Account__c' : component.get("v.accountId"),
            'ElixirSuite__Email_CTM__c': '' ,
            'ElixirSuite__Email_Referred_To__c': '',
            'ElixirSuite__Instructions__c': '',
            'ElixirSuite__Phone_CTM__c': '',
            'ElixirSuite__Phone_Referred_To__c' : '',
            'ElixirSuite__Provider__c' : '',
            'ElixirSuite__Reasons_for_Referral__c' : '',
            'ElixirSuite__Referred_Out_Organization__c' : '', 
            'ElixirSuite__Referred_To__c' : '',
            'ElixirSuite__User__c' : component.get("v.userName")}); 
        console.log('referralRecord '+JSON.stringify(component.get("v.referralRecord")));
    },

    globalFlagToast : function(component, event, helper,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":  message,
            "type" :type
        });
        toastEvent.fire();
    },
    
    getDefaultURL : function(component, event, helper,title,message,type) {
        let urlString = window.location.href;
        let baseURL = urlString.substring(0, urlString.indexOf('/s'));
        console.log('baseURL '+baseURL); 
    }
})