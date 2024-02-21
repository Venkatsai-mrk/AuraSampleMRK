({
    
    refreshEvent : function(component, event, helper) {
       console.log("refreshEvent");
       component.set("v.PatientId", "");
       var urlString = window.location.href;
       console.log("urlString"+urlString);
       var selectedClaimType= 'Primary';
       component.set("v.displayTable", false);
       component.set("v.isUB04",false);  
       component.set("v.isCMS1500",false);  
       component.set("v.headerLabel", selectedClaimType);
       var heading;
       heading = "CMS-1500 Form";
       component.set("v.claimLabel",heading);
       component.set("v.heading","CMS_1500");
        
      $A.get("e.force:refreshView").fire()   
    },
	myAction : function(component, event, helper) {
       console.log("QQQQQQQQQQQQQQQQQQQQQQ"); 
       component.set("v.PatientId", "");
       var urlString = window.location.href;
       console.log("urlString"+urlString);
       var selectedClaimType= 'Primary';
       component.set("v.displayTable", false);
       component.set("v.isUB04",false);  
       component.set("v.isCMS1500",false);  
       component.set("v.headerLabel", selectedClaimType);
       var heading;
       heading = "CMS-1500 Form";
       component.set("v.claimLabel",heading);
       component.set("v.heading","CMS_1500");
        
		
	},
    parentComponentEvent : function(cmp, event,helper) { 
        
        var accId = event.getParam("lookUpData"); 
        console.log("accId "+accId);
        
        cmp.set("v.PatientId", accId);
        if(accId == ""){
            console.log("nullaccid");
            cmp.set("v.displayTable", false);  
            cmp.set("v.VobList", []);
        }
        if(accId != "" && cmp.get("v.headerLabel") != null && cmp.get("v.claimLabel") != null){
            console.log("notnullaccid");
            helper.fetchdata(cmp, event);
            
        } 
    },
    claimTypeChange : function(component, event, helper) {
        
        var selectedClaimType= event.getSource().get('v.value');
        console.log('selectedClaimType',selectedClaimType);
        component.set("v.headerLabel", selectedClaimType);
        if(component.get("v.PatientId") != "" && component.get("v.headerLabel") != null && component.get("v.claimLabel") != null){
            helper.fetchdata(component, event);
        }
        
        
    },
    claimFormChange : function(component, event, helper) {
        
        var selectedClaimForm= event.getSource().get('v.value');
        console.log('selectedClaimForm',selectedClaimForm);
        if(selectedClaimForm == "CMS-1500 Form"){
            component.set("v.heading","CMS_1500");
            component.set("v.claimLabel", selectedClaimForm);
        }
        if(selectedClaimForm == "UB-04 Form"){
            component.set("v.heading","UB_04"); 
            component.set("v.claimLabel", selectedClaimForm);
        }
        if(component.get("v.PatientId") != "" && component.get("v.headerLabel") != null && component.get("v.claimLabel") != null){
            helper.fetchdata(component, event);
        }
        
    },
     rowSelectionHandle: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        cmp.set('v.selectedVOBList', selectedRows);
        console.log('selectedVOBList',cmp.get('v.selectedVOBList'));
    },
    proceedNext : function(component, event, helper){
        console.log("rtttttt")
        component.set("v.isOpen",false);
        if(component.get("v.PatientId") != ""){
             console.log("rtttttt  222222222222")
            if( component.get("v.claimLabel") == "UB-04 Form"){
                component.set("v.isUB04",true); 
            }
            if( component.get("v.claimLabel") == "CMS-1500 Form"){
                component.set("v.isCMS1500",true); 
            }
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Please fill mandatory fields!",
                "message": "Select the patient name and fill all required fields !"
            });
            toastEvent.fire(); 
        }
        
    },
    handleSort: function(component,event,helper){
        var sortBy = event.getParam("fieldName");       
        var sortDirection = event.getParam("sortDirection");
        
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        
        helper.sortData(component,sortBy,sortDirection);
    },
    
    closePopUp : function(component,event){
        component.set("v.PatientId", "");
        component.set("v.displayTable", false);
        component.set("v.VobList", []);
        component.set("v.isUB04",false); 
        component.set("v.isCMS1500",false); 
        component.set("v.isOpen",false);
        var dummy = 'https://momentum-nosoftware-7512-dev-ed.scratch.lightning.force.com/lightning/o/ElixirSuite__Claim__c/list?filterName=Recent';
        //var navEvent = sforce.one.navigateToURL(dummy, true);
        
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "ElixirSuite__Claim__c"
        });
        homeEvent.fire();
        $A.get("e.force:refreshView").fire()
        
    },
        
})