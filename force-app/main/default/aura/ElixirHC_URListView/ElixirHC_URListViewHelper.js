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
                if(returnval==true){          
                    component.set("v.careModal",true);
                     component.set("v.heading",'Utilization Review');
                }else{                   
                        component.set("v.uRListView",true);/*

                  var evt = $A.get("e.force:navigateToComponent");
                      evt.setParams({
                         componentDef:"c:ElixirHC_UtilizationReview",
                         componentAttributes:{
                               patientID:patientId,
                               backPage:true
                          }
                       });
                  evt.fire(); */
                }
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
    //Added by Ashwini//
    fetchAccountName:function(component, event, helper){
     var action = component.get("c.fetchAccountName");
        action.setParams({ accountId : component.get("v.patientID") });
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
    //End by Ashwini//
    
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
  
    deleteSelectedHelper: function(component, event, helper, selectedIds) {
        console.log(typeof(selectedIds));
        var arrRec = [];
        if(typeof(selectedIds)=="string"){
            arrRec.push(selectedIds); 
            helper.finalDelete(component, event,helper, arrRec);
        }
        else {
            helper.finalDelete(component, event,helper, selectedIds);
        }
        
    },
    finalDelete : function(component, event,helper, toDelete) {
        // component.set('v.IsSpinner',true);
        var action = component.get('c.deleteAllUtilizationRecords');
        action.setParams({
            "lstRecordId": toDelete,
        });
        // console.log("****Id****",selectedIds);
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.IsSpinner',false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "title": "The Record has been successfully deleted!",
                    "message": "Deletion Successfull!"
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            } else if (state === "ERROR") {
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action);
        
    }
})