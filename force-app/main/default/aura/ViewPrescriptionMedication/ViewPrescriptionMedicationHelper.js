({
    helperMethod : function(component, event, helper) {
        var jsonListForPRN = [];
        var jsonListForPRN = [];
        var jsonListForTaper = [];
        var jsonListForAOrder = [];
        var nameSpace = 'ElixirSuite__';
        console.log('Child component Json '+JSON.stringify(component.get("v.OrderList")));
        
        var records=[];
        var data=component.get("v.OrderList");
        
        var result = data.filter(o => Object.keys(o).length);
        console.log(result);
        for(var j in data){
            data
            
            if(data[j]['Id'] !=null)
                records.push(data[j]); 
            
            
            
            
            var jsonListName = [];
            var usersList = [];
            var jMap = {};
            
            
            var jsonInside = {};
            var newFilter ={};
            var jsonList = [];
            var jsonInsideList = [];
            var finalKeys =[];
            var totalDays= [];
            var today;
            var todayDate = new Date();
            var dd = String(todayDate.getDate()).padStart(2, '0');
            var mm = String(todayDate.getMonth() + 1).padStart(2, '0'); //January is 0!
            var yyyy = todayDate.getFullYear();
            console.log('today');
            today = yyyy +'-'+ mm +'-' + dd ;
            
            today = yyyy +'-'+ mm +'-' + dd ;
            for(var key in records){
                finalKeys.push(records[key]['Id']);
                totalDays.push(records[key][nameSpace+'Frequency__r'].length);
            }
            records.forEach(item => {
  			item.medicationName1 = item.ElixirSuite__Medication__r.Name;
            item.medicationNameId= item.ElixirSuite__Medication__r.Id;
            item.Route1 = item.ElixirSuite__Route_New_1__r.Name;
            item.RouteId= item.ElixirSuite__Route_New_1__r.Id;
            item.Dosage1 = item.ElixirSuite__Dosage1__r.Name;
            item.DosageId= item.ElixirSuite__Dosage1__r.Id;
			});
           		
            console.log('finalKeys '+finalKeys);
            console.log('totalDays length '+JSON.stringify(totalDays));
            for(var key in finalKeys){                    
                if( records[key][nameSpace+'Type__c'] =='Taper'){
                    
                    jsonInsideList = [];                    
                    console.log(key);
                    console.log(records[key]["Id"]);
                    var mapId =  records[key]["Id"];
                    var numberOfTimesCount = 0;
                    var numberOfTimes =  parseInt(records[key][nameSpace+'Number_of_Times_Days_Weeks__c']);
                    var isExtraChilEvaluated = false ; 
                    for(var i=1 ;i<=totalDays[key]; i++){
                        
                        
                        /*  if(totalDays[key] != records[key][nameSpace+'Number_of_Times_Days_Weeks__c']){
                            	equalChilds = false;	
                       			 }*/
                            jsonInside = {};  
                            var tempVar = records[key][nameSpace + "Frequency__r"][i-1];
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
                            var messageSufCheck = records[key][nameSpace + "Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"];
                            var flagCheck ;
                            if(parseInt(messageSufCheck) != countOfRepeat){
                                flagCheck = true;
                            }
                            if(!$A.util.isUndefinedOrNull(countOfRepeat) && countOfRepeat != 0){
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
                                if(flagCheck){
                                    var getDifference = Math.abs(parseInt(messageSufCheck) - countOfRepeat);
                                    var len  = timeList.length; 
                                    for(var j=1;j<=getDifference ; j++){
                                        timeList.push("00:00");
                                        strengthList.push("5mg");
                                        dosageList.push("1");
                                        unitsList.push("film");
                                    }
                                }
                            }
                            else {
                                var getNumberOfTimes  = parseInt(messageSufCheck);
                                for(var n=1 ; n<=getNumberOfTimes;n++){
                                    timeList.push("00:00"); 
                                    strengthList.push("5mg");
                                    dosageList.push("1");
                                    unitsList.push("film");
                                }
                                
                            }
                            // for message
                            var messagePre = records[key][nameSpace+'Frequency__r'][i-1][nameSpace+"Repeat__c"];
                            var messageSuf = records[key][nameSpace+"Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"];
                            if(messagePre == 'After every '+ '\''+ 'n' +'\''+ ' hours'){
                                message = ' After every ' + messageSuf + ' hours';
                            }else if(messagePre == '\''+'n'+'\''+ ' times a day'){
                                message = ' ' + messageSuf +' times a day' ;
                            }
                                else if($A.util.isUndefinedOrNull(message)){
                                    message = '';
                                }
                            var handleIfRepeatNotValid;
                            var handleIfDosageInstructionNotValid;
                            if($A.util.isUndefinedOrNull(records[key][nameSpace+'Frequency__r'][i-1][nameSpace+"Repeat__c"])){
                                handleIfRepeatNotValid  = '\''+'n'+'\''+ ' times a day';
                            }
                            else {
                                handleIfRepeatNotValid = records[key][nameSpace+'Frequency__r'][i-1][nameSpace+"Repeat__c"];
                            }
                            if($A.util.isUndefinedOrNull(records[key][nameSpace+"Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"])){
                                handleIfDosageInstructionNotValid  = "1" ; 
                                message = "1 times a day"; 
                                timeList.push("00:00"); 
                                strengthList.push("5mg");
                                dosageList.push("1");
                                unitsList.push("film");
                            }
                            else {
                                handleIfDosageInstructionNotValid = records[key][nameSpace+"Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"];
                            }
                            
                           
                            var getRepeatedTimes  = parseInt(records[key][nameSpace+'Number_of_Times_Days_Weeks__c']);
                            var getChildCount = totalDays[key];
                            
                            if(!isExtraChilEvaluated){
                                if(getRepeatedTimes>getChildCount){
                                    var idx =  getRepeatedTimes - getChildCount ;
                                    for(var l=1 ; l<=idx; l ++){
                                        jsonInside = {"times" : timeList,
                                                      "Strength" : strengthList,
                                                      "Units" : unitsList, 
                                                      "Dosage" : dosageList,                                                                                       
                                                      "indexOfDay"	: i,
                                                      "Repeat": handleIfRepeatNotValid,
                                                      "Dosage_Instruction" : handleIfDosageInstructionNotValid,
                                                      "textMessage" : message
                                                     } 
                                        jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
                                        
                                       console.log('json Days'+JSON.parse(JSON.stringify(jsonInsideList)));  
                                    }
                                }
                                isExtraChilEvaluated = true;
                            }
                            var larger  = Math.max(getRepeatedTimes, getChildCount);
                            if(getRepeatedTimes == getChildCount){
                                jsonInside = {"times" : timeList,
                                              "Strength" : strengthList,
                                              "Units" : unitsList, 
                                              "Dosage" : dosageList,                                                                                       
                                              "indexOfDay"	: i,
                                              "Repeat": handleIfRepeatNotValid,
                                              "Dosage_Instruction" : handleIfDosageInstructionNotValid,
                                              "textMessage" : message
                                             } 
                                jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
                                console.log('json Days'+JSON.parse(JSON.stringify(jsonInsideList)));
                            }
                            else {
                                if(numberOfTimesCount < numberOfTimes){
                                    jsonInside = {"times" : timeList,
                                                  "Strength" : strengthList,
                                                  "Units" : unitsList, 
                                                  "Dosage" : dosageList,                                                                                       
                                                  "indexOfDay"	: i,
                                                  "Repeat": handleIfRepeatNotValid,
                                                  "Dosage_Instruction" : handleIfDosageInstructionNotValid,
                                                  "textMessage" : message
                                                 } 
                                    jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
                                    console.log('json Days'+JSON.parse(JSON.stringify(jsonInsideList)));
                                    numberOfTimesCount++;
                                }
                                
                            }
                            
                            
                            
                        }
                        var erDate = todayDate;
                        if($A.util.isUndefinedOrNull(records[key][nameSpace+'Number_of_Times_Days_Weeks__c'])){
                            records[key][nameSpace+'Number_of_Times_Days_Weeks__c'] = 1;
                        }
                        erDate.setDate(erDate.getDate() + parseInt(records[key][nameSpace+'Number_of_Times_Days_Weeks__c']));
                        //console.log('erDate'+erDate);
                        var dd = String(erDate.getDate()).padStart(2, '0');
                        var mm = String(erDate.getMonth() + 1).padStart(2, '0'); //January is 0!
                        var yyyy = erDate.getFullYear();
                        
                        erDate = yyyy +'-'+ mm +'-' + dd ;
                        newFilter = {"Id" : mapId,
                                    "medicationName" : records[key]['medicationName1'],
                                     "medicationId" : records[key]['medicationNameId'], 
                                     "types" : records[key][nameSpace+'Type__c'],
                                     "startDate" : today,
                                     "dispenseExpectedSupplyDuration" : records[key][nameSpace+'Number_of_Times_Days_Weeks__c'],
                                     "afterDischarge" : records[key][nameSpace+'After_Discharge__c'],
                                     "Route" : records[key]['Route1'],
                                     "RouteId" : records[key]['RouteId'],
                                     "Warning"	: records[key][nameSpace+"Warning__c"],
                                     "dosageForm" : records[key]['Dosage1'], 
                                     "dosageFormId" : records[key]['DosageId'],
                                     "reasonLabel" : records[key][nameSpace+'Reason_new__c'],
                                     "accountId" : records[key][nameSpace+'Account__c'],
                                     "endDate"	:  erDate,
                                     "Days" : JSON.parse(JSON.stringify(jsonInsideList)),
                                     
                                    }
                        if(newFilter.medicationName && newFilter.medicationId) {
                            var medicationSelectedRecord = {'label':newFilter.medicationName, 'value':newFilter.medicationId};
                            component.set("v.selectedDrugRecord",medicationSelectedRecord);
                            }
                            if(newFilter.Route && newFilter.RouteId) {
                            var routeSelectedRecord = {'label':newFilter.Route, 'value':newFilter.RouteId};
                            component.set("v.selectedRouteRecord",routeSelectedRecord);
                            }
                            if(newFilter.dosageForm && newFilter.dosageFormId) {
                            var dosageFormSelectedRecord = {'label':newFilter.dosageForm, 'value':newFilter.dosageFormId};
                            component.set("v.selectedDosageRecord",dosageFormSelectedRecord);
                            }
                        jsonList.push(newFilter);
                    }
                      else if(records[key][nameSpace+'Type__c'] =='PRN'){
                          
                          jsonInsideList = [];                    
                          console.log(key);
                          console.log('records[key]["Id"]'+records[key]["Id"]);
                          var mapId =  records[key]["Id"];
                          console.log('medicationName for PRN1 '+records[key][nameSpace+'Medication__c']);
                          console.log('medicationName for PRN2 '+records[key]['medicationName1']);
                          var numberOfTimesCount = 0;
                          var numberOfTimes =  parseInt(records[key][nameSpace+'Number_of_Times_Days_Weeks__c']);
                          var isExtraChilEvaluated = false ; 
                          for(var i=1 ;i<=totalDays[key]; i++){
                              
                              
                              /*  if(totalDays[key] != records[key][nameSpace+'Number_of_Times_Days_Weeks__c']){
                            	equalChilds = false;	
                       			 }*/
                            jsonInside = {};  
                            var tempVar = records[key][nameSpace + "Frequency__r"][i-1];
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
                            var messageSufCheck = records[key][nameSpace + "Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"];
                            var flagCheck ;
                            if(parseInt(messageSufCheck) != countOfRepeat){
                                flagCheck = true;
                            }
                            if(!$A.util.isUndefinedOrNull(countOfRepeat) && countOfRepeat != 0){
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
                                if(flagCheck){
                                    var getDifference = Math.abs(parseInt(messageSufCheck) - countOfRepeat);
                                    var len  = timeList.length; 
                                    for(var j=1;j<=getDifference ; j++){
                                        timeList.push("00:00");
                                        strengthList.push("5mg");
                                        dosageList.push("1");
                                        unitsList.push("film");
                                    }
                                }
                            }
                            else {
                                var getNumberOfTimes  = parseInt(messageSufCheck);
                                for(var n=1 ; n<=getNumberOfTimes;n++){
                                    timeList.push("00:00"); 
                                    strengthList.push("5mg");
                                    dosageList.push("1");
                                    unitsList.push("film");
                                }
                                
                            }
                            // for message
                            var messagePre = records[key][nameSpace+'Frequency__r'][i-1][nameSpace+"Repeat__c"];
                            var messageSuf = records[key][nameSpace+"Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"];
                            if(messagePre == 'After every '+ '\''+ 'n' +'\''+ ' hours'){
                                message = ' After every ' + messageSuf + ' hours';
                            }else if(messagePre == '\''+'n'+'\''+ ' times a day'){
                                message = ' ' + messageSuf +' times a day' ;
                            }
                                else if($A.util.isUndefinedOrNull(message)){
                                    message = '';
                                }
                            var handleIfRepeatNotValid;
                            var handleIfDosageInstructionNotValid;
                            if($A.util.isUndefinedOrNull(records[key][nameSpace+'Frequency__r'][i-1][nameSpace+"Repeat__c"])){
                                handleIfRepeatNotValid  = '\''+'n'+'\''+ ' times a day';
                            }
                            else {
                                handleIfRepeatNotValid = records[key][nameSpace+'Frequency__r'][i-1][nameSpace+"Repeat__c"];
                            }
                            if($A.util.isUndefinedOrNull(records[key][nameSpace+"Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"])){
                                handleIfDosageInstructionNotValid  = "1" ; 
                                message = "1 times a day"; 
                                timeList.push("00:00"); 
                                strengthList.push("5mg");
                                dosageList.push("1");
                                unitsList.push("film");
                            }
                            else {
                                handleIfDosageInstructionNotValid = records[key][nameSpace+"Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"];
                            }
                            
                            /* if($A.util.isUndefinedOrNull(countOfRepeat) || countOfRepeat == 0){
                                 handleIfDosageInstructionNotValid  = "1";
                                message = "1 times a day"; 
                            }*/
                            var getRepeatedTimes  = parseInt(records[key][nameSpace+'Number_of_Times_Days_Weeks__c']);
                            var getChildCount = totalDays[key];
                            
                            if(!isExtraChilEvaluated){
                                if(getRepeatedTimes>getChildCount){
                                    var idx =  getRepeatedTimes - getChildCount ;
                                    for(var l=1 ; l<=idx; l ++){
                                        jsonInside = {"times" : timeList,
                                                      "Strength" : strengthList,
                                                      "Units" : unitsList, 
                                                      "Dosage" : dosageList,                                                                                       
                                                      "indexOfDay"	: i,
                                                      "Repeat": handleIfRepeatNotValid,
                                                      "Dosage_Instruction" : handleIfDosageInstructionNotValid,
                                                      "textMessage" : message
                                                     } 
                                        jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
                                        console.log('json Days'+JSON.stringify(jsonInsideList));
                                    }
                                }
                                isExtraChilEvaluated = true;
                            }
                            var larger  = Math.max(getRepeatedTimes, getChildCount);
                            if(getRepeatedTimes == getChildCount){
                                jsonInside = {"times" : timeList,
                                              "Strength" : strengthList,
                                              "Units" : unitsList, 
                                              "Dosage" : dosageList,                                                                                       
                                              "indexOfDay"	: i,
                                              "Repeat": handleIfRepeatNotValid,
                                              "Dosage_Instruction" : handleIfDosageInstructionNotValid,
                                              "textMessage" : message
                                             } 
                                jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
                                console.log('json Days'+JSON.stringify(jsonInsideList));
                            }
                            else {
                                if(numberOfTimesCount < numberOfTimes){
                                    jsonInside = {"times" : timeList,
                                                  "Strength" : strengthList,
                                                  "Units" : unitsList, 
                                                  "Dosage" : dosageList,                                                                                       
                                                  "indexOfDay"	: i,
                                                  "Repeat": handleIfRepeatNotValid,
                                                  "Dosage_Instruction" : handleIfDosageInstructionNotValid,
                                                  "textMessage" : message
                                                 } 
                                    jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
                                    console.log('json Days'+JSON.stringify(jsonInsideList));
                                    numberOfTimesCount++;
                                }
                                
                            }
                            
                            
                            
                        }
                        var erDate = todayDate;
                        if($A.util.isUndefinedOrNull(records[key][nameSpace+'Number_of_Times_Days_Weeks__c'])){
                            records[key][nameSpace+'Number_of_Times_Days_Weeks__c'] = 1;
                        }
                        erDate.setDate(erDate.getDate() + parseInt(records[key][nameSpace+'Number_of_Times_Days_Weeks__c']));
                        
                        var dd = String(erDate.getDate()).padStart(2, '0');
                        var mm = String(erDate.getMonth() + 1).padStart(2, '0'); //January is 0!
                        var yyyy = erDate.getFullYear();
                        
                        erDate = yyyy +'-'+ mm +'-' + dd ;
                       
                        newFilter = {"Id" : mapId,
                                     "medicationName" : records[key]['medicationName1'],
                                     "medicationId" : records[key]['medicationNameId'],
                                     "types" : records[key][nameSpace+'Type__c'],
                                     "startDate" : today,
                                     "dispenseExpectedSupplyDuration" : records[key][nameSpace+'Number_of_Times_Days_Weeks__c'],
                                     "afterDischarge" : records[key][nameSpace+'After_Discharge__c'],
                                     "Route" : records[key]['Route1'],
                                     "RouteId" : records[key]['RouteId'],
                                     "Warning"	: records[key][nameSpace+"Warning__c"],
                                     "dosageForm" : records[key]['Dosage1'], 
                                     "dosageFormId" : records[key]['DosageId'],
                                     "reasonLabel" : records[key][nameSpace+'Reason_new__c'],
                                     "accountId" : records[key][nameSpace+'Account__c'],
                                     "endDate"	:  erDate,
                                     "Days" : JSON.parse(JSON.stringify(jsonInsideList)),
                                     
                                    }
                        
                          
                        if(newFilter.medicationName && newFilter.medicationId) {
                            var medicationSelectedRecord = {'label':newFilter.medicationName, 'value':newFilter.medicationId};
                            component.set("v.selectedDrugRecord",medicationSelectedRecord);
                            }
                            if(newFilter.Route && newFilter.RouteId) {
                            var routeSelectedRecord = {'label':newFilter.Route, 'value':newFilter.RouteId};
                            component.set("v.selectedRouteRecord",routeSelectedRecord);
                            }
                            if(newFilter.dosageForm && newFilter.dosageFormId) {
                            var dosageFormSelectedRecord = {'label':newFilter.dosageForm, 'value':newFilter.dosageFormId};
                            component.set("v.selectedDosageRecord",dosageFormSelectedRecord);
                            }
                         
                        jsonList.push(newFilter);
                          console.log('jsonList--PRN '+jsonList);
                        
                        
                    }
                      //Action Order
                      
                        else {   
                            jsonInsideList = [];                    
                            console.log(key);
                            console.log(records[key]["Id"]);
                            var mapId =  records[key]["Id"];
                            var numberOfTimesCount = 0;
                            var numberOfTimes =  parseInt(records[key][nameSpace+'Number_of_Times_Days_Weeks__c']);
                            var isExtraChilEvaluated = false ; 
                            for(var i=1 ;i<=totalDays[key]; i++){
                                
                                
                                /*  if(totalDays[key] != records[key][nameSpace+'Number_of_Times_Days_Weeks__c']){
                            	equalChilds = false;	
                       			 }*/
                            jsonInside = {};  
                            var tempVar = records[key][nameSpace + "Frequency__r"][i-1];
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
                            var messageSufCheck = records[key][nameSpace + "Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"];
                            var flagCheck ;
                            if(parseInt(messageSufCheck) != countOfRepeat){
                                flagCheck = true;
                            }
                            if(!$A.util.isUndefinedOrNull(countOfRepeat) && countOfRepeat != 0){
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
                                if(flagCheck){
                                    var getDifference = Math.abs(parseInt(messageSufCheck) - countOfRepeat);
                                    var len  = timeList.length; 
                                    for(var j=1;j<=getDifference ; j++){
                                        timeList.push("00:00");
                                        strengthList.push("5mg");
                                        dosageList.push("1");
                                        unitsList.push("film");
                                    }
                                }
                            }
                            else {
                                var getNumberOfTimes  = parseInt(messageSufCheck);
                                for(var n=1 ; n<=getNumberOfTimes;n++){
                                    timeList.push("00:00"); 
                                    strengthList.push("5mg");
                                    dosageList.push("1");
                                    unitsList.push("film");
                                }
                                
                            }
                            // for message
                            var messagePre = records[key][nameSpace+'Frequency__r'][i-1][nameSpace+"Repeat__c"];
                            var messageSuf = records[key][nameSpace+"Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"];
                            if(messagePre == 'After every '+ '\''+ 'n' +'\''+ ' hours'){
                                message = ' After every ' + messageSuf + ' hours';
                            }else if(messagePre == '\''+'n'+'\''+ ' times a day'){
                                message = ' ' + messageSuf +' times a day' ;
                            }
                                else if($A.util.isUndefinedOrNull(message)){
                                    message = '';
                                }
                            var handleIfRepeatNotValid;
                            var handleIfDosageInstructionNotValid;
                            if($A.util.isUndefinedOrNull(records[key][nameSpace+'Frequency__r'][i-1][nameSpace+"Repeat__c"])){
                                handleIfRepeatNotValid  = '\''+'n'+'\''+ ' times a day';
                            }
                            else {
                                handleIfRepeatNotValid = records[key][nameSpace+'Frequency__r'][i-1][nameSpace+"Repeat__c"];
                            }
                            if($A.util.isUndefinedOrNull(records[key][nameSpace+"Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"])){
                                handleIfDosageInstructionNotValid  = "1" ; 
                                message = "1 times a day"; 
                                timeList.push("00:00"); 
                                strengthList.push("5mg");
                                dosageList.push("1");
                                unitsList.push("film");
                            }
                            else {
                                handleIfDosageInstructionNotValid = records[key][nameSpace+"Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"];
                            }
                            
                            /* if($A.util.isUndefinedOrNull(countOfRepeat) || countOfRepeat == 0){
                                 handleIfDosageInstructionNotValid  = "1";
                                message = "1 times a day"; 
                            }*/
                            var getRepeatedTimes  = parseInt(records[key][nameSpace+'Number_of_Times_Days_Weeks__c']);
                            var getChildCount = totalDays[key];
                            
                            if(!isExtraChilEvaluated){
                                if(getRepeatedTimes>getChildCount){
                                    var idx =  getRepeatedTimes - getChildCount ;
                                    for(var l=1 ; l<=idx; l ++){
                                        jsonInside = {"times" : timeList,
                                                      "Strength" : strengthList,
                                                      "Units" : unitsList, 
                                                      "Dosage" : dosageList,                                                                                       
                                                      "indexOfDay"	: i,
                                                      "Repeat": handleIfRepeatNotValid,
                                                      "Dosage_Instruction" : handleIfDosageInstructionNotValid,
                                                      "textMessage" : message
                                                     } 
                                        jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
                                    }
                                }
                                isExtraChilEvaluated = true;
                            }
                            var larger  = Math.max(getRepeatedTimes, getChildCount);
                            if(getRepeatedTimes == getChildCount){
                                jsonInside = {"times" : timeList,
                                              "Strength" : strengthList,
                                              "Units" : unitsList, 
                                              "Dosage" : dosageList,                                                                                       
                                              "indexOfDay"	: i,
                                              "Repeat": handleIfRepeatNotValid,
                                              "Dosage_Instruction" : handleIfDosageInstructionNotValid,
                                              "textMessage" : message
                                             } 
                                jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
                            }
                            else {
                                if(numberOfTimesCount < numberOfTimes){
                                    jsonInside = {"times" : timeList,
                                                  "Strength" : strengthList,
                                                  "Units" : unitsList, 
                                                  "Dosage" : dosageList,                                                                                       
                                                  "indexOfDay"	: i,
                                                  "Repeat": handleIfRepeatNotValid,
                                                  "Dosage_Instruction" : handleIfDosageInstructionNotValid,
                                                  "textMessage" : message
                                                 } 
                                    jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
                                    numberOfTimesCount++;
                                }
                                
                            }
                            
                            
                            
                        }
                            var erDate = todayDate;
                            if($A.util.isUndefinedOrNull(records[key][nameSpace+'Number_of_Times_Days_Weeks__c'])){
                                records[key][nameSpace+'Number_of_Times_Days_Weeks__c'] = 1;
                            }
                            erDate.setDate(erDate.getDate() + parseInt(records[key][nameSpace+'Number_of_Times_Days_Weeks__c']));
                            //console.log('erDate'+erDate);
                            var dd = String(erDate.getDate()).padStart(2, '0');
                            var mm = String(erDate.getMonth() + 1).padStart(2, '0'); //January is 0!
                            var yyyy = erDate.getFullYear();
                            
                            erDate = yyyy +'-'+ mm +'-' + dd ;
                            var marCheck = records[key][nameSpace+"MAR_display__c"];
                            if(marCheck == null){
                                marCheck = false;
                            }
                              
                            newFilter = {"Id" : mapId,
                                         "medicationName" : records[key]['medicationName1'],
                                     	 "medicationId" : records[key]['medicationNameId'], 
                                         "types" : records[key][nameSpace+'Type__c'],
                                         "startDate" : today,
                                         "dispenseExpectedSupplyDuration" : records[key][nameSpace+'Number_of_Times_Days_Weeks__c'],
                                         "afterDischarge" : records[key][nameSpace+'After_Discharge__c'],
                                         "dosageForm" : records[key]['Dosage1'], 
                                     	 "dosageFormId" : records[key]['DosageId'],
                                         "accountId" : records[key][nameSpace+'Account__c'],  
                                         "PRNdisplay": records[key][nameSpace+"PRN__c"],
                                         "MARdisplay" : marCheck,
                                         "Route" : records[key]['Route1'],
                                         "RouteId" : records[key]['RouteId'],
                                         "Warning"	: records[key][nameSpace+"Warning__c"],
                                         "reasonLabel" : records[key][nameSpace+'Reason_new__c'],
                                         "accountId" : records[key][nameSpace+'Account__c'],
                                         "endDate"	:  erDate,
                                         "Days" : JSON.parse(JSON.stringify(jsonInsideList)),
                                         
                                        }
                             if(newFilter.medicationName && newFilter.medicationId) {
                            var medicationSelectedRecord = {'label':newFilter.medicationName, 'value':newFilter.medicationId};
                            component.set("v.selectedDrugRecord",medicationSelectedRecord);
                            }
                            if(newFilter.Route && newFilter.RouteId) {
                            var routeSelectedRecord = {'label':newFilter.Route, 'value':newFilter.RouteId};
                            component.set("v.selectedRouteRecord",routeSelectedRecord);
                            }
                            if(newFilter.dosageForm && newFilter.dosageFormId) {
                            var dosageFormSelectedRecord = {'label':newFilter.dosageForm, 'value':newFilter.dosageFormId};
                            component.set("v.selectedDosageRecord",dosageFormSelectedRecord);
                            }
                            
                            jsonList.push(newFilter);
                            
                        }       
                      
                      
                  }
           
       }
        
        console.log('json Papa '+(JSON.stringify(jsonList)));
        //  component.set("v.accId",records[0]['HealthCloudGA__Account__c']);
        console.log('json '+'1');
        var arrPRN=[]
        var arrtTaper = [];
        var arrAction = [];
        for(var rec in jsonList){
            if(jsonList[rec].types=='PRN'){
                arrPRN.push(jsonList[rec]);
                
            }
            else if(jsonList[rec].types=='Taper'){
                arrtTaper.push(jsonList[rec]);
            }
                else if(jsonList[rec].types=='Action Order'){
                    arrAction.push(jsonList[rec]);
                }
        }
        component.set("v.Papajson",jsonList); 
        component.set("v.PRN",arrPRN); 
        component.set("v.Taper",arrtTaper); 
        component.set("v.ActionOrder",arrAction); 
        console.log('json prn'+JSON.stringify(arrPRN));
        console.log('json taper'+JSON.stringify(arrtTaper));
        console.log('json Action'+JSON.stringify(arrAction));
        console.log('json '+'2');
        component.set("v.jsonListCopy",JSON.parse(JSON.stringify(jsonList[0])));
        console.log('json '+'3');
        component.set("v.jsonSize",JSON.parse(JSON.stringify(jsonList[0])));
        console.log('json '+(JSON.stringify(jsonList)));
    }
})