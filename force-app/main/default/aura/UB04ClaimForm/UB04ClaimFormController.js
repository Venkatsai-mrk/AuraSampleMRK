({
    doInit : function(component, event, helper) {
        helper.setRevenueData(component);
        var vobId = '';
        if(!$A.util.isEmpty(component.get('v.selectedVOBList'))){
            vobId = component.get('v.selectedVOBList')[0].Id;
            console.log('vobId' +vobId);
        }
        console.log('bew', component.get("v.patId"));
        var action = component.get("c.getAccountDetails");
        action.setParams({
            "patientId": component.get("v.patId"),
            "vobId" : vobId
        });
        action.setCallback(this, function (response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                var jsonList = [];
                var insideJson = {};
                var completeJson = [];
                var payerNamePrimary, payerNameSecondary,payerNameTertiary = '';
                var insuredNamePrimary,insuredNameSecondary,insuredNameTertiary = '';
                var insuredGroupNamePrimary,insuredGroupNameSecondary,insuredGroupNameTertiary = '';
                var insuredGroupNumberPrimary,insuredGroupNumberSecondary,insuredGroupNumberTertiary = '';
                var relVobData = res.relatedVobData;
                console.log('relVobData' + JSON.stringify(relVobData));
                
                relVobData.forEach(function (element) {
                    if (element.RecordType && element.RecordType.DeveloperName == 'VOB_record_type' && element.ElixirSuite__Payer__r) {
                        payerNamePrimary = element.ElixirSuite__Payer__r.Name;
                        insuredNamePrimary = element.ElixirSuite__Insured_First_Name__c + ' '+element.ElixirSuite__Insured_Last_Name__c;
                        insuredGroupNamePrimary = element.ElixirSuite__Group_Name__c;
                        insuredGroupNumberPrimary = element.ElixirSuite__Group_Number__c;
                    }
                    
                    if (element.RecordType && element.RecordType.DeveloperName == 'Secondary_VOB' && element.ElixirSuite__Payer__r) {
                        payerNameSecondary = element.ElixirSuite__Payer__r.Name;
                        insuredNameSecondary = element.ElixirSuite__Insured_First_Name__c + ' '+element.ElixirSuite__Insured_Last_Name__c;
                        insuredGroupNameSecondary = element.ElixirSuite__Group_Name__c;
                        insuredGroupNumberSecondary = element.ElixirSuite__Group_Number__c;
                    }
                    
                    if (element.RecordType && element.RecordType.DeveloperName == 'Tertiary_VOB' && element.ElixirSuite__Payer__r) {
                        payerNameTertiary = element.ElixirSuite__Payer__r.Name;
                        insuredNameTertiary = element.ElixirSuite__Insured_First_Name__c + ' '+element.ElixirSuite__Insured_Last_Name__c;
                        insuredGroupNameTertiary = element.ElixirSuite__Group_Name__c;
                        insuredGroupNumberTertiary = element.ElixirSuite__Group_Number__c;
                    }
                });
                component.set("v.selectedBirthSex",res.accDetails.ElixirSuite__Gender__c);
                insideJson = {"id" : res.accDetails.Id,
                              "patientFirstName" : res.accDetails.ElixirSuite__First_Name__c ,
                              "patientLastName" : res.accDetails.ElixirSuite__Last_Name__c ,
                              "patientDOB" : res.accDetails.ElixirSuite__DOB__c , 
                              "patiSex" : res.accDetails.ElixirSuite__Gender__c ,
                              "patientAddress" : res.accDetails.BillingStreet ,
                              "patientCity" : res.accDetails.BillingCity , 
                              "patientState" : res.accDetails.BillingState,
                              "patientZipcode" : res.accDetails.BillingPostalCode ,
                              "patientCountryCode" : res.accDetails.BillingCountry ,
                              "patientMRN" : res.accDetails.ElixirSuite__MRN_Number_New__c ,
                              "patientPhone" : res.accDetails.Phone ,
                              "primaryPayerName" : payerNamePrimary,
                              "secondaryPayerName" : payerNameSecondary,
                              "tertiaryPayerName" : payerNameTertiary,
                              "primaryInsuredName" : insuredNamePrimary,
                              "secondaryInsuredName":insuredNameSecondary,
                              "tertiaryInsuredName":insuredNameTertiary,
                              "primaryGroupName" : insuredGroupNamePrimary,
                              "secondaryGroupName":insuredGroupNameSecondary,
                              "tertiaryGroupName":insuredGroupNameTertiary,
                              "primaryGroupNumber" : insuredGroupNumberPrimary,
                              "secondaryGroupNumber":insuredGroupNumberSecondary,
                              "tertiaryGroupNumber":insuredGroupNumberTertiary,
                             }
                completeJson.push(insideJson);
                
                component.set("v.popupData",insideJson);
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
    
    cancelButton : function(component){
        component.set("v.isActive",false);
        var compEvent = component.getEvent("cancelEvent");
        compEvent.fire();
        
    },
    
    addRevenueDataRow: function(component) {
        let revenueData = component.get("v.revenueData");
        revenueData.push({'revenueCode' : '',
                          'revenueCodeDescription' : '',
                          'HCPCSRates' : '',
                          'serviceDate' : '',
                          'serviceUnits' : '',
                          'totalCharge' : '',
                          'nonCoveredCharges' : '',
                          'futureUse' : ''
                         });
        component.set("v.revenueData", revenueData);
    },
    callRemoveThisRow : function(component, event) {
        let revenueData = component.get("v.revenueData");
        
        if (revenueData && revenueData.length <= 1) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "message": "Can not delete last row",
                "type" : "error"
            });
            toastEvent.fire();
            return;
        }
        
        let elementIndexToRemove = event.currentTarget.dataset.value;
        revenueData.splice(elementIndexToRemove, 1);
        component.set("v.revenueData", revenueData);
    },
    save :function(component, event) {
        var globalReqCheckValid = component.find('globalReqCheck').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
    }
})