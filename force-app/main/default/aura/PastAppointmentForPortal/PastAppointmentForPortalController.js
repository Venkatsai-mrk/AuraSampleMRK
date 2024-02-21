({
  
        
        doInit: function (component) {
        var action = component.get('c.getAllVisitNotes');
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === 'SUCCESS') {

                var result = response.getReturnValue();
                console.log('result in init: '+JSON.stringify(result));
                var eventsData = result.eventList;
                var careEpisodeIdAndFormApprovalBoolean = result.careEpisodeIdAndFormApprovalBoolean;
                console.log('careEpisodeIdAndFormApprovalBoolean map: ', careEpisodeIdAndFormApprovalBoolean);

                console.log('careEpisodeIdAndFormApprovalBoolean: '+JSON.stringify(careEpisodeIdAndFormApprovalBoolean));
                eventsData.forEach(function(appointment) {
                    appointment.hasDocument = false;
                    appointment.hasNotes = false; 
                });
                
                var documentsData = result.getDocuments;
                var hasDocumentMap = {};
                if(documentsData){
                    documentsData.forEach(function(documentData) {
                        hasDocumentMap[documentData.LinkedEntityId] = true; // Set hasDocument to true if document is available
                    });
                    // Update hasDocument attribute for each appointment based on document availability
                    eventsData.forEach(function(appointment) {
                        appointment.hasDocument = hasDocumentMap[appointment.Id] || false;
                    });
                }
                
                var visitNoteData = result.formList;
                var hasNoteMap = {};
                if(visitNoteData){
                    visitNoteData.forEach(function(visitData) {
                        hasNoteMap[visitData.ElixirSuite__Care_Episode__c] = true;
                    });
                 /*   eventsData.forEach(function(appointment) {	
                        appointment.hasNotes = hasNoteMap[appointment.ElixirSuite__Care_Episode__c] || false;	
                    });*/
                    eventsData.forEach(function(appointment) {
                        
                        console.log('Current appointment ID: ', appointment.ElixirSuite__Care_Episode__c);
                        console.log('corresponding careEpisodeIdAndFormApprovalBoolean value: ', careEpisodeIdAndFormApprovalBoolean[appointment.ElixirSuite__Care_Episode__c]);
                        appointment.hasNotes = (hasNoteMap[appointment.ElixirSuite__Care_Episode__c] && careEpisodeIdAndFormApprovalBoolean[appointment.ElixirSuite__Care_Episode__c] )|| false;
                    });
                }     

                component.set("v.pastAppointmentsList", eventsData);
            }
        });
        $A.enqueueAction(action);
        
    },
    navToMoreAppointments : function(component) {
        var navService = component.find("navigationService");
        let pageReference = {
            type: "standard__webPage", 
            attributes: {
                url: "/myappointments"
            }
        }
        navService.navigate(pageReference);
    },
    
    generateVisitSummary: function(component, event) {
        var appointmentId = event.getSource().get("v.name");
        console.log("Appointment ID: ", appointmentId);
        var action = component.get('c.getVisitSummaryPdf');
        action.setParams({
            recordId: appointmentId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('State visit summary: '+state)
            
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                var DocId = result.documentId;
              
                console.log('DocId: '+DocId)
                console.log('Visit result : '+JSON.stringify(result));
                var navService = component.find("navigationService");
                let pageReference = {
                    type: "standard__webPage", 
                    attributes: {
                        url: result.oragnizationBaseURl + '/sfc/servlet.shepherd/document/download/' + result.documentId + '?operationContext=S1'
                    }
                }
                navService.navigate(pageReference);
                /*var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": result+ '?operationContext=S1'
                        });
                        urlEvent.fire();  */    
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
    },
    generateVisitNote: function(component, event) {
        var appointmentId = event.getSource().get("v.name");
        console.log("Appointment ID: ", appointmentId);
        
        var action = component.get('c.getVisitNotes');
        action.setParams({
            recordId: appointmentId
        });
        action.setCallback(this, function(response){
        var state = response.getState();
        console.log(state + ' state for visit notes');
        if (state === 'SUCCESS') {
            var result = response.getReturnValue();
            console.log('result ' + JSON.stringify(result));

            if (result) {
                var fId = result[0].ElixirSuite__Form_Id__c; 
                
                var fName = result[0].ElixirSuite__Form_Name__c;
                var aId = result[0].ElixirSuite__Account__c;
                console.log('accountId: '+aId)
                console.log('formnamme: '+fName)
                console.log('formId: '+fId)
                component.set("v.PresId", fId);
                component.set("v.recordVal", aId);
                component.set("v.selectedFormName", fName);
                
                window.open("/apex/ElixirSuite__Elixir_FormsPdfGenerator?fName="+fName+"&fId="+fId+"&aId="+aId+"&fCName="+fName,'_blank');
		
            }
        }
    });
        
    
    $A.enqueueAction(action);
    }
})