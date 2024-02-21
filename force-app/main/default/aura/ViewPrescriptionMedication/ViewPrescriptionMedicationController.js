({
    init : function(component, event, helper) {
        var index  = component.get("v.indexForChange");
        console.log('yadi tene '+JSON.stringify(component.get("v.Papajsonv2")));
        //getNameSPace 
        var nameSpace = 'ElixirSuite__';
        
        //component.set("v.nameSpace",nameSpace);
        console.log('selectedRec'+JSON.stringify(component.get("v.SelectedRec")));
        var records=[];
        records.push(component.get("v.SelectedRec"));
        console.log('records'+JSON.stringify(records));
        console.log('records'+records);
        
       // Parse the JSON data (assuming it's an array with one element)
        var data = records[0];
		var medicationRecord = {
            label: data.ElixirSuite__Medication__r.Name,
            value: data.ElixirSuite__Medication__r.Id
        };
         component.set("v.selectedDrugRecord", medicationRecord);
        
        // // Extract Medication, Dosage, and Route details
        if(data.ElixirSuite__Type__c == 'PRN' || data.ElixirSuite__Type__c == 'Taper'){
        var dosageRecord = {
            label: data.ElixirSuite__Dosage1__r.Name,
            value: data.ElixirSuite__Dosage1__r.Id
        };

        var routeRecord = {
            label: data.ElixirSuite__Route_New_1__r.Name,
            value: data.ElixirSuite__Route_New_1__r.Id
        };
		
        // Set the extracted records into the component attributes
       
        component.set("v.selectedDosageRecord", dosageRecord);
        component.set("v.selectedRouteRecord", routeRecord);
    }
        
        var jsonListName = [];
        var usersList = [];
        var jMap = {};
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
        var  mapOfNTimes = {
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
        var keys = []; 
        var keyList = [];
        keyList.push(component.get("v.recordId"));
        console.log(JSON.stringify(keyList));
        
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
            totalDays.push(records[key][nameSpace + 'Frequency__r'].length);
        }
        records.forEach(item => {
            item.medicationName1 = item.ElixirSuite__Medication__r.Name;
            item.medicationNameId=item.ElixirSuite__Medication__r.Id;
            if(item.ElixirSuite__Type__c != 'Action Order' && item.ElixirSuite__Type__c){
            item.Route1 = item.ElixirSuite__Route_New_1__r.Name;
             item.RouteId=item.ElixirSuite__Route_New_1__r.Id;
            item.Dosage1 = item.ElixirSuite__Dosage1__r.Name;
             item.DosageId=item.ElixirSuite__Dosage1__r.Id;
        }
        });
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
                            var checkRepeat = 'After every '+ '\''+ 'n' +'\''+ ' hours';
                            console.log('messageSufCheck'+messageSufCheck);
                            console.log('checkRepeat'+checkRepeat);
            				console.log('countOfRepeat'+countOfRepeat);
            				console.log('tempVar Repeat'+tempVar[nameSpace+'Repeat__c']);
                            var flagCheck ;
                            if(parseInt(messageSufCheck) != countOfRepeat && tempVar[nameSpace+'Repeat__c']!=checkRepeat){
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
                        		console.log('flagCheck'+flagCheck);
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
						    console.log('XYZ'+records[key][nameSpace+"Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"]);
                            if($A.util.isUndefinedOrNull(records[key][nameSpace+"Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"])){
                                console.log('entered in isUndefinedOrNull');
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
							console.log('getRepeatedTimes'+getRepeatedTimes);
                            console.log('getChildCount'+getChildCount);
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
                             console.log('messageSufCheck'+messageSufCheck);
                            var checkRepeat = 'After every '+ '\''+ 'n' +'\''+ ' hours';
                            
                            
                            var flagCheck ;
                             console.log('flagCheck'+flagCheck);
                            if(parseInt(messageSufCheck) != countOfRepeat && tempVar[nameSpace+'Repeat__c']!=checkRepeat){
                                flagCheck = true;
                            }
                             console.log('flagCheck'+flagCheck);
                             console.log('countOfRepeat'+countOfRepeat);
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
                                    strengthList.push(tempVar[strength]);
                                    unitsList.push(tempVar[units]);
                                    dosageList.push(tempVar[dosage]);
                                    console.log('timeList'+JSON.stringify(timeList));
                                    console.log('strengthList'+JSON.stringify(strengthList));
                                    console.log('unitsList'+JSON.stringify(unitsList));
                                    console.log('dosageList'+JSON.stringify(dosageList));
                                    
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
                                    console.log('timeList2'+JSON.stringify(timeList));
                                    console.log('strengthList2'+JSON.stringify(strengthList));
                                    console.log('unitsList2'+JSON.stringify(unitsList));
                                    console.log('dosageList2'+JSON.stringify(dosageList));
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
                                console.log('timeList3'+JSON.stringify(timeList));
                                    console.log('strengthList3'+JSON.stringify(strengthList));
                                    console.log('unitsList3'+JSON.stringify(unitsList));
                                    console.log('dosageList3'+JSON.stringify(dosageList));
                                
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
                             console.log('Dosage Instruction'+records[key][nameSpace+"Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"]);
                            if($A.util.isUndefinedOrNull(records[key][nameSpace+"Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"])){
                                 console.log('Dosage Instruction');
                                handleIfDosageInstructionNotValid  = "1" ; 
                                message = "1 times a day"; 
                                timeList.push("00:00"); 
                                strengthList.push("5mg");
                                dosageList.push("1");
                                unitsList.push("film");
                                console.log('timeList4'+JSON.stringify(timeList));
                                    console.log('strengthList4'+JSON.stringify(strengthList));
                                    console.log('unitsList4'+JSON.stringify(unitsList));
                                    console.log('dosageList4'+JSON.stringify(dosageList));
                            }
                            else {
                                handleIfDosageInstructionNotValid = records[key][nameSpace+"Frequency__r"][i-1][nameSpace+"Dosage_Instruction__c"];
                            }
                            
                           var getRepeatedTimes  = parseInt(records[key][nameSpace+'Number_of_Times_Days_Weeks__c']);
                            var getChildCount = totalDays[key];
                            console.log('getRepeatedTimes'+getRepeatedTimes);
                             console.log('getChildCount'+getChildCount);
                            if(!isExtraChilEvaluated){
                                if(getRepeatedTimes>getChildCount){
                                    var idx =  getRepeatedTimes - getChildCount ;
                                    for(var l=1 ; l<=idx; l ++){
                                        jsonInside = { 
                                            "times" : timeList,
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
                                jsonInside = { 
                                    "times" : timeList,
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
                                    jsonInside = {
                                        "times" : timeList,
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
                                    console.log('json Days'+JSON.stringify(jsonInsideList));
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
                        
                        	console.log('medicationName '+records[key]["medicationName1"]);
                			console.log('medicationId '+records[key]["medicationId"]);
                        	jsonList.push(newFilter);
                         	console.log('jsonList '+JSON.stringify(jsonList));
                        
                        
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
                            var checkRepeat = 'After every '+ '\''+ 'n' +'\''+ ' hours';
                            
                            
                            var flagCheck ;
                            if(parseInt(messageSufCheck) != countOfRepeat && tempVar[nameSpace+'Repeat__c']!=checkRepeat){
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
                                        jsonInside = {
                                            "times" : timeList,
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
                                    numberOfTimesCount++;
                                    console.log('json Days'+JSON.parse(JSON.stringify(jsonInsideList))); 
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
                                        "medicationName" : records[key]['medicationName1'],
                                        "medicationId" : records[key]['medicationNameId'], 
                                         "types" : records[key][nameSpace+'Type__c'],
                                         "startDate" : today,
                                         "dispenseExpectedSupplyDuration" : records[key][nameSpace+'Number_of_Times_Days_Weeks__c'],
                                         "afterDischarge" : records[key][nameSpace+'After_Discharge__c'],
										 "accountId" : records[key][nameSpace+'Account__c'],  
                                         "PRNdisplay": records[key][nameSpace+"PRN__c"],
                                         "MARdisplay" : marCheck,
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
                            
                            jsonList.push(newFilter);
                            console.log('jsonList '+JSON.stringify(jsonList));
                            
                        }       
                     
                     
                 }
       console.log('json '+(JSON.stringify(jsonList)));
       component.set("v.accId",records[0][nameSpace+'Account__c']);
       console.log('final wali final  '+'1' + JSON.stringify(jsonList[0]));
       component.set("v.jsonList",jsonList[0]); 
       component.set("v.replicaHold",JSON.parse(JSON.stringify(jsonList[0])));  
       console.log('json '+'2');
       component.set("v.jsonListCopy",JSON.parse(JSON.stringify(jsonList[0])));
       console.log('json '+'3');
       component.set("v.jsonSize",JSON.parse(JSON.stringify(jsonList[0])));
       console.log('json '+(JSON.stringify(jsonList)));
       //JSON manipulation ends
       var action = component.get("c.fetchData");
       component.find("Id_spinner").set("v.class" , 'slds-show');
       action.setParams({ 
           "keys"	: keyList
       });
       action.setCallback(this, function(response){
           var apiValues = [];
           var state = response.getState();
           
           if(state === "SUCCESS"){
               component.find("Id_spinner").set("v.class" , 'slds-hide');
               console.log('Success');
               var allFieldList = response.getReturnValue()['picklistValues']; 
               
               //records = response.getReturnValue()['listOfRecs'];
               
               console.log('all f '+allFieldList);
               //console.log('records '+records);
               usersList = response.getReturnValue()['listOfUsers'];
               console.log('usersList '+usersList);
               console.log('records '+JSON.stringify(response.getReturnValue().listOfRecs));
               for(var key in allFieldList){
                   if(key == nameSpace+'Prescription_Order__c'){
                       for(var keyInside in allFieldList[key]){
                           console.log(keyInside);
                           if(keyInside.toUpperCase() == nameSpace.toUpperCase()+'DOSAGE_FORM__C'){
                               console.log('records '+JSON.stringify(allFieldList[key][keyInside]));
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
                            if(keyInside.toUpperCase() == nameSpace.toUpperCase()+'ROUTE_NEW_1__C'){
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
                               console.log('allFieldList[key][keyInside]'+allFieldList[key][keyInside]);
                               component.set("v.RepeatPicklistValues",allFieldList[key][keyInside]);
                               
                           }
                           if(keyInside.toUpperCase() ==  nameSpace.toUpperCase()+'DOSAGE_INSTRUCTION__C'){
                               console.log('allFieldList[key][keyInside] dosage'+allFieldList[key][keyInside]);
                               component.set("v.DosagePicklistValues",allFieldList[key][keyInside]); 
                           }  
                           if(keyInside.toUpperCase() ==  nameSpace.toUpperCase()+'UNIT_1__C'){
                               component.set("v.UnitsValues",allFieldList[key][keyInside]); 
                           }
                           
                       }
                   }
               }
                
                
                
                component.set("v.AllUsers",usersList);
                helper.helperMethod(component, event, helper);
                
            }
            else if(state ==="ERROR"){
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                console.log('Failure');
            }
        });        
       $A.enqueueAction(action);
       
       
   },
    hideExampleModal : function(component, event, helper) {
        console.log('recId '+component.get("v.accId"));
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef:"ElixirCS:MedicationListView",
            componentAttributes: {
                recordVal : component.get("v.accId"),
                
            }
        });
        evt.fire();
        component.set("v.OpenPopUp",false);
        if(component.get("v.viewflag") == true){
            $A.get('e.force:refreshView').fire();
        }
        
    },
    DaysSelectionEvent  :  function(component,event,helper){
        //console.log('SelectedUser '+component.get("v.SelectedUser"));
        console.log('Days');
        var value = event.getSource().get("v.value");
        // var upperIndex = event.getSource().get("v.name");     
        console.log('value  '+value);
        
        var jsonListCopy = component.get("v.jsonListCopy");
        
        var jsonList = component.get("v.jsonList");
        //   var jsonListCopy = component.get("v.replicaHold");
        
        
        var timeList = [];
        var strengthList = [];
        var unitsList = [];
        var dosageList = [];
        var startingIndex;
        var wrapper ={};
        var message;
        
        startingIndex = jsonListCopy["dispenseExpectedSupplyDuration"];
        console.log('st'+startingIndex);
        if(startingIndex == ''){
            startingIndex=0;
            
            wrapper = { "Dosage_Instruction" :  "1",    
                       "Strength" : ['5mg'],
                       "Units" : ['film'],
                       "Dosage" : ['1'],
                       "times" : ['00:00:00.000'],
                       "Repeat" : '\''+'n'+'\''+ ' times a day'}    
            
        }else{
            wrapper = jsonList["Days"][0]; 
        }
        console.log('startingIndex '+startingIndex);
        
        if((jsonListCopy["dispenseExpectedSupplyDuration"] ==''  || value!='' && parseInt(startingIndex) < parseInt(value))){
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
                3  : 	8,
                2  :	12,
                1  :    24
                
            }
            for(var i=0;i<value-startingIndex;i++){
                var jsonInside = {};
                jsonInside = {//"Id"	:	wrapper['Id'],
                    "times" : timeList,                       
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
                    if(!$A.util.isUndefinedOrNull(jsonList['Days'][index])){
                        console.log('if');
                        jsonList['Days'][index] = (JSON.parse(JSON.stringify(jsonInsideList[i])));
                        
                    }
                    else{
                        console.log('else');
                        jsonList['Days'].push((JSON.parse(JSON.stringify(jsonInsideList[0]))));
                    }
                    i++;
                    
                }
            }
            
            console.log('After if1');
            jsonList.dispenseExpectedSupplyDuration = value;
            
            
        }
        else{
            if(value==''){
                jsonList['Days'] = []; 
            }else{
                jsonList['Days'].splice(value,startingIndex-value);             
            }
            jsonList.dispenseExpectedSupplyDuration = value;
            console.log('else down');  
        }
        var dateConvert = new Date(jsonList['startDate']);
        dateConvert.setDate(dateConvert.getDate() + parseInt(value));
        var dd = String(dateConvert.getDate()).padStart(2, '0');
        var mm = String(dateConvert.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = dateConvert.getFullYear();
        
        dateConvert = yyyy +'-'+ mm +'-' + dd ;
        
        jsonList["endDate"] = dateConvert;   
        
        //  }
        console.log('Finished '+JSON.stringify(jsonList));
        component.set("v.jsonList",jsonList);
        component.set("v.jsonListCopy",JSON.parse(JSON.stringify(jsonList)));
        var papa;
        var v2  = component.get("v.Papajsonv2");
        if($A.util.isEmpty(v2)){
            papa = component.get("v.Papajson");
        }
        else {
            papa = component.get("v.Papajsonv2");
        }
        var papaCopy = JSON.parse(JSON.stringify(papa));
        for(var i in papaCopy){
            if(papaCopy[i]['medicationName'] == jsonList['medicationName']){
                console.log('papaCopy[i] '+papaCopy[i]['medicationName']);
                console.log('jsonList '+ jsonList['medicationName']);
                papa.splice(i,1);
                papa.push(jsonList);
            }           
        }
        component.set("v.Papajsonv2",JSON.parse(JSON.stringify(papa)));
        console.log('papa updated 1234 '+JSON.stringify(component.get("v.Papajsonv2")));
        var cmpEvent = component.getEvent("ListOfEditedPrescription");
        // Get the value from Component and set in Event
        cmpEvent.setParams( { "PresRecord" : component.get("v.Papajsonv2") } );
        cmpEvent.fire();        
        
        
    },
    GetFrequency	:	function(component,event,helper){       
        var jsonList = component.get("v.jsonList"); 
        var value = event.getSource().get("v.value");
        //  if(jsonList['types'] == 'Taper'){
        
        var DayIndex = event.getSource().get("v.name");       
        jsonList.Days[DayIndex]['Repeat'] = value;
        var jsonInside = jsonList.Days[DayIndex];  
        var map = {};
        if(jsonList.Days[DayIndex]['Repeat'] == 'After every '+ '\''+ 'n' +'\''+ ' hours' || jsonList.Days[DayIndex]['Repeat'] == '\''+'n'+'\''+ ' times a day'){
            jsonInside.Strength=[];
            jsonInside.Units=[];
            jsonInside.Dosage=[]
            jsonInside.times = [];
            jsonInside.times = ['00:00:00.000'];    
            if(jsonList.Days[DayIndex]['Repeat'] == 'After every '+ '\''+ 'n' +'\''+ ' hours' ){
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
                    3  : 	8,
                    2  :	12,
                    1  :    24
                    
                }
                jsonInside.times = ["12:00:00.000","24:00:00.000"];    
                jsonInside.Strength = ['5mg','5mg'];
                jsonInside.Units = ['film','film'];
                jsonInside.Dosage = ['1','1'];
                jsonInside.Dosage_Instruction = parseInt("12"); 
                jsonList.Days[DayIndex]['textMessage'] = ' After every 12 hours';
            }
            else if(jsonList.Days[DayIndex]['Repeat'] == '\''+'n'+'\''+ ' times a day'){
                jsonInside.Dosage_Instruction = parseInt("1");     
                jsonInside.Strength = ['5mg'];
                jsonInside.Units = ['film'];
                jsonInside.Dosage = ['1'];
                jsonInside.times = ['00:00:00.000'];    
                jsonList.Days[DayIndex]['textMessage'] = ' 1 times a day';
            }
            
        }
        
        else{
            jsonList.Days[DayIndex]['textMessage'] = ' '; 
            map = {'After lunch' : ['13:30:00.000'],
                   'After supper/Dinner'	: ['19:00:00.000'],
                   'Before Breakfast'	: ['06:30:00.000'],
                   'Custom pheno' 		: ['09:00:00.000','15:00:00.000','22:00:00.000'],
                   'Once a day (AM)'	: ['09:00:00.000'],
                   'Once  a day (HS)'	: ['22:00:00.000'],
                   'Once a day midday'	: ['17:00:00.000'],
                   'Once a day (Qam)' 	: ['09:00:00.000'],
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
        
        
        
        component.set("v.jsonList",jsonList);
        console.log('json List '+JSON.stringify(jsonList));
        var papa;
        var v2  = component.get("v.Papajsonv2");
        if($A.util.isEmpty(v2)){
            papa = component.get("v.Papajson");
        }
        else {
            papa = component.get("v.Papajsonv2");
        }
        var papaCopy = JSON.parse(JSON.stringify(papa));
        console.log('papaCopy '+papaCopy);
        for(var i in papaCopy){
            if(papaCopy[i]['medicationName'] == jsonList['medicationName']){
                papa.splice(i,1);
                papa.push(jsonList);
            }           
        }
        component.set("v.Papajsonv2",JSON.parse(JSON.stringify(papa)));
        console.log('papa updated 1234 '+JSON.stringify(component.get("v.Papajsonv2")));
        var cmpEvent = component.getEvent("ListOfEditedPrescription");
        // Get the value from Component and set in Event
        cmpEvent.setParams( { "PresRecord" : component.get("v.Papajsonv2") } );
        cmpEvent.fire();        
        
    },
    GettimesPrn  	:	function(component,event,helper){
        
        var value = event.getSource().get("v.value");
        var jsonList = component.get("v.jsonList");
        var message;
        jsonList['singleRecForPrn'][0]['Dosage_Instruction'] = value;
        var messagePre = jsonList['singleRecForPrn'][0]['Repeat'];
        if(messagePre == 'After every '+ '\''+ 'n' +'\''+ ' hours'){
            message = ' After every ' + value + ' hours';
        }else if(messagePre == '\''+'n'+'\''+ ' times a day'){
            message = ' '+value +' times a day' ;
        }else{
            message = '';
        }
        
        jsonList['singleRecForPrn'][0]['textMessage'] = message;
        console.log(JSON.stringify(jsonList));
        component.set("v.jsonList",jsonList);
        var papa;
        var v2  = component.get("v.Papajsonv2");
        if($A.util.isEmpty(v2)){
            papa = component.get("v.Papajson");
        }
        else {
            papa = component.get("v.Papajsonv2");
        }
        var papaCopy = JSON.parse(JSON.stringify(papa));
        for(var i in papaCopy){
            if(papaCopy[i]['medicationName'] == jsonList['medicationName']){
                papa.splice(i,1);
                papa.push(jsonList);
            }           
        }
        component.set("v.Papajsonv2",JSON.parse(JSON.stringify(papa)));
        console.log('papa updated 1234 '+JSON.stringify(component.get("v.Papajsonv2")));
        var cmpEvent = component.getEvent("ListOfEditedPrescription");
        // Get the value from Component and set in Event
        cmpEvent.setParams( { "PresRecord" : component.get("v.Papajsonv2") } );
        cmpEvent.fire();
    },
    GetTimes		:	function(component,event,helper){
        console.log('gettimes');
        
        var value = event.getSource().get("v.value");
        var DayIndex = event.getSource().get("v.name");
        var timeList = [];
        var strengthList = [];
        var unitsList = [];
        var dosageList = [];
        
        
        var mapOfEveryHours = {};
        var mapOfNTimes = {};
        var jsonList = component.get("v.jsonList");
        if(jsonList.Days[DayIndex]['Repeat'] == 'After every '+ '\''+ 'n' +'\''+ ' hours'){
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
            jsonList.Days[DayIndex]['textMessage'] = ' After every '+ value.toString() +' hours';
            timeList = mapOfEveryHours[value];
        }
        else if(jsonList.Days[DayIndex]['Repeat'] == '\''+'n'+'\''+ ' times a day'){
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
            jsonList.Days[DayIndex]['textMessage'] =  ' ' + value.toString() +' times a day';
            timeList = mapOfNTimes[value];
        }
            else{
                jsonList.Days[DayIndex]['textMessage'] = '';
            }
        
        for(var i=1;i<=timeList.length;i++){           
            strengthList.push("5mg");
            unitsList.push("film");
            dosageList.push("1");  
        }
        
        console.log('DayIndex '+DayIndex);
        console.log('jsonList '+JSON.stringify(jsonList));
        
        console.log(JSON.stringify(jsonList.Days[DayIndex]));
        var jsonInside = (jsonList.Days)[DayIndex];
        
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
        var papa;
        var v2  = component.get("v.Papajsonv2");
        if($A.util.isEmpty(v2)){
            papa = component.get("v.Papajson");
        }
        else {
            papa = component.get("v.Papajsonv2");
        }
        var papaCopy = JSON.parse(JSON.stringify(papa));
        for(var i in papaCopy){
            if(papaCopy[i]['medicationName'] == jsonList['medicationName']){
                papa.splice(i,1);
                papa.push(jsonList);
            }           
        }
        component.set("v.Papajsonv2",JSON.parse(JSON.stringify(papa)));
        console.log('papa updated 1234 '+JSON.stringify(component.get("v.Papajsonv2")));
        var cmpEvent = component.getEvent("ListOfEditedPrescription");
        // Get the value from Component and set in Event
        cmpEvent.setParams( { "PresRecord" : component.get("v.Papajsonv2") } );
        cmpEvent.fire();
        
        
    },
    editInsideData	:	function(component,event,helper){
        console.log('EditInsideData');
        var index = event.getSource().get("v.name");
        var arr = index.split('$');
        var allValid = true;
        if(arr[2]=="STRENGTH"){
            /* allValid = component.find('fieldstrength').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);*/
        }
        if(allValid == true){
            
            var value = event.getSource().get("v.value");
            console.log('index '+index);
            console.log('value '+value);
            if(!$A.util.isUndefinedOrNull(value)){
                var array = index.split('$');
                var repeatIndex = array[0];
                var DayIndex = array[1];
                var fieldName = array[2];
                
                var jsonList = component.get("v.jsonList");
                var jsonString ;
                //  if(jsonList["types"] == 'Taper'){
                var jsonInside = (jsonList.Days)[DayIndex];
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
                //  }
                
                
                
                component.set("v.jsonList",jsonList);
                var papa;
                var v2  = component.get("v.Papajsonv2");
                if($A.util.isEmpty(v2)){
                    papa = component.get("v.Papajson");
                }
                else {
                    papa = component.get("v.Papajsonv2");
                }
                var papaCopy = JSON.parse(JSON.stringify(papa));
                for(var i in papaCopy){
                    if(papaCopy[i]['medicationName'] == jsonList['medicationName']){
                        papa.splice(i,1);
                        papa.push(jsonList);
                    }           
                }
                component.set("v.Papajsonv2",JSON.parse(JSON.stringify(papa)));
                console.log('papa updated 1234 '+JSON.stringify(component.get("v.Papajsonv2")));
                var cmpEvent = component.getEvent("ListOfEditedPrescription");
                // Get the value from Component and set in Event
                cmpEvent.setParams( { "PresRecord" : component.get("v.Papajsonv2") } );
                cmpEvent.fire();
            }
        }
        console.log('Pushed'+JSON.stringify(component.get("v.jsonList")));
        
        
    },
    handleRecordForm :  function(component, event, helper) {
        component.set("v.ShowEditable",true);
    },
    recordEdit : function(component, event, helper){
        var name = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        var dad  = component.get("v.Papajson");
        var jsonList = component.get("v.jsonList");
        if(name == 'startDate' || name=="Days"){
            if(jsonList['dispenseExpectedSupplyDuration'] != ''){
                var dte = new Date(jsonList['startDate']);
                dte.setDate(dte.getDate() + parseInt(jsonList['dispenseExpectedSupplyDuration']));
                var dd = String(dte.getDate()).padStart(2, '0');
                var mm = String(dte.getMonth() + 1).padStart(2, '0'); //January is 0!
                var yyyy = dte.getFullYear();          
                dte = yyyy +'-'+ mm +'-' + dd ;
                jsonList['endDate'] = dte;
            }
            else {
                jsonList['endDate'] = ''; 
            }
        } 
        jsonList[name] = value; 
        component.set("v.jsonList",jsonList);
        var papa;
        console.log('jsonList '+JSON.stringify(component.get("v.jsonList")));
        console.log('Papajsonv2 '+JSON.stringify(component.get("v.Papajsonv2")));
        console.log('Papajson '+JSON.stringify(component.get("v.Papajson")));
        var v2  = component.get("v.Papajsonv2");
        if($A.util.isEmpty(v2)){
            papa = component.get("v.Papajson");
        }
        else {
            papa = component.get("v.Papajsonv2");
        }
        var papaCopy = JSON.parse(JSON.stringify(papa));
        console.log('papaCopy '+papaCopy);
        console.log('jsonList[medicationName] '+jsonList['medicationName']);
        for(var i in papaCopy){
             console.log('papaCopy[i][medicationName] '+papaCopy[i]['medicationName']);
            if(papaCopy[i]['medicationName'] == jsonList['medicationName']){
                papa.splice(i,1);
                papa.push(jsonList);
            }           
        }
        component.set("v.Papajsonv2",JSON.parse(JSON.stringify(papa)));
        console.log('papa updated 1234 '+JSON.stringify(component.get("v.Papajsonv2")));
        var cmpEvent = component.getEvent("ListOfEditedPrescription");
        // Get the value from Component and set in Event
        cmpEvent.setParams( { "PresRecord" : component.get("v.Papajsonv2") } );
        cmpEvent.fire();
        console.log(JSON.stringify(jsonList));
        
    },
    recordEditPRN	: function(component, event, helper){
         console.log('after');    
        var name = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        console.log('below');
        
        if(!$A.util.isUndefinedOrNull(value)){    
            var jsonList = component.get("v.jsonList");
            jsonList['singleRecForPrn'][0][name] = value;
            
            component.set("v.jsonList",jsonList);
            var papa;
            var v2  = component.get("v.Papajsonv2");
            if($A.util.isEmpty(v2)){
                papa = component.get("v.Papajson");
            }
            else {
                papa = component.get("v.Papajsonv2");
            }
            var papaCopy = JSON.parse(JSON.stringify(papa));
            for(var i in papaCopy){
                if(papaCopy[i]['medicationName'] == jsonList['medicationName']){
                    papa.splice(i,1);
                    papa.push(jsonList);
                }           
            }
            component.set("v.Papajsonv2",JSON.parse(JSON.stringify(papa)));
            console.log('papa updated 1234 '+JSON.stringify(component.get("v.Papajsonv2")));
            var cmpEvent = component.getEvent("ListOfEditedPrescription");
            // Get the value from Component and set in Event
            cmpEvent.setParams( { "PresRecord" : component.get("v.Papajsonv2") } );
            cmpEvent.fire();
        }
        console.log(JSON.stringify(component.get("v.jsonList")));
    },
    ActionOrderEdit	:	function(component, event, helper){
        var index = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        var repeatIndex;
        var jsonList = component.get("v.jsonList");
        var array = index.split('$');
        if(!$A.util.isUndefinedOrNull(value)){
            if(array.length == 2){
                repeatIndex = array[0];
                jsonList.singleRecForActionOrder[0].StartTime[repeatIndex] = value;
            }
            else if(array.length == 1){
                
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
                jsonList.singleRecForActionOrder[0]['StartTime'] = mapOfNTimes[value];
            }
            console.log(JSON.stringify(jsonList));
        }
        component.set("v.jsonList",jsonList); 
        var papa;
        var v2  = component.get("v.Papajsonv2");
        if($A.util.isEmpty(v2)){
            papa = component.get("v.Papajson");
        }
        else {
            papa = component.get("v.Papajsonv2");
        }
        var papaCopy = JSON.parse(JSON.stringify(papa));
        for(var i in papaCopy){
            if(papaCopy[i]['medicationName'] == jsonList['medicationName']){
                papa.splice(i,1);
                papa.push(jsonList);
            }           
        }
        component.set("v.Papajsonv2",JSON.parse(JSON.stringify(papa)));
        console.log('papa updated 1234 '+JSON.stringify(component.get("v.Papajsonv2")));
        var cmpEvent = component.getEvent("ListOfEditedPrescription");
        // Get the value from Component and set in Event
        cmpEvent.setParams( { "PresRecord" : component.get("v.Papajsonv2") } );
        cmpEvent.fire();
    },
    utilityEventMethod : function(component, event, helper){
        
        var dad  = component.get("v.Papajson");
        var jsonList = component.get("v.jsonList");
        component.set("v.jsonList",jsonList);
        var papa;
        var v2  = component.get("v.Papajsonv2");
        if($A.util.isEmpty(v2)){
            papa = component.get("v.Papajson");
        }
        else {
            papa = component.get("v.Papajsonv2");
        }
        var papaCopy = JSON.parse(JSON.stringify(papa));
        for(var i in papaCopy){
            if(papaCopy[i]['medicationName'] == jsonList['medicationName']){
                papa.splice(i,1);
                papa.push(jsonList);
            }           
        }
        component.set("v.Papajsonv2",JSON.parse(JSON.stringify(papa)));
        console.log('papa updated 1234 '+JSON.stringify(component.get("v.Papajsonv2")));
        var cmpEvent = component.getEvent("ListOfEditedPrescription");
        // Get the value from Component and set in Event
        cmpEvent.setParams( { "PresRecord" : component.get("v.Papajsonv2") } );
        cmpEvent.fire();
    },
    SetJSONForParent :  function(component, event, helper){
        
    },
    Save  : function(component, event, helper){
        var nspc  = component.get("v.orgWideValidNamespace");
        
        if(nspc == ''){
            
        }
        
        
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        console.log('guhj '+component.get("v.recordId"));
        console.log('Initialised');
        
        var jsonListForPRN = [];
        var jsonListForTaper = [];
        var jsonListForAOrder = [];
        var oldJsonList = component.get("v.jsonList");
        var copyToSend = component.get("v.jsonSize");
        var sizeOfOldDays;
        console.log('oldJsonList '+ JSON.stringify(oldJsonList));
        
        if(oldJsonList['types'] == 'PRN'){               
            
            jsonListForPRN.push(oldJsonList);
        }
        else if(oldJsonList['types'] == 'Taper'){       
            
            jsonListForTaper.push(oldJsonList);
        }    
            else if(oldJsonList['types'] == 'Action Order'){
                
                jsonListForAOrder.push(oldJsonList);
            }  
        // For Copy Json
        
        if(copyToSend['types'] == 'Taper'){       
            sizeOfOldDays = copyToSend['Days'].length; 
            
        }     
        
        var jsonString={
            "jsonListForTaper" :	JSON.parse(JSON.stringify(jsonListForTaper)),
            "jsonListForPRN"   :		JSON.parse(JSON.stringify(jsonListForPRN)),
            "jsonListForAOrder" :	JSON.parse(JSON.stringify(jsonListForAOrder))
        };
        console.log('String bnn gyi'+JSON.stringify(jsonString));
        if(allValid == false){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Failed!",
                "message": "Please fill all the mandatory fields."
            });
            toastEvent.fire();
        }
        if(allValid==true){
            component.set("v.isDisabled",true); 
            var action = component.get("c.saveData");
            action.setParams({ 
                keys	:  component.get("v.recordId"),
                jsonList : JSON.stringify(jsonString),
                sizeOfOldDays  : sizeOfOldDays,
                selectedUser	:	component.get("v.SelectedUser"),
                selectedVia	:	component.get("v.SelectedVia")
                
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    
                    console.log('Success');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The record has been created successfully."
                    });
                    toastEvent.fire();

                    var appEvent = $A.get("e.c:Elixir_RefreshViewsGenericAppEvt");
                    appEvent.setParams({
                        "screenType" : "Medication",
                        "action" : "Edit" });
                    appEvent.fire();

                    component.set("v.OpenPopUp",false);
                    var compDef ;
                    var refreshEvt; 
                    if(nspc == ''){
                        compDef = 'MedicationListView';
                        refreshEvt = "e.RefreshViewEvent";
                    }
                    else {
                        compDef =  nspc + ':' + 'MedicationListView';
                        refreshEvt = 'e.' + nspc + ':' + 'RefreshViewEvent';
                    }
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef:compDef,
                        componentAttributes: {
                            recordVal : component.get("v.accId")
                        }
                    });
                    evt.fire();
                    
                    //	
                    var appEvent = $A.get(refreshEvt);
                    appEvent.setParams({ "message" : true });
                    appEvent.fire();      
                    
                }
                else if(state ==="ERROR"){
                    ////alert(jsonList);
                    console.log('Failure');
                    
                }
            });        
            $A.enqueueAction(action);
        }
    }
    
})