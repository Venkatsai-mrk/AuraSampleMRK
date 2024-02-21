({
	doInit : function() {
        
		
	},
    handleClickForEnableAppointmentBooking: function(component) {
		component.set("v.openMedicationEmailSetting",false); 
        component.set("v.openInsuranceEmailSetting",false);
        component.set("v.openPortalMessaging",false);
        component.set("v.visitSummaryTemplate",false);
        component.set("v.enableAppointmentBooking",true);
        component.set("v.enableVisitNotes",false);
        
        var cmpTarget = component.find('appointmentBooking');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        var cmpTarget1 = component.find('medicationSetting');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('portalMessageSetting');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('visitSummaryTemplate');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('visitNotesSetting');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
        var cmpTarget5 = component.find('insuranceSetting');
        $A.util.removeClass(cmpTarget5, 'parentCSS_1 act');
	},

	handleClickForInsurance : function(component) {
		component.set("v.openMedicationEmailSetting",false); 
        component.set("v.openInsuranceEmailSetting",true);
        component.set("v.openPortalMessaging",false);
        component.set("v.visitSummaryTemplate",false);
        component.set("v.enableAppointmentBooking",false);
        var cmpTarget = component.find('insuranceSetting');
        component.set("v.enableVisitNotes",false);
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        var cmpTarget1 = component.find('medicationSetting');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('portalMessageSetting');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('visitSummaryTemplate');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('visitNotesSetting');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
        var cmpTarget5 = component.find('appointmentBooking');
        $A.util.removeClass(cmpTarget5, 'parentCSS_1 act');
	},

	handleClickForMedication : function(component) {
		component.set("v.openInsuranceEmailSetting",false); 
        component.set("v.openMedicationEmailSetting",true);
        component.set("v.openPortalMessaging",false);
        component.set("v.visitSummaryTemplate",false);
        component.set("v.enableAppointmentBooking",false);
        component.set("v.enableVisitNotes",false);
        var cmpTarget = component.find('medicationSetting');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        var cmpTarget1 = component.find('insuranceSetting');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('portalMessageSetting');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('visitSummaryTemplate');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('visitNotesSetting');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
        var cmpTarget5 = component.find('appointmentBooking');
        $A.util.removeClass(cmpTarget5, 'parentCSS_1 act');
	},
    handleClickForPortalMessaging : function(component) {
		component.set("v.openInsuranceEmailSetting",false); 
        component.set("v.openMedicationEmailSetting",false);
    	component.set("v.openPortalMessaging",true);
        component.set("v.portalMessage",true);
        component.set("v.visitSummaryTemplate",false);
        component.set("v.enableAppointmentBooking",false);
        component.set("v.enableVisitNotes",false);
        var cmpTarget = component.find('portalMessageSetting');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        var cmpTarget1 = component.find('medicationSetting');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('insuranceSetting');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('visitSummaryTemplate');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('visitNotesSetting');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
        var cmpTarget5 = component.find('appointmentBooking');
        $A.util.removeClass(cmpTarget5, 'parentCSS_1 act');
	},
    handleClickFovisitSummaryTemplate : function(component) {
		component.set("v.openMedicationEmailSetting",false); 
        component.set("v.openInsuranceEmailSetting",false);
        component.set("v.openPortalMessaging",false);
        component.set("v.visitSummaryTemplate",true);
        component.set("v.enableAppointmentBooking",false);
        component.set("v.enableVisitNotes",false);
        var cmpTarget = component.find('visitSummaryTemplate');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        var cmpTarget1 = component.find('insuranceSetting');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('medicationSetting');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('portalMessageSetting');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('visitNotesSetting');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
        var cmpTarget5 = component.find('appointmentBooking');
        $A.util.removeClass(cmpTarget5, 'parentCSS_1 act');
	},
    handleClickForVisitNotes : function(component) {
		component.set("v.openMedicationEmailSetting",false); 
        component.set("v.openInsuranceEmailSetting",false);
        component.set("v.openPortalMessaging",false);
        component.set("v.visitSummaryTemplate",false);
        component.set("v.enableAppointmentBooking",false);
        component.set("v.enableVisitNotes",true);
        var cmpTarget = component.find('visitNotesSetting');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        var cmpTarget1 = component.find('insuranceSetting');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('medicationSetting');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('portalMessageSetting');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('visitSummaryTemplate');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
        var cmpTarget5 = component.find('appointmentBooking');
        $A.util.removeClass(cmpTarget5, 'parentCSS_1 act');
	}
})