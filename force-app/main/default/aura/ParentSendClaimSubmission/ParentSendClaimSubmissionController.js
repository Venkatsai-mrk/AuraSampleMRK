({
    myAction : function(component, event, helper) {
        
    },
    submitDetails: function(component, event, helper) {
        var pageRef = component.get( "v.pageReference" );
        var strInp = pageRef.state.c__strInput;
        console.log('test',strInp );
        component.set("v.claimIds" , strInp); 
        component.set("v.callClaimSubmit" , true);
        /* var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ClaimSubmission",
            componentAttributes: {
                claimIds : strInp
            }
        });
        evt.fire();*/
        
        
    },
    closePopUp : function(component,event){
        var duplicateChecker = component.get("c.viewIdAll");
        duplicateChecker.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){   
                let viewId = response.getReturnValue();
                if(!$A.util.isUndefinedOrNull(viewId)){
                    /* var homeEvent = $A.get("e.force:navigateToList");
                    homeEvent.setParams({
                        "listViewId": viewId,
                        "listViewName": null,
                        "scope": "ElixirSuite__Claim__c"
                    });
                    homeEvent.fire();*/
                     // Commented above lines and Added below code,
                    //  as it is redirecting to new tab on cancel.Now it will redirect in the same tab - JAMI
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/lightning/o/ElixirSuite__Claim__c/list?filterName=" + viewId,
                        "isredirect": true
                    });
                    urlEvent.fire(); 
                }  
            }
        });  
        $A.enqueueAction(duplicateChecker);
    },
})