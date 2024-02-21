({
    createObjectData: function(component, event) {
       var Id = component.get("v.recordId");
        var RowItemList = component.get("v.TreatList");
        RowItemList.push({
            'sobjectType': 'ElixirSuite__Treatment_History__c',
            'ElixirSuite__Date__c':'',
            'ElixirSuite__Facility__c': '',
            'ElixirSuite__Level_of_Care__c' : '',
            'ElixirSuite__Length_Of_Stay__c' : '',
            'ElixirSuite__Outcome_Relapsed_when__c':'',
            'ElixirSuite__Pre_assessment__c' : Id
        });

 
//alert(JSON.stringify(RowItemList));
        component.set("v.TreatList", []);      
        component.set("v.TreatList", RowItemList);
        
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
        var allContactRows = component.get("v.TreatList");
        for (var indexVar = 0; indexVar < allContactRows.length; indexVar++) {
            if (allContactRows[indexVar].ElixirSuite__Facility__c == '') {
                
                isValid = false;
               message='Please fill Facility Type on row '+(indexVar+1);
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
     
        console.log('value of isValid'+isValid);
        return isValid;
    },
})