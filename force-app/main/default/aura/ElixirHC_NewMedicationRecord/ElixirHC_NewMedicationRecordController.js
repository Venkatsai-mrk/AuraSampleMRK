({
    init : function(component, event, helper) {
        console.log('Init ');
        var keys = []; 
        var totalDays = [];
        var jsonListName = [];
        var usersList = [];
        var jMap = {};
        var nameSpace = component.get("v.orgWideValidNamespace");
        var nameSpaceElixir ='ElixirSuite__';
        var accoundId=component.get("v.RecId");
		console.log('accoundId'+accoundId);
        var records = [{"Id":"a0Y3i000000WbbKEAS","ElixirSuite__Drug_Name__c":"",
                        "ElixirSuite__Reason_new__c":"","ElixirSuite__Type__c":"PRN",
                        "ElixirSuite__Start_Date__c":"","ElixirSuite__Number_of_Times_Days_Weeks__c":1,
                        "ElixirSuite__After_Discharge__c":false,"ElixirSuite__Route__c":"",
                        "ElixirSuite__Warning__c":"",
                        "ElixirSuite__Route_New__c" :"","ElixirSuite__Dosage_Form__c":"",
                        "ElixirSuite__Frequency__r":
                        [{"ElixirSuite__Prescription_Order__c":"",
                          "ElixirSuite__Strength__c": "",
                          "ElixirSuite__Dosage_Instruction__c" : 1,
                          "ElixirSuite__Frequency_Unit__c":"",
                          "ElixirSuite__Frequency_Value__c":"",
                         
                          "Repeat__c":'\''+'n'+'\''+ ' times a day'}]
                       }];
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
                
                jsonInsideList = [];                    
                jsonInside = {};
                var message;
                console.log(JSON.stringify(records[0]));
                console.log(JSON.stringify(records[0][nameSpaceElixir+"Frequency__r"]));
                var tempVar = records[0][nameSpaceElixir+"Frequency__r"][0];           
                console.log(JSON.stringify(tempVar));
                // for message
                var messagePre = records[0][nameSpaceElixir+'Frequency__r'][0][nameSpaceElixir+"Repeat__c"];
                var messageSuf = records[0][nameSpaceElixir+"Frequency__r"][0][nameSpaceElixir+"Dosage_Instruction__c"];
                if(messagePre == 'After every '+ '\''+ 'n' +'\''+ ' hours'){
                    message = ' After every ' + messageSuf + ' hours';
                }else if(messagePre == '\''+'n'+'\''+ ' times a day'){
                    message = ' ' +messageSuf +' times a day' ;
                }
                    else{
                        message = '';
                    }
                
                jsonInside = {
                    "UnitsForPrn" :tempVar[nameSpaceElixir+'Frequency_Unit__c'],
                    "StrengthForPrn" : tempVar[nameSpaceElixir+'Strength__c'], 
                    "DosageForPrn" : tempVar[nameSpaceElixir+'Frequency_Value__c'],
                    "Repeat":tempVar[nameSpaceElixir+"Repeat__c"],
                    "Dosage_Instruction" : tempVar[nameSpaceElixir+"Dosage_Instruction__c"],
                    "textMessage"  :  message,
                   
                }  
                jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
        
        var erDate = todayDate;
        erDate.setDate(erDate.getDate() + parseInt(records[0][nameSpaceElixir+'Number_of_Times_Days_Weeks__c']));
        //console.log('erDate'+erDate);
        var dd = String(erDate.getDate()).padStart(2, '0');
        var mm = String(erDate.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = erDate.getFullYear();
        erDate = yyyy +'-'+ mm +'-' + dd ;
                 var jsonInside = {};
            var newFilter ={};
          
            var jsonInsideList = [];
            var finalKeys =[];
         
            
            jsonInsideList = [];                    
            
            var string ;
            var timeList = [];
            var strengthList = [];
            var unitsList = [];
            var dosageList = [];
            
            timeList.push("00:00:00.000");
            strengthList.push("5mg");
            unitsList.push("Tablet");
            dosageList.push("1");  
          
            
            jsonInside = {"times" : timeList,
                          "Strength" : strengthList,
                          "Units" : unitsList, 
                          "Dosage" : dosageList,                                     
                          "Repeat": '\''+'n'+'\''+ ' times a day',
                          "Dosage_Instruction" : 1,
                          "textMessage"  :  '1'+ ' times a day'
                         }  
            jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
           var todayDate = new Date();
        var dd = String(todayDate.getDate()).padStart(2, '0');
        var mm = String(todayDate.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = todayDate.getFullYear();
        var today = yyyy +'-'+ mm +'-' + dd ;
        //end date
        var erDate = new Date;
        erDate.setDate(erDate.getDate() + parseInt(records[0][nameSpaceElixir+'Number_of_Times_Days_Weeks__c']));
        //console.log('erDate'+erDate);
        var dd = String(erDate.getDate()).padStart(2, '0');
        var mm = String(erDate.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = erDate.getFullYear();
        erDate = yyyy +'-'+ mm +'-' + dd ;
        
            newFilter = {
                "medicationName" : records[0][nameSpaceElixir+'Medication__c'], 
                "types" : "PRN",
                "startDate" : today,
                "dispenseExpectedSupplyDuration" : 1,
                "afterDischarge" : records[0][nameSpaceElixir+'After_Discharge__c'],
                "Route" : records[0][nameSpaceElixir+"Route_New__c "],
                "Warning"	: records[0][nameSpaceElixir+"Warning__c "],
                "dosageForm" : records[0][nameSpaceElixir+'Dosage1__c'],
                "reasonLabel" : records[0][nameSpaceElixir+'Reason_new__c'],
                "endDate" : erDate,
                "Days" : JSON.parse(JSON.stringify(jsonInsideList))
               }
            
            jsonList.push(newFilter);
                
                component.set("v.jsonList",jsonList[0]);
        		
               
                console.log('2nd component '+JSON.stringify(component.get("v.jsonList")));
    
        var action = component.get("c.fetchData");
        action.setParams({ 
        });
        action.setCallback(this, function(response){
            var apiValues = [];
            var state = response.getState();
            
            if(state === "SUCCESS"){
                console.log('Success');
                var allFieldList = response.getReturnValue()['picklistValues']; 
                // records = response.getReturnValue()['listOfRecs'];
                
                //console.log('records '+records);
                // usersList = response.getReturnValue()['listOfUsers'];
                //console.log('records '+JSON.stringify(response.getReturnValue().listOfRecs));
                for(var key in allFieldList){
                    if(key ==nameSpaceElixir+'Prescription_Order__c'){
                        for(var keyInside in allFieldList[key]){
                            console.log(keyInside);
                            if(keyInside.toUpperCase() == nameSpaceElixir.toUpperCase()+'DOSAGE1__C'){
                                component.set("v.dosageFormPicklistValues",allFieldList[key][keyInside]);
                            }
                            if(keyInside.toUpperCase() == nameSpaceElixir.toUpperCase()+'TYPE__C'){
                                component.set("v.typePicklistValues",allFieldList[key][keyInside]); 
                            }
                            /*if(keyInside.toUpperCase() == 'DISPENSEEXPECTEDSUPPLYDURATION__C'){
                                component.set("v.DaysPicklistValues",allFieldList[key][keyInside]); 
                            }*/
                            if(keyInside.toUpperCase() == nameSpaceElixir.toUpperCase()+'NUMBER_OF_TIMES_DAYS_WEEKS__C'){
                                component.set("v.DaysPicklistValues",allFieldList[key][keyInside]);
                            }
                            if(keyInside.toUpperCase() == nameSpaceElixir.toUpperCase()+'ROUTE_NEW__C'){
                                component.set("v.RouteList",allFieldList[key][keyInside]);
                            }
                            if(keyInside.toUpperCase() == nameSpaceElixir.toUpperCase()+'ORDERED_VIA__C'){
                                component.set("v.OrderedViaList",allFieldList[key][keyInside]);
                            }
                            
                        }
                        
                    } 
                    if(key == nameSpaceElixir+'Frequency__c'){
                        for(var keyInside in allFieldList[key]){
                            //console.log('key1 '+keyInside +allFieldList[key]);
                            if(keyInside.toUpperCase() == nameSpaceElixir.toUpperCase()+'REPEAT__C'){
                                console.log('key '+keyInside);
                                component.set("v.RepeatPicklistValues",allFieldList[key][keyInside]);
                                
                            }
                            if(keyInside.toUpperCase() ==  nameSpaceElixir.toUpperCase()+'DOSAGE_INSTRUCTION__C'){
                                component.set("v.DosagePicklistValues",allFieldList[key][keyInside]); 
                            }  
                            if(keyInside.toUpperCase() ==  nameSpaceElixir.toUpperCase()+'UNIT_1__C'){
                                //allFieldList[key][keyInside].unshift("Choose One...");
                                component.set("v.UnitsValues",allFieldList[key][keyInside]); 
                            }
                            
                        }
                    }
                }
                
                
                
            
            }
            else if(state ==="ERROR"){
                console.log('Failure');
            }
        });        
        $A.enqueueAction(action);
        
        component.set("v.jsonList",jsonList[0]);
        console.log('parent JSON --> '+JSON.stringify( component.get("v.jsonList",jsonList[0])));
    //    if(jsonList[0].types == "Taper"){
             component.set("v.jsonListCopy",JSON.parse(JSON.stringify(jsonList[0])));
     //   }
     
    },
    hideExampleModal : function(component, event, helper) {
        //component.set("v.OpenPopUp",false);
        //component.set("v.isOpen",false);
        var createEvent = component.getEvent("HandleBackInMedicaion");
        //createEvent.setParams({ "expense": newExpense });
        createEvent.fire();
        component.set("v.isOpen",false);
    },
    DaysSelectionEvent  :  function(component,event,helper){
        //console.log('SelectedUser '+component.get("v.SelectedUser"));
        console.log('Days');
        var value = event.getSource().get("v.value");
        //var upperIndex = event.getSource().get("v.name");     
        console.log('value  '+value);
        var jsonList = component.get("v.jsonList");
		var erDate = new Date(Date.parse(jsonList.startDate));
        erDate.setDate(erDate.getDate() + parseInt(value));
        //console.log('erDate'+erDate);
        var dd = String(erDate.getDate()).padStart(2, '0');
        var mm = String(erDate.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = erDate.getFullYear();
        erDate = yyyy +'-'+ mm +'-' + dd ;
        jsonList.endDate =  erDate ; 
     	var jsonListCopy = component.get("v.jsonListCopy");
     
        var timeList = [];
        var strengthList = [];
        var unitsList = [];
        var dosageList = [];
        var startingIndex;
        var wrapper ={};
        var message;
      /*  if(jsonList["types"] == 'PRN'){
            
            var messagePre = jsonList["singleRecForPrn"][0]['Repeat'];
            var messageSuf = jsonList["singleRecForPrn"][0]['Dosage_Instruction'];
            if(messagePre == 'After every '+ '\''+ 'n' +'\''+ ' hours'){
                message = ' After every ' + messageSuf + ' hours';
            }else if(messagePre == '\''+'n'+'\''+ ' times a day'){
                message = ' ' + messageSuf +' times a day' ;
            }
            jsonList["dispenseExpectedSupplyDuration"] = value;
            jsonList["singleRecForPrn"][0]['textMessage'] = message;
        }*/
   //     else{
           
            if(jsonListCopy == ''){
                startingIndex=1;
            }else{
                startingIndex = jsonListCopy["dispenseExpectedSupplyDuration"];
            }
            
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
            
      //  }
        console.log('Finished '+JSON.stringify(jsonList));
        component.set("v.jsonList",jsonList);
        component.set("v.jsonListCopy",JSON.parse(JSON.stringify(jsonList)));
        
        
    },
    GetFrequency	:	function(component,event,helper){       
        var jsonList = component.get("v.jsonList"); 
         var value = event.getSource().get("v.value");
        if(jsonList['types'] == 'Taper' ){
            
        var DayIndex = event.getSource().get("v.name");       
        jsonList.Days[DayIndex]['Repeat'] = value;
        var jsonInside = jsonList.Days[DayIndex];  
            var map = {};
            if(jsonList.Days[DayIndex]['Repeat'] == 'After every '+ '\''+ 'n' +'\''+ ' hours' || jsonList.Days[DayIndex]['Repeat'] == '\''+'n'+'\''+ ' times a day'){
                jsonInside.Strength=[];
                jsonInside.Units=[];
                jsonInside.Dosage=[];
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
                    jsonInside.Units = ['Choose One...','Choose One...'];
                    jsonInside.Dosage = ['1','1'];
                    jsonInside.Dosage_Instruction = parseInt("12"); 
                    jsonList.Days[DayIndex]['textMessage'] = ' After every 12 hours';
                }
                else if(jsonList.Days[DayIndex]['Repeat'] == '\''+'n'+'\''+ ' times a day'){
                    jsonInside.Dosage_Instruction = parseInt("1");     
                    jsonInside.Strength = ['5mg'];
                    jsonInside.Units = ['Choose One...'];
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
                        jsonInside.Units = ['Choose One...'];
                        jsonInside.Dosage = ['1'];
                        console.log('If');
                        
                    }else{
                        jsonInside.Strength = ['5mg','5mg','5mg'];
                        jsonInside.Units = ['Choose One...','Choose One...','Choose One...'];
                        jsonInside.Dosage = ['1','1','1'];
                        console.log('custom pheno else');
                    }
                }
            }
            
            
        }
        else{
            var count = jsonList['singleRecForPrn'][0]['Dosage_Instruction'];
            if(jsonList.singleRecForPrn[0]['Repeat'] == '\''+'n'+'\''+ ' times a day'){                
                jsonList['singleRecForPrn'][0]['textMessage'] = ' '+count.toString() +' times a day'; 
                component.set("v.prnTimesAbility",false);
            }
            else if(jsonList.singleRecForPrn[0]['Repeat'] == 'After every '+ '\''+ 'n' +'\''+ ' hours'){
                jsonList['singleRecForPrn'][0]['textMessage'] = ' After every '+ count.toString() +' hours'; 
                 component.set("v.prnTimesAbility",false);
            }
                else{
                     component.set("v.prnTimesAbility",true);
                     // jsonList.Days[DayIndex]['textMessage'] = ' '; 
                map = {'After lunch' : ['13:30:00.000'],
                       'After supper/Dinner'	: 1 ,
                       'Before Breakfast'	: 1 ,
                       'Custom pheno' 		: 3,
                       'Once a day (AM)'	: 1,
                       'Once a day (HS)'	: 1,
                       'Once a day midday'	: 1,
                       'Once a day (Qam)' 	: 1,
                       'Once a day (QHS)'	: 1,
                       'At a specific time' : 1,
                       'Once a day (HS)' : 1
                      }
                

                
                //console.log($A.util.isUndefinedOrNull(map[value]));
                if(!$A.util.isUndefinedOrNull(map[value])){
                    jsonList.singleRecForPrn[0]['Dosage_Instruction'] =  map[value];
                    jsonList['singleRecForPrn'][0]['textMessage'] = ' ';   
                  
                }
                    
                }
            
        }
        component.set("v.jsonList",jsonList);
        console.log('json List '+JSON.stringify(jsonList));
        
        
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
    },
    ActionOrderEdit : function(component,event,helper) {
         var index = event.getSource().get("v.name").toString();
        var value = event.getSource().get("v.value");
        var upperIndex;
        var repeatIndex;
        var jsonList = component.get("v.jsonList.singleRecForActionOrder");
        console.log('ds',JSON.stringify(jsonList));
        var array = index.split('$');
        console.log('value',value);
        if(!$A.util.isUndefinedOrNull(value)){
            if(array.length == 3){
                upperIndex = array[0];
                repeatIndex = array[1];
                jsonList[upperIndex].singleRecForActionOrder[0].StartTime[repeatIndex] = value;
            }
            else if(array.length == 1){
                jsonList[0]['times'] = [];
                //upperIndex = array[0];
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
                  jsonList[0]['textMessage'] =  ' ' + value.toString() +' times a day';
                jsonList[0]['times'] = mapOfNTimes[value];
            }
            console.log(JSON.stringify(jsonList));
        }
        component.set("v.jsonList.singleRecForActionOrder",jsonList); 
          console.log('final included '+JSON.stringify(component.get("v.jsonList")));
        
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
        console.log('json list gettinmes '+JSON.stringify(jsonList));
        if(jsonList.Days[DayIndex]['Repeat'] == 'After every '+ '\''+ 'n' +'\''+ ' hours'){
            var mapOfEveryHours ={
                "12":	["12:00:00.000","24:00:00.000"],
                "8":	["08:00:00.000","16:00:00.000","24:00:00.000"],
                "6":	["06:00:00.000","12:00:00.000","18:00:00.000","24:00:00.000"],
                "5":	["04:00:00.000","09:00:00.000","14:00:00.000","19:00:00.000","24:00:00.000"],
                "4":	["04:00:00.000","08:00:00.000","12:00:00.000","16:00:00.000","20:00:00.000","24:00:00.000"],
                "7":	["01:00:00.000","04:00:00.000","07:00:00.000","10:00:00.000","13:00:00.000","16:00:00.000","19:00:00.000"],
                "3":    ["01:00:00.000","04:00:00.000","07:00:00.000","10:00:00.000","13:00:00.000","16:00:00.000","19:00:00.000","21:00:00.000"],
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
            unitsList.push("Choose One...");
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
        
        
    },
    editInsideData	:	function(component,event,helper){
       console.log('EditInsideData');
        var index = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
		console.log('index '+index);
        console.log('value '+value);
         var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        console.log(allValid);
      //  if(allValid == true){
        

        var array = index.split('$');
        var repeatIndex = array[0];
        var DayIndex = array[1];
        var fieldName = array[2];
        if(!$A.util.isUndefinedOrNull(value)){

        var jsonList = component.get("v.jsonList");
        var jsonString ;
       // if(jsonList["types"] == 'Taper'){
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
     //   }
       
     
        
        component.set("v.jsonList",jsonList);
        }
      //  }
           console.log('Pushed'+JSON.stringify(component.get("v.jsonList")));
        
    },
    handleRecordForm :  function(component, event, helper) {
        component.set("v.ShowEditable",true);
    },
    recordEdit : function(component, event, helper){
        var name = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
        var jsonList = component.get("v.jsonList");
        var desp = jsonList.dispenseExpectedSupplyDuration;
        jsonList[name] = value; 
     	var erDate = new Date(Date.parse(jsonList.startDate));
        erDate.setDate(erDate.getDate() + parseInt(desp));
        //console.log('erDate'+erDate);
        var dd = String(erDate.getDate()).padStart(2, '0');
        var mm = String(erDate.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = erDate.getFullYear();
        erDate = yyyy +'-'+ mm +'-' + dd ;
        jsonList.endDate =  erDate ; 
        component.set("v.jsonList",jsonList);
        console.log(JSON.stringify(jsonList));
    },
     handleCheckActionOrder : function(component, event, helper){
       // var name = event.getSource().get("v.name");
        var value = event.getSource().get("v.checked");
        var jsonList = component.get("v.jsonList");
       // var desp = jsonList.dispenseExpectedSupplyDuration;
        jsonList['MARDisplay'] = value; 
        component.set("v.jsonList",jsonList);
        console.log(JSON.stringify(jsonList));
    },
    recordEditPRN	: function(component, event, helper){
        var name = event.getSource().get("v.name");
        var value = event.getSource().get("v.value");
     
        var jsonList = component.get("v.jsonList");
      
            if(!$A.util.isUndefinedOrNull(value)){
        jsonList['singleRecForPrn'][0][name] = value;
        
        component.set("v.jsonList",jsonList);
        }

        console.log(JSON.stringify(jsonList));
    },
    typeEvaluator : function(component, event, helper){   
        var nameSpaceElixir ='ElixirSuite__';
        console.log('initiated');
        component.set("v.jsonListCopy",'');
        var records = [{"Id":"","ElixirSuite__Drug_Name__c":"",
                        "ElixirSuite__Reason_new__c":"","ElixirSuite__Type__c":"PRN",
                        "ElixirSuite__Start_Date__c":"","ElixirSuite__Number_of_Times_Days_Weeks__c":1,
                        "ElixirSuite__After_Discharge__c":false,"ElixirSuite__Route__c":"",
                        "ElixirSuite__Warning__c":"",
                        "ElixirSuite__Route_New__c" :"","ElixirSuite__Dosage_Form__c":"","ElixirSuite__Notes__c" : "To be added",
                        "ElixirSuite__Justification__c"	:	"To be added","ElixirSuite__MAR_display__c":false,
                        "ElixirSuite__Frequency__r":
                        [{"ElixirSuite__Prescription_Order__c":"",
                          "ElixirSuite__Strength__c": "",
                          "ElixirSuite__Frequency_Unit__c":"",
                          "ElixirSuite__Frequency_Value__c":"",
                          "ElixirSuite__Repeat__c":""}]
                       }];
        var type = event.getSource().get("v.value");
        
        //today date
        var todayDate = new Date();
        var dd = String(todayDate.getDate()).padStart(2, '0');
        var mm = String(todayDate.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = todayDate.getFullYear();
        var today = yyyy +'-'+ mm +'-' + dd ;
        //end date
        var erDate = new Date;
        erDate.setDate(erDate.getDate() + parseInt(records[0][nameSpaceElixir+'Number_of_Times_Days_Weeks__c']));
        //console.log('erDate'+erDate);
        var dd = String(erDate.getDate()).padStart(2, '0');
        var mm = String(erDate.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = erDate.getFullYear();
        erDate = yyyy +'-'+ mm +'-' + dd ;
        var jsonList = [];
        
        if(type=="Taper" || type=="PRN"){
            console.log('inside taper');
            var jsonInside = {};
            var newFilter ={};
          
            var jsonInsideList = [];
            var finalKeys =[];
         
            
            jsonInsideList = [];                    
            
            var string ;
            var timeList = [];
            var strengthList = [];
            var unitsList = [];
            var dosageList = [];
            
            timeList.push("00:00:00.000");
            strengthList.push("5mg");
            unitsList.push("Tablet");
            dosageList.push("1");  
          
            
            jsonInside = {"times" : timeList,
                          "Strength" : strengthList,
                          "Units" : unitsList, 
                          "Dosage" : dosageList,                                     
                          "Repeat": '\''+'n'+'\''+ ' times a day',
                          "Dosage_Instruction" : 1,
                          "textMessage"  :  '1'+ ' times a day'
                         }  
            jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
          
            newFilter = {
                "medicationName" : records[0][nameSpaceElixir+'Medication__c'], 
                "types" : type,
                "startDate" : today,
                "dispenseExpectedSupplyDuration" : 1,
                "afterDischarge" : records[0][nameSpaceElixir+'After_Discharge__c'],
                "Route" : records[0][nameSpaceElixir+"Route_New__c "],
                "Warning"	: records[0][nameSpaceElixir+"Warning__c "],
                "dosageForm" : records[0][nameSpaceElixir+'Dosage1__c'],
                "reasonLabel" : records[0][nameSpaceElixir+'Reason_new__c'],
                "endDate" : erDate,
                "Days" : JSON.parse(JSON.stringify(jsonInsideList))
                }
            jsonList.push(newFilter);
            console.log('if '+JSON.stringify(jsonList));
        }
       /* else if(type=="PRN"){
            console.log('isndie else');
            var jsonInsideList = [];                    
            var jsonInside = {};  
            var tempVar = records[0]["Frequency__r"][0];           
            console.log(' tempVar'+JSON.stringify(tempVar));
            
            jsonInside = {
                "UnitsForPrn" :tempVar['Frequency_Unit__c'],
                "StrengthForPrn" : tempVar['Strength__c'], 
                "DosageForPrn" : tempVar['Frequency_Value__c'],
                "Repeat":'\''+'n'+'\''+ ' times a day',
                "Dosage_Instruction" : 1,
                "textMessage"	:	'1'+ ' times a day'
            }  
            jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
            
            console.log('first');
            var newFilter = {
                "medicationName" : records[0]['Drug_Name__c'], 
                "types" : type,
                "startDate" : today,
                "dispenseExpectedSupplyDuration" : records[0]['Number_of_Times_Days_Weeks__c'],
                "afterDischarge" : records[0]['After_Discharge__c'],
                "Route" : records[0]["Route_New__c "],
                "Warning"	: records[0]["Warning__c "],
                "endDate" : erDate,
                "dosageForm" : records[0]['Dosage_Form__c'],
                "singleRecForPrn" : JSON.parse(JSON.stringify(jsonInsideList))
            }
            console.log('scnd');
            jsonList.push(newFilter);
            
        }*/
        //Action Order
            else if(type=='Action Order'){
                console.log('act order inside ');
                var jsonInside = {};
                var newFilter ={};
                
                var jsonInsideList = [];
                var finalKeys =[];
                
                
                jsonInsideList = [];                    
                
                var string ;
                var timeList = [];
                var strengthList = [];
                var unitsList = [];
                var dosageList = [];
                timeList.push("00:00:00.000");
            strengthList.push("5mg");
            unitsList.push("Tablet");
            dosageList.push("1");  

               
                 jsonInside = {"times" : timeList,
                          "Strength" : strengthList,
                          "Units" : unitsList, 
                          "Dosage" : dosageList,                                     
                          "Repeat": '\''+'n'+'\''+ ' times a day',
                          "Dosage_Instruction" : 1,
                          "textMessage"  :  '1'+ ' times a day'
                         }  
               
                jsonInsideList.push(JSON.parse(JSON.stringify(jsonInside)));
                
                 newFilter = {
                "medicationName" : records[0][nameSpaceElixir+'Medication__c'], 
                "types" : type,
                "startDate" : today,
                "dispenseExpectedSupplyDuration" : 1,
                "afterDischarge" : records[0][nameSpaceElixir+'After_Discharge__c'],
                    
                    "PRNdisplay" : false,
                    "MARDisplay" : records[0][nameSpaceElixir+"MAR_display__c"],
                    "Justification"	: records[0][nameSpaceElixir+"Justification__c"],
                   
                    "PRN"	:	records[0][nameSpaceElixir+'PRN__c'],
                    "Notes"	:	records[0][nameSpaceElixir+'Notes__c'],//add
                "Route" : records[0][nameSpaceElixir+"Route_New__c "],
                "Warning"	: records[0][nameSpaceElixir+"Warning__c "],
                "dosageForm" : records[0][nameSpaceElixir+'Dosage1__c'],
                "reasonLabel" : records[0][nameSpaceElixir+'Reason_new__c'],
                "endDate" : erDate,
                "Days" : JSON.parse(JSON.stringify(jsonInsideList))
            }
                jsonList.push(newFilter);
                console.log('if '+JSON.stringify(jsonList));
        }
       
        console.log(JSON.stringify(jsonList[0]));
        component.set("v.jsonList",jsonList[0]); 
        
    },
      daysForActionOrder  : function(component, event, helper){
        console.log('Days Action Order');
        var value = event.getSource().get("v.value");
        //var upperIndex = event.getSource().get("v.name");     
        console.log('value  '+value);
        var jsonList = component.get("v.jsonList");
		var erDate = new Date(Date.parse(jsonList.startDate));
        erDate.setDate(erDate.getDate() + parseInt(value));
        //console.log('erDate'+erDate);
        var dd = String(erDate.getDate()).padStart(2, '0');
        var mm = String(erDate.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = erDate.getFullYear();
        erDate = yyyy +'-'+ mm +'-' + dd ;
        jsonList.endDate =  erDate ; 
          component.set("v.jsonList",jsonList);
      },
    
    Save  : function(component, event, helper){
        
        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
      
        console.log('Initialised');
      // var getNames = component.find('field');
        var jsonListForPRN = [];
        var jsonListForTaper = [];
        var jsonListForActionOrder = [];
        var oldJsonList = component.get("v.jsonList");
        console.log('oldJsonList '+ JSON.stringify(oldJsonList));
        var medicationName = oldJsonList.medicationName;  
        console.log('medicationName '+ medicationName);
        var types = oldJsonList.types;
        console.log('types '+ types);
        var dosageForm = oldJsonList.dosageForm;
        console.log('dosageForm '+ dosageForm);
        var Route = oldJsonList.Route;
        console.log('Route '+ Route);
        if(types =='PRN'|| types =='Taper'){
            if(medicationName ==undefined || medicationName ==''){
                var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please fill the medication field."
            });
            toastEvent.fire();
             allValid=false;
            }
            if(dosageForm ==undefined || dosageForm ==''){
                var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please fill the Dosage field."
            });
            toastEvent.fire();
             allValid=false;
            }
            if(Route ==undefined || Route ==''){
                var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please fill the Route field."
            });
            toastEvent.fire();
            allValid=false;
            }
        }
        if(types =='Action Order'){
            if(medicationName ==undefined || medicationName ==''){
                var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please fill the medication field."
            });
            toastEvent.fire();
            allValid=false;
            }
           
        }
            
            if(oldJsonList['types'] == 'PRN'){               
             
                jsonListForPRN.push(oldJsonList);
            }
            else if(oldJsonList['types'] == 'Taper'){       
             
                jsonListForTaper.push(oldJsonList);
            }
                else if(oldJsonList['types'] == 'Action Order'){
                     jsonListForActionOrder.push(oldJsonList);
                }
        console.log(' ACTION  ORDER '+JSON.stringify(jsonListForActionOrder));
        //console.log(' Frequency '+component.get("v.freqRec"));
        console.log(' Type '+oldJsonList['types']);
      
        var jsonString={
            "jsonListForTaper" :	JSON.parse(JSON.stringify(jsonListForTaper)),
            "jsonListForPRN"   :		JSON.parse(JSON.stringify(jsonListForPRN)),
            "jsonListForAOrder" : JSON.parse(JSON.stringify(jsonListForActionOrder))
        };
        console.log('String bnn gyi'+JSON.stringify(jsonString));
        
       console.log('String bnn gyi'+JSON.stringify(jsonString));
        if(allValid == false){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Failed!",
                "message": "Please fill all the mandatory fields."
            });
            toastEvent.fire();
        }
        //freq : component.get("v.freqRec")
        if(allValid == true){
            component.set("v.isDisabled",true);
            console.log('JSON string for new medication '+JSON.stringify(jsonString));
            var action = component.get("c.saveData");
            
            action.setParams({ 
                jsonList : JSON.stringify(jsonString),
                accId	: component.get("v.RecId")
                
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
                     var createEvent = component.getEvent("HandleBackInMedicaion");
                        //createEvent.setParams({ "expense": newExpense });
                        createEvent.fire();
                    //$A.get("e.force:closeQuickAction").fire();
                   // component.set("v.OpenPopUp",false);
                    component.set("v.isOpen",false);
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