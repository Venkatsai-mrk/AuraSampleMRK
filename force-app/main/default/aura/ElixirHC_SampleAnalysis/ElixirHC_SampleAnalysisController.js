({
    doInit : function(component, event, helper) {
        component.set("v.openModal",true);
        var nameSpace = component.get("v.nameSpace");
        var createObject = {};
        createObject['Name'] = '';
        createObject[nameSpace + 'Sample_Type__c'] = '';
        createObject[nameSpace + 'Name_of_container__c'] = '';
        createObject[nameSpace + 'ContainerType__c'] = '';
        createObject[nameSpace + 'Container_Description__c'] = '';
        createObject[nameSpace + 'ContainerSize__c'] = '';
        createObject[nameSpace + 'Specimen_Quantity__c'] = '';
        createObject[nameSpace + 'Additives_if_Any__c'] = '';
        createObject[nameSpace + 'Specimen_Condition__c'] = '';
        createObject[nameSpace + 'Notes__c'] = '';
        createObject[nameSpace + 'Collection_Datetime__c'] = '';
        createObject[nameSpace + 'Specimen_Collector__c'] = '';
        createObject[nameSpace + 'Order_to__c'] = '';
        createObject[nameSpace + 'Lab_Name__c'] = '';
        createObject[nameSpace + 'Order_By__c'] = '';
        createObject[nameSpace + 'Lab_Code__c'] = '';
        createObject[nameSpace + 'Lab_Location__c'] = '';
        createObject[nameSpace + 'Lab_email__c'] = '';
        createObject[nameSpace + 'Comments__c'] = '';
         createObject[nameSpace + 'Examined_By__c'] = '';
        component.set("v.physicalSampleDetails",createObject);
        component.set("v.typeCheckBox",'Physical');   
        //Account details 
        var action = component.get("c.getAccountDetails");
        action.setParams({
            accountId : component.get("v.accountId"),
            sampleId  : component.get("v.physicalSampleDetail")
        });      
        action.setCallback(this, function (response) {
            var res = response.getReturnValue();
            var state = response.getState();
             component.set("v.nameSpace" , 'ElixirSuite__');
            if (state === "SUCCESS") {
                component.set("v.accountDetails",res.accountRec);   
                component.set("v.patAge" , res.patientAge );
                component.set("v.patDOB" , res.patientBirthdate );
                component.set("v.physicalSampleDetails",res.sampleDetails);  
                component.set("v.usersList",res.listOfUsers);  
                var allFieldList = res.mapOfNameToField;
                var nameSpace = 'ElixirSuite__';
                for(var keyInside in allFieldList){
                    if(keyInside.toUpperCase() == (nameSpace + 'Specimen_Status__c').toUpperCase()){
                        component.set("v.specimenStatusPicklistValues",allFieldList[keyInside]);
                    }
                    else if(keyInside.toUpperCase() == (nameSpace + 'Status__c').toUpperCase()){
                        component.set("v.statusPicklistValues",allFieldList[keyInside]); 
                    }
                        else if(keyInside.toUpperCase() == (nameSpace + 'Colour__c').toUpperCase()){
                            component.set("v.colourPicklistValues",allFieldList[keyInside]); 
                        }
                            else if(keyInside.toUpperCase() == (nameSpace + 'Appearance__c').toUpperCase()){
                                component.set("v.appearancePicklistValues",allFieldList[keyInside]); 
                            }
                }
                if(!$A.util.isUndefinedOrNull(res.physicalSampleAnalysis)){
                    component.set("v.physicalSampleAnalysis", res.physicalSampleAnalysis);   
                    component.set("v.isDisabledSample",true);    
                    component.set("v.showPhysicalAnalysis",true);
                    component.set("v.typeCheckBox",'Physical');       
                }else{
                    helper.createPhysicalAnalysis(component);
                    component.set("v.isDisabledSample",false);
                    component.set("v.showPhysicalAnalysis",true);
                    component.set("v.typeCheckBox",'Physical');
                }  
                if(component.get("v.isDisabledSample") == true){
                    if(!$A.util.isUndefinedOrNull(res.labDetails)){
                        component.set("v.physicalLabDetails", res.labDetails);   
                        component.set("v.isDisabledLabSampleDetails",true);    
                        component.set("v.showLabSampleDetails",true);    
                        component.set("v.typeCheckBox",'Laboratory');       
                    }else{
                        helper.createLabDetails(component);
                        component.set("v.isDisabledLabSampleDetails",false);
                        component.set("v.showLabSampleDetails",true);
                        component.set("v.typeCheckBox",'Laboratory');  
                    } 
                }   
                if(component.get("v.isDisabledLabSampleDetails") == true){
                    if(!$A.util.isUndefinedOrNull(res.labAnalysis)){
                        component.set("v.labSampleAnalysis", res.labAnalysis);   
                        component.set("v.isDisabledLabSampleAnalysis",true);    
                        component.set("v.showLabSampleAnalysis",true);    
                        component.set("v.typeCheckBox",'Laboratory');
                        component.set("v.hideSaveIfAssesmentIsCompleted",false);   
                        
                    }else{
                        helper.createLabAnalysis(component);
                        component.set("v.isDisabledLabSampleAnalysis",false);
                        component.set("v.showLabSampleAnalysis",true);
                        component.set("v.typeCheckBox",'Laboratory');  
                    } 
                }
                
                component.set("v.loaded",true);    
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
   
    radioCheck  : function(component, event, helper) {
        console.log(event.getSource().get("v.value"));
        var name = event.getSource().get("v.name");
        var array = name.split('$');
        var value = array[0];
        var field = array[1];
        var args = component.find("checkone");
        for(var key in args){
            if(args[key].get("v.name").split('$')[0] != value){             
                args[key].set("v.checked",false);
            }
        }
        var physicalAnalysis = component.get("v.physicalSampleAnalysis");
        physicalAnalysis[field] = value;  
        component.set("v.physicalSampleAnalysis",physicalAnalysis);
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
        var nameSpace = component.get("v.nameSpace") ;
        var emailOutSectionIdentifier = '';
        
        var physicalSampleAnalysis = component.get("v.physicalSampleAnalysis");
        physicalSampleAnalysis[nameSpace + 'Account__c'] = component.get("v.accountId");
        physicalSampleAnalysis[nameSpace + 'UA_Sample_Details__c'] = component.get("v.physicalSampleDetail");
        
        var labDetails = component.get("v.physicalLabDetails");
         
        if(! $A.util.isUndefinedOrNull(labDetails)){
            labDetails[nameSpace + 'UA_Sample_Details__c'] = component.get("v.physicalSampleDetail");//Self Lookup on Sample Details
            labDetails[nameSpace + 'Account__c'] = component.get("v.accountId");
            labDetails[nameSpace + 'Sample_Type__c'] = 'Laboratory';
        }
         console.log('3rd level lab details '+JSON.stringify(labDetails));        
        var labSampleAnalysis = component.get("v.labSampleAnalysis");
        if(! $A.util.isUndefinedOrNull(labSampleAnalysis)){
            labSampleAnalysis[nameSpace + 'UA_Sample_Details__c'] = component.get("v.physicalLabDetails").Id;//Self Lookup on Sample Details
            labSampleAnalysis[nameSpace + 'Account__c'] = component.get("v.accountId");
        }
        
        var showPhysicalAnalysis = component.get("v.showPhysicalAnalysis");
        var isDisabledSample =  component.get("v.isDisabledSample");
        
        var showLabSampleDetails = component.get("v.showLabSampleDetails");
        var isDisabledLabSampleDetails =  component.get("v.isDisabledLabSampleDetails");
        
        var showLabSampleAnalysis = component.get("v.showLabSampleAnalysis");
        var isDisabledLabSampleAnalysis =  component.get("v.isDisabledLabSampleAnalysis");
        
        if(showPhysicalAnalysis && !isDisabledSample){
            emailOutSectionIdentifier = 'PhysicalSampleAnalysis'
        }
        else if(showLabSampleDetails && !isDisabledLabSampleDetails){
            emailOutSectionIdentifier = 'LabSampleDetails' 
        }
        else if(showLabSampleAnalysis && !isDisabledLabSampleAnalysis){
            emailOutSectionIdentifier = 'LabSampleAnalysis'  
        }
        console.log('email out value '+emailOutSectionIdentifier);
        console.log('physical sample '+JSON.stringify(physicalSampleAnalysis));
        console.log('lab details '+JSON.stringify(labDetails));
        console.log('lab sample analysis sample '+JSON.stringify(labSampleAnalysis));
        if(allValid == true){ //change it to true
            component.set("v.disabled",true);
            var action = component.get("c.saveDetails");
            action.setParams({
                physicalSampleAnalysis : physicalSampleAnalysis,
                labDetails : labDetails,
                labSampleAnalysis : labSampleAnalysis,
                patientId : component.get("v.accountId"),
                emailOutSectionIdentifier : emailOutSectionIdentifier,
                stringifiedPhysicalSample : JSON.stringify(physicalSampleAnalysis),
                stringifiedLabSample : JSON.stringify(labSampleAnalysis)
            });      
            action.setCallback(this, function (response) {
                var res = response.getReturnValue();
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.physicalSampleDisabled",true);
                    //component.set("v.openModal",false);
					 //$A.get('e.force:refreshView').fire();                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Success",
                        "title": "SAMPLE SUBMITTED SUCCESSFULLY!",
                        "message": "Submitted Successfull!"
                    });
                    toastEvent.fire();   
                   //$A.get('e.force:refreshView').fire();                    
                     component.set("v.openModal",false);
                     var cmpEvent = component.getEvent("LandingPage"); 
                     cmpEvent.fire();
                    var refreshevt = component.getEvent("RefreshUAListView"); 
                        refreshevt.fire(); 
                    //Nikhil  ---0
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
                "title": "FILL MANDATORY FIELDS!",
                "message": "Failed!"
            });
            toastEvent.fire();    
        }
        
    },
    closeModel  : function(component, event, helper) {
        component.set("v.openModal",false);
    },
    sectionOne : function(component, event, helper) {
        helper.helperFun(component,event,'articleOne');
    },
    sectionTwo : function(component, event, helper) {
        helper.helperFun(component,event,'articleTwo');
    },
    
    sectionThree : function(component, event, helper) {
        helper.helperFun(component,event,'articleThree');
    },
    
    sectionFour : function(component, event, helper) {
        helper.helperFun(component,event,'articleFour');
    }
})