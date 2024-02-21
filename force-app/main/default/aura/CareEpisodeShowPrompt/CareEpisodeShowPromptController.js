({	
    closePrompt:function(component,event,helper){
        component.set("v.showPrompt",false);
    },
    openNewCarePlanModal : function(component, event, helper){    
       component.set("v.showPrompt",false);
      // console.log('careEpisode-Prompt--- '+component.get("v.patientId"));
       // console.log('careEpisode-Prompt--- '+component.get("v.heading"));
       var evt = $A.get("e.force:navigateToComponent");
           evt.setParams({
          componentDef:"c:createNewCareEpisode",               
          componentAttributes: {
              patientID:component.get("v.patientId"), 
              heading:component.get("v.heading")
          }               
      });
     evt.fire();
    },
})