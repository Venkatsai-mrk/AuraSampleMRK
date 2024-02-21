({
    doInit : function(component) {
        
        var acctId = component.get("v.recordId");
        var action = component.get("c.parentInitFetchDataForPatientStatement");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({ accountId :  acctId});        
        action.setCallback(this, function (response){
            
            var state = response.getState(); 
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var radioButtonVal = component.get("v.optValue");
                if(radioButtonVal =='Generate Statement'){
                    component.set("v.isStatementHistoryAllowed",true);
                    component.set("v.heading",'Generate Statement');
                    component.set("v.isViewStatementAllowed",false);
                    
                    console.log('generateBillSummary');
                    component.set("v.isImage",false);
                }
                // component.set("v.statementRecords",response.getReturnValue().allPatientStatements);
                
            }
            else{
                //getting errors if callback fails
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
    handleChange: function (cmp, event) {
        var changeValue = event.getParam("value");
        //alert(changeValue);
        if(changeValue =='Generate Statement'){
            cmp.set("v.isStatementHistoryAllowed",true);
            cmp.set("v.heading",'Generate Statement');
            cmp.set("v.isViewStatementAllowed",false);
        }
        else if(changeValue =='View Historical Statement'){
            cmp.set("v.isViewStatementAllowed",true);
            cmp.set("v.heading",'View Historical Statement');
            cmp.set("v.isStatementHistoryAllowed",false);
        }
    },
    generateBillSummary: function (cmp) {
        console.log('generateBillSummary');
        cmp.set("v.isImage",false);
        cmp.set("v.isStatementHistoryAllowed",true);
        cmp.set("v.heading",'Generate Statement');
        cmp.set("v.isViewStatementAllowed",false);
        
    },
    viewPreviousStatements: function (cmp) {
        console.log('viewPreviousStatements');
        cmp.set("v.isImage",false);
        cmp.set("v.isViewStatementAllowed",true);
        cmp.set("v.heading",'View Historical Statement');
        cmp.set("v.isStatementHistoryAllowed",false);
    },
    viewStatement :  function(component, event) {
        console.log('statement id '+event.getSource().get("v.name"));
        component.set("v.statementID",event.getSource().get("v.name"));   
        component.set("v.redirectToSingleStatement",true);   
    },
    delFiles :  function(component, event) {
        component.set("v.statementID",event.getSource().get("v.name"));   
        var statementID = event.getSource().get("v.name");
        var vfUrl = '/apex/ElixirSuite__PatientStatementGen?Id='+statementID;
        var newWindow;
        newWindow = window.open(vfUrl);
        newWindow.focus();
    },
    
    fetchPaymentTransactions : function(component) {
        var fromDate = component.get("v.fromDate");
        var endDate = component.get("v.toDate");
        var acctId = component.get("v.recordId");
        var finalParametre = fromDate + '$' + endDate + '$' + acctId;
        console.log('for exportPDF row selected is '+JSON.stringify(finalParametre));  
        if(fromDate!=null)
        {
             component.set("v.secondvalidation",false);
        }
        if(endDate!=null)
        {
            component.set("v.firstvalidation",false);
        }
        if(fromDate!=null && endDate!=null)
        {
        var action = component.get("c.checkStatementExists");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({ accountId :  acctId,
                          startDate : fromDate,
                          endDate : endDate});        
        action.setCallback(this, function (response){            
            var state = response.getState(); 
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                if(response.getReturnValue()){
                   //  var orderId=finalParametre;   
                        var url = '/apex/ElixirSuite__PatientStatementExportPDF?orderId='+finalParametre;
                    var newWindow;
                    newWindow = window.open(url);
                    newWindow.focus();
                    }
                else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "warning",
                        "title" : "NO PROCEDURES PRESENT IN THE SPECIFIED DATE!",
                        "message": "Please input different filter.",
                        
                    });
                    toastEvent.fire(); 
                }
                
            }
            else{
                //getting errors if callback fails
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        
        $A.enqueueAction(action); 
        /* var finalParametre = '';
          var url = '/apex/PatientStatementExport?orderId='+finalParametre;
                 //   alert(url);
                    var newWindow;
                    newWindow = window.open(url);
                    newWindow.focus();*/
        }    
    	else if(fromDate==null && endDate==null)
        {
            component.set("v.secondvalidation",true);
            component.set("v.firstvalidation",true);
        }
        else if(fromDate==null)
        {
            component.set("v.secondvalidation",true);
        }
        else if(endDate==null)
        {
           component.set("v.firstvalidation",true);
        }        
    },
    closeModel : function(component) {
        component.set("v.isOpen",false);    
    },
    fetchStatementHistory : function(component) {
        var fromDate = component.get("v.fromDateSH");
        var endDate = component.get("v.toDateSH");
        var acctId = component.get("v.recordId");
        var finalParametre = fromDate + '$' + endDate + '$' + acctId;
        console.log('for exportPDF row selected is '+JSON.stringify(finalParametre)); 
        if(fromDate!=null)
        {
             component.set("v.secondvalidation",false);
        }
        if(endDate!=null)
        {
            component.set("v.firstvalidation",false);
        }
        if(fromDate!=null && endDate!=null)
        {
            component.set("v.secondvalidation",false);
            component.set("v.firstvalidation",false);
        var action = component.get("c.filteredPaymentHistory");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({ accountId :  acctId,
                          startDate : fromDate,
                          endDate : endDate});        
        action.setCallback(this, function (response){            
            var state = response.getState(); 
            if (state === "SUCCESS") {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                if(!$A.util.isEmpty(response.getReturnValue())){
                    component.set("v.statementRecords",response.getReturnValue());
                    component.set("v.openStatementHistory",true);
                    
                }
                else {
                    component.set("v.openStatementHistory",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "warning",
                        "title" : "NO STATEMENT PRESENT IN THE SPECIFIED DATE!",
                        "message": "Please input different filter.",
                        
                    });
                    toastEvent.fire(); 
                }
                
            }
            else{
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                //getting errors if callback fails
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        
        $A.enqueueAction(action);  
    }
        else if(fromDate==null && endDate==null)
        {
            component.set("v.secondvalidation",true);
            component.set("v.firstvalidation",true);
        }
        else if(fromDate==null)
        {
            component.set("v.secondvalidation",true);
        }
        else if(endDate==null)
        {
           component.set("v.firstvalidation",true);
        }
        
    }
})