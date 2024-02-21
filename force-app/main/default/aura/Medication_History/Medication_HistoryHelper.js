({
    createObjectData: function(component, event) {
      
       var Id = component.get("v.recordId");
        var RowItemList = component.get("v.MedList");
        RowItemList.push({
            'sobjectType': 'ElixirSuite__Medication_History__c',
            'ElixirSuite__Medication__c':'',
            'ElixirSuite__Dose__c': '',
            'ElixirSuite__Frequency__c' : '',
            'ElixirSuite__Currently_taking__c' : 'Yes',
            'ElixirSuite__Pre_assessment__c' : Id
        });

 

        component.set("v.MedList", []);      
        component.set("v.MedList", RowItemList);
        
        
        
    },
    
  
     showToast: function(message){
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({
                "title": "Notification!",
                "message": message,
                "type": "info"
            });
            toastEvent.fire();
        }
    },

    validateRequired: function(component, event, helper) {
       var message='';
        console.log('inside validate');
       
        var isValid = true;
        var allContactRows = component.get("v.MedList");
        for (var indexVar = 0; indexVar < allContactRows.length; indexVar++) {
            if (allContactRows[indexVar].ElixirSuite__Medication__c == '') {
                
                isValid = false;
               message='Please fill Medication Type on row '+(indexVar+1);
                    var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({
                "title": "Notification!",
                "message": message,
                "type": "info"
            });
            toastEvent.fire();
            break;
        }
              console.log('message-->'+message);
         
             // alert('Please fill Primary Drug Type on row ' + (indexVar + 1));
            }
           
             
        }
      //  helper.showToast(message);
   
        console.log('value of isValid'+isValid);
        return isValid;
    },
})