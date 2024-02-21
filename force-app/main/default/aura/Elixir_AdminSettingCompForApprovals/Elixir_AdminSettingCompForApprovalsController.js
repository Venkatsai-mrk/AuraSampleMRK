({
    doInit : function(component, event, helper) {
        helper.getProfileName(component, event, helper);
    },
    openPatientTileconfigScreen : function(component , event , helper){
        component.set("v.openPatientTileConfigurationscreen",true); 
        component.set("v.openLabOrderApprovalSettings",false);
        component.set("v.openPrescripOrderApprovalSettings",false);
        component.set("v.openPatientInfoCardConfigurationscreen",false);
        component.set("v.openCarePlanApprovalSettings",false);
        component.set("v.openLocationConfigurationscreen",false);
         component.set("v.openApprovalTask",false);
        component.set("v.openCareEpisode",false);
        component.set("v.openBulkMessage",false);
        
        var cmpTarget = component.find('patientTile');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        var cmpTarget1 = component.find('LabOrder');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('prescriptionOrder');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('patientCard');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('CarePlan');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
        var cmpTarget5 = component.find('Location');
        $A.util.removeClass(cmpTarget5, 'parentCSS_1 act');
        var cmpTarget6 = component.find('CustomSettings');
        $A.util.removeClass(cmpTarget6, 'parentCSS_1 act');
        
    },
    openPatientInfoCardConfigScreen : function(component , event , helper){
        component.set("v.openPatientInfoCardConfigurationscreen",true);
        component.set("v.openPatientTileConfigurationscreen",false); 
        component.set("v.openLabOrderApprovalSettings",false);
        component.set("v.openPrescripOrderApprovalSettings",false);
        component.set("v.openCarePlanApprovalSettings",false);
        component.set("v.openLocationConfigurationscreen",false);
         component.set("v.openApprovalTask",false);
        component.set("v.openCareEpisode",false);
        component.set("v.openBulkMessage",false);
        
        var cmpTarget = component.find('patientCard');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        
        var cmpTarget1 = component.find('LabOrder');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('prescriptionOrder');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('patientTile');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('CarePlan');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
        var cmpTarget5 = component.find('Location');
        $A.util.removeClass(cmpTarget5, 'parentCSS_1 act');
        var cmpTarget6 = component.find('CustomSettings');
        $A.util.removeClass(cmpTarget6, 'parentCSS_1 act');
    },
    handleLabOrder : function(component, event, helper) {
        component.set("v.openLabOrderApprovalSettings",true);
        component.set("v.openPrescripOrderApprovalSettings",false);
        component.set("v.openPatientTileConfigurationscreen",false);
        component.set("v.openPatientInfoCardConfigurationscreen",false);
        component.set("v.openCarePlanApprovalSettings",false);
        component.set("v.openLocationConfigurationscreen",false);
        component.set("v.openApprovalTask",false);
        component.set("v.openCareEpisode",false);
        component.set("v.openBulkMessage",false);
        
        component.set("v.ApprovalFor",'Lab Order');
        var cmpTarget = component.find('LabOrder');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        var cmpTarget1 = component.find('prescriptionOrder');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('patientTile');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('patientCard');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('CarePlan');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
        var cmpTarget5 = component.find('Location');
        $A.util.removeClass(cmpTarget5, 'parentCSS_1 act');
         var cmpTarget6 = component.find('CustomSettings');
        $A.util.removeClass(cmpTarget6, 'parentCSS_1 act');
    },
    handlePrescripOrder : function(component, event, helper) {
        component.set("v.openPrescripOrderApprovalSettings",true);
        component.set("v.openLabOrderApprovalSettings",false);
        component.set("v.openPatientTileConfigurationscreen",false);
        component.set("v.openPatientInfoCardConfigurationscreen",false);
        component.set("v.openCarePlanApprovalSettings",false);
        component.set("v.openLocationConfigurationscreen",false);
        component.set("v.openApprovalTask",false);
        component.set("v.openCareEpisode",false);
        component.set("v.openBulkMessage",false);
        
        component.set("v.ApprovalFor",'Prescription Order');
        var cmpTarget = component.find('prescriptionOrder');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        var cmpTarget1 = component.find('LabOrder');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('patientTile');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('patientCard');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('CarePlan');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
        var cmpTarget5 = component.find('Location');
        $A.util.removeClass(cmpTarget5, 'parentCSS_1 act');
         var cmpTarget6 = component.find('CustomSettings');
        $A.util.removeClass(cmpTarget6, 'parentCSS_1 act');
    },
    handleCarePlan : function(component, event, helper) {
        component.set("v.openCarePlanApprovalSettings",true);
        component.set("v.openPrescripOrderApprovalSettings",false);
        component.set("v.openLabOrderApprovalSettings",false);
        component.set("v.openPatientTileConfigurationscreen",false);
        component.set("v.openPatientInfoCardConfigurationscreen",false);
        component.set("v.openLocationConfigurationscreen",false);
        component.set("v.openApprovalTask",false);
        component.set("v.openCareEpisode",false);
        component.set("v.openBulkMessage",false);
        component.set("v.ApprovalFor",'Care Plan');
        
        var cmpTarget = component.find('CarePlan');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        var cmpTarget1 = component.find('LabOrder');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('prescriptionOrder');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('patientTile');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('patientCard');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
        var cmpTarget5 = component.find('Location');
        $A.util.removeClass(cmpTarget5, 'parentCSS_1 act');
         var cmpTarget6 = component.find('CustomSettings');
        $A.util.removeClass(cmpTarget6, 'parentCSS_1 act');
    },
    openLocationConfiguration :  function(component , event , helper){
        component.set("v.openLocationConfigurationscreen",true);
        component.set("v.openPatientTileConfigurationscreen",false); 
        component.set("v.openPatientInfoCardConfigurationscreen",false);
        component.set("v.openLabOrderApprovalSettings",false);
        component.set("v.openPrescripOrderApprovalSettings",false);
        component.set("v.openCarePlanApprovalSettings",false);
        component.set("v.openApprovalTask",false);
        component.set("v.openCareEpisode",false);
        component.set("v.openBulkMessage",false);
        
        
        var cmpTarget = component.find('Location');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        var cmpTarget1 = component.find('LabOrder');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('prescriptionOrder');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('patientTile');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('patientCard');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
        var cmpTarget5 = component.find('CarePlan');
        $A.util.removeClass(cmpTarget5, 'parentCSS_1 act');
        var cmpTarget6 = component.find('CustomSettings');
        $A.util.removeClass(cmpTarget6, 'parentCSS_1 act');
        
    },
    openApprovalTasks :  function(component , event , helper){
        component.set("v.openApprovalTask",true);
        component.set("v.openLocationConfigurationscreen",false);
        component.set("v.openPatientTileConfigurationscreen",false); 
        component.set("v.openPatientInfoCardConfigurationscreen",false);
        component.set("v.openLabOrderApprovalSettings",false);
        component.set("v.openPrescripOrderApprovalSettings",false);
        component.set("v.openCarePlanApprovalSettings",false);
        component.set("v.openCareEpisode",false);
        component.set("v.openBulkMessage",false);
        
        component.set("v.approvalTask",true);
        component.set("v.careEpisodeOpen",false);
        component.set("v.bulkMessageOpen",false);
        
        
        var cmpTarget = component.find('CustomSettings');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        var cmpTarget1 = component.find('LabOrder');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('prescriptionOrder');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('patientTile');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('patientCard');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
        var cmpTarget5 = component.find('CarePlan');
        $A.util.removeClass(cmpTarget5, 'parentCSS_1 act');
         var cmpTarget6 = component.find('Location');
        $A.util.removeClass(cmpTarget6, 'parentCSS_1 act');
        
    },
    openCareEpisodeSettings :  function(component , event , helper){
        component.set("v.openCareEpisode",true);
        component.set("v.openLocationConfigurationscreen",false);
        component.set("v.openPatientTileConfigurationscreen",false); 
        component.set("v.openPatientInfoCardConfigurationscreen",false);
        component.set("v.openLabOrderApprovalSettings",false);
        component.set("v.openPrescripOrderApprovalSettings",false);
        component.set("v.openCarePlanApprovalSettings",false);
        component.set("v.openApprovalTask",false);
        component.set("v.openBulkMessage",false);
        
        component.set("v.approvalTask",false);
        component.set("v.careEpisodeOpen",true);
        component.set("v.bulkMessageOpen",false);
        
        
        var cmpTarget = component.find('CustomSettings');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        var cmpTarget1 = component.find('LabOrder');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('prescriptionOrder');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('patientTile');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('patientCard');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
        var cmpTarget5 = component.find('CarePlan');
        $A.util.removeClass(cmpTarget5, 'parentCSS_1 act');
        var cmpTarget6 = component.find('Location');
        $A.util.removeClass(cmpTarget6, 'parentCSS_1 act');
        
    },
    openBulkMessageSettings :  function(component , event , helper){
        component.set("v.openBulkMessage",true);
        component.set("v.openLocationConfigurationscreen",false);
        component.set("v.openPatientTileConfigurationscreen",false); 
        component.set("v.openPatientInfoCardConfigurationscreen",false);
        component.set("v.openLabOrderApprovalSettings",false);
        component.set("v.openPrescripOrderApprovalSettings",false);
        component.set("v.openCarePlanApprovalSettings",false);
        component.set("v.openApprovalTask",false);
        component.set("v.openCareEpisode",false);
        
        component.set("v.approvalTask",false);
        component.set("v.careEpisodeOpen",false);
        component.set("v.bulkMessageOpen",true);
        
        
        var cmpTarget = component.find('CustomSettings');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        var cmpTarget1 = component.find('LabOrder');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('prescriptionOrder');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('patientTile');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('patientCard');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
        var cmpTarget5 = component.find('CarePlan');
        $A.util.removeClass(cmpTarget5, 'parentCSS_1 act');
         var cmpTarget6 = component.find('Location');
        $A.util.removeClass(cmpTarget6, 'parentCSS_1 act');
        
    },
    
})