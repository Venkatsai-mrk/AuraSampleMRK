({
    //fetch category information
    doInit : function(component, event, helper) {   
        component.set("v.loaded",false); 
        
        var action = component.get("c.fetchCategory"); 
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                try{
                  
                    component.set("v.customCategory",data);
                    console.log('category values' +component.get("v.customCategory")); 
                    helper.myAction(component, event, helper); 
                }
                catch(e){
                    alert(e);
                }
            }
            
        });
        
        $A.enqueueAction(action);     
    },
    handleSendForms: function(component, event, helper) {
        // alert(typeof(event.getParam('value')));
        let options = component.get("v.options");
        let arr = [];
        for(let rec in options){
            if(options[rec].checked){
                arr.push(options[rec].label);
            }
        }
        component.set("v.formsToSendForPortal",arr);
      //  component.set("v.formsToSendForPortal",event.getParam('value'));
        console.log('selected forms '+JSON.stringify( component.get("v.formsToSendForPortal")));
    },
    
    
    handleChange: function(component, event, helper) {
        
        component.set("v.RecordId",event.getParam("value"));
        //component.set("v.formName",event.getParam("label"));
        console.log('label value >'+event.getSource().get("v.name"));
        console.log('HANDLE CHANGE>'+event.getSource().get("v.value"));
        //  alert('meg' + component.get("v."))
    },
    navigateToSpecificForm : function(component, event, helper) {
        // alert(component.get("v.RecordId"));
        if(component.get("v.RecordId") == undefined){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Notification!",
                "type": 'info',
                "message": 'PLEASE SELECT FORM TYPE!'
            });
            toastEvent.fire();
            
        }
        else {
            console.log('isActual '+component.get("v.isActualNotes"));
            component.set("v.openForm",true);
            
        }        
        
    },
    
    closeModal : function(component, event, helper) {
        console.log('inside close modal');
        component.set("v.forPatientPortal",false);
        component.set("v.isOpen",false);
        if(component.get("v.isActualNotes")){
            component.set("v.customCategory",[]); 
        }
         $A.get('e.force:refreshView').fire();
    },
    searchKeyChange: function(component, event,helper) {
        //debugger;
        component.set("v.notFound",false);
        component.set("v.searchKey",component.find("searchKey").get("v.value"));
        var searchKey = component.get("v.searchKey");
        /***************/
        var existingList =   component.get("v.optionsForSearching");
        
        
        var fillData = existingList.filter(function(dat) {
            return (dat['label'].toLowerCase()).startsWith(searchKey.toLowerCase());
        });
        component.set("v.options",fillData);
        /***************/
        /* console.log('typed keyword '+searchKey );
        console.log('searchKey:::::'+searchKey +' category '+component.get("v.Category"));
        var action = component.get("c.getSearchForms");
        action.setParams({
            "searchKey": searchKey,
            "category": component.get("v.Category"),
            "categorized" : component.get("v.categorized")
        });
        action.setCallback(this, function(a) {
            
            var allData =  a.getReturnValue();
            if(allData.length == 0){
                component.set("v.notFound",true);
            }
            console.log('123 '+allData);
            var b = [];
            for (var i = 0; i < allData.length; i++) {
                console.log('inside for' +b);
                b[i] = {
                    'label': allData[i],
                    'value': allData[i]
                };     
            }
            console.log('response + data  bee  '+JSON.stringify(b));       
            component.set("v.options", b);          
        });
        $A.enqueueAction(action);*/
    },
    onChange: function (cmp, evt, helper) {
        // alert(cmp.find('select').get('v.value') + ' pie is good.');
        var action = cmp.get("c.filterForms");
        cmp.set("v.searchKey",'');
        var categoryCustom = cmp.get("v.customCategoryResults");
        
        
        action.setParams({
            "category": cmp.find('select').get('v.value')
        });
        console.log('value '+cmp.find('select').get('v.value'));
        action.setCallback(this, function(a) {
            
            var allData=  a.getReturnValue();
            console.log('123 '+allData);
            var b = [];
            for (var i = 0; i < allData.length; i++) {
                console.log('inside for' +b);
                b[i] = {
                    'label': allData[i],
                    'value': allData[i]
                };                
            }
            console.log('response + data  bee  '+JSON.stringify(b));       
            cmp.set("v.options", b);
            cmp.set("v.optionsForSearching", JSON.parse(JSON.stringify(b)));
            if(!cmp.find('select').get('v.value')){
                if(categoryCustom.length>0){
                    cmp.set("v.options", cmp.get("v.customCategoryResults"));
                }
            }
            
        });
        $A.enqueueAction(action);
        
    },
        sendToPatientPortal: function (cmp, event, helper) {
        console.log('response + data  bee  ' + JSON.stringify(cmp.get("v.patientID")));
        console.log('response + data  bee  ' + JSON.stringify(cmp.get("v.formsToSendForPortal")));
    
        if ($A.util.isEmpty(cmp.get("v.formsToSendForPortal"))) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "PLEASE SELECT A FORM TO PROCEED!",
                "type": "error",
                "message": " "
            });
            toastEvent.fire();
        } else {
            var action = cmp.get("c.checkExistingForm");
            action.setParams({
                "formsToSendOnPortal": cmp.get("v.formsToSendForPortal"),
                "accountId": cmp.get("v.patientID")
            });
    
            action.setCallback(this, function (a) {
                var state = a.getState();
                if (state === "SUCCESS") {
                    var result = a.getReturnValue();
                    if (result !== '') {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "ERROR",
                            "type": "error",
                            "message": "Form(s) already sent to the patient. Please wait for the patient to complete the form or delete the sent form and send a new one"
                        });
                        toastEvent.fire();
                    } else {
                        // Continue with sending forms to the patient
                        helper.sendFormsToPatientPortal(cmp);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    }

})