({
    doInit : function(component, event, helper) {
        // alert('patient id '+JSON.stringify(component.get("v.isEnabledEdit")));
        
        helper.getAllPicklistValues(component);
        helper.getAllUser(component);
        //   helper.getNameSpaceOrgWide(component);
        component.set('v.todayString', new Date().toISOString());
        var action = component.get("c.getLabOrder");
        console.log('Lab order id '+JSON.stringify(component.get("v.recordValue")));       
        action.setParams({
            "record": component.get("v.recordValue"),            
        });
        action.setCallback(this, function(response) {                     
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue().UASampleDetails;
                console.log('Lab order id received'+JSON.stringify(res));       
                component.set("v.nameSpace",response.getReturnValue().nameSpace);
                if($A.util.isUndefinedOrNull(res.ElixirSuite__Necessity_Details__c)){
                    res.ElixirSuite__Necessity_Details__c='';
                }
                res.ElixirSuite__Necessity_Details__c= '\n\n' +  res.ElixirSuite__Necessity_Details__c;
                component.set("v.attachId1" ,res.ElixirSuite__Signature_Link__c );
                component.set("v.dateTodayForForm1" ,res.ElixirSuite__Signed_Date__c );
                component.set("v.signee1" ,res.ElixirSuite__Account__r.Name );
                
                if(res.ElixirSuite__Signature_Link__c  !=null){
                    component.set("v.showSign",false)
                    component.set("v.signstatus",false)
                }
                component.set("v.signComment1" ,res.ElixirSuite__Signature_Comments__c );
                console.log('response value '+JSON.stringify(response.getReturnValue()));
                component.set("v.Response",JSON.parse(JSON.stringify(response.getReturnValue())));
                component.set("v.ProcReqToSave",response.getReturnValue()); 
                component.set("v.AvailableTestValue",response.getReturnValue().ElixirSuite__Medical_Test__c); 
                console.log('response value after set '+JSON.stringify( component.get("v.Response")));
                helper.fetchCheckBoxesValues(component);
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
        //KISHAN CODE START
        var action1 = component.get("c.getCode");
        action1.setParams({  
            accId : component.get("v.AcctIden")
        });
        action1.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var code = response.getReturnValue(); 
                
                
                
                component.set("v.passcode", code); 
            }
            else{
                console.log('failure');
            }                           
        });
        $A.enqueueAction(action1);
        // KISHAN CODE END
        
    },
    handleConfirmDialogNo:function(component) {
        component.set("v.showConfirmDialog",false);
    },
    closeModel: function(component) {
        var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
        appEvent.setParams({
            "screenType" : "LabTest",
            "action" : "Edit",
            "button" : "Cancel",
            "recordIds" : ""});
        appEvent.fire();
        component.set("v.isOpen", false);
    },
    handleConfirmDialogYes :  function(component) {
        var action = component.get("c.saveRecordAfterEdit"); 
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get("v.value");
        
        if(endProcedureTime == null)
        {
            var today = new Date();
            endProcedureTime = today;
        }
        var newProcRec = component.get("v.ProcReqToSave").UASampleDetails;
                        action.setParams({               
                            "procReq": newProcRec,
                            "acct": component.get("v.recordValue"),
                            "starttimeProcedure" : component.get('v.todayString'),
                            "endtimeProcedure" : endProcedureTime,
                            "attachId": component.get("v.attachId1"),
                            "commentSign": component.get("v.signComment1"),
                            "signedDate": component.get("v.dateTodayForForm1"),
                            "LabOrderID": component.get("v.recordValue"),
                            "orderByID" : newProcRec.ElixirSuite__Order_By__r.Id
                        });
                        action.setCallback(this, function(response) {                    
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
                                appEvent.setParams({
                                    "screenType" : "LabTest",
                                    "action" : "Edit",
                                    "recordIds" : [response.getReturnValue().Id] });
                                appEvent.fire();
                                console.log('wfh '+JSON.stringify(response.getReturnValue()));                       
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "Success",
                                    "title": "PROCEDURE REQUEST UPDATED SUCCESSFULLY!",
                                    "message": "Updation Successfull!"
                                });
                                toastEvent.fire(); 
                                
                                component.set("v.isOpen", false);
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
                                var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
                                appEvent.setParams({
                                    "screenType" : "LabTest",
                                    "action" : "Edit",
                                    "button" : "Cancel",
                                    "recordIds" : [response.getReturnValue().Id] });
                                appEvent.fire();
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": "error",
                                    "title": "PROCEDURE REQUEST UPDATION FAILED!",
                                    "message": "Failed!"
                                });
                                toastEvent.fire();
                            }
                        });
                        $A.enqueueAction(action); 
                    
        
    },
    handleSelect: function(component, event) {
        alert('inside  selecthandle '+ event.getSource().get("v.value"));           
        component.set("v.AvailableTestValue",event.getSource().get("v.value"));
        component.set("v.ProcReqToSave.ElixirSuite__Medical_Test__c", event.getSource().get("v.value"));
        alert('medical test value after set'+  component.get("v.ProcReqToSave.ElixirSuite__Medical_Test__c"));
        // component.set("v.OrderedTests", true);
        
    },
    procedureValidity  : function(component ,event ,helper){
        var valid = true;
        helper.helperMethod(component , valid);
    },
    handleCheckboxChange: function(component, event) {
        console.log('checkbox change ' );
        var isChecked  = event.getSource().get("v.checked");
        var index  =  event.getSource().get("v.name");
        if(isChecked) {
            let slectedNecessity = component.get("v.checkOptions");
            let finalVal = slectedNecessity[index];
            let getValue  = component.get("v.ProcReqToSave.UASampleDetails.ElixirSuite__Necessity_Details__c");
            if($A.util.isUndefinedOrNull(getValue)){
                getValue='';
            }  
            getValue=getValue.concat(finalVal.value);
            component.set("v.ProcReqToSave.UASampleDetails.ElixirSuite__Necessity_Details__c",getValue);      
            console.log('after set' +JSON.stringify( component.get("v.ProcReqToSave.UASampleDetails.ElixirSuite__Necessity_Details__c")));
        }
        else {  
            let slectedNecessity = component.get("v.checkOptions");
            let finalVal = slectedNecessity[index];
            let getValue = '';
            getValue  = component.get("v.ProcReqToSave.UASampleDetails.ElixirSuite__Necessity_Details__c");
            getValue=getValue.replace(finalVal.value,'');
            component.set("v.ProcReqToSave.UASampleDetails.ElixirSuite__Necessity_Details__c",getValue);      
            console.log('after set' +JSON.stringify( component.get("v.ProcReqToSave.UASampleDetails.ElixirSuite__Necessity_Details__c")));
        }
    },
    
    handleCheck: function(component) {
        var isChecked = component.find("OnAdmissionCheckBox").get("v.checked");
        component.set("v.ProcReqToSave.UASampleDetails.ElixirSuite__On_Admission__c", isChecked);
    },
    
    downloadWithVF : function(component){
        var labOrderId=component.get("v.recordValue"); 
        var url = '/apex/ElixirSuite__PDFGenerator?orderId='+labOrderId;
        // alert(url);
        var newWindow;
        newWindow = window.open(url);
        newWindow.focus();
    }
    ,
    downloaBarcode : function(component){
        var labOrderId=component.get("v.recordValue"); 
        var url = '/apex/ElixirSuite__ElixirHc_BarCodeGenerator_V2?orderId='+labOrderId;
        // alert(url);
        var newWindow;
        newWindow = window.open(url);
        newWindow.focus();
    },
    
    downloadpdf:function(component){
        var orderId = component.get("v.recordValue");
        var action=component.get("c.getLabOrder");
        action.setParams({"record":orderId});
        action.setCallback(this,function(response){
            if(response.getState()=="SUCCESS"){
                var res=response.getReturnValue().UASampleDetails;
                console.log('download response '+JSON.stringify(res));
                
                var jsonForPdf=response.getReturnValue();
                console.log('parsed '+jsonForPdf);
                var pdfName=" "+"Patient Lab Order";
                var pdfString="<h1>"+" "+"</h1><br/><table border='0' cellspacing='0' cellpadding='0' style='border-collapse:collapse;background-color: #000;' ><thead><td style='padding: 5px 10px;'<table border='0' cellspacing='0' cellpadding='0' style='padding: 10px 15px; background-color: #f1f2f3; margin: 5px 0; width: 100%;'><tbody><tr><td><h4 style='margin: 0 0; font-size: 20px;'>HELLO</h4></td></tr>"+
                    "</tbody></table></td></thead><tbody>";
                pdfName+=Object.keys(jsonForPdf); 
                var countOrder=0;
                //   console.log('JSON FOR PDF STRINGIFIED '+JSON.stringify(pdfName));               
                for(var j in jsonForPdf){                   
                    countOrder=countOrder+1;
                    pdfString+="<tr><td>"+j+" : "+jsonForPdf[j]+"</td></tr>";    
                    pdfString=pdfString.replace("null","");
                    
                }
                if(countOrder%2!=0)
                {
                    pdfString+="<tr><td></td></tr>";  
                }
                pdfString+="</tbody ></table><br/>";
                console.log('PDF STRING '+pdfString);
                console.log('PDF STRING '+pdfName);                
                var generatePdfAction=component.get("c.generatePdf");
                generatePdfAction.setParams({
                    "labOrderJSON":pdfString
                    ,"DisId":pdfName})                
                generatePdfAction.setCallback(this,function(resp){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Notification!",
                        "type": 'info',
                        "message": 'YOUR PDF IS BEING DOWNLOADED!'
                    });
                    toastEvent.fire();
                    alert('Id '+JSON.stringify(resp.getReturnValue()));
                    var link=window.location.href;
                    //	alert('link '+link);
                    link=link.substring(0,link.indexOf("one/"));
                    link+="sfc/servlet.shepherd/version/download/"+resp.getReturnValue();
                    component.set("v.contentDocId",resp.getReturnValue());
                    window.open(link,"_blank"); 
                    //delete
                    var action2 = component.get("c.deleteDocument");
                    action2.setParams({ "contId" : component.get("v.contentDocId")});
                    action2.setCallback(this, function(response1){
                        var state = response1.getState();
                        if (state === "SUCCESS"){
                            component.set("v.isOpen", false);
                            
                        }
                        else if(state === "ERROR"){                                  
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    console.log("Error message for deleting content version : " +
                                                errors[0].message);
                                }
                            } else {
                                console.log("Unknown error");
                            }
                            
                            
                        }
                        
                    });
                    $A.enqueueAction(action2);
                    
                });
                $A.enqueueAction(generatePdfAction);
                
            }
            
        });
        $A.enqueueAction(action); 
        // component.set("v.isOpen", false);
        
    },
    
    
    saveAfterEdit: function(component, event, helper) {
        
        var valid = true;
        valid = helper.helperMethod(component , valid);
        var isValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            console.log(validSoFar);
            console.log('s',inputCmp.get('v.validity').valid);
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true); 
        
        var action = component.get("c.saveRecordAfterEdit");            
        var newProcRec = component.get("v.ProcReqToSave").UASampleDetails;
        
        console.log('wfh '+JSON.stringify(component.get("v.ProcReqToSave").UASampleDetails));
        if(isValid == true && valid== true){
            var procedureEndCmp = component.find("procedure-end_time");
            var endProcedureTime = procedureEndCmp.get('v.value');
            if(endProcedureTime == null){
                component.set("v.showConfirmDialog", true);
                return;
            }else{
                action.setParams({               
                    "procReq": newProcRec,
                    // "NecessityDetails": necessityDes,
                    "acct": component.get("v.recordValue"),
                    "starttimeProcedure" : component.get('v.todayString'),
                    "endtimeProcedure" : component.get('v.endString'),
                    "attachId": component.get("v.attachId1"),
                    "commentSign": component.get("v.signComment1"),
                    "signedDate": component.get("v.dateTodayForForm1"),
                    "LabOrderID": component.get("v.recordValue"),
                    "orderByID" : newProcRec.ElixirSuite__Order_By__r.Id
                });
                action.setCallback(this, function(response) {                    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
                        appEvent.setParams({
                            "screenType" : "LabTest",
                            "action" : "Edit",
                            "recordIds" : [response.getReturnValue().Id] });
                        appEvent.fire();
                        console.log('wfh '+JSON.stringify(response.getReturnValue()));                       
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "Success",
                            "title": "PROCEDURE REQUEST UPDATED SUCCESSFULLY!",
                            "message": "Updation Successfull!"
                        });
                        toastEvent.fire(); 
                        
                        component.set("v.isOpen", false);
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
                        var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
                        appEvent.setParams({
                            "screenType" : "LabTest",
                            "action" : "Edit",
                            "button" : "Cancel",
                            "recordIds" : [response.getReturnValue().Id] });
                        appEvent.fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "title": "PROCEDURE REQUEST UPDATION FAILED!",
                            "message": "Failed!"
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(action); 
            }
            
        }
        
    },
    handleEditRecord :  function(component) {
        var getStatus = component.get("v.ProcReqToSave.ElixirSuite__Status__c");
        if(getStatus=='Approved'){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "info",
                "title": "CANNOT EDIT LAB ORDER AFTER IT HAS BEEN APPROVED!",
                "message": "Lab Order is in Approved state!"
            });
            toastEvent.fire();
            
        }
        else {
            component.set("v.viewflag",false);
            component.set("v.isEnabledEditButton",false);
        }
    },
    
    parentComponentEvent : function(component , event){
        console.log('att id' , event.getParam("dateToday"));
        var attId = event.getParam("attachementId"); 
        var commentSign = event.getParam("signComment");
        var dateToday = event.getParam("dateToday");
        component.set("v.signComment1" , commentSign);
        component.set("v.attachId1" , '/servlet/servlet.FileDownload?file='+attId);
        component.set("v.url" , '/servlet/servlet.FileDownload?file='+attId);
        component.set("v.dateTodayForForm1" ,  dateToday );
        console.log('kk'+component.get("v.attachId1"));
        component.set("v.showSign",false);
    },
    
    showVerifyOtp :  function(component){
        
        console.log("dfghjk" ,component.get("v.passcode"));
        if( $A.util.isUndefinedOrNull(component.get("v.passcode")) ){
            alert('You do not have the appropriate access, please contact your administrator');
        }
        else{
            
            component.set("v.showSign",false);
            component.set("v.verifyOtp",true);
        }
        
        
    },
    SaveSign :  function(component){	
        var action = component.get("c.saveSign");	
        action.setParams({               	
            "attachId": component.get("v.attachId1"),	
            "commentSign": component.get("v.signComment1"),	
            "signedDate": component.get("v.dateTodayForForm1"),	
            "LabOrderID": component.get("v.recordValue")	
        });	
        action.setCallback(this, function(response) {                    	
            var state = response.getState();	
            if (state === "SUCCESS") {                 	
                var toastEvent = $A.get("e.force:showToast");	
                toastEvent.setParams({	
                    "type": "Success",	
                    "title": "APPROVED SUCCESSFULLY!",	
                    "message": "Approval Successfull!"	
                });	
                toastEvent.fire(); 	
                component.set("v.isOpen", false);	
                $A.get('e.force:refreshView').fire();	
            }  	
        });	
        $A.enqueueAction(action);	
    },
    
    
    
})