({
    doInit : function(component, event, helper) {
        console.log('url',component.get("v.url"));
        
        console.log('urlhref',window.location.href);
       
        console.log('urlhref',window.location.pathname);
        console.log('urlhref',window.location);
        console.log('page',document.URL);
        console.log('page',document);
        var action = component.get("c.getEventDataObject");
        
        action.setParams({
            "eventId": component.get("v.recordId")
            
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                var res = response.getReturnValue();
                //added by mahesh
                component.set("v.eventDataRecordId",res.ElixirSuite__Event_Data_Object__c);
                component.set("v.SelectedStartTime", res.StartDateTime);
                component.set("v.SelectedEndTime", res.EndDateTime);
                helper.getMuliSelectedData(component,event,component.get("v.eventDataRecordId"));
            }
        });
        $A.enqueueAction(action);
    },
    UpdateEventDataRecord : function(component, event, helper) {
        let grpArr = component.get("v.selectedGroupRecords");
        let idArr = [];
        for(let obj in  grpArr){
            idArr.push(grpArr[obj].Id);
        }
        var action = component.get("c.getAllPatientDetailsFromGroupIDs");
        action.setParams({
            groupIDs:idArr
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var respForPatientDataFromGroup = response.getReturnValue();
                var patientArray =[];
                var patientIds =[];
                var patientGroupArray =[];
                var patientGroupIds =[];
                var accountArray =[];
                var accountIds =[];
                var coFacilitatorArray =[];
                var coFacilitatorIds =[];
                var coFacilitatorIds =[];
                var equipArray =[];
                var equipIds =[];
                var accAdditional =[];
                
                
                equipArray = component.get("v.equipList");
                equipArray.forEach(eq => equipIds.push({'Id' :eq.Id, 'EquipmentNeed': eq.Needed}));
                
                
                
                patientArray = component.get("v.selectedAccountRecords");
                patientArray.forEach(patient => patientIds.push(patient.Id));
                let profilePicId = '';
                
                patientArray.forEach(function(patient){
                    if(patient.hasOwnProperty('ElixirSuite__Profile_Picture__c')){
                        profilePicId = patient.ElixirSuite__Profile_Picture__c;
                    }        
                    
                    accAdditional.push({
                        'patientId' :patient.Id, 'patientName': patient.Name,'attended':true,'profilePicIId': profilePicId
                    });
                });
                respForPatientDataFromGroup.forEach(function(patient){
                    if(patient.hasOwnProperty('ElixirSuite__Current_Patient_Name__r')){
                        accAdditional.push({
                            'patientId' :patient.ElixirSuite__Current_Patient_Name__r.Id, 'patientName': patient.ElixirSuite__Current_Patient_Name__r.Name,'attended':true,'profilePicIId': patient.ElixirSuite__Current_Patient_Name__r.ElixirSuite__Profile_Picture__c
                        });
                        
                    }        
                    
                    
                });
                
                const uniqueIds = [];
                
                const unique = accAdditional.filter(element => {
                    const isDuplicate = uniqueIds.includes(element.patientId);
                    
                    if (!isDuplicate) {
                    uniqueIds.push(element.patientId);
                    
                    return true;
                }
                                          
                                          return false;
                                          });
                
                
                console.log('unique '+unique);
                
                patientGroupArray = component.get("v.selectedGroupRecords");
                patientGroupArray.forEach(patientGroup => patientGroupIds.push(patientGroup.Id));
                
                accountArray = component.get("v.selectedBussinessAccountsRecords");
                accountArray.forEach(acc => accountIds.push(acc.Id));
                
                coFacilitatorArray = component.get("v.selectedCoFacilitatorsRecords");
                coFacilitatorArray.forEach(cofacilitator => coFacilitatorIds.push(cofacilitator.Id));
                
                var locationId = component.get("v.selectedRecordOfLocation").Id;
                console.log('locationId', locationId);
                var roomId = component.get("v.selectedRecordOfRoom").Id;
                //component.get("v.selectedRecordOfRoom").Id;
                console.log('parent', locationId);
                console.log('parent', roomId);
                
                var action = component.get("c.modifyEventDataObject");
                console.log('parent');
                console.log('eventDataRecordId',component.get("v.eventDataRecordId"));
                action.setParams({
                    "eventDataId": component.get("v.eventDataRecordId"),
                    "patients": JSON.stringify(patientIds),
                    "patientGroups": JSON.stringify(patientGroupIds),
                    "bussinessAccounts": JSON.stringify(accountIds),
                    "coFacilitators": JSON.stringify(coFacilitatorIds),
                    "locId": locationId,
                    "roomId": roomId,
                    "equipments" : JSON.stringify(equipIds),
                    "accountAdditionalInfo": JSON.stringify({'key' : unique})
                });
                
                console.log('parent');
                action.setCallback(this, function(response){
                    var state = response.getState();
                    console.log('state' +state);
                    if(state ==='SUCCESS'){
                        var res = response.getReturnValue();
                        console.log('res',res);
                        alert('Record is updated Successfully');
                        // helper.showToast(component,event,'Data Updated Successfully.')
                    }else if(state ==='ERROR'){
                        
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " +
                                            errors[0].message);
                                
                                
                                
                            }        
                        }
                    }
                });
                $A.enqueueAction(action);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    bypassSelect : function(component,event,helper){
        
        component.set("v.ByPassEvent",event.getSource().get('v.checked'));
        
    }
})