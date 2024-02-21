({
    doInit : function(component, event, helper) {
                console.log('component.get("v.patientDiagnosisLst") '+JSON.stringify(component.get("v.patientDiagnosisLst")));

        component.set("v.loaded",false);
        component.set("v.loaded",true);
        console.log('entityData --> '+JSON.stringify(component.get("v.chartSummaryOptions")));
        var refRecord = component.get("v.referralRecord");
        var filesVal = component.get("v.files");
         console.log(component.get("v.fileListSize"));
       /** var fileListSize = 0;
        console.log('Referral Preview - Other Douments '+filesVal);
        if(!filesVal)
        {
            fileListSize = 0;
            console.log('No Other Documents hence fileListSize = 0 '+fileListSize);
        }**/
        console.log('Form Preview  doInit() referralRecord ----->'+JSON.stringify(refRecord));
        console.log('Refered To Contact------> '+refRecord.ElixirSuite__Referred_To__c);
                          
        
        //
         /** component.set("v.referralRecord",{ 
            'sobjectType': 'ElixirSuite__Referral__c', 
            'ElixirSuite__Account__c' : component.get("v.accountId"),
            //'ElixirSuite__Email_CTM__c': ,
            'ElixirSuite__Email_Referred_To__c': component.get("v.referralRecord.ElixirSuite__Email_Referred_To__c") ,
           // 'ElixirSuite__Instructions__c': '',
            //'ElixirSuite__Phone_CTM__c': '',
            'ElixirSuite__Phone_Referred_To__c' : component.get("v.referralRecord.ElixirSuite__Phone_Referred_To__c"),
            //'ElixirSuite__Provider__c' : '',
            //'ElixirSuite__Reasons_for_Referral__c' : '',
            'ElixirSuite__Referred_Out_Organization__c' : component.get("v.referredOutOrgName") 
           // 'ElixirSuite__Referred_To__c' : '',
          //  'ElixirSuite__User__c' : ''
          });   
           helper.fetchDetails(component, event, helper);**/
        
    },
    closeModal : function(component, event, helper) {
        //component.set("v.isOpen",false);  
        /************Nikhil**************/ 
        var workspaceAPI =component.find("workspace");
        if(component.get("v.backPage2")){
        component.set("v.isOpen",false);    
        }else{
            window.history.go(-2);
        }
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error){
            console.log(error);
        });  
    },
    generatePDF :  function(component, event, helper) {
        helper.sendDataForPDF(component, event, helper);       
    },
    backFromPageThree :  function(component, event, helper) {
        try{  
            var cmpEvent = component.getEvent("ElixirOEM_ReferralToggle");         
            cmpEvent.setParams({            
                "pageNumber" : "BackFromThree" });        
            cmpEvent.fire();
        }
        catch(e){
            alert('backFromPageTwo error '+e);
        }
    }
})