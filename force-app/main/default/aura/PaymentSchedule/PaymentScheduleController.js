({
    init: function(component, event, helper) {
        var acctId = component.get("v.recordId");
        
        var action = component.get("c.getOutstanding");
        action.setParams({ accountId :  acctId});        
        action.setCallback(this, function (response){
            
            var state = response.getState(); 
            if (state === "SUCCESS") {  
                var data = response.getReturnValue();
                component.set("v.patientOutstanding" , data.ElixirSuite__Outstanding_Amount__c);
                
            }
        });
        $A.enqueueAction(action);
    },
    
    
    saveSchedule : function(component, event, helper) {
        
        //   component.set('v.Spinner',true);
        var recordId=component.get('v.recordId');
        var schedData = component.get("v.PayList") ; 
        if($A.util.isEmpty(schedData) || $A.util.isUndefined(schedData)){
           var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "Error",
                    "title": "Problem Occured!",
                    "message": "Please create the schedule to proceed."
                });
                toastEvent.fire(); 
        }
        /*  var newList = [];
         for (var i = 0; i < schedData.length; i++) {
            newList.push(schedData);
        }*/
        var scheduleToSave = {'keysToSaveSchedule' : component.get("v.PayList")};
        // alert(component.get("v.PayList"));
        var action=component.get("c.saveData");
        action.setParams ({
            ids : recordId,
            scheduleData : JSON.stringify(scheduleToSave),
            totalPlanAmount : component.get("v.patientResponse") ,
            frequencyRate : component.get("v.frequencyVal"),
            installmentAmt : component.get("v.installAmt"),
            isCheck : component.get("v.scheduleActive")
            
        });
        
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
                component.set("v.isOpen" , false);
                var appEvent = $A.get("e.c:RefreshEstimatesListView");
                appEvent.fire();

                //     component.set('v.Spinner',false);
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "Warning",
                    "title": "Warning!",
                    "message": "Payment Schedule not successful. Please Check the Data."
                    
                });
                toastEvent.fire();
                //  component.set('v.Spinner',false);
            }
            //    $A.get("e.force:closeQuickAction").fire(); 
            //    $A.get('e.force:refreshView').fire();
            
        });
        $A.enqueueAction(action);        
        
    },
    generateSchedule : function(component , event , helper){
        //Change Total amount with Patient Responsibility to check totalPlan Amount
        //Change  Patient Responsibility with Product Total to check totalPlan Amount
        //Subtract initial amount collected by admissions from Products total
         
        component.set("v.disable",false);
		var valOne =  component.get("v.scheduleActive");     
        var Status;
        if(valOne == true)
        {
            Status = 'Active';
        }
        else if(valOne == false)
        {
            Status = 'Inactive';
        }
        var totalPlanAmount= component.get("v.patientResponse") ;
        var totalOut = component.get("v.patientOutstanding") ;
        var installmentAmt1 = component.get("v.installAmt");    
        var freqVal = component.get("v.frequencyVal");
        
        if(!totalPlanAmount)
        {
             var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : "Error",
                "title": "Problem Occured!",
                "message": "Please enter the Patient Responsibility amount."
            });
            toastEvent.fire();
        }
        else
        {
            if(parseInt(totalPlanAmount) > parseInt(totalOut) || (!totalOut))
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "Error",
                    "title": "Problem Occured!",
                    "message": "Patient Responsibility amount cannot be greater than outstanding amount."
                });
                toastEvent.fire();
                
            }
            else if($A.util.isEmpty(installmentAmt1) || $A.util.isEmpty(freqVal))
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "Error",
                        "title": "Problem Occured!",
                        "message": "Please enter all the details."
                    });
                    toastEvent.fire();
                }
                
            else
            {
                 
                component.set("v.isData" , true);
                
                var listOfFields=[];
                var frequencyRate = component.get("v.frequencyVal");
                var installmentAmt = component.get("v.installAmt");
                console.log('a' , totalPlanAmount);
                console.log('b' , frequencyRate);
                console.log('c' , installmentAmt);
                var iteration=totalPlanAmount % component.get("v.installAmt");
                var iteration1=totalPlanAmount / component.get("v.installAmt");
                console.log('d' , iteration);
                console.log('e' , iteration1);
                var noofRows=0.0;
                var moneyResidue;
                if(iteration==0){
                    noofRows=iteration1;
                }
                else{
                    noofRows=Math.floor(iteration1);
                }
                if(iteration1<=0){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "Error",
                        "title": "Problem Occured!",
                        "message": "Please add Product and fill installment amount."
                    });
                    toastEvent.fire();
                }
                else{                   
                    // var update=$A.localizationService.formatDate(data[0].Payment_Date__c, "MM/DD/YYYY");
                    
                    /*   if(totalPlanAmount!=0){
                        var rec = {'LOC' : 'abc',
                               'instAmt': totalPlanAmount,
                                'DD' :update,
                               'Active' : 'Paid',
                               'BalAmt' : totalPlanAmount,
                                   'Des':'Upfront Collected By Admission'
                              };

                    listOfFields.push(rec); 
                    }*/
                var dateForUse;
                console.log('dh678' , noofRows);
               
                    for(var i=1;i<=noofRows;i+=1){
                        
                        if(frequencyRate=='Daily'){
                            dateForUse =new Date(new Date().getTime()+(i*24*60*60*1000));
                            console.log('DFU1' , dateForUse);
                        }
                        if(frequencyRate=='Weekly'){
                            dateForUse =new Date(new Date().getTime()+(7*i*24*60*60*1000));
                            console.log('DFU2' , dateForUse);
                        }
                        if(frequencyRate=='Monthly'){
                            dateForUse =new Date(new Date().getTime()+(30*i*24*60*60*1000));
                            console.log('DFU3' , dateForUse);
                        }
                        if(frequencyRate=='Annually'){
                            dateForUse =new Date(new Date().getTime()+(365*i*24*60*60*1000));
                            console.log('DFU4' , dateForUse);
                        }
                        console.log('dhdjnjf' , dateForUse);
                        var update=$A.localizationService.formatDate(dateForUse, "MM/DD/YYYY");
                        var rec = {
                            'instAmt': installmentAmt,
                            'DD' : update,
                            'Active' : Status,
                            'BalAmt' : installmentAmt,
                            'Des':''
                        };
                        //var items={Duedate, date};
                        listOfFields.push(rec); 
                        console.log('list of values 1st' , listOfFields);
                    }
                if(iteration !=0){
                    var duration=Math.ceil(iteration1);
                    if(frequencyRate=='Daily'){
                        dateForUse =new Date(new Date().getTime()+(duration*24*60*60*1000));
                        
                    }
                    if(frequencyRate=='Weekly'){
                        dateForUse =new Date(new Date().getTime()+(7*duration*24*60*60*1000));
                        
                    }
                    if(frequencyRate=='Monthly'){
                        dateForUse =new Date(new Date().getTime()+(30*duration*24*60*60*1000));
                        
                    }
                    if(frequencyRate=='Annually'){
                        dateForUse =new Date(new Date().getTime()+(365*duration*24*60*60*1000));
                        
                    }
                    var update=$A.localizationService.formatDate(dateForUse, "MM/DD/YYYY");
                    moneyResidue=totalPlanAmount-Math.floor(iteration1)*installmentAmt;

                    var rec1 = {
                        'instAmt': moneyResidue,
                        'DD' : update,
                        'Active' : Status,
                        'BalAmt' : moneyResidue,
                        'Des':''
                    };
                    listOfFields.push(rec1);}
            }
        }
        }
        component.set("v.PayList",listOfFields);
        var schedData = component.get("v.PayList") ; 
        if($A.util.isEmpty(schedData) || $A.util.isUndefined(schedData)){
        component.set("v.disable",false);
        }
        
    },
    getField: function (cmp, evt, helper) {
        
        var freqValue = cmp.find('select1').get('v.value') ;
        cmp.set("v.frequencyVal" , freqValue);
    },
    
    showInfo : function(component, event, helper) {
        patientRes = component.get("v.patientResponse");
        patiReponsibity = 1000;
        if(patientRes > patiReponsibity)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Info',
                message: 'This is an information message.',
                duration:' 5000',
                key: 'info_alt',
                type: 'info',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        
    },
    valueChangeValidation : function(component, event, helper) {
        var inputField = component.find('inputField');
        var value = inputField.get('v.value');
        if(value != 'foo') {
            inputField.set('v.validity', {valid:false, badInput :true});
            inputField.showHelpMessageIfInvalid();
            
        }
    },
    
    onCheck : function (cmp, evt, helper) {
        
        var checkValue = cmp.find('checkbox').get('v.value') ;
        cmp.set("v.scheduleActive" , checkValue);
    },
    Cancel : function(component ,event, helper){
        component.set("v.isOpen" , false);
    }
})