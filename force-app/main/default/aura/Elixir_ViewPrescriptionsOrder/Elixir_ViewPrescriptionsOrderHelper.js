({
    validityProcedure : function(component , valid) {
        var procedureStartCmp = component.find("procedure-start_time");
        var strtProcedureTime = procedureStartCmp.get('v.value');
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get('v.value');
        //
        if(!($A.util.isUndefinedOrNull(strtProcedureTime)))
        {
            var today = new Date();
            var dte = new Date(strtProcedureTime);
            var endte = new Date(endProcedureTime);
            
            dte.setHours(dte.getHours(),dte.getMinutes(),0,0);
            endte.setHours(endte.getHours(),endte.getMinutes(),0,0);
            today.setHours(today.getHours(),today.getMinutes(),0,0);
            
            
            if((endte.setDate(endte.getDate()) > today))
            {
                procedureEndCmp.setCustomValidity("End Time cannot be greater than the Current Time.");
                procedureEndCmp.reportValidity();
                valid = false;
            }
            else
            {
                procedureEndCmp.setCustomValidity("");
                procedureEndCmp.reportValidity();
            }
            
            if((dte.setDate(dte.getDate()) >today))
            {
                procedureStartCmp.setCustomValidity("Start Time cannot be greater than the Current Time.");
                procedureStartCmp.reportValidity();
                valid = false;
                console.log('ss');
            }
            else 
            {
                procedureStartCmp.setCustomValidity("");
                procedureStartCmp.reportValidity();
                
            }
        }
        else if($A.util.isUndefinedOrNull(endProcedureTime))
        {
            valid = false;
            procedureEndCmp.setCustomValidity("Complete this field");
            procedureEndCmp.reportValidity();
        }
        return valid;
    },
    helperMethod : function(component) {
        
        var action = component.get("c.getCode");
        action.setParams({  
            accId : component.get("v.recordId")
        });
        action1.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var code = response.getReturnValue(); 
                alert(code);
                
                
                component.set("v.passcode", code); 
            }
            else{
                Console.log('failure');
            }                           
        });
        $A.enqueueAction(action);
    },
    DelSelectedRec : function(component, event) {
        debugger;
        var selectedMenuItemValue = event.getParam("value");
        let orderToDel =  component.get("v.orderToDelLst");
        orderToDel.push(selectedMenuItemValue);
        component.set("v.orderToDelLst",orderToDel);
        var action = component.get("c.kkk");
        action.setParams({  
            medicationID : selectedMenuItemValue
        });
        action.setCallback(this, function(response){});
        console.log('selctedMenuitem '+selectedMenuItemValue);
        console.log('OrderList  '+JSON.stringify(component.get("v.OrderList")));
        let OrderList = component.get("v.OrderList");
        for(let rec in OrderList){
            if(OrderList[rec].Id == selectedMenuItemValue){
                OrderList.splice(rec,1);
                break;
            }
        }
        component.set("v.OrderList", OrderList); 
        //  $A.enqueueAction(action);
        var nameSpace = 'ElixirSuite__';
        /*   var action1 = component.get("c.getOrder");
       action1.setParams({  
           OrderId : component.get("v.OrderID")
       });
       action1.setCallback(this, function(response){
           var state = response.getState();
           if (state === "SUCCESS") { 
               var nameSpace = component.get("v.orgWideValidNamespace");
               var OrderData = response.getReturnValue().listOfRecords; 
               console.log('hey '+JSON.stringify(OrderData));
               for(var name in OrderData){
                console.log('tt',OrderData[name][nameSpace+'Type__c']);
                   if(OrderData[name][nameSpace+'Type__c'] == 'PRN'){
                       component.set("v.PRNvalue",true);
                   }
                   else if(OrderData[name][nameSpace+'Type__c'] == 'Taper'){
                       component.set("v.Tapersvalue",true);
                      
                   }
                   
                       else if(OrderData[name][nameSpace+'Type__c'] == 'Action Order'){
                           component.set("v.Actionvalue",true);
                       }
               }
               component.set("v.OrderList", OrderData); 
           }
           else{
               Console.log('failure');
           }                           
       });
       $A.enqueueAction(action1);*/
        /*   var SelRec= component.get("v.SelectedRecords");
        var screenData =component.get("v.MaintainOrderList");
        var Sdata = screenData.filter(function( element ) {
            return element !== undefined;
        });
        if(Sdata != null){
            for(var l in Sdata){
                SelRec.push(Sdata[l]);
            } 
        } 
        var orderDatalist=[]; 
        
        for(var i in SelRec){
            orderDatalist.push(SelRec[i]);
        }
        var filtered = orderDatalist.filter(function (el) {
            return el != null;
        });
        alert('orderDatalist'+JSON.stringify(orderDatalist));
        for(var k in filtered){
            if(filtered[k]['Id'] != null){
                OrderData.push(filtered[k]);
            }
        }
         component.set("v.OrderList", OrderData); */
    },
    arrangeAuraIfFForEntities : function(component, event, helper,OrderData) {
        var nameSpace = 'ElixirSuite__';
        for(var name in OrderData){            
            if(OrderData[name][nameSpace+'Type__c'] == 'PRN'){
                component.set("v.PRNvalue",true);
                break;
            }
            else {
                component.set("v.PRNvalue",false);                  
            }            
        }
        
        for(var name in OrderData){            
            if(OrderData[name][nameSpace+'Type__c'] == 'Taper'){
                component.set("v.Tapersvalue",true);
                break;
            }
            else {
                component.set("v.Tapersvalue",false);                  
            }            
        }
        
        for(var name in OrderData){            
            if(OrderData[name][nameSpace+'Type__c'] == 'Action Order'){
                component.set("v.Actionvalue",true);
                break;
            }
            else {
                component.set("v.Actionvalue",false);                  
            }            
        }
    },
    AddSelectedRec : function(component) {
        //  alert('here ');
        var nameSpace = 'ElixirSuite__';
        var OrderDatalist = component.get("v.OrderList");
        var forSavingRec  = component.get("v.jsonList");
        var SelRec= component.get("v.SelectedRecords");
        //alert('hie '+SelRec);
        //  let arr =   component.get("v.jsonList"); // xxx
        for(var i in SelRec){
            OrderDatalist.push(SelRec[i]);
            //  arr.push(SelRec[i]);
            // forSavingRec.push(SelRec[i]);
        } 
        //   component.set("v.jsonList",arr); // xxx
        for(var name in OrderDatalist){
            
            if(OrderDatalist[name][nameSpace+'Type__c'] == 'PRN'){
                component.set("v.PRNvalue",true);
            }
            else if(OrderDatalist[name][nameSpace+'Type__c'] == 'Taper'){
                component.set("v.Tapersvalue",true);
            }
            
                else if(OrderDatalist[name][nameSpace+'Type__c'] == 'Action Order'){
                    component.set("v.Actionvalue",true);
                }
        }
        component.set("v.OrderList", OrderDatalist);  
        /*var cmpEvent = component.getEvent("getToUpdateList"); 
           
            cmpEvent.fire();*/
        //  component.set("v.jsonList", forSavingRec);
        // alert('here 2');
        console.log('kishan '+JSON.stringify(OrderDatalist));
    },
    init : function(component) {
        //getNameSPace 
        var nameSpace = 'ElixirSuite__';
        //component.set("v.nameSpace",nameSpace);
        console.log('selectedRec'+JSON.stringify(component.get("v.OrderList")));
        var records=[];
        records.push(component.get("v.OrderList"));
        //var jsonListName = [];
        //var usersList = [];
        //var jMap = {};
        
        
        //var keys = []; 
        var keyList = [];
        keyList.push(component.get("v.recordId"));
        console.log(JSON.stringify(keyList));
        
        var jsonInside = {};
        var newFilter ={};
        var jsonList = [];
        var jsonInsideList = [];
        var finalKeys =[];
        var totalDays= [];
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        
        today = yyyy +'-'+ mm +'-' + dd ;
        for(var key in records){
            finalKeys.push(records[key]['Id']);
            totalDays.push(records[key]['ElixirSuite__DosageInstructions__r'].length);
        }
        console.log('totalDays length '+JSON.stringify(totalDays));
        for(var key in finalKeys){                    
            if( records[key][nameSpace+'Type__c'] =='Taper'){
                jsonInsideList = [];                    
                console.log(key);
                
                for(var i=1 ;i<=totalDays[key]; i++){
                    jsonInside = {};  
                    var tempVar = records[key]["ElixirSuite__DosageInstructions__r"][i-1];
                    console.log(JSON.stringify(tempVar));
                    var string ;
                    var timeList = [];
                    var strengthList = [];
                    var unitsList = [];
                    var dosageList = [];
                    var message;
                    var countOfRepeat=0;
                    var z=1;
                    for(z=1;z<=24;z++){
                        string = nameSpace+'Strength_'+z+'__c';
                        console.log('string '+string);                    
                        if(!$A.util.isEmpty(tempVar[string]) || !$A.util.isUndefinedOrNull(tempVar[string])){
                            countOfRepeat++;
                            console.log(z);
                        }
                    }
                    console.log('countOfrepeat '+countOfRepeat);
                    console.log(JSON.stringify(tempVar));
                    var strength;
                    var units;
                    var startTime;
                    var dosage;
                    var c=1;
                    for(c=1;c<=countOfRepeat;c++){
                        strength = nameSpace+'Strength_'+c+'__c';
                        units = nameSpace+'Unit_'+c+'__c';
                        startTime = nameSpace+'Start_Time_'+c+'__c';
                        dosage = nameSpace+'Quantity_'+c+'__c';
                        
                        var milliseconds = parseInt((tempVar[startTime] % 1000) / 100),
                            seconds = Math.floor((tempVar[startTime] / 1000) % 60),
                            minutes = Math.floor((tempVar[startTime] / (1000 * 60)) % 60),
                            hours = Math.floor((tempVar[startTime] / (1000 * 60 * 60)) % 24);
                        
                        hours = (hours < 10) ? "0" + hours : hours;
                        minutes = (minutes < 10) ? "0" + minutes : minutes;
                        seconds = (seconds < 10) ? "0" + seconds : seconds;
                        console.log('the time is' , hours + ":" + minutes );
                        var newTime =  hours + ":" + minutes ;
                        
                        timeList.push(newTime);
                        console.log(JSON.stringify(timeList));
                        strengthList.push(tempVar[strength]);
                        console.log(JSON.stringify(strengthList));
                        unitsList.push(tempVar[units]);
                        console.log(JSON.stringify(unitsList));
                        dosageList.push(tempVar[dosage]);
                        console.log(JSON.stringify(dosageList));
                        
                    }
                    // for message
                    var messagePre = records[key]['ElixirSuite__DosageInstructions__r'][i-1][nameSpace+"Repeat__c"];
                    var messageSuf = records[key]["ElixirSuite__DosageInstructions__r"][i-1][nameSpace+"Dosage_Instruction__c"];
                    if(messagePre == 'After every '+ '\''+ 'n' +'\''+ ' hours'){
                        message = ' After every ' + messageSuf + ' hours';
                    }else if(messagePre == '\''+'n'+'\''+ ' times a day'){
                        message = ' ' + messageSuf +' times a day' ;
                    }
                        else{
                            message = '';
                        }
                    
                    jsonInside = {	"Id"	: records[key]['ElixirSuite__DosageInstructions__r'][i-1]["Id"],
                                  "times" : timeList,
                                  "Strength" : strengthList,
                                  "Units" : unitsList, 
                                  "Dosage" : dosageList,                                                                                       
                                  "indexOfDay"	: i,
                                  "Repeat": records[key]['ElixirSuite__DosageInstructions__r'][i-1][nameSpace+"Repeat__c"],
                                  "Dosage_Instruction" : records[key]["ElixirSuite__DosageInstructions__r"][i-1][nameSpace+"Dosage_Instruction__c"].toString(),
                                  "textMessage" : message
                                 }  
                    jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
                    
                }
                
                newFilter = {
                    "medicationName" : records[key][nameSpace+'Medication__r.Name'], 
                    "types" : records[key][nameSpace+'Type__c'],
                    "startDate" : today,
                    "dispenseExpectedSupplyDuration" : records[key][nameSpace+'DispenseExpectedSupplyDuration__c'].toString(),
                    "afterDischarge" : records[key][nameSpace+'After_Discharge__c'],
                    "Route" : records[key][nameSpace+"Route_New_1__r.Name"],
                    "Warning"	: records[key][nameSpace+"x"],
                    "dosageForm" : records[key][nameSpace+'Dosage1__r.Name'],
                    "reasonLabel" : records[key][nameSpace+'Reason_new__c'],
                    "accountId" : records[key][nameSpace+'Account__c'],
                    "Days" : JSON.parse(JSON.stringify(jsonInsideList)),
                    
                }
                console.log('Days '+records[key]['ElixirSuite__DispenseExpectedSupplyDuration__c']);
                jsonList.push(newFilter);
            }
            else if(records[key][nameSpace+'Type__c'] =='PRN'){
                jsonInsideList = [];                    
                jsonInside = {};
                
                
                console.log(JSON.stringify(records[key]));
                console.log(JSON.stringify(records[key]["ElixirSuite__DosageInstructions__r"]));
                var tempVar = records[key]["ElixirSuite__DosageInstructions__r"][0];           
                console.log('tempVar '+ JSON.stringify(tempVar));
                // for message
                var messagePre = records[key]['ElixirSuite__DosageInstructions__r'][0][nameSpace+"Repeat__c"];
                var messageSuf = records[key]["ElixirSuite__DosageInstructions__r"][0][nameSpace+"Dosage_Instruction__c"];
                if(messagePre == 'After every '+ '\''+ 'n' +'\''+ ' hours'){
                    message = ' After every ' + messageSuf + ' hours';
                }else if(messagePre == '\''+'n'+'\''+ ' times a day'){
                    message = ' ' +messageSuf +' times a day' ;
                }
                    else{
                        message = '';
                    }
                
                jsonInside = {
                    "Id"   :	tempVar['Id'],
                    "UnitsForPrn" :tempVar['ElixirSuite__DoseQuantityUnit__c'],
                    "StrengthForPrn" : tempVar[nameSpace+'Strength__c'], 
                    "DosageForPrn" : tempVar['ElixirSuite__DoseQuantityValue__c'],
                    "Repeat":tempVar[nameSpace+"Repeat__c"],
                    "Dosage_Instruction" : tempVar[nameSpace+"Dosage_Instruction__c"].toString(),
                    "textMessage"  :  message
                }  
                console.log('Days '+tempVar[nameSpace+"Dosage_Instruction__c"]);
                jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
                
                
                newFilter = {
                    "medicationName" : records[key][nameSpace+'Medication__r.Name'], 
                    "types" : records[key][nameSpace+'Type__c'],
                    "startDate" : today,
                    "dispenseExpectedSupplyDuration" : records[key][nameSpace+'DispenseExpectedSupplyDuration__c'].toString(),
                    "afterDischarge" : records[key][nameSpace+'After_Discharge__c'],
                    "Route" : records[key][nameSpace+"Route_New_1__r.Name"],
                    "Warning"	: records[key][nameSpace+"Warning__c"],
                    "dosageForm" : records[key][nameSpace+'Dosage1__r.Name'],
                    "accountId" : records[key][nameSpace+'Account__c'],
                    "reasonLabel" : records[key][nameSpace+'Reason_new__c'],
                    "singleRecForPrn" : JSON.parse(JSON.stringify(jsonInsideList))
                }
                jsonList.push(newFilter);
                console.log('Days '+records[key]['ElixirSuite__DispenseExpectedSupplyDuration__c']);
            }
                else if( records[key][nameSpace+'Type__c'] =='Action Order'){
                    jsonInsideList = [];                    
                    jsonInside = {};
                    console.log(records[key]["Id"]);
                    var mapId =  records[key]["Id"];
                    
                    console.log(JSON.stringify(records[key]));
                    console.log(JSON.stringify(records[key]["ElixirSuite__DosageInstructions__r"]));
                    var tempVar = records[key]["ElixirSuite__DosageInstructions__r"][0];           
                    console.log('tempVar '+ JSON.stringify(tempVar));
                    // for message
                    var messagePre = records[key]['ElixirSuite__DosageInstructions__r'][0][nameSpace+"Repeat__c"];
                    var messageSuf = records[key]["ElixirSuite__DosageInstructions__r"][0][nameSpace+"Dosage_Instruction__c"];
                    if(messagePre == 'After every '+ '\''+ 'n' +'\''+ ' hours'){
                        message = ' After every ' + messageSuf + ' hours';
                    }else if(messagePre == '\''+'n'+'\''+ ' times a day'){
                        message = ' ' +messageSuf +' times a day' ;
                    }
                        else{
                            message = '';
                        }
                    
                    
                    var tempVar = records[key]["ElixirSuite__DosageInstructions__r"][0];
                    console.log(JSON.stringify(tempVar));
                    var string ;
                    var timeList = [];
                    var strengthList = [];
                    var unitsList = [];
                    var dosageList = [];
                    var message;
                    var countOfRepeat=0;
                    var z=1;
                    for(z=1;z<=24;z++){
                        string = nameSpace+'Start_Time_'+z+'__c';
                        console.log('string '+string);                    
                        if(!$A.util.isEmpty(tempVar[string]) || !$A.util.isUndefinedOrNull(tempVar[string])){
                            countOfRepeat++;
                            
                        }
                    }
                    var milliseconds = parseInt((tempVar[startTime] % 1000) / 100),
                        seconds = Math.floor((tempVar[startTime] / 1000) % 60),
                        minutes = Math.floor((tempVar[startTime] / (1000 * 60)) % 60),
                        hours = Math.floor((tempVar[startTime] / (1000 * 60 * 60)) % 24);
                    for(c=1;c<=countOfRepeat;c++){
                        
                        startTime = nameSpace+'Start_Time_'+c+'__c';
                        
                        var milliseconds = parseInt((tempVar[startTime] % 1000) / 100),
                            seconds = Math.floor((tempVar[startTime] / 1000) % 60),
                            minutes = Math.floor((tempVar[startTime] / (1000 * 60)) % 60),
                            hours = Math.floor((tempVar[startTime] / (1000 * 60 * 60)) % 24);
                        
                        hours = (hours < 10) ? "0" + hours : hours;
                        minutes = (minutes < 10) ? "0" + minutes : minutes;
                        seconds = (seconds < 10) ? "0" + seconds : seconds;
                        console.log('the time is' , hours + ":" + minutes );
                        var newTime =  hours + ":" + minutes ;
                        
                        timeList.push(newTime);
                        
                    }
                    
                    
                    //Check
                    jsonInside = {              
                        "StartTime" : timeList,
                        "Repeat":tempVar[nameSpace+"Repeat__c"],
                        "Dosage_Instruction" : tempVar[nameSpace+"Dosage_Instruction__c"],
                        "textMessage"  :  message
                    }  
                    console.log('Days '+tempVar[nameSpace+"Dosage_Instruction__c"]);
                    jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
                    console.log('erDathvghe');
                    var erDate = new Date();
                    erDate.setDate(erDate.getDate() + parseInt(records[key]['ElixirSuite__DispenseExpectedSupplyDuration__c']));
                    //console.log('erDate'+erDate);
                    var dd = String(erDate.getDate()).padStart(2, '0');
                    var mm = String(erDate.getMonth() + 1).padStart(2, '0'); //January is 0!
                    var yyyy = erDate.getFullYear();
                    
                    erDate = yyyy +'-'+ mm +'-' + dd ;
                    
                    //console.log('yyy'+erDate.toString());
                    newFilter = {"Id" : mapId,
                                 "medicationName" : records[key][nameSpace+'Medication__r.Name'], 
                                 "types" : records[key][nameSpace+'Type__c'],
                                 "startDate" : today,
                                 "dispenseExpectedSupplyDuration" : records[key][nameSpace+'DispenseExpectedSupplyDuration__c'],
                                 "afterDischarge" : records[key][nameSpace+'After_Discharge__c'],     
                                 "dosageForm" : records[key][nameSpace+'Dosage1__r.Name'],
                                 "accountId" : records[key][nameSpace+'Account__c'],                                    
                                 "endDate"	: erDate,
                                 "PRNdisplay": records[key][nameSpace+"PRN__c"],
                                 "MARdisplay" : records[key][nameSpace+"MAR_Display__c"],
                                 "Justification"	: records[key][nameSpace+"Justification__c"],
                                 "singleRecForActionOrder" : JSON.parse(JSON.stringify(jsonInsideList))
                                }
                    jsonList.push(newFilter);
                    //check
                }
        }
        console.log('json '+(JSON.stringify(jsonList)));
        //  component.set("v.accId",records[0]['HealthCloudGA__Account__c']);
        console.log('json '+'1');
        component.set("v.jsonList",jsonList[0]); 
        console.log('json '+'2');
        component.set("v.jsonListCopy",JSON.parse(JSON.stringify(jsonList[0])));
        console.log('json '+'3');
        component.set("v.jsonSize",JSON.parse(JSON.stringify(jsonList[0])));
        console.log('json '+(JSON.stringify(jsonList)));
        //JSON manipulation ends
        
    },
})