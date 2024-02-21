({
    doInit : function(component, event, helper) {
        component.set("v.openModal",true);
        var nameSpace = 'ElixirSuite__';
        var createObject = {};
        createObject['Name'] = 'Patient Object';
        createObject[nameSpace + 'Sample_Type__c'] = '';
        createObject[nameSpace + 'Name_of_container__c'] = '';
        createObject[nameSpace + 'ContainerType__c'] = '';
        createObject[nameSpace + 'Container_Description__c'] = '';
        createObject[nameSpace + 'ContainerSize__c'] = '';
        createObject[nameSpace + 'Specimen_Quantity__c'] = '';
        createObject[nameSpace + 'Additives_if_Any__c'] = '';
        createObject[nameSpace + 'Specimen_Condition__c'] = '';
        createObject[nameSpace + 'Notes__c'] = '';
        createObject[nameSpace + 'Status__c'] = 'Open';
        createObject[nameSpace + 'Collection_Datetime__c'] = '';
        createObject[nameSpace + 'Specimen_Collector__c'] = '';
        createObject[nameSpace + 'Order_to__c'] = '';
        createObject[nameSpace + 'Lab_Name__c'] = '';
        createObject[nameSpace + 'Order_By__c'] = '';
        createObject[nameSpace + 'Lab_Code__c'] = '';
        createObject[nameSpace + 'Lab_Location__c'] = '';
        createObject[nameSpace + 'Lab_email__c'] = '';
        createObject[nameSpace + 'Comments__c'] = '';
        component.set("v.physicalSampleDetails",createObject);
        
        //Account details
        var action = component.get("c.getAccountDetails");
        action.setParams({
            accountId : component.get("v.accountId")
        });      
        action.setCallback(this, function (response) {
            var res = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.accountDetails",res.accountRec);  
                component.set("v.usersList",res.listOfUsers);  
                component.set("v.patAge" , res.patientAge );
                component.set("v.patDOB" , res.patientBirthdate );
                component.set("v.nameSpace" , 'ElixirSuite__' );
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
    },
   showInfo : function(component, event, helper) {
      var myLabel = component.find("SpecimenQuantity").value;
      var mycmp = component.get("v.physicalSampleDetails.ElixirSuite__Specimen_Quantity__c");

       if($A.util.isEmpty(mycmp) || $A.util.isUndefined(mycmp)){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type : 'Error',
            message: 'Please Enter a Valid Number.',
            
        });
        toastEvent.fire();
     }
    },
   showAction : function(component, event, helper) {
      var myLabel2 = component.find("containersize").value;
      var mycmp2 = component.get("v.physicalSampleDetails.ElixirSuite__ContainerSize__c");
         
       if($A.util.isEmpty(mycmp2) || $A.util.isUndefined(mycmp2)){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type : 'Error',
            message: 'Please Enter a Valid Number.',
            
        });
        toastEvent.fire();
     }
    },

    
    Save  : function(component, event, helper) {
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true); 
        
        var dataToSave = component.get("v.physicalSampleDetails");
        var nameSpace = 'ElixirSuite__';
        dataToSave[nameSpace + 'Account__c'] = component.get("v.accountId");
        dataToSave[nameSpace + 'Sample_Type__c'] = 'Physical';
        console.log('DETAILS '+JSON.stringify(dataToSave));
        if(allValid == true){
            component.set("v.disabled",true);
            var action = component.get("c.savePhysicalDetail");
            action.setParams({
                dataToSave : dataToSave
            });      
            action.setCallback(this, function (response) {
                var res = response.getReturnValue();
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(res){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "info",
                            "title": "USER'S EMAIL ID IS NOT VALID OR DOES NOT EXISTS!",
                            "message": "Mail was not sent to the UA team member !"
                        });
                        toastEvent.fire(); 
                    }
                    //$A.get('e.force:refreshView').fire();
                    var cmpEvent = component.getEvent("LandingPage"); 
                    cmpEvent.fire();
                    //component.set("v.openModal",false);
                    
                    
                    var refreshevt = component.getEvent("RefreshUAListView"); 
                    refreshevt.fire();
                    
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Success",
                        "title": "SAMPLE SUBMITTED SUCCESSFULLY!",
                        "message": "Submitted Successfull!"
                    });
                    toastEvent.fire();              
                    
                    var workspaceAPI = component.find("workspace");//NK------
                    if(component.get("v.popFlag")){
                        component.set("v.openModal",false); 
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
                    
                }
                
                else if (state === "ERROR") {
                    component.set("v.disabled",false);
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
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "Failed",
                "title": "Please Fill the Mandatory Fields.",
                "message": "Unable to Save Record"
            });
            toastEvent.fire();    
        }
       
    },
    closeModel  : function(component, event, helper) {
       //component.set("v.openModal",false);
       
       /*-- Nikhil ---*/
        var workspaceAPI = component.find("workspace");
        if(component.get("v.popFlag")){
          component.set("v.openModal",false); 
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
        
    }
})