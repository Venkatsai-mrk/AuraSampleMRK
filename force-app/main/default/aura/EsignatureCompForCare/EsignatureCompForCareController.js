({
    doInit : function(component, event, helper) {
        var action = component.get('c.userId');
        action.setParams({
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                
                var recId = response.getReturnValue();
                component.set("v.recordId",recId);
            }
        });
        $A.enqueueAction(action);
        helper.getProfileName(component, event, helper);
    },
    
    handleClickForOTP : function(component , event , helper){
       // component.set("v.openLocationConfigurationscreen",false); 
        var recId = component.get("v.recordId");
        
        var action = component.get("c.sendEmail");
        action.setParams({  
            recordId : recId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var sentEmailId = data.regEmail ;
                console.log('the data is' , data);
                
                component.set("v.result" , data.regEmail);
                component.set("v.vfCode" , data.code);
                console.log('the data is' , component.get("v.result"));
                var msg =  'The Verification Code has been sent to' + ' ' + sentEmailId ;
                var msg1 = 'The Patient emailId is not registered , Please contact the Administrator ';
                if($A.util.isUndefinedOrNull(data.regEmail) || $A.util.isEmpty(data.regEmail)){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: msg1 ,
                        duration:' 5000',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
                else{
                    var toastEvent1 = $A.get("e.force:showToast");
                    toastEvent1.setParams({
                        title : 'Success !',
                        message: msg,
                        duration:' 5000',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent1.fire();    
                }
            }
            else{
                console.log('nhjl');
            }
        });
        $A.enqueueAction(action);
        var cmpTarget = component.find('generatePin');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        
        var cmpTarget = component.find('companyLogo');
        $A.util.removeClass(cmpTarget, 'parentCSS_1 act');
        var cmpTarget1 = component.find('registerSign');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
       /* var cmpTarget2 = component.find('patientCard');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('userLocation');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('patientTile');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');*/
    },
    
    signaturePad : function(component , event , helper){
        //component.set("v.openLocationConfigurationscreen",false); 
        component.set("v.recordVal" ,component.get("v.recordId"));
        component.set("v.openSignaturePad",true);
        console.log('dds456');
        
        var cmpTarget = component.find('registerSign');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        
        var cmpTarget = component.find('companyLogo');
        $A.util.removeClass(cmpTarget, 'parentCSS_1 act');
        var cmpTarget1 = component.find('generatePin');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        /*var cmpTarget2 = component.find('userLocation');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('patientTile');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('patientCard');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');*/
    },
    
    updateSignature : function(component , event , helper){
        console.log('dds');
        component.set("v.recordVal" ,component.get("v.recordId"));
        component.set("v.openSignaturePadUpdate",true);
       // component.set("v.openLocationConfigurationscreen",false); 
        console.log('dds456');
    },
  /*  openUserLocationConfiguration :  function(component , event , helper){
        component.set("v.openPatientTileConfigurationscreen",false); 
        component.set("v.openLocationConfigurationscreen",true); 
        component.set("v.openPatientInfoCardConfigurationscreen",false);
        component.set("v.openCompanyLogoUpload",false);
        
        var cmpTarget = component.find('userLocation');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        
        var cmpTarget = component.find('companyLogo');
        $A.util.removeClass(cmpTarget, 'parentCSS_1 act');
        var cmpTarget1 = component.find('generatePin');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('registerSign');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('patientTile');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('patientCard');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
    },*/
  /*  openPatientTileconfigScreen : function(component , event , helper){
        component.set("v.openLocationConfigurationscreen",false); 
        component.set("v.openPatientTileConfigurationscreen",true); 
        component.set("v.openPatientInfoCardConfigurationscreen",false);
        component.set("v.openCompanyLogoUpload",false);
        
        var cmpTarget = component.find('patientTile');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        
        var cmpTarget = component.find('companyLogo');
        $A.util.removeClass(cmpTarget, 'parentCSS_1 act');
        var cmpTarget1 = component.find('generatePin');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('registerSign');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('userLocation');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('patientCard');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
    },*/
   /* openPatientInfoCardConfigScreen : function(component , event , helper){
        component.set("v.openLocationConfigurationscreen",false); 
        component.set("v.openPatientTileConfigurationscreen",false); 
        component.set("v.openPatientInfoCardConfigurationscreen",true);
        component.set("v.openCompanyLogoUpload",false);
        
        var cmpTarget = component.find('patientCard');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        
        var cmpTarget = component.find('companyLogo');
        $A.util.removeClass(cmpTarget, 'parentCSS_1 act');
        var cmpTarget1 = component.find('generatePin');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
        var cmpTarget2 = component.find('registerSign');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('userLocation');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('patientTile');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');
    },*/
    handleCompanyLogoUpload : function(component , event , helper){
       // component.set("v.openLocationConfigurationscreen",false); 
       // component.set("v.openPatientTileConfigurationscreen",false); 
       // component.set("v.openPatientInfoCardConfigurationscreen",false);
        component.set("v.openCompanyLogoUpload",true);
        var cmpTarget = component.find('companyLogo');
        $A.util.addClass(cmpTarget, 'parentCSS_1 act');
        
        
        var cmpTarget = component.find('generatePin');
        $A.util.removeClass(cmpTarget, 'parentCSS_1 act');
        var cmpTarget1 = component.find('registerSign');
        $A.util.removeClass(cmpTarget1, 'parentCSS_1 act');
      /*  var cmpTarget2 = component.find('userLocation');
        $A.util.removeClass(cmpTarget2, 'parentCSS_1 act');
        var cmpTarget3 = component.find('patientTile');
        $A.util.removeClass(cmpTarget3, 'parentCSS_1 act');
        var cmpTarget4 = component.find('patientCard');
        $A.util.removeClass(cmpTarget4, 'parentCSS_1 act');*/
        
    }
})