({
    init : function(component, event, helper) {
        var today = new Date();
        //    var nameSpace = component.get("v.orgWideValidNamespace");
        var nameSpace = 'ElixirSuite__';
        component.set('v.todayString', today.toISOString());
        helper.fetchUserName(component, event, helper);
       
        
       
    
        
        
        
        
        
        
        
        
        
        console.log('Init '+JSON.stringify(component.get("v.SelectedRecords")));
        //  console.log('path string '+JSON.stringify(component.get("v.RouteForComponent")));
        var listOfRecs = component.get("v.SelectedRecords");
        var jsonListName = [];
        var usersList = [];
        var jMap = {};
        // alert('redd'+JSON.stringify(listOfRecs));
        for(var name in listOfRecs){
            jMap = {
                'medicationName' : listOfRecs[name][nameSpace+'Drug_Name__c']
            }
            console.log(JSON.stringify(listOfRecs[name][nameSpace+'Drug_Name__c']));
            jsonListName.push(jMap);
            
            if(listOfRecs[name][nameSpace+'Type__c'] == 'PRN'){
                component.set("v.PRNvalue",true);
            }
            else if(listOfRecs[name][nameSpace+'Type__c'] == 'Taper'){
                component.set("v.Tapersvalue",true);
            }
            
                else if(listOfRecs[name][nameSpace+'Type__c'] == 'Action Order'){
                    component.set("v.Actionvalue",true);
                }
        }
        // alert('hie '+component.get("v.Tapersvalue"));
        component.set("v.jsonList",jsonListName);
        //alert('Hie '+JSON.stringify(jsonListName));
        var records=[];
        var keys = []; 
        var totalDays = [];
        var selectedRecords = component.get("v.SelectedRecords");
        
        for(var key in selectedRecords){
            keys.push(selectedRecords[key]['Id']);
            
        } 
        console.log(JSON.stringify(keys));
        var action = component.get("c.fetchData");
        component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setParams({ 
            "keys"	: keys
        });
        action.setCallback(this, function(response){
           
            var state = response.getState();
            
            if(state === "SUCCESS"){
                console.log('Success');
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var allFieldList = response.getReturnValue()['picklistValues']; 
                records = response.getReturnValue()['listOfRecs'];
                
                
           
                //  nameSpace = response.getReturnValue().nameSpace;
                var nameSpace = 'ElixirSuite__';
                //console.log('records '+records);
                usersList = response.getReturnValue()['listOfUsers'];
                console.log('records '+JSON.stringify(response.getReturnValue().listOfRecs));
                for(var key in allFieldList){
                    if(key == nameSpace+'Prescription_Order__c'){
                        for(var keyInside in allFieldList[key]){
                            console.log(keyInside);
                            if(keyInside.toUpperCase() == nameSpace.toUpperCase()+'DOSAGE_FORM__C'){
                                component.set("v.dosageFormPicklistValues",allFieldList[key][keyInside]);
                            }
                            if(keyInside.toUpperCase() == nameSpace.toUpperCase()+'TYPE__C'){
                                component.set("v.typePicklistValues",allFieldList[key][keyInside]); 
                            }
                            /* if(keyInside.toUpperCase() == 'DISPENSEEXPECTEDSUPPLYDURATION__C'){
                                component.set("v.DaysPicklistValues",allFieldList[key][keyInside]); 
                            }*/
                            if(keyInside.toUpperCase() == nameSpace.toUpperCase()+'NUMBER_OF_TIMES_DAYS_WEEKS__C'){
                                component.set("v.DaysPicklistValues",allFieldList[key][keyInside]);
                            }
                            if(keyInside.toUpperCase() == nameSpace.toUpperCase()+'ROUTE_NEW__C'){
                                component.set("v.RouteList",allFieldList[key][keyInside]);
                            }
                            if(keyInside.toUpperCase() == nameSpace.toUpperCase()+'ORDERED_VIA__C'){
                                component.set("v.OrderedViaList",allFieldList[key][keyInside]);
                            }
                            
                        }
                        
                    } 
                    if(key == nameSpace+'Frequency__c'){
                        for(var keyInside in allFieldList[key]){
                            //console.log('key1 '+keyInside +allFieldList[key]);
                            if(keyInside.toUpperCase() == nameSpace.toUpperCase()+'REPEAT__C'){
                                console.log('key '+keyInside);
                                component.set("v.RepeatPicklistValues",allFieldList[key][keyInside]);
                                
                            }
                            if(keyInside.toUpperCase() ==  nameSpace.toUpperCase()+'DOSAGE_INSTRUCTION__C'){
                                component.set("v.DosagePicklistValues",allFieldList[key][keyInside]); 
                            }  
                            if(keyInside.toUpperCase() ==  nameSpace.toUpperCase()+'UNIT_1__C'){
                                component.set("v.UnitsValues",allFieldList[key][keyInside]); 
                                //alert(component.set("v.UnitsValues",allFieldList[key][keyInside]));
                            }
                            
                        }
                    }
                }
                
                
                console.log('DosagePicklistValues '+JSON.stringify(component.get("v.DosagePicklistValues")));
                console.log('repeat #456 '+JSON.stringify(component.get("v.RepeatPicklistValues")));
                var jsonInside = {};
                var newFilter ={};
                var jsonList = [];
                var jsonInsideList = [];
                var finalKeys =[];
                var today;
                var todayDate = new Date();
                var dd = String(todayDate.getDate()).padStart(2, '0');
                var mm = String(todayDate.getMonth() + 1).padStart(2, '0'); //January is 0!
                var yyyy = todayDate.getFullYear();
                console.log('today');
                today = yyyy +'-'+ mm +'-' + dd ;
                //console.log("data==",records);
                
                for(var key in records){
                    finalKeys.push(records[key]['Id']);
                    totalDays.push(records[key][nameSpace + 'Frequency__r'].length); 
                    //console.log("v.ownerNameValue",records[key]['Owner']['Name']);
                   
          
                   
                     component.set("v.ownerNameValue",records[key]['Owner']['Name']);
                }
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
                            /*  var toCheck = records[key][nameSpace + "Frequency__r"][i-1][nameSpace+"Repeat__c"];
                            if(toCheck == 'After every '+ '\''+ 'n' +'\''+ ' hours' || toCheck == '\''+'n'+'\''+ ' times a day'){
                                 component.set("v.disabledAfterData",false);
                            }
                            component.set("v.disabledAfterData",false);*/
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
                                // 
                                message = ' After every ' + messageSuf + ' hours';
                            }else if(messagePre == '\''+'n'+'\''+ ' times a day'){
                                //  
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
                        /*if(!equalChilds){
                            jsonInsideList = [];
                            for(var i = 1; i<=records[key][nameSpace+'Number_of_Times_Days_Weeks__c'];i++){
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
                        }*/
                        
                        newFilter = {"Id" : mapId,
                                     "medicationName" : records[key][nameSpace+'Drug_Name__c'], 
                                     "types" : records[key][nameSpace+'Type__c'],
                                     "startDate" : today,
                                     "dispenseExpectedSupplyDuration" : records[key][nameSpace+'Number_of_Times_Days_Weeks__c'],
                                     "afterDischarge" : records[key][nameSpace+'After_Discharge__c'],
                                     "Route" : records[key][nameSpace+"Route_New__c"],
                                     "Warning"	: records[key][nameSpace+"Warning_new__c"],
                                     "dosageForm" : records[key][nameSpace+'Dosage_Form__c'],
                                     "reasonLabel" : records[key][nameSpace+'Reason_new__c'],
                                     "accountId" : records[key][nameSpace+'Account__c'],
                                     "endDate"	:  erDate,
                                     "Days" : JSON.parse(JSON.stringify(jsonInsideList)),
                                     
                                    }
                        // console.log('ROute '+records[key]["endDate"]);
                        jsonList.push(newFilter);
                    }
                    else if(records[key][nameSpace+'Type__c'] =='PRN'){
                        
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
                            var timeString ; 
                            var timeList = [];
                            var strengthList = [];
                            var unitsList = [];
                            var dosageList = [];
                            var message;
                            var countOfRepeat=0;
                            var z=1;
                            for(z=1;z<=24;z++){
                                string = nameSpace+'Strength_'+z+'__c';
                                timeString = nameSpace + 'Start_Time_'+z+'__c';
                                console.log('string '+string);                    
                                if( (!$A.util.isEmpty(tempVar[string]) || !$A.util.isUndefinedOrNull(tempVar[string])) 
                                   && (!$A.util.isEmpty(tempVar[timeString]) || !$A.util.isUndefinedOrNull(tempVar[timeString])) ){
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
                        /*if(!equalChilds){
                            jsonInsideList = [];
                            for(var i = 1; i<=records[key][nameSpace+'Number_of_Times_Days_Weeks__c'];i++){
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
                        }*/
                        
                        newFilter = {"Id" : mapId,
                                     "medicationName" : records[key][nameSpace+'Drug_Name__c'], 
                                     "types" : records[key][nameSpace+'Type__c'],
                                     "startDate" : today,
                                     "dispenseExpectedSupplyDuration" : records[key][nameSpace+'Number_of_Times_Days_Weeks__c'],
                                     "afterDischarge" : records[key][nameSpace+'After_Discharge__c'],
                                     "Route" : records[key][nameSpace+"Route_New__c"],
                                     "Warning"	: records[key][nameSpace+"Warning_new__c"],
                                     "dosageForm" : records[key][nameSpace+'Dosage_Form__c'],
                                     "reasonLabel" : records[key][nameSpace+'Reason_new__c'],
                                     "accountId" : records[key][nameSpace+'Account__c'],
                                     "endDate"	:  erDate,
                                     "Days" : JSON.parse(JSON.stringify(jsonInsideList)),
                                     
                                    }
                        /*newFilter = {"Id" : mapId,
                                     "medicationName" : records[key][nameSpace+'Drug_Name__c'], 
                                     "types" : records[key][nameSpace+'Type__c'],
                                     "startDate" : today,
                                     "dispenseExpectedSupplyDuration" : records[key][nameSpace+'Number_of_Times_Days_Weeks__c'],
                                     "afterDischarge" : records[key][nameSpace+'After_Discharge__c'],
                                     "Route" : records[key][nameSpace+"Route_New__c"],
                                     "Warning"	: records[key][nameSpace+"Warning_new__c"],
                                     "dosageForm" : records[key][nameSpace+'Dosage_Form__c'],
                                     "accountId" : records[key][nameSpace+'Account__c'],
                                     "reasonLabel" : records[key][nameSpace+'Reason_new__c'],
                                     "endDate"	: erDate,
                                     "singleRecForPrn" : JSON.parse(JSON.stringify(jsonInsideList))
                                    }*/
                        // console.log('ROute '+records[key]["endDate"]);
                        jsonList.push(newFilter);
                        
                        
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
                            var marCheck = records[key][nameSpace+"MAR_Display__c"];
                            if(marCheck == null){
                                marCheck = false;
                            }
                            
                            newFilter = {"Id" : mapId,
                                         "medicationName" : records[key][nameSpace+'Drug_Name__c'], 
                                         "types" : records[key][nameSpace+'Type__c'],
                                         "startDate" : today,
                                         "dispenseExpectedSupplyDuration" : records[key][nameSpace+'Number_of_Times_Days_Weeks__c'],
                                         "afterDischarge" : records[key][nameSpace+'After_Discharge__c'],
                                         "dosageForm" : records[key][nameSpace+'Dosage_Form__c'],
                                         "accountId" : records[key][nameSpace+'Account__c'],  
                                         "PRNdisplay": records[key][nameSpace+"PRN__c"],
                                         "MARdisplay" : marCheck,
                                         "Route" : records[key][nameSpace+"Route_New__c"],
                                         "Warning"	: records[key][nameSpace+"Warning_new__c"],
                                         "dosageForm" : records[key][nameSpace+'Dosage_Form__c'],
                                         "reasonLabel" : records[key][nameSpace+'Reason_new__c'],
                                         "accountId" : records[key][nameSpace+'Account__c'],
                                         "endDate"	:  erDate,
                                         "Days" : JSON.parse(JSON.stringify(jsonInsideList)),
                                         
                                        }
                            
                            jsonList.push(newFilter);
                            
                        }       
                    
                    
                }
                
                component.set("v.jsonList",jsonList); 
                component.set("v.jsonListCopy",JSON.parse(JSON.stringify(jsonList)));
                console.log('final json 007 '+JSON.stringify(component.get("v.jsonList")));
                component.set("v.AllUsers",usersList);
                
                console.log('2nd component '+JSON.stringify(component.get("v.jsonList")));
            }
            else if(state ==="ERROR"){
                console.log('Failure');
            }
        });        
        $A.enqueueAction(action);
        
        
    },
    daysForActionOrder  : function(component, event){
        console.log('Days Action Order');
        var value = event.getSource().get("v.value");
        if(value==""){
            value = '0';
        }
        var upperIndex = event.getSource().get("v.name");     
        console.log('value  '+value);
        var jsonList = component.get("v.jsonList");
        var erDate = new Date(Date.parse(jsonList[upperIndex].startDate)); 
        erDate.setDate(erDate.getDate() + parseInt(value));
        //console.log('erDate'+erDate);
        var dd = String(erDate.getDate()).padStart(2, '0');
        var mm = String(erDate.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = erDate.getFullYear();
        erDate = yyyy +'-'+ mm +'-' + dd ;
        jsonList[upperIndex].endDate =  erDate ; 
        component.set("v.jsonList",jsonList);
    },
    hideExampleModal : function(component,  helper) {
        //var accId = component.get("v.accId");
        //var RecId = component.get("v.RecId");
        /*var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/r/Account'/+RecId+'/view'
        });
        urlEvent.fire();*/
        var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
                    appEvent.setParams({
                        "screenType" : "Medication",
                        "action" : "New",
                        "button" : "Cancel"
                         });
                    appEvent.fire();
        component.set("v.OpenPopUp",false);
        component.set("v.isOpen",false);
    },
    DaysSelectionEvent  :  function(component,event,helper){
        //console.log('SelectedUser '+component.get("v.SelectedUser"));
        console.log('Days');
        var value = event.getSource().get("v.value");
        var upperIndex = event.getSource().get("v.name");     
        console.log('value  '+value);
        var jsonList = component.get("v.jsonList");
        var jsonListCopy = component.get("v.jsonListCopy");
        var timeList = [];
        var strengthList = [];
        var unitsList = [];
        var dosageList = [];
        var startingIndex;
        var wrapper ={};
       
        /*  if(jsonList[upperIndex]["types"] == 'PRN'){
            
            var messagePre = jsonList[upperIndex]["singleRecForPrn"][0]['Repeat'];
            var messageSuf = jsonList[upperIndex]["singleRecForPrn"][0]['Dosage_Instruction'];
            if(messagePre == 'After every '+ '\''+ 'n' +'\''+ ' hours'){
                message = ' After every ' + messageSuf + ' hours';
            }else if(messagePre == '\''+'n'+'\''+ ' times a day'){
                message = ' ' + messageSuf +' times a day' ;
            }
            jsonList[upperIndex]["dispenseExpectedSupplyDuration"] = value;
            // var arr = jsonList[upperIndex].startDate.split('-');
            //var dateConvert = new Date(arr[0]+ '.' + arr[2]+ '.' +arr[1]);
            var dateConvert = new Date(jsonList[upperIndex].startDate);
            dateConvert.setDate(dateConvert.getDate() + parseInt(value));
            var dd = String(dateConvert.getDate()).padStart(2, '0');
            var mm = String(dateConvert.getMonth() + 1).padStart(2, '0'); //January is 0!
            var yyyy = dateConvert.getFullYear();          
            dateConvert = yyyy +'-'+ mm +'-' + dd ;
            
            jsonList[upperIndex]["endDate"] = dateConvert;
            jsonList[upperIndex]["singleRecForPrn"][0]['textMessage'] = message;
            
        }*/
        //else{
        
        startingIndex = jsonListCopy[upperIndex]["dispenseExpectedSupplyDuration"];
        
        console.log('st'+startingIndex);
        if(startingIndex == ''){
            startingIndex=0;
            
            //wrapper = jsonListCopy[upperIndex]["Days"][0];
            wrapper = { "Dosage_Instruction" :  "1",    
                       "Strength" : ['5mg'],
                       "Units" : ['film'],
                       "Dosage" : ['1'],
                       "times" : ['00:00:00.000'],
                       "Repeat" : '\''+'n'+'\''+ ' times a day'}    
            
        }else{
            wrapper = jsonList[upperIndex]["Days"][0]; 
        }
        console.log('startingIndex '+startingIndex);
        
        if((jsonListCopy[upperIndex]["dispenseExpectedSupplyDuration"] ==''  || value!='' && parseInt(startingIndex) < parseInt(value))){
            timeList = JSON.parse(JSON.stringify(wrapper['times']));
            strengthList = JSON.parse(JSON.stringify(wrapper['Strength']));
            unitsList = JSON.parse(JSON.stringify(wrapper['Units']));
            dosageList = JSON.parse(JSON.stringify(wrapper['Dosage']));
            
            var jsonInsideList = [];
            var jsonMap = {};
            jsonMap ={
                24 :    1,
                12 :	2,
                11 :    2,
                10 :	2,
                9  :	2,
                8  :    3,
                7  :	3,
                6  :	4,
                5  :	5,
                4  :	6,
                3  : 8,
                2  :	12,
                1  :    24
                
            }
            for(var i=0;i<value-startingIndex;i++){
                var jsonInside = {};
                jsonInside = {"times" : timeList,                       
                              "Units" : unitsList, 
                              "Dosage" : dosageList,
                              "Strength"	:	timeList, 
                              "indexOfDay"	: i,
                              "Repeat": wrapper['Repeat'],
                              "Strength" : strengthList,
                              "textMessage"	:	'',
                              "Dosage_Instruction" : timeList.length
                             } 
                if(jsonInside['Repeat'] == 'After every '+ '\''+ 'n' +'\''+ ' hours'){	
                    jsonInside['Dosage_Instruction'] = jsonMap[timeList.length.toString()];
                    jsonInside['textMessage'] = ' After every '+ jsonMap[timeList.length.toString()]+' hours' ;
                    
                }else if(jsonInside['Repeat'] == '\''+'n'+'\''+ ' times a day'){
                    jsonInside['textMessage'] =  ' ' +jsonInside['Dosage_Instruction'] + ' times a day' ;
                }
                    else{
                        jsonInside['textMessage'] = '';
                    }
                jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
            }
            
            
            var i=0;
            for(var index=0 ; index<value ; index++){
                if(index > startingIndex-1){
                    if(!$A.util.isUndefinedOrNull(jsonList[upperIndex]['Days'][index])){
                        console.log('if');
                        jsonList[upperIndex]['Days'][index] = (JSON.parse(JSON.stringify(jsonInsideList[i])));
                        
                    }
                    else{
                        console.log('else');
                        jsonList[upperIndex]['Days'].push((JSON.parse(JSON.stringify(jsonInsideList[0]))));
                    }
                    i++;
                    
                }
            }
            
            console.log('After if1');
            jsonList[upperIndex].dispenseExpectedSupplyDuration = value;
            
            
        }
        else{
            if(value==''){
                jsonList[upperIndex]['Days'] = []; 
            }else{
                jsonList[upperIndex]['Days'].splice(value,startingIndex-value);             
            }
            jsonList[upperIndex].dispenseExpectedSupplyDuration = value;
            //var arr = jsonList[upperIndex].startDate.split('-');
            //var dateConvert = new Date(arr[0]+ '.' + arr[2]+ '.' +arr[1]);'
            
            console.log('else down');  
        }
        var dateConvert = new Date(jsonList[upperIndex]['startDate']);
        dateConvert.setDate(dateConvert.getDate() + parseInt(value));
        var dd = String(dateConvert.getDate()).padStart(2, '0');
        var mm = String(dateConvert.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = dateConvert.getFullYear();
        
        dateConvert = yyyy +'-'+ mm +'-' + dd ;
        
        jsonList[upperIndex]["endDate"] = dateConvert;  
        
        
        //}
        console.log('Finished '+JSON.stringify(jsonList));
        component.set("v.jsonList",jsonList);
        component.set("v.jsonListCopy",JSON.parse(JSON.stringify(jsonList)));
        
        
    },
    updateDaysForActionOrder : function(component,event,helper){
        var value = event.getSource().get("v.value");
        var upperIndex = event.getSource().get("v.name");     
        console.log('value  '+value);
        var jsonList = component.get("v.jsonList");
        var jsonListCopy = component.get("v.jsonListCopy");
        
        var dateConvert = new Date(jsonList[upperIndex]['startDate']);
        dateConvert.setDate(dateConvert.getDate() + parseInt( jsonList[upperIndex].dispenseExpectedSupplyDuration));
        var dd = String(dateConvert.getDate()).padStart(2, '0');
        var mm = String(dateConvert.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = dateConvert.getFullYear();
        
        dateConvert = yyyy +'-'+ mm +'-' + dd ;
        
        jsonList[upperIndex]["endDate"] = dateConvert;  
        
        
        //}
        console.log('Finished '+JSON.stringify(jsonList));
        component.set("v.jsonList",jsonList);
        component.set("v.jsonListCopy",JSON.parse(JSON.stringify(jsonList)));
        
    },
    GetFrequency	:	function(component,event,helper){
        
        var index = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        
        console.log('index '+index);
        console.log('value '+value);
        
        var array = index.split('$');
        var upperIndex = array[0];
        var DayIndex = array[1];
        var jsonList = component.get("v.jsonList");      
        
        //  if(jsonList[upperIndex]['types'] == 'Taper')
        //  {
        jsonList[upperIndex].Days[DayIndex]['Repeat'] = value;
        var jsonInside = jsonList[upperIndex].Days[DayIndex];  
        
        var map = {};
        if(jsonList[upperIndex].Days[DayIndex]['Repeat'] == 'After every '+ '\''+ 'n' +'\''+ ' hours' || jsonList[upperIndex].Days[DayIndex]['Repeat'] == '\''+'n'+'\''+ ' times a day'){
            jsonInside.Strength=[];
            jsonInside.Units=[];
            jsonInside.Dosage=[]
            jsonInside.times = [];
            jsonInside.times = ['00:00:00.000'];    
            if(jsonList[upperIndex].Days[DayIndex]['Repeat'] == 'After every '+ '\''+ 'n' +'\''+ ' hours' ){
                var jsonMap = {};
                jsonMap ={
                    24 :    1,
                    12 :	2,
                    11 :    2,
                    10 :	2,
                    9  :	2,
                    8  :    3,
                    7  :	3,
                    6  :	4,
                    5  :	5,
                    4  :	6,
                    3  : 8,
                    2  :	12,
                    1  :    24
                    
                }
                jsonInside.times = ["12:00:00.000","24:00:00.000"];    
                jsonInside.Strength = ['5mg','5mg'];
                jsonInside.Units = ['film','film'];
                jsonInside.Dosage = ['1','1'];
                jsonInside.Dosage_Instruction = parseInt("12"); 
                jsonList[upperIndex].Days[DayIndex]['textMessage'] = ' After every 12 hours';
            }
            else if(jsonList[upperIndex].Days[DayIndex]['Repeat'] == '\''+'n'+'\''+ ' times a day'){
                jsonInside.Dosage_Instruction = parseInt("1");     
                jsonInside.Strength = ['5mg'];
                jsonInside.Units = ['film'];
                jsonInside.Dosage = ['1'];
                jsonInside.times = ['00:00:00.000'];    
                jsonList[upperIndex].Days[DayIndex]['textMessage'] = ' 1 times a day';
            }
            
        }
        
        else{
            jsonList[upperIndex].Days[DayIndex]['textMessage'] = ' '; 
            map = {'After lunch' : ['13:30:00.000'],
                   'After supper/Dinner'	: ['19:00:00.000'],
                   'Before Breakfast'	: ['06:30:00.000'],
                   'Custom pheno' : ['09:00:00.000','15:00:00.000','22:00:00.000'],
                   'Once a day (AM)'	: ['09:00:00.000'],
                   'Once  a day (HS)'	: ['22:00:00.000'],
                   'Once a day midday'	: ['16:00:00.000'],
                   'Once a day (Qam)' : ['09:00:00.000'],
                   'Once a day (QHS)'	: ['21:00:00.000'],
                   'At a specific time' : ['09:00:00.000']
                  }
            
            //console.log($A.util.isUndefinedOrNull(map[value]));
            if(!$A.util.isUndefinedOrNull(map[value])){
                console.log('value hai');                   
                console.log('first');   
                jsonInside.Strength=[];
                jsonInside.Units=[];
                jsonInside.Dosage=[]
                jsonInside.times = [];
                jsonInside.times = map[value];                                     
                jsonInside.Dosage_Instruction = parseInt(jsonInside.times.length);
                console.log('secnd');
                if(value != 'Custom pheno'){
                    jsonInside.Strength = ['5mg'];
                    jsonInside.Units = ['film'];
                    jsonInside.Dosage = ['1'];
                    console.log('If');
                    
                }else{
                    jsonInside.Strength = ['5mg','5mg','5mg'];
                    jsonInside.Units = ['film','film','film'];
                    jsonInside.Dosage = ['1','1','1'];
                    console.log('custom pheno else');
                }
            }
        }    
        
        //}
        
        /* else{
             
            jsonList[upperIndex].singleRecForPrn[0]['Repeat'] = value; 
            var count = jsonList[upperIndex]['singleRecForPrn'][0]['Dosage_Instruction'];
            if(jsonList[upperIndex].singleRecForPrn[0]['Repeat'] == '\''+'n'+'\''+ ' times a day'){    
                component.set("v.PRNTimesDisabled", false);
                jsonList[upperIndex]['singleRecForPrn'][0]['textMessage'] = ' '+count.toString() +' times a day'; 
            }
            else if(jsonList[upperIndex].singleRecForPrn[0]['Repeat'] == 'After every '+ '\''+ 'n' +'\''+ ' hours'){
                component.set("v.PRNTimesDisabled", false);
                jsonList[upperIndex]['singleRecForPrn'][0]['textMessage'] = ' After every '+ count.toString() +' hours'; 
            }
            else{
                
                map = {'After lunch' : '1',
                       'After supper/Dinner'	: '1',
                       'Before Breakfast'	: '1',
                       'Custom pheno' : '3',
                       'Once a day (AM)'	:'1',
                       'Once  a day (HS)'	: '1',
                       'Once a day midday'	:'1',
                       'Once a day (Qam)' : '1',
                       'Once a day (QHS)'	:'1',
                       'At a specific time' :'1'
                      }
                  if(value == 'Custom pheno'){
                        jsonList[upperIndex]['singleRecForPrn'][0]['textMessage']  = '3 time a day';
                  }
                else {
                  jsonList[upperIndex]['singleRecForPrn'][0]['textMessage']  = '1 time a day';
                }
                //console.log($A.util.isUndefinedOrNull(map[value]));
                if(!$A.util.isUndefinedOrNull(map[value])){
                   component.set("v.PRNTimesDisabled", true);
                   jsonList[upperIndex]['singleRecForPrn'][0].Dosage_Instruction = map[value];                                     
                }
            }    
               /* else{
                    jsonList[upperIndex]['singleRecForPrn'][0]['textMessage'] = ' ';   
                }*/
        
        // }
        component.set("v.jsonList",jsonList);
        console.log('json List '+JSON.stringify(jsonList));
        
    },
    GettimesPrn  	:	function(component,event){
        var jsonList = component.get("v.jsonList");
        var index = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        var jsonList = component.get("v.jsonList");
        var message;
        jsonList[index]['singleRecForPrn'][0]['Dosage_Instruction'] = value;
        var messagePre = jsonList[index]['singleRecForPrn'][0]['Repeat'];
        if(messagePre == 'After every '+ '\''+ 'n' +'\''+ ' hours'){
            message = ' After every ' + value + ' hours';
        }else if(messagePre == '\''+'n'+'\''+ ' times a day'){
            message = ' '+value +' times a day' ;
        }else{
            message = '';
        }
        
        jsonList[index]['singleRecForPrn'][0]['textMessage'] = message;
        console.log(JSON.stringify(jsonList));
        component.set("v.jsonList",jsonList);
    },
    GetTimes	:	function(component,event){
        console.log('gettimes');
        var index = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        var label = event.getSource().get("v.label"); 
        console.log('index '+index);
        console.log('value '+value);
        console.log('label '+label);
        var timeList = [];
        var strengthList = [];
        var unitsList = [];
        var dosageList = [];
        var array = index.split('$');
        var upperIndex = array[0];
        var DayIndex = array[1];
        var mapOfEveryHours = {};
        var mapOfNTimes = {};
        var jsonList = component.get("v.jsonList");
        if(jsonList[upperIndex].Days[DayIndex]['Repeat'] == 'After every '+ '\''+ 'n' +'\''+ ' hours'){
            var mapOfEveryHours ={
                "12":	["12:00:00.000","24:00:00.000"],
                "8":	["08:00:00.000","16:00:00.000","24:00:00.000"],
                "6":	["06:00:00.000","12:00:00.000","18:00:00.000","24:00:00.000"],
                "5":	["04:00:00.000","09:00:00.000","14:00:00.000","19:00:00.000","24:00:00.000"],
                "4":	["04:00:00.000","08:00:00.000","12:00:00.000","16:00:00.000","20:00:00.000","24:00:00.000"],
                "7":	["01:00:00.000","04:00:00.000","07:00:00.000","10:00:00.000","13:00:00.000","16:00:00.000","19:00:00.000"],
                "3": ["01:00:00.000","04:00:00.000","07:00:00.000","10:00:00.000","13:00:00.000","16:00:00.000","19:00:00.000","21:00:00.000"],
                "9":	["09:00:00.000","18:00:00.000"],
                "10":	["01:00:00.000","11:00:00.000"],
                "11":	["01:00:00.000","12:00:00.000"],
                "1":	["00:00:00.000","01:00:00.000","02:00:00.000","03:00:00.000","04:00:00.000","05:00:00.000","06:00:00.000","07:00:00.000","08:00:00.000","09:00:00.000","10:00:00.000","11:00:00.000",
                         "12:00:00.000","13:00:00.000","14:00:00.000","15:00:00.000","16:00:00.000","17:00:00.000","18:00:00.000","19:00:00.000","20:00:00.000","21:00:00.000","22:00:00.000","23:00:00.000"],
                "2":	["01:00:00.000","03:00:00.000","05:00:00.000","07:00:00.000","09:00:00.000","11:00:00.000","13:00:00.000","15:00:00.000","17:00:00.000","19:00:00.000","21:00:00.000","23:00:00.000"]
            };
            jsonList[upperIndex].Days[DayIndex]['textMessage'] = ' After every '+ value.toString() +' hours';
            timeList = mapOfEveryHours[value];
        }
        else if(jsonList[upperIndex].Days[DayIndex]['Repeat'] == '\''+'n'+'\''+ ' times a day'){
            mapOfNTimes = {
                "1":["09:00:00.000"],
                "2":	["09:00:00.000","21:00:00.000"],
                "3":	["09:00:00.000","15:00:00.000","21:00:00.000"],
                "4":	["09:00:00.000","13:00:00.000","17:00:00.000","21:00:00.000"],
                "5":	["04:00:00.000","08:00:00.000","12:00:00.000","16:00:00.000","20:00:00.000"],
                "6":	["02:00:00.000","06:00:00.000","10:00:00.000","14:00:00.000","18:00:00.000","22:00:00.000"],
                "7":	["01:00:00.000","04:00:00.000","07:00:00.000","10:00:00.000","13:00:00.000","16:00:00.000","19:00:00.000"],
                "8": ["01:00:00.000","04:00:00.000","07:00:00.000","10:00:00.000","13:00:00.000","16:00:00.000","19:00:00.000","21:00:00.000"],
                "9":	["01:00:00.000","04:00:00.000","07:00:00.000","10:00:00.000","13:00:00.000","16:00:00.000","19:00:00.000","21:00:00.000","23:00:00.000"],
                "10":	["01:00:00.000","03:00:00.000","05:00:00.000","07:00:00.000","09:00:00.000","11:00:00.000","13:00:00.000","15:00:00.000","17:00:00.000","19:00:00.000"],
                "11":	["01:00:00.000","03:00:00.000","05:00:00.000","07:00:00.000","09:00:00.000","11:00:00.000","13:00:00.000","15:00:00.000","17:00:00.000","19:00:00.000","21:00:00.000"],
                "12":	["01:00:00.000","03:00:00.000","05:00:00.000","07:00:00.000","09:00:00.000","11:00:00.000","13:00:00.000","15:00:00.000","17:00:00.000","19:00:00.000","21:00:00.000","23:00:00.000"]
            }; 
            jsonList[upperIndex].Days[DayIndex]['textMessage'] =  ' ' + value.toString() +' times a day';
            timeList = mapOfNTimes[value];
        }
            else{
                jsonList[upperIndex].Days[DayIndex]['textMessage'] = '';
            }
        
        
        
        for(var i=1;i<=timeList.length;i++){           
            strengthList.push("5mg");
            unitsList.push("film");
            dosageList.push("1");  
        }
        
        
        
        console.log('DayIndex '+DayIndex);
        console.log('jsonList '+JSON.stringify(jsonList));
        
        console.log(JSON.stringify(jsonList[upperIndex].Days[DayIndex]));
        var jsonInside = (jsonList[upperIndex].Days)[DayIndex];
        
        console.log('Json list'+jsonList);
        jsonInside.times=[];
        jsonInside.Strength=[];
        jsonInside.Units=[];
        jsonInside.Dosage=[];
        jsonInside.times = timeList;
        jsonInside.Strength = strengthList;
        jsonInside.Units = unitsList;
        jsonInside.Dosage = dosageList;
        //jsonInside.Dosage_Instruction = value;
        
        console.log('Pushed'+JSON.stringify(jsonList));
        
        component.set("v.jsonList",jsonList);
        
        
    },
    editInsideData	:	function(component,event){
        console.log('EditInsideData');
        var allValid = component.find('fieldstrength').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        console.log(allValid);
        if(allValid == true){
            var index = event.getSource().get("v.name");
            var value = event.getSource().get("v.value");
            var label = event.getSource().get("v.label");
            if(!$A.util.isUndefinedOrNull(value)){
                var array = index.split('$');
                var upperIndex = array[0];
                var repeatIndex = array[1];
                var DayIndex = array[2];
                var fieldName = array[3];
                var jsonList = component.get("v.jsonList");
                var jsonString ;
                
                console.log(JSON.stringify((jsonList[upperIndex].Days)[DayIndex]));
                var jsonInside = (jsonList[upperIndex].Days)[DayIndex];
                if(fieldName.toUpperCase()=='STRENGTH'){
                    jsonInside.Strength[repeatIndex] = value ;
                }
                else if(fieldName.toUpperCase()=='START TIME'){
                    jsonInside.times[repeatIndex] = value ;
                }
                    else if(fieldName.toUpperCase()=='DOSAGE'){
                        jsonInside.Dosage[repeatIndex] = value ;
                    }
                        else{
                            jsonInside.Units[repeatIndex] = value ;
                        }
                
                console.log('Pushed'+JSON.stringify(jsonList));
                component.set("v.jsonList",jsonList);
            }
        }
        console.log('Pushed'+JSON.stringify(component.get("v.jsonList")));
        
    },
    handleRecordForm :  function(component, event, helper) {
        component.set("v.ShowEditable",true);
    },
    recordEdit : function(component, event, helper){
        
        var index = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        // console.log(allValid);
        if(!$A.util.isUndefinedOrNull(value)){    
            var array = index.split('$');
            var upperIndex = array[0];
            var name = array[1];
            console.log('index '+index);
            console.log('value '+value);
            
            var jsonList = component.get("v.jsonList");
            /* if(jsonList[upperIndex]['types'] == "PRN"){
                jsonList[upperIndex]['singleRecForPrn'][0][name] =value;
                
            }*/
            //  else{
            jsonList[upperIndex][name] = value;   
            //   }
            if(name == 'startDate'){
                var dte = new Date(jsonList[upperIndex]['startDate']);
                dte.setDate(dte.getDate() + parseInt(jsonList[upperIndex]['dispenseExpectedSupplyDuration']));
                var dd = String(dte.getDate()).padStart(2, '0');
                var mm = String(dte.getMonth() + 1).padStart(2, '0'); //January is 0!
                var yyyy = dte.getFullYear();          
                dte = yyyy +'-'+ mm +'-' + dd ;
                
                jsonList[upperIndex]['endDate'] = dte;
            }
            
            component.set("v.jsonList",jsonList);
        }
        console.log(JSON.stringify(component.get("v.jsonList")));
    },
    handleSectionToggle: function (component, event) {
        var openSections =  event.getParam('openSections');
        console.log("func initiated" +openSections );
        console.log('s '+openSections.length);
        if(!$A.util.isUndefinedOrNull(openSections ) && openSections.length == 0){
            $A.util.addClass(component.find("orderby"), "slds-hide");
            $A.util.addClass(component.find("ordervia"), "slds-hide");
            $A.util.addClass(component.find("procedureid"), "slds-hide");
            $A.util.addClass(component.find("btns"), "slds-hide");
            //$A.util.addClass(component.find("label2"), "slds-hide");
            //$A.util.addClass(component.find("buttons-cls"), "slds-hide");
            console.log('size '+openSections );
        }
        else{
            
            $A.util.removeClass(component.find("orderby"), "slds-hide");
            $A.util.removeClass(component.find("ordervia"), "slds-hide");
            $A.util.removeClass(component.find("procedureid"), "slds-hide");
            $A.util.removeClass(component.find("btns"), "slds-hide");
            //$A.util.removeClass(component.find("label2"), "slds-hide");  
            //$A.util.removeClass(component.find("buttons-cls"), "slds-hide");
            console.log('size else'+openSections );
        }
        
    },
    procedureValidity  : function(component ,event ,helper){
        var valid = true;
        valid = helper.helperMethod(component , valid);
    },
    ActionOrderEdit	:	function(component, event, helper){
        var index = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        var upperIndex;
        var repeatIndex;
        var jsonList = component.get("v.jsonList");
        var array = index.split('$');
        var DayIndex = array[1];
        
        
        if(!$A.util.isUndefinedOrNull(value)){
            if(array.length == 3){
                upperIndex = array[0];
                repeatIndex = array[1];
                jsonList[upperIndex].singleRecForActionOrder[0].StartTime[repeatIndex] = value;
            }
            else if(array.length == 2){
                upperIndex = array[0];
                var mapOfNTimes = {
                    "1":["09:00:00.000"],
                    "2":	["09:00:00.000","21:00:00.000"],
                    "3":	["09:00:00.000","15:00:00.000","21:00:00.000"],
                    "4":	["09:00:00.000","13:00:00.000","17:00:00.000","21:00:00.000"],
                    "5":	["04:00:00.000","08:00:00.000","12:00:00.000","16:00:00.000","20:00:00.000"],
                    "6":	["02:00:00.000","06:00:00.000","10:00:00.000","14:00:00.000","18:00:00.000","22:00:00.000"],
                    "7":	["01:00:00.000","04:00:00.000","07:00:00.000","10:00:00.000","13:00:00.000","16:00:00.000","19:00:00.000"],
                    "8":    ["01:00:00.000","04:00:00.000","07:00:00.000","10:00:00.000","13:00:00.000","16:00:00.000","19:00:00.000","21:00:00.000"],
                    "9":	["01:00:00.000","04:00:00.000","07:00:00.000","10:00:00.000","13:00:00.000","16:00:00.000","19:00:00.000","21:00:00.000","23:00:00.000"],
                    "10":	["01:00:00.000","03:00:00.000","05:00:00.000","07:00:00.000","09:00:00.000","11:00:00.000","13:00:00.000","15:00:00.000","17:00:00.000","19:00:00.000"],
                    "11":	["01:00:00.000","03:00:00.000","05:00:00.000","07:00:00.000","09:00:00.000","11:00:00.000","13:00:00.000","15:00:00.000","17:00:00.000","19:00:00.000","21:00:00.000"],
                    "12":	["01:00:00.000","03:00:00.000","05:00:00.000","07:00:00.000","09:00:00.000","11:00:00.000","13:00:00.000","15:00:00.000","17:00:00.000","19:00:00.000","21:00:00.000","23:00:00.000"]
                }; 
                jsonList[upperIndex].singleRecForActionOrder[0]['StartTime'] = mapOfNTimes[value];
                jsonList[upperIndex].singleRecForActionOrder[0]['textMessage'] =  ' ' + value.toString() +' times a day';
            }
            console.log(JSON.stringify(jsonList));
        }
        component.set("v.jsonList",jsonList);       
    },
    
    handleConfirmDialogNo:function(component, event, helper) {
        component.set("v.showConfirmDialog",false);
    },
    
    handleConfirmDialogYes :  function(component, event, helper) {
        
        var procedureStartCmp = component.find("procedure-start_time");
        var strtProcedureTime = procedureStartCmp.get('v.value');
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get('v.value');
        if(endProcedureTime == null )
        {
            var today = new Date();
            endProcedureTime = today;
        }
        var valid = true;
        var duplicateErrorMessage = false ; 
        var allValid = true;
        var allValidAction = true;
        var jsonListForPRN = [];
        var jsonListForTaper = [];
        var jsonListForAOrder = [];
        var oldJsonList = component.get("v.jsonList");
        console.log('oldJsonList '+ JSON.stringify(oldJsonList));
        var footerButtonsValid = component.find('footerbtn').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true); 
        var commonJson = [];
        for(var rec in oldJsonList){       
            if(oldJsonList[rec]['types'] == 'PRN'){               
                
                
                jsonListForPRN.push(oldJsonList[rec]);
                commonJson.push(oldJsonList[rec]);
            }
            else if(oldJsonList[rec]['types'] == 'Taper'){       
                
                jsonListForTaper.push(oldJsonList[rec]);
                commonJson.push(oldJsonList[rec]);
            }
                else{
                    jsonListForAOrder.push(oldJsonList[rec]);
                    commonJson.push(oldJsonList[rec]);
                }            
            
            if(! $A.util.isEmpty(jsonListForPRN)){
                allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    console.log(validSoFar);
                    console.log('s',inputCmp.get('v.validity').valid);
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true); 
            }  
            
            if(! ($A.util.isEmpty(jsonListForTaper))){
                allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    console.log(validSoFar);
                    console.log('s',inputCmp.get('v.validity').valid);
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true); 
            }  
            
            
            if(!($A.util.isEmpty(jsonListForAOrder))){
                var allValidAction = component.find('fieldAction').reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    console.log(validSoFar);
                    console.log('s',inputCmp.get('v.validity').valid);
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
            }
            if(allValid==false || allValidAction==false || footerButtonsValid == false){
                duplicateErrorMessage = true;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Failed!",
                    "message": "Please fill all the mandatory fields."
                });
                toastEvent.fire();
            }
        }

        var userName = component.get("v.userName");
                console.log('username**',userName);
        for(var i =0 ; i<commonJson.length ; i++){
            commonJson[i]['Name'] = userName;
        }
        var jsonString={
            "jsonListForTaper" :	JSON.parse(JSON.stringify(jsonListForTaper)),
            "jsonListForPRN"   :	JSON.parse(JSON.stringify(jsonListForPRN)),
            "jsonListForAOrder"  :	JSON.parse(JSON.stringify(jsonListForAOrder))
        };
        console.log('String bnn gyi'+JSON.stringify(jsonString));
        console.log('accId '+ component.get("v.RecId"));
        if(allValid==true && allValidAction==true && footerButtonsValid==true && valid==true){
            component.set("v.isDisabled",true); 
            
            if(component.get("v.RouteForComponent")=='fromForm') {
                var cmpEvent = component.getEvent("FormMedicationData"); 
                
                
                
                cmpEvent.setParams({ 
                    
                    jsonList : jsonString,
                    selectedUser	:	component.get("v.SelectedUser"),
                    selectedVia	:	component.get("v.SelectedVia")
                    
                }); 
                
                cmpEvent.fire(); 
                component.set("v.OpenPopUp",false);
                component.set("v.isOpen",false);
                component.set("v.openUpdateMedication",false);
                
                
            }

            else if(component.get("v.RouteForComponent")=='prescForm'){
             
                var columns = component.get("v.column");
                
                console.log('presclst save***',JSON.stringify(jsonString));
        		columns['prescLst']= JSON.stringify(jsonString);
                columns['selectedUser']= component.get("v.SelectedUser");
                columns['selectedVia']= component.get("v.SelectedVia");
                columns['starttime']= component.get('v.todayString');
                columns['endtime']= endProcedureTime;

                console.log('columns**',columns);
        		component.set("v.column",columns);
               component.set("v.OpenPopUp",false);
                
                component.set("v.jsonFinal",commonJson);
                component.set("v.jsonValueSet",true);
                component.set("v.openUpdateMedication",false);
                   component.set("v.isOpenMed",false);
                component.set("v.addPresc",false);
                component.set("v.PreTable",true);
                
               //  var cmpEvent = component.getEvent("FormPrescData"); 
                 var cmpEvent = $A.get("e.c:FormPrescData");
                cmpEvent.setParams({ 
                    
                    jsonList : commonJson,
                    selectedUser	:	component.get("v.SelectedUser"),
                    selectedVia	:	component.get("v.SelectedVia")
                    
                }); 
                
                cmpEvent.fire(); 
                console.log('prescForm event fired');
            
            }
            
            
            else {
                
                var action = component.get("c.saveData");
                component.find("Id_spinner").set("v.class" , 'slds-show');
                action.setParams({ 
                    jsonList : JSON.stringify(jsonString),
                    selectedUser	:	component.get("v.SelectedUser"),
                    selectedVia	:	component.get("v.SelectedVia"),
                    accId	: component.get("v.RecId"),
                    starttimeProcedure : component.get('v.todayString'),
                    endtimeProcedure : endProcedureTime,
                    formUnId : 'No FormId'
                });
                
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        try {
                            // for n prescriptions only one parent will be there, ex: ["a1JN0000002oT2VMAU"]
                            let parentPrescriptionId = response.getReturnValue()[0];
                            // helper.attachApprovalDataToParentPrescriptionJS(component, event, helper, parentPrescriptionId);

                            // at max 3 approval levels will be there, ex-
                            //'[{"approvalLevel":1,"comments":"comm1","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T14:06:18.758Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"},{"approvalLevel":2,"comments":"comm2","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T14:06:31.832Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"},{"approvalLevel":3,"comments":"comm3","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T14:06:41.884Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"}]'
                            let approvedValues = JSON.stringify(component.get("v.approvedValues"));

                            let action = component.get("c.attachApprovalDataToParentPrescription");
                            action.setParams({
                                parentPrescriptionId: parentPrescriptionId,
                                approvedValues: approvedValues
                            });

                            action.setCallback(this, function (response) {

                                if (response.getState() == "ERROR") {
                                    alert("Failed to attach approval data");
                                    console.log("Failed to attach approval data", JSON.stringify(response.getError()));
                                }

                                // after success start
                                component.find("Id_spinner").set("v.class", 'slds-hide');
                                console.log('Success');

                                var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
                                appEvent.setParams({
                                    "screenType": "Medication",
                                    "action": "New",
                                    "recordIds": response.getReturnValue()
                                });
                                appEvent.fire();

                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": 'success',
                                    "title": "RECORD CREATED SUCCESSFULLY!",
                                    "message": "Creation Successfull!"
                                });
                                toastEvent.fire();
                                component.set("v.OpenPopUp", false);
                                component.set("v.isOpen", false);
                                $A.get('e.force:refreshView').fire();
                                // after success end


                            });

                            $A.enqueueAction(action);
                        } catch (error) {
                            console.error("Failed to attach approval data: ", error);
                        }

                    }
                    else if(state ==="ERROR"){
                        ////alert(jsonList);
                        console.log('Failure');
                        
                        
                    }
                }); 
                
                $A.enqueueAction(action);
            }
        }
        else{
            if(!duplicateErrorMessage){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "REVIEW ERROR MESSAGES!",
                    "message": "Please review all the error messages on the page."
                });
                toastEvent.fire();
            }
        }
        
    },
    
    Save  : function(component, event, helper){
        
        var procedureStartCmp = component.find("procedure-start_time");
        var strtProcedureTime = procedureStartCmp.get('v.value');
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get('v.value');
        if(endProcedureTime == null )
        {
            component.set("v.showConfirmDialog",true); 
            return;
        }
        var valid = true;
        var duplicateErrorMessage = false ; 
        valid = helper.helperMethod(component , valid);
        var allValid = true;
        var allValidAction = true;
        var jsonListForPRN = [];
        var jsonListForTaper = [];
        var jsonListForAOrder = [];
        var oldJsonList = component.get("v.jsonList");
        console.log('oldJsonList '+ JSON.stringify(oldJsonList));
        var footerButtonsValid = component.find('footerbtn').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true); 
        var commonJson = [];
        for(var rec in oldJsonList){       
            if(oldJsonList[rec]['types'] == 'PRN'){ 
               // console.log('rec****'+rec);
               // console.log('days****'+JSON.stringify(oldJsonList[rec]['Days'][rec]['Dosage']));
                
                jsonListForPRN.push(oldJsonList[rec]);
                commonJson.push(oldJsonList[rec]);
            }
            else if(oldJsonList[rec]['types'] == 'Taper'){       
                
                jsonListForTaper.push(oldJsonList[rec]);
                commonJson.push(oldJsonList[rec]);
            }
                else{
                    jsonListForAOrder.push(oldJsonList[rec]);
                    commonJson.push(oldJsonList[rec]);
                }            
            
            if(! $A.util.isEmpty(jsonListForPRN)){
                allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    console.log(validSoFar);
                    console.log('s',inputCmp.get('v.validity').valid);
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true); 
            }  
            
            if(! ($A.util.isEmpty(jsonListForTaper))){
                allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    console.log(validSoFar);
                    console.log('s',inputCmp.get('v.validity').valid);
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true); 
            }  
            
            
            if(!($A.util.isEmpty(jsonListForAOrder))){
                var allValidAction = component.find('fieldAction').reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    console.log(validSoFar);
                    console.log('s',inputCmp.get('v.validity').valid);
                    return validSoFar && inputCmp.get('v.validity').valid;
                }, true);
            }
            if(allValid==false || allValidAction==false || footerButtonsValid == false){
                duplicateErrorMessage = true;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Failed!",
                    "message": "Please fill all the mandatory fields."
                });
                toastEvent.fire();
            }
        }
        
        var singleObj = {};
        var userName = component.get("v.userName");
                console.log('username**',userName);
        for(var i =0 ; i<commonJson.length ; i++){
            commonJson[i]['Name'] = userName;
        }
                   
        var jsonString={
            "jsonListForTaper" :	JSON.parse(JSON.stringify(jsonListForTaper)),
            "jsonListForPRN"   :	JSON.parse(JSON.stringify(jsonListForPRN)),
            "jsonListForAOrder"  :	JSON.parse(JSON.stringify(jsonListForAOrder))
        };
        
      //  console.log('Taper bnn gyi'+JSON.stringify(jsonString.jsonListForTaper));
       // console.log('Prn bnn gyi'+JSON.stringify(jsonString.jsonListForPRN));
      //  console.log('Order bnn gyi'+JSON.stringify(jsonString.jsonListForAOrder));
        console.log('accId '+ component.get("v.RecId"));
        //component.set("v.jsonFinal",jsonString);
        
       // console.log('PRN bnn gyi'+JSON.stringify(jsonString.jsonListForPRN));
        //console.log('PRN Json***'+JSON.stringify(jsonString.jsonListForPRN));
        
        if(allValid==true && allValidAction==true && footerButtonsValid==true && valid==true){
            component.set("v.isDisabled",true); 
            var cmpName = component.get("v.RouteForComponent");
            console.log('cmpName***',cmpName);
            if(component.get("v.RouteForComponent")=='fromForm') {
                var cmpEvent = component.getEvent("FormMedicationData"); 
                
                cmpEvent.setParams({ 
                    
                    jsonList : jsonString,
                    selectedUser	:	component.get("v.SelectedUser"),
                    selectedVia	:	component.get("v.SelectedVia")
                    
                }); 
                
                cmpEvent.fire(); 
                component.set("v.OpenPopUp",false);
                component.set("v.isOpen",false);
                component.set("v.openUpdateMedication",false);
             
                
            }
            else if(component.get("v.RouteForComponent")=='prescForm'){
                
                if(endProcedureTime == null )
        {
            component.set("v.showConfirmDialog",true); 
        }
        else{
                var columns = component.get("v.column");
                
                console.log('presclst save***',JSON.stringify(jsonString));
        		columns['prescLst']= JSON.stringify(jsonString);
                columns['selectedUser']= component.get("v.SelectedUser");
                columns['selectedVia']= component.get("v.SelectedVia");
                columns['starttime']= component.get('v.todayString');
                columns['endtime']= component.get('v.endString');

                console.log('columns**',columns);
        		component.set("v.column",columns);
               component.set("v.OpenPopUp",false);
                
                component.set("v.jsonFinal",commonJson);
                component.set("v.jsonValueSet",true);
                component.set("v.openUpdateMedication",false);
                   component.set("v.isOpenMed",false);
                component.set("v.addPresc",false);
                component.set("v.PreTable",true);
                
               //  var cmpEvent = component.getEvent("FormPrescData"); 
                 var cmpEvent = $A.get("e.c:FormPrescData");
                cmpEvent.setParams({ 
                    
                    jsonList : commonJson,
                    selectedUser	:	component.get("v.SelectedUser"),
                    selectedVia	:	component.get("v.SelectedVia")
                    
                }); 
                
                cmpEvent.fire(); 
                console.log('prescForm event fired');

                // Fire one for form too!
                let cmpEventForm = component.getEvent("FormMedicationData"); 
                
                cmpEventForm.setParams({ 
                    
                    jsonList : jsonString,
                    selectedUser	:	component.get("v.SelectedUser"),
                    selectedVia	:	component.get("v.SelectedVia")
                    
                }); 
                
                cmpEventForm.fire();
                // // component.set("v.OpenPopUp",false);
                // // component.set("v.isOpen",false);
                // // component.set("v.openUpdateMedication",false);
            }
            }
            else {
                var action = component.get("c.saveData");
                component.find("Id_spinner").set("v.class" , 'slds-show');
                action.setParams({ 
                    jsonList : JSON.stringify(jsonString),
                    selectedUser	:	component.get("v.SelectedUser"),
                    selectedVia	:	component.get("v.SelectedVia"),
                    accId	: component.get("v.RecId"),
                    starttimeProcedure : component.get('v.todayString'),
                    endtimeProcedure : component.get('v.endString'),
                    formUnId : 'No FormId'
                });
                
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        try {
                            // for n prescriptions only one parent will be there, ex: ["a1JN0000002oT2VMAU"]
                            let parentPrescriptionId = response.getReturnValue()[0];
                            // helper.attachApprovalDataToParentPrescriptionJS(component, event, helper, parentPrescriptionId);

                            // at max 3 approval levels will be there, ex-
                            //'[{"approvalLevel":1,"comments":"comm1","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T14:06:18.758Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"},{"approvalLevel":2,"comments":"comm2","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T14:06:31.832Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"},{"approvalLevel":3,"comments":"comm3","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T14:06:41.884Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"}]'
                            let approvedValues = JSON.stringify(component.get("v.approvedValues"));

                            let action = component.get("c.attachApprovalDataToParentPrescription");
                            action.setParams({
                                parentPrescriptionId: parentPrescriptionId,
                                approvedValues: approvedValues
                            });
                            var startDate = component.find("procedure-start_time").get("v.value");
                            var endDate = component.find("procedure-end_time").get("v.value");
                            action.setCallback(this, function (response) {
                                    var toastEvent = $A.get("e.force:showToast");
                                    if(endDate < startDate){
                                        component.find("Id_spinner").set("v.class" , 'slds-hide');
                                        toastEvent.setParams({
                                            "type" : 'error' , 
                                            "title": "End Date can not be less than the Start Date",
                                            "message": "Creation Failed!"
                                        });
                                    }else{
                                        component.find("Id_spinner").set("v.class" , 'slds-hide');
                                        console.log('Success');
                                        
                                        toastEvent.setParams({
                                            "type" : 'success' , 
                                            "title": "RECORD CREATED SUCCESSFULLY!",
                                            "message": "Creation Successfull!"
                                        });
                                        var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
                                        appEvent.setParams({
                                            "screenType" : "Medication",
                                            "action" : "New",
                                            "recordIds" :response.getReturnValue()
                                        });
                                        appEvent.fire();
                                        component.set("v.OpenPopUp",false);
                                        component.set("v.isOpen",false);
                                        $A.get('e.force:refreshView').fire();
                                    }
                                    toastEvent.fire();
                               
                            });

                            $A.enqueueAction(action);
                        } catch (error) {
                            console.error("Failed to attach approval data: ", error);
                        }

                    }
                    else if(state ==="ERROR"){
                    var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
                    appEvent.setParams({
                        "screenType" : "Medication",
                        "action" : "New",
                        "button" : "Cancel"
                         });
                    appEvent.fire();
                        ////alert(jsonList);
                        console.log('Failure');
                        
                        
                    }
                }); 
                
                $A.enqueueAction(action);
            }
        }
    }
})