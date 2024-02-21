({
    /***Nikhil-----****/
   checkCareEpisodehelper:function(component , event , helper,patientId){        
       var action = component.get("c.checkCareEpisode");    
       action.setParams({
           "patientId":patientId
       });
       
       //console.log("Heading-"+component.get("v.heading"));
       //console.log("patientID-"+patientId);
       action.setCallback(this,function(response){
           if(response.getState()==="SUCCESS"){
               var returnval=response.getReturnValue();
               if(returnval==true){          
                   component.set("v.careModal",true);
               }else{
                      component.set("v.CreateSampleUA",true);/*
                 var evt = $A.get("e.force:navigateToComponent");
                     evt.setParams({
                       componentDef:"c:ElixirHC_CreateSampleUA",
                       componentAttributes:{
                           accountId:patientId,
                           popFlag:true,
                       }
                     });
                     evt.fire(); */
               }
           }
       });
       $A.enqueueAction(action);
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
       var action = component.get('c.deleteRecords');
       action.setParams({
           "lstRecordId": toDelete,
       });
       // console.log("****Id****",selectedIds);
       action.setCallback(this, function(response) { 
           var state = response.getState();
           if (state === "SUCCESS") {
               component.set('v.IsSpinner',false);
               if(response.getReturnValue()) {
               var toastEvent = $A.get("e.force:showToast");
               toastEvent.setParams({
                   "type": "Success",
                   "title": "RECORD(s) DELETED SUCCESSFULLY!",
                   "message": "Deletion Successfull!"
               });
               toastEvent.fire();
               var cmpEvent = component.getEvent("LandingPage"); 
                   cmpEvent.fire();
                   component.set("v.showConfirmDialog",false);
               var refreshevt = component.getEvent("RefreshUAListView"); 
                   refreshevt.fire();
                   //$A.get('e.force:refreshView').fire();
               }
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