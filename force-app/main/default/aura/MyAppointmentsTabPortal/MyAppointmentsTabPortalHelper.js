({
    filterList : function(component) {
        var filterOptions = [
            { value: 'Upcoming Appointments', label: 'Upcoming Appointments' },
            { value: 'Past Appointments', label: 'Past Appointments' }
            
        ];
        component.set("v.filterOptions",filterOptions);
    },
    handleOpenRecordView: function(component) {
        var action = component.get('c.getEvent');
        action.setParams({
            "selectedAppointmentId" : component.get("v.selectedAppointmentId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('result for handleOpenRecordView' + JSON.stringify(result));
            }
        });
        $A.enqueueAction(action);       
    },

    fetchAppointmentColumns: function(component, event, helper) {
        component.set("v.loaded", false);
        var action = component.get("c.getAppointmentColumns");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                console.log('res for getappointmentColumns '+JSON.stringify(res));
                var resCol  = res.appointmentColumns;
                var reqFieldsMap  = res.mapRequiredFields;
                component.set("v.appointmentdataTypeToApi", JSON.stringify(res.mapDataTypeToApi));
                if (!$A.util.isUndefinedOrNull(resCol)) {
                    let csColArr = resCol.split(';');
                    
                    // Set the split array to the component attribute
                    component.set("v.parentAppointmentColumns", csColArr);
                }
                // Convert reqFieldsMap to a list of objects with label and value properties
                var reqFieldsList = [];
                for (var key in reqFieldsMap) {
                    if (reqFieldsMap.hasOwnProperty(key)) {
                        reqFieldsList.push({ label: key, value: reqFieldsMap[key] });
                    }
                }
                component.set("v.appointmentColumnsLst", reqFieldsList);
                
                component.set("v.loaded", true);
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
                
                if (errors && errors[0] && errors[0].message) {
                    console.error("Error:", errors[0].message);
                } else {
                    console.error("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },

    columns : function(component,event) {
        
        var columnsFromCustomSetting = component.get('v.parentAppointmentColumns');
        var currentUserTimezone = component.get("v.currentUserTimezone");
        var enablePayNow = component.get("v.enablePayNow");
        let currentFilter = component.get("v.currentFilter");
        if(currentFilter == 'Upcoming Appointments'){    
            
            var action = component.get("c.getAllUpcomingAppointments");
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.loaded",true);
                    var appointmentData = response.getReturnValue();
                    console.log('appointmentData 1: '+JSON.stringify(appointmentData))
                    component.set("v.data", appointmentData);
                    
                    var csColumns;
                    if(csColumns!=null){
                        component.set('v.parentAppointmentColumns', csColumns);
                    }
                    if(csColumns==null){
                        csColumns = component.get('v.parentAppointmentColumns');
                    }
                    console.log('csColumns.length: '+csColumns.length)
                    var columns = [
                        { label: 'Subject', fieldName: 'Id',
                         type: 'button', 
                         typeAttributes: { label: { fieldName: 'Subject' } ,
                                          name: 'Subject',
                                          title: 'Subject',
                                          target: '_blank',
                                          value: 'Subject',
                                          iconPosition: 'center',
                                          variant: 'base'
                                         } }];
                    console.log('0')
                    var labelToApiList = component.get('v.appointmentColumnsLst');
                    console.log('labelToApiList in appointment: '+JSON.stringify(labelToApiList))
                    
                    var apiToDataType = JSON.parse(component.get("v.appointmentdataTypeToApi"));
                    
                    console.log('apiToDataType in appointmentColumns: '+JSON.stringify(apiToDataType))
                    
                    if (csColumns && csColumns.length > 0 ) {
                        for (let i = 0; i < csColumns.length; i++) {
                            let fieldName = csColumns[i];
                            // Find the corresponding entry in reqFieldsList
                            let reqField = labelToApiList.find(field => field.value == fieldName);
                            console.log('reqField appointmentColumnsLst:', reqField);
                            
                            if (reqField) {
                                let label = reqField.label;
                                console.log('label in appointmentColumnsLst columns: '+label);
                                let fieldType = apiToDataType[fieldName];
                                console.log('fieldType in appointmentColumnsLst columns: '+fieldType);
                                if (label === 'Created By ID') {
                                    label = 'Created By';
                                } else if (label === 'Last Modified By ID') {
                                    label = 'Last Modified By';
                                }
                                else if (label === 'Name ID') {
                                    label = 'Name';
                                }
                                if (fieldType === 'DATE'){
                                    columns.push({
                                        label: label,
                                        fieldName: fieldName,
                                        type: 'date',
                                        typeAttributes: {
                                            day: 'numeric',  
                                            month: 'short',  
                                            year: 'numeric'
                                        },
                                    });  
                                }
                                else if(fieldType === 'DATETIME'){
                                    console.log('updated the foemat inside datetime')
                                    columns.push({
                                        label: label,
                                        fieldName: fieldName,
                                        type: 'date', 
                                        typeAttributes: {
                                            day: 'numeric',  
                                            month: 'short',  
                                            year: 'numeric',  
                                            hour: '2-digit',  
                                            minute: '2-digit',  
                                            hour12: true,
                                            timeZone:currentUserTimezone},
                                    });}
                                    else{
                                        columns.push({
                                            label: label,
                                            fieldName: fieldName,
                                            type: fieldType
                                        });
                                    }
                            } else {
                                console.error(`Field "${fieldName}" not found in labelToApiList.`);
                            }
                        }
                    }
                    
                    
                    if (enablePayNow) {
                        columns.push({
                            type: 'button',
                            initialWidth: 150,
                            typeAttributes: {
                                label: 'Pay Now',
                                name: 'Pay Now',
                                title: 'Pay Now',
                                target: '_blank',
                                value: 'PayNow',
                                iconPosition: 'center',
                                class: 'slds-m-left_large'
                            }
                        });
                    }
                    
                    columns.push({
                        type: 'button', typeAttributes: {
                            label: 'Cancel',
                            name: 'Cancel',
                            title: 'Cancel',
                            target: '_blank',
                            value: 'Cancel',
                            iconPosition: 'center',
                            class: 'slds-m-left_large'
                        }
                    });
                    
                    component.set("v.columns",columns);
                    console.log('columns value after setting: '+JSON.stringify((component.get('v.columns'))))
                    
                    appointmentData.forEach(function(element) {
                        
                        if (element && element.hasOwnProperty('ElixirSuite__Practitioner__r')) {
                            
                            element['ElixirSuite__Practitioner__c'] = element.ElixirSuite__Practitioner__r.Name;
                            
                        }
                        if (element && element.hasOwnProperty('ElixirSuite__Care_Episode__r')) {
                            
                            element['ElixirSuite__Care_Episode__c'] = element.ElixirSuite__Care_Episode__r.Name;
                            
                        }
                        if (element && element.hasOwnProperty('ElixirSuite__Location__r')) {
                            
                            element['ElixirSuite__Location__c'] = element.ElixirSuite__Location__r.Name;
                            
                        }
                        if (element && element.hasOwnProperty('ElixirSuite__Room__r')) {
                            
                            element['ElixirSuite__Room__c'] = element.ElixirSuite__Room__r.Name;
                            
                        }
                        if (element && element.hasOwnProperty('CreatedBy')) {
                            element['CreatedById'] = element.CreatedBy.Name;
                        }
                    
                        if (element && element.hasOwnProperty('LastModifiedBy') && element.LastModifiedBy.hasOwnProperty('Name')) {
                            element['LastModifiedById'] = element.LastModifiedBy.Name;
                        }
                        if (element && element.hasOwnProperty('WhoId')) {
                            element['WhoId'] = element.Who.Name;
                        }
                        
                    });
                    
                    component.set("v.data", appointmentData);
                    console.log('data value after setting: '+JSON.stringify((component.get('v.data'))))
                    
                }else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.error("Error:", errors[0].message);
                    } else {
                        console.error("Unknown error");
                    }
                }
            });
            
            $A.enqueueAction(action);
            
        }
        else{
            
            
            let csColumns;
            if(csColumns!=null){
                component.set('v.parentAppointmentColumns', csColumns);
            }
            if(csColumns==null){
                csColumns = component.get('v.parentAppointmentColumns');
            }
            console.log('past csColumns 1: '+JSON.stringify(csColumns))
            console.log('csColumns.length: '+csColumns.length)
            
            let columns = [
                { label: 'Subject', fieldName: 'Id',
                 type: 'button', 
                 typeAttributes: { label: { fieldName: 'Subject' } ,
                                  name: 'Subject',
                                  title: 'Subject',
                                  target: '_blank',
                                  value: 'Subject',
                                  iconPosition: 'center',
                                  variant: 'base'
                                 } }];
            console.log('0')
            let labelToApiList = component.get('v.appointmentColumnsLst');
            console.log('labelToApiList in appointment: '+JSON.stringify(labelToApiList))
            
            let apiToDataType = JSON.parse(component.get("v.appointmentdataTypeToApi"));
            
            console.log('apiToDataType in appointmentColumns: '+JSON.stringify(apiToDataType))
            
            if (csColumns && csColumns.length > 0 ) {
                for (let i = 0; i < csColumns.length; i++) {
                    let fieldName = csColumns[i];
                    // Find the corresponding entry in reqFieldsList
                    let reqField = labelToApiList.find(field => field.value == fieldName);
                    console.log('reqField appointmentColumnsLst:', reqField);
                    
                    if (reqField) {
                        let label = reqField.label;
                        let fieldType = apiToDataType[fieldName];
                        console.log('fieldType in appointmentColumnsLst columns: '+fieldType);
                        if (label === 'Created By ID') {
                            label = 'Created By';
                        } else if (label === 'Last Modified By ID') {
                            label = 'Last Modified By';
                        }
                        else if (label === 'Name ID') {
                            label = 'Name';
                        }
                        if (fieldType === 'DATE'){
                            columns.push({
                                label: label,
                                fieldName: fieldName,
                                type: 'date',
                                typeAttributes: {
                                    day: 'numeric',  
                                    month: 'short',  
                                    year: 'numeric'
                                },
                            });  
                        }
                        else if(fieldType === 'DATETIME'){
                            console.log('updated the foemat inside datetime')
                            columns.push({
                                label: label,
                                fieldName: fieldName,
                                type: 'date', 
                                typeAttributes: {
                                    day: 'numeric',  
                                    month: 'short',  
                                    year: 'numeric',  
                                    hour: '2-digit',  
                                    minute: '2-digit',  
                                    hour12: true,
                                    timeZone:currentUserTimezone},
                            });}
                            else{
                                columns.push({
                                    label: label,
                                    fieldName: fieldName,
                                    type: fieldType
                                });
                            }
                    } else {
                        console.error(`Field "${fieldName}" not found in labelToApiList.`);
                    }
                }
            }
            
            
            
            columns.push({
                type: 'button',
                initialWidth: 150, 
                typeAttributes:  {
                    label: 'Visit Notes',
                    name: 'Visit Notes', 
                    title: 'Visit Notes', 
                    target: '_blank', 
                    value: 'Visit Notes',
                    iconPosition: 'center',
                    class: 'slds-m-left_large',
                    disabled: { fieldName: 'hasNotes' }
                }
            });
            
            
            columns.push({
                
                type: 'button',initialWidth: 150,
                typeAttributes:  {
                    label: 'Visit Summary',
                    name: 'Visit Summary', 
                    title: 'Visit Summary', 
                    target: '_blank', 
                    value: 'Visit Summary',
                    iconPosition: 'center',
                    class: 'slds-m-left_large',
                    disabled: { fieldName: 'hasDocument' }
                }
                
            });
            
            component.set("v.columns",columns);
            console.log('columns value after setting: '+JSON.stringify((component.get('v.columns'))))
            
            //  component.set("v.data", appointmentData);
            console.log('data value after setting: '+JSON.stringify((component.get('v.data'))))
        }
    },

    
fetchUpcomingAppointmentsData : function(component, helper){
    
    var action = component.get('c.getAllUpcomingAppointments');
    action.setCallback(this, function(response){
        var state = response.getState();
        console.log(state+' state for messages');
        if(state === 'SUCCESS'){
            helper.columns(component);
            var result = response.getReturnValue();
            console.log('result '+JSON.stringify(result));
            result.forEach(function(element) {
                if (element && element.hasOwnProperty('ElixirSuite__Practitioner__r')) {
                           
                    element['ElixirSuite__Practitioner__c'] = element.ElixirSuite__Practitioner__r.Name;
                     
                }
            });
            component.set("v.data",result);
            
        }
    });
    $A.enqueueAction(action);   
},
    
    fetchPastAppointmentsData : function(component, helper){
        
        var action = component.get('c.getAllVisitNotes');  
        
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state+' state for past appointmwnt');
            if(state === 'SUCCESS'){
                helper.columns(component);
                var result = response.getReturnValue();
                var eventsData = result.eventList;
                var careEpisodeIdAndFormApprovalBoolean = result.careEpisodeIdAndFormApprovalBoolean;
                console.log('result in past appointment'+JSON.stringify(eventsData));
                eventsData.forEach(function(element) {

                    if (element && element.hasOwnProperty('ElixirSuite__Practitioner__r')) {
                           
                        element['ElixirSuite__Practitioner__c'] = element.ElixirSuite__Practitioner__r.Name;
                         
                    }
                    if (element && element.hasOwnProperty('ElixirSuite__Care_Episode__r')) {
                            
                        element['ElixirSuite__Care_Episode__c'] = element.ElixirSuite__Care_Episode__r.Name;
                        
                    }
                    if (element && element.hasOwnProperty('ElixirSuite__Location__r')) {
                        
                        element['ElixirSuite__Location__c'] = element.ElixirSuite__Location__r.Name;
                        
                    }
                    if (element && element.hasOwnProperty('ElixirSuite__Room__r')) {
                        
                        element['ElixirSuite__Room__c'] = element.ElixirSuite__Room__r.Name;
                        
                    }
                    if (element && element.hasOwnProperty('CreatedBy')) {
                        element['CreatedById'] = element.CreatedBy.Name;
                    }
                
                    if (element && element.hasOwnProperty('LastModifiedBy') && element.LastModifiedBy.hasOwnProperty('Name')) {
                        element['LastModifiedById'] = element.LastModifiedBy.Name;
                    }
                    if (element && element.hasOwnProperty('WhoId')) {
                        element['WhoId'] = element.Who.Name;
                    }
                    
                });
                eventsData.forEach(function(appointment) {
                    appointment.hasDocument = true;
                    appointment.hasNotes = true; 
                });
             	var documentsData = result.getDocuments;
                console.log('documentsData in tab: '+JSON.stringify(documentsData));
                
                var hasDocumentMap = {};
                if(documentsData){
                    documentsData.forEach(function(documentData) {
                        hasDocumentMap[documentData.LinkedEntityId] = true; // Set hasDocument to true if document is available
                    });
                    // Update hasDocument attribute for each appointment based on document availability
                    eventsData.forEach(function(appointment) {
                   //     appointment.hasDocument = hasDocumentMap[appointment.Id] || false;
                        if(hasDocumentMap[appointment.Id]){
                            appointment.hasDocument = false;
                        }
                        else{
                             appointment.hasDocument = true;
                        }
                        console.log('appointment.hasDocument: '+appointment.hasDocument)
                    });
                }
                
                var visitNoteData = result.formList;
                var hasNoteMap = {};
                if(visitNoteData){
                    visitNoteData.forEach(function(visitData) {
                        hasNoteMap[visitData.ElixirSuite__Care_Episode__c] = true;
                    });
                    eventsData.forEach(function(appointment) {
                      //  appointment.hasNotes = hasNoteMap[appointment.ElixirSuite__Care_Episode__c] || false;
                       // if(hasNoteMap[appointment.ElixirSuite__Care_Episode__c]){
                         if((hasNoteMap[appointment.ElixirSuite__Care_Episode__c] && careEpisodeIdAndFormApprovalBoolean[appointment.ElixirSuite__Care_Episode__c] )){
                            appointment.hasNotes = false;
                        }
                        else{
                            appointment.hasNotes = true;
                        }
                        console.log('appointment.hasNotes: '+appointment.hasNotes)
                    });
                } 
                component.set("v.data",eventsData);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    console.error("Error:", errors[0].message);
                } else {
                    console.error("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    generateVisitSummary: function(component) {
            var appointmentId = component.get("v.selectedAppointmentId");
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
                        console.log('Visit result : '+JSON.stringify(result));
                        var navService = component.find("navigationService");
                        let pageReference = {
                            type: "standard__webPage", 
                            attributes: {
                                url: result.oragnizationBaseURl + '/sfc/servlet.shepherd/document/download/' + result.documentId + '?operationContext=S1'
                            }
                        }
                        navService.navigate(pageReference); 
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
    generateVisitNote: function(component) {
        var appointmentId = component.get("v.selectedAppointmentId");
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
                console.log('result for visit notes' + JSON.stringify(result));
                
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
    },
  
})