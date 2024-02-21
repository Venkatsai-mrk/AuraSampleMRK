({
    doInit: function(component, event, helper) {
        
        var action3 = component.get('c.LicensBasdPermission');
        action3.setParams({
        });
        
        action3.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var wrapList = response.getReturnValue();
                component.set("v.Ehr",wrapList.isEhr);
                component.set("v.Billing",wrapList.isRcm);
                component.set("v.ContactCentr",wrapList.isContactCenter);
            }
        });
        
        var recordId=component.get('v.recordId');
        var action = component.get("c.FetchOppdataForPayment");
        var listOfFields=[];
        action.setParams ({opid : recordId});
        
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==="ERROR"){
                if(component.get("v.ContactCentr") == true)
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "Error",
                        "title": "Error!",
                        "message": "For Sober Living Level of Care, the Payment Schedule can not be Generated"
                        
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire(); 
                }
                
              }
            if(state==="SUCCESS"){
            var data=response.getReturnValue();
           // product total--Initial Agreement Amount
            console.log('data'+JSON.stringify(data));
            
            if($A.util.isEmpty(data[0].ElixirSuite__Initial_Agreement_Amount__c)||$A.util.isEmpty(data[0].ElixirSuite__Instalments_by_Frequency__c)||$A.util.isEmpty(data[0].ElixirSuite__Payment_frequency__c)){
                if(component.get("v.ContactCentr") == true)
                {
                    var close=$A.get("e.force:closeQuickAction");
                    close.fire();
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "Error",
                        "title": "Problem Occured!",
                        "message": "Please check Initial Aggreement Amount, installment amount and frequency."
                    });
                    toastEvent.fire();
                }
                
                
            }
            var totalPlanAmount;
                if(!$A.util.isUndefinedOrNull(data[0].ElixirSuite__Initial_Amount_collected_by_admissions__c)){
                    totalPlanAmount=data[0].ElixirSuite__Initial_Agreement_Amount__c-data[0].ElixirSuite__Initial_Amount_collected_by_admissions__c;
                }else{
                    totalPlanAmount=data[0].ElixirSuite__Initial_Agreement_Amount__c;
                }
            
            var iteration=totalPlanAmount % data[0].ElixirSuite__Instalments_by_Frequency__c;
            var iteration1=totalPlanAmount / data[0].ElixirSuite__Instalments_by_Frequency__c;
            var noofRows;
            var moneyResidue;
            if(iteration==0){
                noofRows=iteration1;
            }
            else{
                noofRows=iteration1;
            }
            if(iteration1<=0){
                 $A.get("e.force:closeQuickAction").fire();  
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "Error",
                    "title": "Problem Occured!",
                    "message": "Please add Product and fill installment amount."
                });
                toastEvent.fire();
            }
            else{           
                console.log('data[0].Payment_Date__c'+JSON.stringify(data[0].ElixirSuite__Payment_Date__c));
                var update=$A.localizationService.formatDate(data[0].ElixirSuite__Payment_Date__c, "MM/DD/YYYY");
                  //prachi.....handle this scenario
                try{
                 if(data[0].ElixirSuite__Initial_Amount_collected_by_admissions__c!=0){
                        var rec = {'LOC' : data[0].ElixirSuite__LOC__c,
                               'instAmt': data[0].ElixirSuite__Initial_Amount_collected_by_admissions__c,
                               'DD' :'',
                               'Active' : 'Paid',
                               'BalAmt' :0,
                                   'Des':'Upfront Collected By Admission'
                              };
                    
                                        listOfFields.push(rec); 
                    }
                }catch(err){
                    
                }
                console.log('list'+JSON.stringify(listOfFields));
                for(var i=1;i<=noofRows;i+=1){
                    var dateForUse;
                    
                   
                    if(data[0].ElixirSuite__Payment_frequency__c=='Daily'){
                        dateForUse =new Date(new Date().getTime()+(i*24*60*60*1000));
                        
                        
                        
                    }
                    if(data[0].ElixirSuite__Payment_frequency__c=='weekly'){
                        dateForUse =new Date(new Date().getTime()+(7*i*24*60*60*1000));
                        console.log('hii'+dateForUse);
                        
                    }
                    if(data[0].ElixirSuite__Payment_frequency__c=='Monthly'){
                        dateForUse =new Date(new Date().getTime()+(30*i*24*60*60*1000));
                        
                    }
                    console.log('dateForUse'+dateForUse);
                    var update=$A.localizationService.formatDate(dateForUse, "MM/DD/YYYY");
                    console.log('prachidate'+JSON.stringify(update));
                    var rec = {'LOC' : data[0].ElixirSuite__LOC__c,
                               'instAmt': data[0].ElixirSuite__Instalments_by_Frequency__c,
                               'DD' : update,
                               'Active' : 'Active',
                               'BalAmt' : data[0].ElixirSuite__Instalments_by_Frequency__c,
                               'Des':'N/A'
                              };
                    
                    //var items={Duedate, date};
                    listOfFields.push(rec); 
                    
                }
                if(totalPlanAmount % data[0].ElixirSuite__Instalments_by_Frequency__c!=0){
                    var duration=Math.ceil(iteration1);
                    if(data[0].ElixirSuite__Payment_frequency__c=='Daily'){
                        dateForUse =new Date(new Date().getTime()+(duration*24*60*60*1000));
                        
                    }
                    if(data[0].ElixirSuite__Payment_frequency__c=='weekly'){
                        dateForUse =new Date(new Date().getTime()+(7*duration*24*60*60*1000));
                        
                    }
                    if(data[0].ElixirSuite__Payment_frequency__c=='Monthly'){
                        dateForUse =new Date(new Date().getTime()+(30*duration*24*60*60*1000));
                        
                    }
                    var update=$A.localizationService.formatDate(dateForUse, "MM/DD/YYYY");
                    moneyResidue=totalPlanAmount-Math.floor(iteration1)*data[0].ElixirSuite__Instalments_by_Frequency__c;
                    
                    var rec1 = {'LOC' : data[0].ElixirSuite__LOC__c,
                                'instAmt': moneyResidue,
                                'DD' : update,
                                'Active' : 'Active',
                                'BalAmt' : moneyResidue,
                                'Des':'N/A'
                               };
                    listOfFields.push(rec1);}
                
            }
            console.log('iteration '+iteration1);
            console.log('iteration '+JSON.stringify(listOfFields));
            component.set("v.PayList",listOfFields);
            console.log('response'+response.getReturnValue);
                        } 
        });
        
        $A.enqueueAction(action3);
        $A.enqueueAction(action);
    },
    
    
    FreezeAction : function(component, event, helper) {
        
        component.set('v.Spinner',true);
        var recordId=component.get('v.recordId');
        console.log('id'+recordId);
        
        var action=component.get("c.InsertRecordFromOppCreatePayment");
        action.setParams ({ids : recordId});
        
        action.setCallback(component,function(response){
            
            var state=response.getState();
            
            if(state=='SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "Success",
                    "title": "Success!",
                    "message": "Payment Schedule created successfully."
                    
                });
                toastEvent.fire();
              component.set('v.Spinner',false);
            }
            else{
                console.log('error state');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "Warning",
                    "title": "Warning!",
                    "message": "Payment Is Allready Scheduled for this patient!."
                    
                });
                toastEvent.fire();
               component.set('v.Spinner',false);
            }
            $A.get("e.force:closeQuickAction").fire(); 
            $A.get('e.force:refreshView').fire();
            
        });
        $A.enqueueAction(action);
    },
    Cancel : function(component,event,helper){
        
        $A.get("e.force:closeQuickAction").fire();         
    }
})