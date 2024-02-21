({
    helperMethod : function() {
        
    },
    sendFormsToPatientPortal :  function(cmp, event, helper) { 
        console.log('response + data  bee  '+JSON.stringify(cmp.get("v.patientID")));   
        console.log('response + data  bee  '+JSON.stringify(cmp.get("v.formsToSendForPortal")));  
     var action = cmp.get("c.sendFormsToPP");
        cmp.set("v.searchKey",'');
        cmp.set("v.loaded",false); 
        action.setParams({
            "formsToSendOnPortal": cmp.get("v.formsToSendForPortal"),
            "accountId" : cmp.get("v.patientID"),
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                cmp.set("v.loaded",true); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                   // "title": "FORMS SEND TO PORTAL SUCCESSFULLY!",
                    "type" : "success",
                    "message": "Selected forms have been sent to the patient"
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                cmp.set("v.isOpen",false);
            }
            });
        $A.enqueueAction(action);
    
    },
    filterByCategoryIfCategoryProvided : function(cmp, event, helper) {   
        var action = cmp.get("c.filterFormsIfUserDefinedCategoryGiven");
        cmp.set("v.searchKey",'');
        action.setParams({
            "category": cmp.get("v.customCategory") 
        });
        
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
            cmp.set("v.customCategoryResults", JSON.parse(JSON.stringify(b)));
            cmp.set("v.optionsForSearching", JSON.parse(JSON.stringify(b)));
            
        });
        $A.enqueueAction(action);
        
    },
    fetchAllSentForms : function(component, event, helper,sreverResp) {  
      
        console.log('sreverResp ' + JSON.stringify(sreverResp));
        var action = component.get("c.bringDataForpatientPortalUser");
        action.setParams({  
            accountId : component.get("v.recordVal"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                try{
                    component.set("v.loaded",true); 
                    var res = response.getReturnValue();
                    let b = [];
                    console.log('res of saved forms ' + JSON.stringify(res));
                    for (var i = 0; i < sreverResp.length; i++) {
                        b[i] = {
                            'label': sreverResp[i],
                            'value': sreverResp[i]
                        };
                        
                    }
                    console.log('sreverResp ' + JSON.stringify(b));		
                    
                    sreverResp = b;
                    for(let rec in sreverResp){
                        for(let savedobj in res){
                            if(sreverResp[rec].label == res[savedobj].formName){
                                
                                sreverResp[rec]['badge'] =  ' Was sent to patient ';
                            }
                        }
                    }
                   
                    let arr = [];
                    for (var i = 0; i < sreverResp.length; i++) {
                        console.log('inside for' +b);
                        arr[i] = {
                            'label': sreverResp[i].label,
                            'value': sreverResp[i].value,
                            'badge' : sreverResp[i].badge,
                            'checked' : false
                        };
                        
                    }
                    console.log('response + data  bee  '+JSON.stringify(arr));       
                    component.set("v.options", arr);
                    component.set("v.optionsForSearching", JSON.parse(JSON.stringify(arr)));
                }
                catch(e){
                    alert(e);
                }
                
                
            }
            else{
                component.find("Id_spinner").set("v.class" , 'slds-show'); 
                console.log("failure");
            }
        });
        $A.enqueueAction(action);
        
    },
    myAction : function(component, event, helper) {   
       
        var action = component.get("c.fetchAllForms");
        
        action.setParams({
            "category": component.get("v.categorized"),
            "subCategory": '',
            "accountId": component.get("v.patientID")
        });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            console.log('response + data  '+JSON.stringify(data));       
            component.set("v.accName",data);
            var res = data.formNames;
            
            
            console.log('accname '+component.get('v.patientID'));
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.fetchAllSentForms(component, event, helper,res);
                
                
            }
            
        });
        
        $A.enqueueAction(action);
        
    },
})