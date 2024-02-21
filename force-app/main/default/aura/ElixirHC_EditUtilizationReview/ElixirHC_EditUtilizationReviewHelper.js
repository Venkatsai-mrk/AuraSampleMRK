({
    getUtilizationRecordForEdit : function(component, event, helper,recordToFetch) {    
        var action = component.get("c.getURRecordForEdit");
    
        action.setParams({ record : recordToFetch });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
               component.find("Id_spinner").set("v.class" , 'slds-hide'); 
                component.set("v.UtilizationRecordToSave",response.getReturnValue());    
                 component.set("v.URRecordCopy",response.getReturnValue()); 
                var getCreatedDate = response.getReturnValue()['ElixirSuite__Date_Time_of_Review__c'];
                console.log('getCreatedDate***',getCreatedDate);
                getCreatedDate =  new Date(getCreatedDate);
                 //added by Anmol for LX3-6162
                 var appNoDays = response.getReturnValue()['ElixirSuite__Approved_Number_of_Days__c'];
                 console.log('appNoDays****',appNoDays);
                 if(appNoDays==undefined){
                      component.set("v.NextReviewDate",'');
                 }
                 else{
                 getCreatedDate =  new Date(getCreatedDate);
                 //  today = helper.addDays(component, event, helper,today,getNumberOfDays);
                  getCreatedDate.setDate(getCreatedDate.getDate() + parseInt(response.getReturnValue()['ElixirSuite__Approved_Number_of_Days__c']));
                 var dd = String(getCreatedDate.getDate()).padStart(2, '0');
                 var mm = String(getCreatedDate.getMonth() + 1).padStart(2, '0'); //January is 0!
                 var yyyy = getCreatedDate.getFullYear();        
                 var stringifiedDate = dd + '/' + mm + '/' + yyyy;
                 component.set("v.NextReviewDate",stringifiedDate);
                 }
                 //end by Anmol for LX3-6162
                component.set("v.isLastURForm",response.getReturnValue()['ElixirSuite__Discharge__c']);
                
            }
            else{                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });        
        $A.enqueueAction(action);
    },

   //added by Anmol for LX3-5961
  fetchSessionCompleted : function(component,accId,revDate) {

    var action = component.get("c.fetchEvent");
    action.setParams({ accountId : accId,
                        reviewDate : revDate
                     });
    action.setCallback(this, function(response){
        var state = response.getState();
        if (state === "SUCCESS") {
            console.log('in helper fetchSessionCompleted**',response.getReturnValue());
            var utilRec = component.get("v.UtilizationRecordToSave");
            utilRec.ElixirSuite__Sessions_Completed__c = response.getReturnValue();
            component.set("v.sessionCompleted",response.getReturnValue());
            component.set("v.UtilizationRecordToSave",utilRec);
            var apsession = utilRec.ElixirSuite__Approved_Number_of_Sessions__c;
            this.fetchSessionAvail(component,apsession);
        }
        else {
                console.log("failure for namespace");
        }
          });
          $A.enqueueAction(action);
       var utilRec = component.get("v.UtilizationRecordToSave");
          var apsession = utilRec.ElixirSuite__Approved_Number_of_Sessions__c;
        //  this.fetchSessionAvail(component,apsession);
},
fetchSessionAvail : function(component,apsession) {

    console.log('apsession****',apsession);
    var utilRec = component.get("v.UtilizationRecordToSave");
    var sesComp = component.get("v.sessionCompleted");
    console.log('apsession****sesComp',sesComp);
    var sesAvail = apsession - sesComp;
    utilRec.ElixirSuite__Sessions_Available__c = sesAvail;
    component.set("v.UtilizationRecordToSave",utilRec);

},
//end by Anmol for LX3-5961

    addDays : function (component, event, helper,date, days) {
        var a = parseInt(days);
        const copy = new Date(Number(date));
        copy.setDate(date.getDate() + a);
        return copy;
    },
    ifObjectsAreSame : function (component, event, helper,obj1, obj2) {
        
        var flag=true;
        
        if(Object.keys(obj1).length==Object.keys(obj2).length){
            for(key in obj1) { 
                if(obj1[key] == obj2[key]) {
                    continue;
                }
                else {
                    flag=false;
                    break;
                }
            }
        }
        else {
            flag=false;
        }
        console.log("is object equal"+flag);
    }
    
})