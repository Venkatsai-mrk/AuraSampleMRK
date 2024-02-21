({
     /***Nikhil-----****/
    checkCareEpisodehelper:function(component , event , helper,patientId){        
        var action = component.get("c.checkCareEpisode");    
        action.setParams({
            "patientId":patientId
        });
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS"){
                var returnval=response.getReturnValue();
                 console.log('HHH-laborder '+component.get("v.heading"));
                if(returnval==true){          
                    component.set("v.careModal",true);
                }else{                   
                    component.set("v.referral",true);
                   /*var evt = $A.get("e.force:navigateToComponent");
                      evt.setParams({
                         componentDef:"c:ElixirOEM_ReferralContainer",
                          componentAttributes:{
                            accountId:patientId,
                              backPage1:true,
                              isOpen:true
                        }
                      });
                    evt.fire();*/
                }
            }
        });
        $A.enqueueAction(action);
    },
     //Added by Ashwini
     fetchAccountName:function(component, event, helper){
        var action = component.get("c.fetchAccountName");
           action.setParams({ accountId : component.get("v.recordVal") });
           action.setCallback(this, function(response) {
               var state = response.getState();
               if (state === "SUCCESS") {
                   
                   console.log('Patient name  data '+JSON.stringify(response.getReturnValue()));                
                   var records =response.getReturnValue();
                   component.set("v.accName", records);
                   
               }
           
            });
           
           $A.enqueueAction(action);
       },
    sortData: function (cmp, helper, fieldName, sortDirection) {
        var data = cmp.get("v.allData");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.allData", data);
        helper.buildData(cmp, helper);
    },
    
    //for selecting order of sorting
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    setTime: function(cmp,helper){
        var currentTime = cmp.get("v.time");
        cmp.set("v.time", (currentTime+1));
    },
    helperMethod : function(component, event, helper) {
        component.set("v.newEncounter",false);         
    },
  
    deleteSelectedRecordRecord : function(component, event, helper) {
        var action = component.get("c.deleteRecord");
        action.setParams({  
            recId : component.get("v.RowId") ,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.doiInitReplica(component, event, helper);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "title": "RECORD DELETED SUCCESSFULLY!",
                    "message": "Deletion Successfull!"
                });
                toastEvent.fire();
                     $A.get('e.force:refreshView').fire();
            }else{
                console.log("failure");
            }
        });
        $A.enqueueAction(action);
    },
    sortData: function (component, fieldName, sortDirection) {
        var fname = fieldName;
        var data = component.get("v.listDetails");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortByfield(fieldName, reverse))
        component.set("v.listDetails", data);
    },
    
    sortByfield: function (field, reverse) {
        var key = function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
     globalFlagToast : function(component, event, helper,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message":  message,
            "type" :type
        });
        toastEvent.fire();
     }
})