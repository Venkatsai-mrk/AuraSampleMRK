({
    doAction : function(component, event, helper) {
        // alert('vitals'); 
        var routeOfComponent = component.get("v.SaveRoute");
        if (routeOfComponent=='form') {
            component.set("v.disableSubmit" , false);
        }
        component.set("v.loaded",false);
        helper.getUser(component, event, helper);
        
        var action = component.get("c.getVitalSignsRecords");
        console.log('AccountId--'+component.get("v.AccountId"));
        action.setParams({
            "AccID"  : component.get("v.AccountId")
            
        });
        action.setCallback(this, function (response){
            //alert('response.getRetunrValue()----'+response.getReturnValue());
            let res = response.getReturnValue();
            for(let rec in res){
                if(res[rec].hasOwnProperty('ElixirSuite__Respiration__c')){
                    if(res[rec].ElixirSuite__Respiration__c.includes('Breaths/Minute')){
                        res[rec].ElixirSuite__Respiration__c = res[rec].ElixirSuite__Respiration__c.replace('Breaths/Minute','');
                    }
                }
                if(res[rec].hasOwnProperty('ElixirSuite__Oxygen_Saturation__c')){
                    if(res[rec].ElixirSuite__Oxygen_Saturation__c.includes('%')){
                        res[rec].ElixirSuite__Oxygen_Saturation__c=  res[rec].ElixirSuite__Oxygen_Saturation__c.replace('%','');
                    }
                }
                if(res[rec].hasOwnProperty('ElixirSuite__Blood_Pressure_Diasystolic__c')){
                    if(res[rec].ElixirSuite__Blood_Pressure_Diasystolic__c.includes('mmHg')){
                        res[rec].ElixirSuite__Blood_Pressure_Diasystolic__c=  res[rec].ElixirSuite__Blood_Pressure_Diasystolic__c.replace('mmHg','');
                    }
                } 	
                if(res[rec].hasOwnProperty('ElixirSuite__Blood_Pressure_Systolic__c')){
                    if(res[rec].ElixirSuite__Blood_Pressure_Systolic__c.includes('mmHg')){
                        res[rec].ElixirSuite__Blood_Pressure_Systolic__c = res[rec].ElixirSuite__Blood_Pressure_Systolic__c.replace('mmHg','');
                    }
                }
                if(res[rec].hasOwnProperty('ElixirSuite__Temperature__c')){
                    if(res[rec].ElixirSuite__Temperature__c.includes('F*')){
                        res[rec].ElixirSuite__Temperature__c = res[rec].ElixirSuite__Temperature__c.replace('F*','');
                    }
                }
                if(res[rec].hasOwnProperty('ElixirSuite__Pulse__c')){
                    if(res[rec].ElixirSuite__Pulse__c.includes('BPM')){
                        res[rec].ElixirSuite__Pulse__c =  res[rec].ElixirSuite__Pulse__c.replace('BPM','');
                    }
                }
            }
            component.set("v.observationList",response.getReturnValue());
            console.log("observationList---"+JSON.stringify(component.get("v.observationList")));
            component.set("v.loaded",true);
        });
        $A.enqueueAction(action);
    },
    
    closeVitalSigns : function(component, event, helper) {
        component.set("v.openVitalSign", false);
        // component.find("thisInput1").set("v.value", '  ');
        
    },
    
    removeRow : function(component, event, helper){
        var abc = event.target.id ;
        console.log('the vital id is' , abc);
        var action = component.get("c.deleteVital");
        action.setParams({
            "vitalId" : event.target.id, 
            "AccID"  : component.get("v.AccountId")
        });
        action.setCallback(this, function(response) {
            component.set("v.observationList",response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    editRow : function(component, event, helper){
        component.set("v.editVitalSign", true);
        var VitalRowId = event.target.id ;
        console.log(VitalRowId);
        component.set("v.abc", VitalRowId);
        
        //  component.set("v.addVital", true);
        /*  component.find("thisInput1").set("v.value", " ");
        component.find("thisInput2").set("v.value", " ");
        component.find("thisInput3").set("v.value", " ");
        component.find("thisInput4").set("v.value", " ");
        component.find("thisInput5").set("v.value", " ");
        component.find("thisInput6").set("v.value", " ");*/
    },
    
    historyVitalSign : function(component,event,helper){
        component.set("v.openVitalSign" , false);
        var p  = component.get("v.AccountId");
        var dummy = '/lightning/r/'+p+'/related/HealthCloudGA__Observations__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+p+'%2Fview';
        console.log('demo url '+dummy);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": dummy
        });
        urlEvent.fire();
        
    },
    
    addVitalSign :  function(component, event, helper) {
        component.set("v.addVital", true);
        component.find("thisInput1").set("v.value", " ");
        component.find("thisInput2").set("v.value", " ");
        component.find("thisInput3").set("v.value", " ");
        component.find("thisInput4").set("v.value", " ");
        component.find("thisInput5").set("v.value", " ");
        component.find("thisInput6").set("v.value", " ");
        component.set("v.disableAddVital", true); 
        component.set("v.disableSubmit", false);  
    },
    saveVitalSign :  function(component, event, helper) {
        console.log('new ---'+JSON.stringify(component.get("v.newVitalSign")));
        var routeOfComponent = component.get("v.SaveRoute");
        if (routeOfComponent=='form') {
            if (helper.validateRequiredForForms(component, event)) { 
                /*component.set("v.addVital", false);
            var cmpEvent = component.getEvent("VitalSignsData");
            // Get the value from Component and set in Event
            console.log('new vs inside route'+JSON.stringify(component.get("v.newVitalSign")));
            cmpEvent.setParams( { "vitalSignDataToSave" : component.get("v.newVitalSign") } );
            cmpEvent.fire();*/
                var vitalSignString = JSON.parse(JSON.stringify(component.get("v.newVitalSign")));
                component.set("v.newVitalSignCopyToSaveOfForm",JSON.parse(JSON.stringify(component.get("v.newVitalSign"))));
                var wrapperExternalObjet =   component.get("v.ExternalcmpData");
                var allergy = wrapperExternalObjet.vitalSignsDataFormSpecific;
                var allergyAccountSpecific = wrapperExternalObjet.vitalSignsData;
                allergy.push(vitalSignString);
                allergyAccountSpecific.push(vitalSignString);
                wrapperExternalObjet.vitalSignsDataFormSpecific = allergy;
                wrapperExternalObjet.vitalSignsData = allergyAccountSpecific;
                component.set("v.ExternalcmpData",wrapperExternalObjet);
                console.log('Above Event');
                var cmpEvent = component.getEvent("hideAllergysection");
                console.log('cmpEvent'+JSON.stringify(cmpEvent));
                cmpEvent.setParams({
                    "path" : "vital" });
                cmpEvent.fire();
                var newVital ={ 
                    'sobjectType': 'ElixirSuite__Medical_Examination__c',                                                                         
                    'BloodPressureSystolic': '' ,
                    'BloodPressureDiasystolic': '',
                    'Temperature': '',
                    'Pulse': '',    
                    'Respiration' : '',
                    'OxygenSaturation' : ''
                }
                component.set("v.newVitalSign",newVital);
                console.log('new1 ---'+JSON.stringify(newVital));

            }
            
            
            
        }
        else {
            if (helper.validateRequired(component, event)) { 
                component.set("v.addVital", false);
                console.log('inside else');
                component.set("v.loaded",false);
                var action = component.get("c.saveVitalSignRecord");
                action.setParams({
                    "ObservationRec" : component.get("v.newVitalSign"),
                    "AccID" : component.get("v.AccountId")
                });
                action.setCallback(this, function (response){
                    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        //    alert('resp'+JSON.stringify(response.getReturnValue()));
                        helper.unitsArrange(component, event, helper,response.getReturnValue());
                        component.set("v.observationList",response.getReturnValue());
                        //  alert('vital sign has been suxccessfully')
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type" : "success!",
                            "title": "VITAL SIGNS HAVE BEEN SAVED!",
                            "message": "Registered Succesfully!"
                        });
                        toastEvent.fire();
                        component.set("v.disableAddVital", false); 
                        component.set("v.disableSubmit", true);  
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
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "title": "VITAL SIGN(S) INSERTION FAILED!",
                            "message": "Failed!"
                        });
                        toastEvent.fire();
                    }
                    
                    
                });
                
                $A.enqueueAction(action);
            }
        }  
    },
    saveVitalsAftereventFrom :  function(component, event, helper) { 
        console.log('saveVitalsAftereventFrom');
        try{
            var formID; var patientID;
            var params = event.getParam('arguments');
            if (params) {
                formID = params.formID;
                console.log('form id'+formID);
                patientID = params.patientID;
                console.log('patientID'+patientID);
            }
            var savedVitalSign = component.get("v.newVitalSignCopyToSaveOfForm");
            console.log('savedVitalSign: ' + JSON.stringify(savedVitalSign));
            
            var finalVitalSignData = {
                'ElixirSuite__Medical_Examination__c': savedVitalSign.sobjectType,
                'ElixirSuite__Blood_Pressure_Systolic__c': savedVitalSign.BloodPressureSystolic,
                'ElixirSuite__Blood_Pressure_Diasystolic__c': savedVitalSign.BloodPressureDiasystolic,
                'ElixirSuite__Temperature__c': savedVitalSign.Temperature,
                'ElixirSuite__Pulse__c': savedVitalSign.Pulse,
                'ElixirSuite__Respiration__c': savedVitalSign.Respiration,
                'ElixirSuite__Oxygen_Saturation__c': savedVitalSign.OxygenSaturation
            };
            var action = component.get("c.saveVitalSignRecord_AddedFromForm");
            action.setParams({
                formUniqueID : formID,
                AccID: patientID,
                ObservationRec : finalVitalSignData
                
            });
            
            // component.find("Id_spinner").set("v.class" , 'slds-show');
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Vital signs have been saved successfully.",
                        "type" : "success"
                    });
                    toastEvent.fire();
                }
                
            });
            
            $A.enqueueAction(action);
        
        
          
        }
        catch(e){
            console.log('EROOR in saveVitalsAftereventFrom vital cmp'+e);
        }
    },
})