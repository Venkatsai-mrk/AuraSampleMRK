({
    createObjectData: function(component, event) {
      
       var Id = component.get("v.recordId");
        var RowItemList = component.get("v.SahList");
        RowItemList.push({
            'sobjectType': 'ElixirSuite__Substance_Use_History__c',
            'ElixirSuite__Substance__c':'',
            'ElixirSuite__First_Use__c': '',
            'ElixirSuite__Last_Use__c': '',
            'ElixirSuite__Amount__c' : '',
            'ElixirSuite__Frequency__c' : '',
            'ElixirSuite__Route__c' : '',
            'ElixirSuite__Pre_assessment__c' : Id
        });

 

        component.set("v.SahList", []);      
        component.set("v.SahList", RowItemList);
        
        
        
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
        var allContactRows = component.get("v.SahList");
        for (var indexVar = 0; indexVar < allContactRows.length; indexVar++) {
            if (allContactRows[indexVar].ElixirSuite__Substance__c == '') {
                
                isValid = false;
               message='Please fill Substance Type on row '+(indexVar+1);
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