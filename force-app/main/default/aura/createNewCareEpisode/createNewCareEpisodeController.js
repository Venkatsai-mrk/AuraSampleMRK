({
    doInit : function(component, event, helper) {
         
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            var issubTab = response.isSubtab;
            if(issubTab)
            {
                workspaceAPI.getTabInfo(
                    { tabId:focusedTabId}
                ).then(function(response1){
                    
                });
                workspaceAPI.setTabLabel({                    
                    label: "New Care Episode"
                });                
            }
            else 
            { 
                workspaceAPI.getTabInfo({ tabId:response.subtabs[0].tabId}).then(function(response1){                 
                });
                workspaceAPI.setTabLabel({
                    label: "New Care Episode"
                });         
            }     
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:variable",
                iconAlt: "New Care Episode"
            });
        }) 
       
         var action1= component.get("c.customLocationStatus"); 
         action1.setCallback(this,function(response){
             if(response.getState()==="SUCCESS"){
                 component.set("v.customLocationStatus",response.getReturnValue());
             }   
         });
        
         $A.enqueueAction(action1);  
        
        
    },
    
    handleSubmit:function(component, event, helper) {       
        event.preventDefault(); 
        const fields = event.getParam('fields');     
        if(component.get("v.customLocationStatus")==true && (fields.ElixirSuite__Care_Episode_Location__c==null || fields.ElixirSuite__Care_Episode_Location__c=='')){ 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "",
                    "message": "Please fill CARE EPISODE LOCATION",
                    "type" : "error"
                });
                toastEvent.fire();   
        }else if(!(fields.ElixirSuite__Status__c=='Active')){
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "",
                    "message": "STATUS field should be active",
                    "type" : "error"
                });
             toastEvent.fire();   
        }else{
            var action = component.get("c.countCareEpisode");              
            action.setParams({ 
                patientId : component.get("v.patientID") 
            }); 
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var wrp=response.getReturnValue();
                    var countCP=wrp.totalCp+1;
                    fields.Name=wrp.patientName+"'"+'s'+' Visit - '+countCP;
                    fields.ElixirSuite__Account__c=wrp.patientId;   
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" :"success",
                        "title": "SUCCESS",
                        "message": "The record has been saved successfully."
                    });
                    toastEvent.fire();
                    component.find('myRecordForm').submit(fields);       
                    
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response){
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    .catch(function(error){
                        console.log(error);
                    });
                    if(component.get("v.heading")=='Lab Orders'){
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef:"c:ElixirHC_LabOrder",
                            componentAttributes: {
                                AcctIden: component.get("v.patientID"),
                                isOpen:true
                            }                             
                        });
                        evt.fire();
                    }
                    
                    if(component.get("v.heading")=='Urine Analysis'){
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef:"c:ElixirHC_CreateSampleUA",
                             componentAttributes: {
                                accountId: component.get("v.patientID"),
                                openModal:true
                           }
                        });
                        evt.fire();
                    }
                    
                    if(component.get("v.heading")=='Medication' || component.get("v.heading")=='Prescription'){
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef:"c:ElixirHC_MedicationComponent",
                        });
                        evt.fire();
                    }
                    
                    if(component.get("v.heading")=='Problem_Diagnosis_List'){
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef:"c:ElixirOEM_NewProblem",
                            componentAttributes: {
                                recordVal: component.get("v.patientID"),
                            }                             
                        });
                        evt.fire();
                    }
                    
                    if(component.get("v.heading")=='Utilization Review'){
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef:"c:ElixirHC_UtilizationReview",
                            componentAttributes: {
                                patientID: component.get("v.patientID"),
                                isOpen:true
                            }                             
                        });
                        evt.fire(); 
                    }
                    
                    if(component.get("v.heading")=='Refferal'){
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef:"c:ElixirOEM_ReferralContainer",
                            componentAttributes: {
                                accountId: component.get("v.patientID"),
                                isOpen:true
                            }                             
                        });
                        evt.fire();
                    }
                    
                    if(component.get("v.heading")=='Medical Coding (In Process Procedures)'){
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef:"c:ElixirOEM_NewProcedure",
                            componentAttributes: {
                                accountId : component.get("v.patientID"),
                                isView:true,
                            }
                        });
                        evt.fire();
                    }
                    if(component.get("v.heading")=='Payment Schedule'){
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef:"c:View_Payment_Schedule_for_EHR",
                            componentAttributes: {
                                patientID: component.get("v.patientID"),
                            } 
                        });
                        evt.fire(); 
                    }
                    if(component.get("v.heading")=='Transport'){
                        var p  = component.get("v.patientID");
                        var dummy = '/lightning/r/'+p+'/related/'+'ElixirSuite__Transports__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+p+'%2Fview';
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": dummy
                        });
                        urlEvent.fire();
                    }
                    if(component.get("v.heading")=='Cost of Care'){
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef:"c:Past_Estimates_for_EHR",
                        });
                        evt.fire(); 
                    }
                    if(component.get("v.heading")=='Claims'){
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef:"c:ClaimListView_for_Ehr",
                        });
                        evt.fire(); 
                    }
                    if(component.get("v.heading")=='Payment'){
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef:"c:PaymentHistory_for_ehr",
                        });
                        evt.fire(); 
                    }
                    if(component.get("v.heading")=='Patient Statement'){
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef:"c:ParentStatement",
                            componentAttributes: {
                                recordId : component.get("v.recordId"),
                                isOpen : true
                            }
                        });
                        evt.fire(); 
                    }
                    if(component.get("v.heading")=='Immunization'){
                        var p  = component.get("v.patientID");
                        var dummy = '/lightning/r/'+p+'/related/ElixirSuite__Vaccines__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+p+'%2Fview';
                        console.log('demo url '+dummy);
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": dummy
                        });
                        urlEvent.fire();
                    }
                    if(component.get("v.heading")=='Medical Examination'){
                        var p  = component.get("v.patientID");
                        var dummy = '/lightning/r/'+p+'/related/ElixirSuite__Medical_Examinations__r/view?ws=%2Flightning%2Fr%2FAccount%2F'+p+'%2Fview';
                        console.log('demo url '+dummy);
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": dummy
                        });
                        urlEvent.fire();
                    }
                    if(component.get("v.heading")=='MOR/MAR'){
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef:"c:MAR",
                            componentAttributes: {
                                recordVal : component.get("v.patientID"),
                                isActive:true,
                            }
                        });
                        evt.fire();
                    }
                }
            });             
            $A.enqueueAction(action);    
        
        }        
        
    },
    handleCancel:function(component,event,helper){
        var workspaceAPI = component.find("workspace");
        window.history.go(-1); 
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error){
            console.log(error);
        });
    },
    
})