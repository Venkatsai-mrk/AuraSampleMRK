({
	doInit : function(component, event, helper) {
        var url = $A.get('$Resource.WaterMarkAllergies');
        component.set('v.backgroundImageURL', url);
        component.find("Id_spinner").set("v.class" , 'slds-show'); 
       var action = component.get("c.getData");
       action.setParams({ 
           accId : component.get("v.accId")
                        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                component.find("Id_spinner").set("v.class" , 'slds-hide'); 
               var Data =response.getReturnValue();
               var FoodAllergy = Data.FoodAllergy;
               var SkinAllergy = Data.SkinAllergy;
               var DrugAllergy = Data.DrugAllergy; 
               var AlertsData = Data.MedicalAlerts;
               console.log('gdd' , Data);
               component.set("v.FoodAllergyList",FoodAllergy);
               component.set("v.SkinAllergyList",SkinAllergy);
               component.set("v.DrugAllergyList",DrugAllergy); 
  			   component.set("v.AlertsList",AlertsData);
            }else{
                console.log('failure');  
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        var action3 = component.get('c.LicensBasdPermission');
        action3.setParams({
        });
        
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var wrapList = response.getReturnValue();
                component.set("v.Ehr",wrapList.isEhr);
                component.set("v.Billing",wrapList.isRcm);
                component.set("v.ContactCentr",wrapList.isContactCenter);
            }
        });
        $A.enqueueAction(action);
        $A.enqueueAction(action3);
    },
    closeModel: function(component, event, helper) {
       
        component.set("v.AlertScreen",false);
        
    }
})