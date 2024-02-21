({
    doInit : function(component , event,helper){
        console.log('fef');
        component.set('v.todayString', new Date().toISOString());
        window.setInterval(
            $A.getCallback(function() { 
                //  var date = new Date().toLocaleTimeString() ;
                component.set("v.time", new Date().toLocaleTimeString(navigator.language, {
                    hour: '2-digit',
                    minute:'2-digit',
                    hour12: false
                })); 
            }), 1000
        ); 
        var dt = new Date();
        
        dt.setMinutes( dt.getMinutes() + 30 );
        component.set("v.afterTime", dt.toLocaleTimeString(navigator.language, {
            hour: '2-digit',
            minute:'2-digit',
            hour12: false
        })); 
        component.set("v.isActive",true);  
        component.set("v.checkSave" , true);
        component.set("v.loaded",false);
        var action = component.get("c.getMORDetails");
        action.setParams({  
            accountId : component.get("v.recordVal")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var multiply = 'X';
                var comma1 = ',';
                var comma2 = ',';
                var allData = response.getReturnValue();
                console.log('allData from apex mahi '+JSON.stringify(allData));
                var nameSpace = 'ElixirSuite__';
                component.set("v.nameSpace",allData.nameSpace);
                component.set("v.adminStatusOptions",allData.adminStatusOptions);
                console.log('here data resp '+JSON.stringify(allData));
                
                component.set("v.allData" , allData.morDataPrn);
                component.set("v.data" , allData.morDataPrn);
                component.set("v.allDataTaper" , allData.morDataTaper);
                component.set("v.dataTaper" , allData.morDataTaper);
                component.set("v.allDataActionOrder" , allData.morDataActionOrder);
                component.set("v.dataTaperActionOrder" , allData.morDataActionOrder);
                component.set("v.allDataVaccine" , allData.vaccineList);
                component.set("v.dataTaperVaccine" , allData.vaccineList);
                
                
                if($A.util.isEmpty(allData.morDataActionOrder)){
                    component.set("v.messege" , true);
                }
                if($A.util.isEmpty(allData.morDataPrn)){
                    component.set("v.messegePrn" , true);
                }
                if($A.util.isEmpty(allData.morDataTaper)){
                    component.set("v.messegeTaper" , true);
                }
                if($A.util.isEmpty(allData.vaccineList)){
                    component.set("v.messegeVaccination" , true);
                }
                var recToSplice = allData.RecordToSplice;
                component.set("v.searchKeyword",'');
                component.set("v.vitalStatus" , allData.checkStatus);
                console.log('the val is',allData);
                var listLength = allData.morDataPrn.length;
                var taperLength = allData.morDataTaper.length ;
                var actionOrderLength = allData.morDataActionOrder.length ;
                var vaccineLength = allData.vaccineList.length ;
                var jsonList = [];
                var jsonList2 = [] ;
                var jsonList3 = [];
                var jsonListVaccine = [];
                var sortTimeList = [];
                console.log('PRN listLength', listLength);
                
                //Vaccination code starts
                var commentsActionOrder ;
                var takenActionOrder ; 
                console.log("vaccination" + JSON.stringify(allData.vaccineList));
                for(var f=0;f< vaccineLength;f++){
                    var recVaccine ={};
                    recVaccine = {"id" : allData.vaccineList[f].Id,
                                  "vaccineName" : allData.vaccineList[f]['Name'],
                                  "patientAccount" : allData.vaccineList[f][nameSpace + 'Account__c'],
                                  "route" : allData.vaccineList[f][nameSpace + 'Vaccine_Route__c'],
                                  "vaccineSite" : allData.vaccineList[f][nameSpace + 'Vaccine_Site__c'],
                                  "administeredOn" : allData.vaccineList[f][nameSpace + 'Administered_Planned_On__c'],
                                  "administeredBy" : allData.userName.Name,
                                  "indexOfDay" : f ,
                                  "Owner" : allData.userName.Name ,
                                  "commentData" : commentsActionOrder ,
                                  "vaccineStatus" : takenActionOrder ,                            
                                  "takenValue" : ''
                                 };
                    jsonListVaccine.push(recVaccine);
                }
                console.log('vaccine List' , JSON.stringify(jsonListVaccine));
                component.set("v.jsonListVaccine" , JSON.parse(JSON.stringify(jsonListVaccine)));
                component.set("v.jsonListVaccineCopy" , JSON.parse(JSON.stringify(jsonListVaccine)));
                
                for (var i = 0; i < listLength; i++) 
                {
                    
                    var insideJson = {};
                    var completeJson = []; //***** field dosage instruction value*****////// or records.length/////
                    console.log('Mordata,',allData.morDataPrn[i][nameSpace + 'Frequency__r']);
                    if(!$A.util.isUndefinedOrNull(allData.morDataPrn[i][nameSpace + 'Frequency__r'])){
                        var countOfRepeat = 0;
                        var tempDataRecord = allData.morDataPrn[i][nameSpace + 'Frequency__r'][0];
                        for(var z=1;z<=24;z++){
                            string = nameSpace+'Strength_'+z+'__c';
                            console.log('string '+string);                   
                            if(!$A.util.isEmpty(tempDataRecord[string]) || !$A.util.isUndefinedOrNull(tempDataRecord[string])){
                                countOfRepeat++;
                                console.log(z);
                            }
                        }
                        if(!$A.util.isUndefinedOrNull(allData.morDataPrn[i][nameSpace+'Medication__r'])){
                    											allData.morDataPrn[i][nameSpace+'DynamicMedField__c']  = allData.morDataPrn[i][nameSpace+'Medication__r'].Name;
                    													}
                                                           if(!$A.util.isUndefinedOrNull(allData.morDataPrn[i][nameSpace+'Route_New_1__r'])){
                    											allData.morDataPrn[i][nameSpace+'DynamicRouteField__c']  = allData.morDataPrn[i][nameSpace+'Route_New_1__r'].Name;
                    													}
                                                           if(!$A.util.isUndefinedOrNull(allData.morDataPrn[i][nameSpace+'Dosage1__r'])){
                    											allData.morDataPrn[i][nameSpace+'DynamicDosageField__c']  = allData.morDataPrn[i][nameSpace+'Dosage1__r'].Name;
                    													}
                        console.log('Medication Iterate',allData.morDataPrn[i][nameSpace + 'DynamicMedField__c']);
                        console.log('Route,',allData.morDataPrn[i][nameSpace + 'DynamicRouteField__c']);
                        console.log('Dosage,',allData.morDataPrn[i][nameSpace + 'DynamicDosageField__c']);
                        for(var j=1;j<= countOfRepeat;j++){nameSpace+'Strength_'+h+'__c';
                                                           
                                                           var unit = allData.morDataPrn[i][nameSpace + 'Frequency__r'][0][nameSpace +'Unit_'+j+'__c'] ;
                                                           var str = allData.morDataPrn[i][nameSpace + 'Frequency__r'][0][nameSpace + 'Strength_'+j+'__c'] ;
                                                           var rout = allData.morDataPrn[i][nameSpace + 'Route_New__c'] ;
                                                           var dos = allData.morDataPrn[i][nameSpace + 'Frequency__r'][0][nameSpace + 'Quantity_'+j+'__c'] ;
                                                           if($A.util.isUndefinedOrNull(str)){
                                                               multiply = ' ';
                                                               str = ' ' ;
                                                           }
                                                           if($A.util.isUndefinedOrNull(unit)){
                                                               comma1 = ' ';
                                                               unit = ' ';
                                                           }
                                                           if($A.util.isUndefinedOrNull(rout)){
                                                               comma2 = ' ';
                                                               rout = ' ';
                                                           }
                                                           if($A.util.isUndefinedOrNull(dos))
                                                               dos = ' ';
                                                           console.log('small  before');
                                                           var newStr = dos + ' ' + multiply + ' ' + str + comma1 + unit + comma2 + rout ;
                                                           console.log('small  middle',newStr);
                                                           var actTime = allData.morDataPrn[i][nameSpace + 'Frequency__r'][0][nameSpace + 'Last_Activity_Time__c'];
                                                           var milliseconds = parseInt((actTime % 1000) / 100),
                                                               seconds1 = Math.floor((actTime / 1000) % 60),
                                                               minutes1 = Math.floor((actTime / (1000 * 60)) % 60),
                                                               hours1 = Math.floor((actTime / (1000 * 60 * 60)) % 24);
                                                           
                                                           hours1 = (hours1 < 10) ? "0" + hours1 : hours1;
                                                           minutes1 = (minutes1 < 10) ? "0" + minutes1 : minutes1;
                                                           seconds1 = (seconds1 < 10) ? "0" + seconds1 : seconds1;
                                                           var newTime1 =  hours1 + ":" + minutes1 ;
                                                           insideJson = {"id" : allData.morDataPrn[i].Id,
                                                                         "dosageId" : allData.morDataPrn[i][nameSpace + 'Frequency__r'][0].Id,
                                                                         "medicationName" : allData.morDataPrn[i][nameSpace + 'DynamicMedField__c'],
                                                                         "patientAccount" : allData.morDataPrn[i][nameSpace + 'Account__c'],
                                                                         "Type" : allData.morDataPrn[i][nameSpace + 'Type__c'],
                                                                         "Start_Date"  : allData.morDataPrn[i][nameSpace + 'Start_Date__c'],
                                                                         "DispenseExpectedSupplyDuration" : allData.morDataPrn[i][nameSpace + 'Number_of_Times_Days_Weeks__c'],
                                                                         "After_Discharge" : allData.morDataPrn[i][nameSpace + 'After_Discharge__c'],
                                                                         "Route" : allData.morDataPrn[i][nameSpace + 'DynamicRouteField__c'],
                                                                         "Dosage_Form" : allData.morDataPrn[i][nameSpace + 'DynamicDosageField__c'] ,
                                                                         "Warning" : allData.morDataPrn[i][nameSpace + 'Warning__c'] ,                                       
                                                                         "Strength" : allData.morDataPrn[i][nameSpace + 'Frequency__r'][0][nameSpace + 'Strength_'+i+'__c'],
                                                                         "Units" : allData.morDataPrn[i][nameSpace + 'Frequency__r'][0][nameSpace + 'Unit_'+i+'__c'], 
                                                                         "Dosage" : allData.morDataPrn[i][nameSpace + 'Frequency__r'][0][nameSpace + 'Quantity_'+i+'__c'], 
                                                                         "Owner" : allData.userName.Name ,
                                                                         "NoOfTimes"	: allData.morDataPrn[i][nameSpace + 'Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'],
                                                                         "Frequency" :  allData.morDataPrn[i][nameSpace + 'Frequency__r'][0][nameSpace + 'Repeat__c'] ,         
                                                                         "commentData" : comments ,
                                                                         "medicationStatus" : taken , 									  
                                                                         "indexOfDay"	: j,
                                                                         "allStrength" : newStr
                                                                         
                                                                        }  
                                                           completeJson.push(insideJson);
                                                           console.log(console.log('complete',completeJson));
                                                          }
                        var rec ={};
                        rec = {"id" : allData.morDataPrn[i].Id,
                               "dosageInstId" : allData.morDataPrn[i][nameSpace + 'Frequency__r'][0].Id,
                               "MedicationName" : allData.morDataPrn[i][nameSpace + 'DynamicMedField__c'] ,
                               "ActivityDate" : allData.morDataPrn[i][nameSpace + 'Frequency__r'][0][nameSpace + 'Last_Activity_Date_MAR__c'] , 
                               "ActivityTime" : newTime1, 
                               "Record" : JSON.parse(JSON.stringify(completeJson))
                              };
                        jsonList.push(rec);
                        console.log('after PRN push');
                        console.log('i',i);
                    }
                    
                    
                }
                
                //taper start
                console.log('taperLength',taperLength);
                for (var m = 0; m < taperLength; m++) {
                    // sample starts
                    
                    var multiply11 = 'X';
                    var comma11 = ',';
                    var comma12 = ',';
                    
                    var tempVar = allData.morDataTaper[m][nameSpace + 'Frequency__r'][0];
                    
                    var tempData = allData.morDataTaper[m][nameSpace + 'Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'];
                    var tempDataRecord = allData.morDataTaper[m][nameSpace + 'Frequency__r'][0];
                    var allTiminingsInApexFormat = [];
                    var allTimings = [];
                    var allStrengths = [];
                    var allDosages = [];
                    var allUnits = [];
                    var comments ;
                    var taken ; 
                    var startTime;
                    var strength;
                    var dosage;
                    var units;
                    var string;
                    var countOfRepeat = 0;
                    console.log('tempData',tempData);
                    for(var z=1;z<=24;z++){
                        string = nameSpace+'Strength_'+z+'__c';
                        console.log('string '+string);                    
                        if(!$A.util.isEmpty(tempDataRecord[string]) || !$A.util.isUndefinedOrNull(tempDataRecord[string])){
                            countOfRepeat++;
                            console.log(z);
                        }
                    }
                    for(var h=1;h<=parseInt(countOfRepeat);h++){
                        strength = nameSpace+'Strength_'+h+'__c';
                        units = nameSpace+'Unit_'+h+'__c';
                        startTime = nameSpace+'Start_Time_'+h+'__c';
                        dosage = nameSpace+'Quantity_'+h+'__c';
                        allTiminingsInApexFormat.push(tempVar[startTime]);
                        var milliseconds = parseInt((tempVar[startTime] % 1000) / 100),
                            seconds = Math.floor((tempVar[startTime] / 1000) % 60),
                            minutes = Math.floor((tempVar[startTime] / (1000 * 60)) % 60),
                            hours = Math.floor((tempVar[startTime] / (1000 * 60 * 60)) % 24);
                        
                        hours = (hours < 10) ? "0" + hours : hours;
                        minutes = (minutes < 10) ? "0" + minutes : minutes;
                        seconds = (seconds < 10) ? "0" + seconds : seconds;
                        var newTime =  hours + ":" + minutes ;
                        
                        allTimings.push(newTime);
                        console.log('ALL timings  '+allTimings);
                        allStrengths.push(tempVar[strength]);
                        
                        allUnits.push(tempVar[units]);
                        allDosages.push(tempVar[dosage]);
                        
                    }
                    
                    var insideJson1 = {};
                    var completeJson1 = []; //***** field dosage instruction value*****////// or records.length/////
if(!$A.util.isUndefinedOrNull(allData.morDataTaper[m][nameSpace+'Medication__r'])){
                    allData.morDataTaper[m][nameSpace+'DynamicMedField__c']  = allData.morDataTaper[m][nameSpace+'Medication__r'].Name;
                    }
                        if(!$A.util.isUndefinedOrNull(allData.morDataTaper[m][nameSpace+'Route_New_1__r'])){
                    allData.morDataTaper[m][nameSpace+'DynamicRouteField__c']  = allData.morDataTaper[m][nameSpace+'Route_New_1__r'].Name;
                    }
                        if(!$A.util.isUndefinedOrNull(allData.morDataTaper[m][nameSpace+'Dosage1__r'])){
                    allData.morDataTaper[m][nameSpace+'DynamicDosageField__c']  = allData.morDataTaper[m][nameSpace+'Dosage1__r'].Name;
                    }
                    
                    for(var p=1;p<= parseInt(countOfRepeat);p++){
                        
                        var str1 = allStrengths[p-1];
                        var dosa1 = allDosages[p-1];
                        var unit1 = allUnits[p-1] ;
                        var rout1 = allData.morDataTaper[m][nameSpace+'DynamicRouteField__c'] ;
                        if($A.util.isUndefinedOrNull(str1)){
                            multiply11 = ' ';
                            str1 = ' ' ;
                        }
                        if($A.util.isUndefinedOrNull(rout1)){
                            comma11 = ' ';
                            rout1 = ' ';
                        }
                        if($A.util.isUndefinedOrNull(unit1)){
                            comma12 = ' ';
                            unit1 = ' ';
                        }
                        if($A.util.isUndefinedOrNull(dosa1)){
                            dosa1 = ' ';
}
                      
                        var newStr1 = dosa1 + ' ' + multiply11 + ' ' + str1 + comma11 + rout1 + comma12 + unit1 ;
                        insideJson1 = {"id" : allData.morDataTaper[m].Id,
                                       "dosageId" : allData.morDataTaper[m][nameSpace + 'Frequency__r'][0].Id,
                                       "medicationName" : allData.morDataTaper[m][nameSpace + 'DynamicMedField__c'],
                                       "patientAccount" : allData.morDataTaper[m][nameSpace + 'Account__c'],
                                       "Type" : allData.morDataTaper[m][nameSpace + 'Type__c'],
                                       "Start_Date" : allData.morDataTaper[m][nameSpace + 'Start_Date__c'],
                                       "DispenseExpectedSupplyDuration" : allData.morDataTaper[m][nameSpace + 'Number_of_Times_Days_Weeks__c'],
                                       "After_Discharge" : allData.morDataTaper[m][nameSpace + 'After_Discharge__c'],
                                       "Route" : allData.morDataTaper[m][nameSpace + 'DynamicRouteField__c'],
                                       "Dosage_Form" : allData.morDataTaper[m][nameSpace + 'DynamicDosageField__c'] ,
                                       "Warning" : allData.morDataTaper[m][nameSpace + 'Warning_new__c'] ,
                                       "Strength" : allStrengths[p-1],
                                       "Units" : allUnits[p-1], 
                                       "Dosage" : allDosages[p-1],
                                       "times" : allTimings[p-1] ,
                                       'timesInApex' : allTiminingsInApexFormat[p-1],
                                       "indexForInspection" : p,
                                       "Owner" : allData.userName.Name ,
                                       "NoOfTimes"	: allData.morDataTaper[m][nameSpace + 'Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'],
                                       "Frequency" :  allData.morDataTaper[m][nameSpace + 'Frequency__r'][0][nameSpace + 'Repeat__c'] ,                          
                                       "commentData" : comments ,
                                       "medicationStatus" : taken , 
                                       "indexOfDay"	: p,
                                       "allStrength" : newStr1,
                                       
                                      }
                        
                        console.log('INSIDE JSON 1 '+JSON.stringify(insideJson1));
                        
                        completeJson1.push(insideJson1);
                    }
                    
                    var rec1 ={};
                    rec1 = {"id" : allData.morDataTaper[m].Id,
                            "dosageInstId" : allData.morDataTaper[m][nameSpace + 'Frequency__r'][0].Id,
                            "MedicationName" : allData.morDataTaper[m][nameSpace + 'DynamicMedField__c'] ,
                            "Record" : JSON.parse(JSON.stringify(completeJson1))
                           };
                    jsonList2.push(rec1);
                }
                
                console.log('in Taper order',jsonList2);
                //Data for action Order starts
                for (var f = 0; f < actionOrderLength; f++) {
                    // sample starts
                    console.log('in action order');
                    var tempVarActionOrder = allData.morDataActionOrder[f][nameSpace + 'Frequency__r'][0];
                    var tempDataActionOrder = allData.morDataActionOrder[f][nameSpace + 'Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'];
                    
                    var allTimingsActionOrder = [];
                    var commentsActionOrder ;
                    var takenActionOrder ; 
                    var startTimeActionOrder;
                    console.log('in action order 2nd time');
                    for(var e=1;e<=parseInt(tempDataActionOrder);e++){
                        startTimeActionOrder = nameSpace+'Start_Time_'+e+'__c';
                        
                        var milliseconds = parseInt((tempVarActionOrder[startTimeActionOrder] % 1000) / 100),
                            seconds = Math.floor((tempVarActionOrder[startTimeActionOrder] / 1000) % 60),
                            minutes = Math.floor((tempVarActionOrder[startTimeActionOrder] / (1000 * 60)) % 60),
                            hours = Math.floor((tempVarActionOrder[startTimeActionOrder] / (1000 * 60 * 60)) % 24);
                        
                        hours = (hours < 10) ? "0" + hours : hours;
                        minutes = (minutes < 10) ? "0" + minutes : minutes;
                        seconds = (seconds < 10) ? "0" + seconds : seconds;
                        var newTime =  hours + ":" + minutes ;
                        
                        allTimingsActionOrder.push(newTime);
                        
                        console.log('in action order 3rd time' , allTimingsActionOrder);
                    }
                    
                    var insideJsonActionOrder = {};
                    var completeJsonActionOrder = []; //***** field dosage instruction value*****////// or records.length/////
if(!$A.util.isUndefinedOrNull(allData.morDataActionOrder[f][nameSpace+'Medication__r'])){
                    allData.morDataActionOrder[f][nameSpace+'DynamicMedActionField__c']= allData.morDataActionOrder[f][nameSpace+'Medication__r'].Name;
                         
                    }
                    for(var g=1;g<= tempDataActionOrder;g++){
                        
                        insideJsonActionOrder = {"id" : allData.morDataActionOrder[f].Id,
                                                 "dosageId" : allData.morDataActionOrder[f][nameSpace + 'Frequency__r'][0].Id,
                                                 "medicationName" : allData.morDataActionOrder[f][nameSpace + 'DynamicMedActionField__c'],
                                                 "patientAccount" : allData.morDataActionOrder[f][nameSpace + 'Account__c'],
                                                 "Type" : allData.morDataActionOrder[f][nameSpace + 'Type__c'],
                                                 "Start_Date" : allData.morDataActionOrder[f][nameSpace + 'Start_Date__c'],
                                                 "DispenseExpectedSupplyDuration" : allData.morDataActionOrder[f][nameSpace + 'Number_of_Times_Days_Weeks__c'],
                                                 "After_Discharge" : allData.morDataActionOrder[f][nameSpace + 'After_Discharge__c'],
                                                 "Warning" : allData.morDataActionOrder[f][nameSpace + 'Warning_new__c'] ,
                                                 "timesActionOrder" : allTimingsActionOrder[g-1] ,
                                                 "indexForInspection" : g,
                                                 "Owner" : allData.userName.Name ,
                                                 "NoOfTimes"	: allData.morDataActionOrder[f][nameSpace + 'Frequency__r'][0][nameSpace + 'Dosage_Instruction__c'],
                                                 "Frequency" :  allData.morDataActionOrder[f][nameSpace + 'Frequency__r'][0][nameSpace + 'Repeat__c'] ,                          
                                                 "commentData" : commentsActionOrder ,
                                                 "medicationStatus" : takenActionOrder , 
                                                 "indexOfDay"	: g,                                                 
                                                 "takenValue" : ''
                                                }  
                        
                        completeJsonActionOrder.push(insideJsonActionOrder);
                    }
                    
                    var recActionOrder ={};
                    recActionOrder = {"id" : allData.morDataActionOrder[f].Id,
                                      "dosageInstId" : allData.morDataActionOrder[f][nameSpace + 'Frequency__r'][0].Id,
                                      "MedicationName" : allData.morDataActionOrder[f][nameSpace + 'DynamicMedActionField__c'] ,
                                      "Record" : JSON.parse(JSON.stringify(completeJsonActionOrder))
                                     };
                    jsonList3.push(recActionOrder);
                }
                
                var keysRec=Object.keys(recToSplice);
                for(var w=0 ; w<jsonList2.length ; w++){
                    var val1 = jsonList2[w].Record ; 
                    console.log(recToSplice);
                    var dosageId=jsonList2[w].dosageInstId;
                    if(keysRec.includes(dosageId)){
                        if (!$A.util.isUndefinedOrNull(recToSplice[dosageId])){
                            recToSplice[dosageId].sort(function(a, b){
                                return b-a;
                            });
                            for(var p in recToSplice[dosageId]){
                                for(var forIndex in jsonList2[w].Record){
                                    console.log('undefy ',jsonList2[w].Record[forIndex].indexOfDay);
                                    if(recToSplice[dosageId][p].toString()==jsonList2[w].Record[forIndex].indexOfDay.toString()){
                                        jsonList2[w].Record.splice(forIndex , 1);
                                        console.log('sds',JSON.stringify(jsonList2));
                                    }else{
                                        console.log('else');
                                    }
                                }
                            }
                        }
                    }
                }
                console.log('$ plicing ',recToSplice);
                var keysRecPRN=Object.keys(recToSplice);
                for(var wa=0 ; wa<jsonList.length ; wa++){
                    var dosageId11=jsonList[wa].dosageInstId;
                    if(keysRecPRN.includes(dosageId11)){
                        
                        if (!$A.util.isUndefinedOrNull(recToSplice[dosageId11])){
                            recToSplice[dosageId11].sort(function(a, b){
                                return b-a;
                            });
                            for(var pa in recToSplice[dosageId11]){
                                for(var forIndex1 in jsonList[wa].Record){
                                    if(recToSplice[dosageId11][pa].toString()==jsonList[wa].Record[forIndex1].indexOfDay.toString()){
                                        jsonList[wa].Record.splice(forIndex1 , 1);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
                //taper end
                
                var keysRecActionOrder=Object.keys(recToSplice);
                for(var ao=0 ; ao<jsonList3.length ; ao++){
                    var dosageId3=jsonList3[ao].dosageInstId;
                    if(keysRecActionOrder.includes(dosageId3)){
                        if (!$A.util.isUndefinedOrNull(recToSplice[dosageId3])){
                            for(var pao in recToSplice[dosageId3]){
                                for(var forIndex3 in jsonList3[ao].Record){
                                    if(recToSplice[dosageId3][pao].toString()==jsonList3[ao].Record[forIndex3].indexOfDay.toString()){
                                        jsonList3[ao].Record.splice(forIndex3 , 1);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
                console.log('y',JSON.stringify(jsonList2));  
                //Taper Sorting 
                var noTaper = true;
                var finalListForTaper = [];
                for(var recSort in jsonList2){
                    var jsonfinal = {};
                    for(var insideRec in jsonList2[recSort].Record){
                        noTaper = false;
                        jsonfinal = {};
                        jsonfinal['id'] = jsonList2[recSort].id;
                        jsonfinal['dosageInstId'] =  jsonList2[recSort].dosageInstId;
                        jsonfinal['MedicationName'] = jsonList2[recSort].MedicationName;
                        jsonfinal['Record']=[];
                        jsonfinal['Record'].push(jsonList2[recSort].Record[insideRec]);
                        finalListForTaper.push(jsonfinal);
                    }                    
                }
                helper.doSort(finalListForTaper);
                var noPRN = true;
                //PRN Sorting
                var finalListForPRN = [];
                for(var recSort in jsonList){
                    var jsonfinal = {};
                    for(var insideRec in jsonList[recSort].Record){
                        noPRN = false;
                        jsonfinal = {};
                        jsonfinal['id'] = jsonList[recSort].id;
                        jsonfinal['dosageInstId'] =  jsonList[recSort].dosageInstId;
                        jsonfinal['MedicationName'] = jsonList[recSort].MedicationName;
                        jsonfinal['Record']=[];
                        jsonfinal['Record'].push(jsonList[recSort].Record[insideRec]);
                        finalListForPRN.push(jsonfinal);
                    }                    
                }
                helper.doSort(finalListForPRN);
                
                //Acion Order Sorting
                var noActionOrder = true;
                var finalListForActionOrder = [];
                for(var recSort in jsonList3){
                    var jsonfinal = {};
                    for(var insideRec in jsonList3[recSort].Record){
                        noActionOrder = false;
                        jsonfinal = {};
                        jsonfinal['id'] = jsonList3[recSort].id;
                        jsonfinal['dosageInstId'] =  jsonList3[recSort].dosageInstId;
                        jsonfinal['MedicationName'] = jsonList3[recSort].MedicationName;
                        jsonfinal['Record']=[];
                        jsonfinal['Record'].push(jsonList3[recSort].Record[insideRec]);
                        finalListForActionOrder.push(jsonfinal);
                    }                    
                }
                helper.doSort(finalListForActionOrder);
                if(noActionOrder == true){
                    component.set("v.messege",true);
                }
                if(noTaper == true){
                    component.set("v.messegeTaper",true);
                }
                if(noPRN == true){
                    component.set("v.messegePrn",true);
                }
                console.log('finaljson---Mahendra ', JSON.stringify(finalListForTaper));
                console.log('finaljson', JSON.parse(JSON.stringify(finalListForPRN)));
                console.log('finaljson', JSON.parse(JSON.stringify(finalListForActionOrder)));
                component.set("v.jsonListTaper" ,JSON.parse(JSON.stringify(finalListForTaper)));
                console.log('fhewbei	wmqn ' , component.get("v.jsonListTaper"));
                component.set("v.jsonListTaperCopy" ,JSON.parse(JSON.stringify(finalListForTaper)));
                component.set("v.jsonList",JSON.parse(JSON.stringify(finalListForPRN)));
                component.set("v.jsonListCopy",JSON.parse(JSON.stringify(finalListForPRN)));
                component.set("v.jsonListActionOrder" , JSON.parse(JSON.stringify(finalListForActionOrder)));
                component.set("v.jsonListActionOrderCopy" , JSON.parse(JSON.stringify(finalListForActionOrder)));
                var onlyDosageRecords = [];
                var taperRecords  = JSON.parse(JSON.stringify(jsonList2));
                for(var rec in taperRecords ){
                    if(!$A.util.isUndefinedOrNull(taperRecords[rec])) {
                        onlyDosageRecords = onlyDosageRecords.concat(taperRecords[rec].Record);
                    }
                }
                console.log('onlyDosageRecords '+JSON.stringify(onlyDosageRecords));
                var allExistingDosageRecords = helper.filterMissedMedications(component, onlyDosageRecords);
                component.set("v.allDataForMissedMedication",allExistingDosageRecords);
                console.log('allExistingDosageRecords '+JSON.stringify(allExistingDosageRecords));
                var  dataTaper = component.get("v.jsonListTaperCopy");
                var  dataPRN = component.get("v.jsonListCopy");
                var  dataAO = component.get("v.jsonListActionOrderCopy");
                var allData = dataTaper.concat(dataPRN,dataAO);
                if($A.util.isEmpty(allData)){
                    component.set("v.hidesearch",true);
                }
                component.set("v.loaded",true);
                
                //Vaccination part
                
            }
        });
        $A.enqueueAction(action);
    },
    
    hideExampleModal : function(component, event, helper) {
        component.set("v.isActive",false);  
        component.destroy(); 
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    Searches: function(component, event, helper) {
        //alert('inside');
        var searchField = component.find('searchFieldes');
        //alert('inside 2');
        var allData = component.get('v.jsonListCopy');
        var allDataTaper = component.get('v.jsonListTaperCopy');
        var allDataActionOrder = component.get('v.jsonListActionOrderCopy');
        var searchKeyWord = component.get("v.searchKeyword");
        var fillData = allData.filter(function(dat) {
            return (dat.MedicationName.toLowerCase()).startsWith(searchKeyWord.toLowerCase());
        });
        var fillDataTaper = allDataTaper.filter(function(dat1) {
            return (dat1.MedicationName.toLowerCase()).startsWith(searchKeyWord.toLowerCase());
        });
        var fillDataActionOrder = allDataActionOrder.filter(function(dat2) {
            return (dat2.MedicationName.toLowerCase()).startsWith(searchKeyWord.toLowerCase());
        });
        component.set("v.jsonList", fillData);
        component.set("v.jsonListTaper", fillDataTaper);
        component.set("v.jsonListActionOrder" , fillDataActionOrder);
    },
    SearchesVaccination: function(component, event, helper) {
        //alert('inside');
        var searchField = component.find('searchFieldes');
        var allDataVaccine = component.get('v.jsonListVaccineCopy');
        var searchKeyWord = component.get("v.searchKeyword");
        var fillDataVaccine = allDataVaccine.filter(function(dat2) {
            return (dat2.vaccineName.toLowerCase()).startsWith(searchKeyWord.toLowerCase());
        });
        component.set("v.jsonListVaccine" , fillDataVaccine);
         
    },
    
    //onblur for PRN
    recordEdit1	:	function(component,event,helper){
        component.set("v.saveValPRN" , true);
        component.set("v.checkSave" , false);
        var index = event.getSource().get('v.name');
        var value = event.getSource().get("v.value");
        console.log('value in recordEdit1 '+value);
        var array = index.split('$');
        var upperIndex = array[0];
        var insideIndex = array[1];
        var fieldName = array[2];
        if(fieldName == 'MedicationNameRadioPRN'){
            fieldName = 'MedicationNameRadio';
        }
        var flag=0;
        var savedListRecordPRN = component.get("v.savedListRecordPRN");
        var jsonListPRN = JSON.parse(JSON.stringify(component.get("v.jsonList")));
        component.set("v.index1PRN",insideIndex);
        var newList = component.get("v.PRNToRemove");
        var jsonInside = (jsonListPRN[upperIndex].Record)[0];
        var indexToSplice =  (jsonListPRN[upperIndex].Record)[0]['indexOfDay'];
        console.log('json',jsonInside);
        if(!$A.util.isUndefinedOrNull(value) && value!=''){
            jsonInside['IsNotRegistered']=true;
        }
        
        console.log('arrived'+JSON.stringify(jsonInside));
        if(! newList.includes(upperIndex)){
            newList.push(upperIndex);
        }
        component.set("v.PRNToRemove",newList);
        console.log('remove PRN ',newList);
        console.log('savedListRecordPRN ',savedListRecordPRN);
        if(!$A.util.isUndefinedOrNull(savedListRecordPRN) && !$A.util.isEmpty(savedListRecordPRN) && savedListRecordPRN.length>0){
            console.log('if');
            for(var rec in savedListRecordPRN){
                
                if(savedListRecordPRN[rec].id == jsonInside['id'] && indexToSplice == savedListRecordPRN[rec]['indexOfDay']){
                    console.log('saidshfdb');
                    savedListRecordPRN[rec][fieldName] = value; 
                    savedListRecordPRN[rec]['indexVar'] = indexToSplice;
                    flag = 1;
                    console.log('ndide if');
                    break;
                }                   
            }
            if(flag == 0){
                console.log('flag is zero ');
                jsonInside['indexVar'] = indexToSplice;
                jsonInside[fieldName] = value;
                savedListRecordPRN.push(jsonInside);
                
            }
            component.set("v.savedListRecordPRN",savedListRecordPRN);
            
        }else{
            console.log('flag is not zero ');
            var newListOne = [] ;
            jsonInside['indexVar'] = indexToSplice;
            jsonInside[fieldName] = value;
            newListOne.push(jsonInside);  
            component.set("v.savedListRecordPRN",newListOne);
            console.log('newListOne data '+JSON.stringify(newListOne));
        }
        console.log('savedListRecordPRN after ',component.get("v.savedListRecordPRN"));
        console.log('ss',component.get("v.jsonListTaper"));
        console.log('final result dcf' +  JSON.stringify(component.get("v.savedListRecordPRN")));
    },
    
    // save for PRN data  - Not used now but do not delete it
    saveMarRecordForPRN :function(component,event,helper){
        component.set("v.loaded",false);
        console.log("vale is" , component.get("v.time"));
        var indexVal = component.get("v.index1PRN");
        var json = component.get("v.jsonList");
        console.log('PRNjson' , json);
        var record = component.get("v.savedListRecordPRN") ;
        var saveTime = component.get("v.time");
        console.log('PRNjsonsaved----' , record + indexVal);
        var action1 = component.get("c.saveMarForPRN");
        action1.setParams({ 
            jsonList : JSON.stringify(record),
            indexValue : indexVal ,
            saveTimeVal : saveTime , 
            accountId : component.get("v.recordVal")
        });
        
        action1.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.loaded",true);
                console.log('success');
                var recordToSplice = response.getReturnValue();
                for(var i=0 ; i<json.length ; i++){
                    var val1 = json[i].Record ; 
                    
                    for(var key in recordToSplice){
                        if(key == json[i].dosageInstId){
                            console.log('reo' , recordToSplice[key] + '' + key + ' ' + json[i].dosageInstId);
                            if (!$A.util.isUndefinedOrNull(recordToSplice[key])){
                                val1.splice(recordToSplice[key] , 1);
                                console.log('dosage id is', val1);
                            }
                        }
                    }
                }
                component.set("v.jsonList" , json) ;
                console.log('cjhvkhb', component.get("v.jsonList")); 
                component.set("v.loaded",true);
            }
            else if(state ==="ERROR"){
                console.log('Failure');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
            
        });        
        $A.enqueueAction(action1);
    },
    
    // for tapers
    recordEdit	:	function(component,event,helper){
        component.set("v.saveValTaper" , true);
        component.set("v.checkSave" , false);
        var index = event.getSource().get('v.name');
        var value = event.getSource().get("v.value");
        console.log(value);
        var array = index.split('$');
        var upperIndex = array[0];
        var insideIndex = array[1];
        var fieldName = array[2];      
        component.set("v.index1",insideIndex);
        console.log('val is',component.get("v.index1"));
        var savedListRecord = component.get("v.savedListRecord");
        var jsonList = JSON.parse(JSON.stringify(component.get("v.jsonListTaper")));
        console.log('jsonList '+JSON.stringify(jsonList));
        var newList = component.get("v.tapersToRemove") ;
        //var flag=0;
        var jsonInside = (jsonList[upperIndex].Record)[0];
        var indexToSplice =  (jsonList[upperIndex].Record)[0]['indexOfDay'];
        if(!$A.util.isUndefinedOrNull(value) && value!=''){
            jsonInside['IsNotRegistered']=true; 
        }
        
        if(! newList.includes(upperIndex)){
            newList.push(upperIndex);
        }
        component.set("v.tapersToRemove",newList);
        console.log('remove ',newList);
        
        var flag=0;
        if(!$A.util.isUndefinedOrNull(savedListRecord) && !$A.util.isEmpty(savedListRecord)){
            for(var rec in savedListRecord){
                if(savedListRecord[rec].id == jsonInside['id'] && indexToSplice == savedListRecord[rec]['indexOfDay']){
                    savedListRecord[rec]['indexVar'] = indexToSplice;
                    savedListRecord[rec][fieldName] = value; 
                    flag = 1;
                    break;
                }                   
            }
            if(flag == 0){                  
                jsonInside['indexVar'] = upperIndex;
                jsonInside[fieldName] = value;
                savedListRecord.push(jsonInside);
                
            }   
            component.set("v.savedListRecord",savedListRecord);
        }else{
            var newListOne = [] ;
            jsonInside['indexVar'] = upperIndex;
            jsonInside[fieldName] = value;
            newListOne.push(jsonInside); 
            component.set("v.savedListRecord",newListOne);
            
        }
        
        console.log('taper ',jsonList);
        console.log('final result ' +  JSON.stringify(component.get("v.savedListRecord")));
    },
    
    // for actionOrder
    recordEditAction : function(component,event,helper){
        component.set("v.checkSave" , false);
        var indexActionOrder = event.getSource().get('v.name');
        console.log('indexActionOrder '+indexActionOrder);
        var valueActionOrder = event.getSource().get("v.value");
        console.log('valueActionOrder '+valueActionOrder);
        var arrayActionOrder = indexActionOrder.split('$');
        console.log('arrayActionOrder '+arrayActionOrder);
        var upperIndex = arrayActionOrder[0];
        console.log('upperIndex '+upperIndex);
        var insideIndex = arrayActionOrder[1];
        console.log('insideIndex '+insideIndex);
        var fieldName = arrayActionOrder[2];
        console.log('fieldName '+fieldName);
        if(fieldName == 'MedicationNameRadioAOrder'){
            fieldName = 'MedicationNameRadio';
        }
        component.set("v.indexAction",insideIndex);
        
        var savedActionOrderRecord = component.get("v.savedActionOrderRecord");
        console.log('savedActionOrderRecord ',JSON.stringify(savedActionOrderRecord));
        console.log('val is',component.get("v.indexAction"));
        var jsonListActionOrder = component.get("v.jsonListActionOrder");
        console.log('jsonListActionOrder '+JSON.stringify(jsonListActionOrder));
        var newList = component.get("v.ActionOrdersToRemove");
        var jsonInside = (jsonListActionOrder[upperIndex].Record)[0];
        var indexToSplice =  (jsonListActionOrder[upperIndex].Record)[0]['indexOfDay'];
        if(valueActionOrder=="false"){
            jsonInside['IsNotRegistered']=true;
        }
        console.log('final json '+JSON.stringify(component.get("v.jsonListActionOrder")));
        if(! newList.includes(upperIndex)){
            newList.push(upperIndex);
        }
        component.set("v.ActionOrdersToRemove",newList);
        console.log('remove ',newList);
        
        
        var flag=0;
        if(!$A.util.isUndefinedOrNull(savedActionOrderRecord) && !$A.util.isEmpty(savedActionOrderRecord) ){
            for(var rec in savedActionOrderRecord){
                if(savedActionOrderRecord[rec].id == jsonInside['id'] && indexToSplice == savedActionOrderRecord[rec]['indexOfDay']){
                    savedActionOrderRecord[rec][fieldName] = valueActionOrder; 
                    savedActionOrderRecord[rec]['indexVar'] = indexToSplice;
                    flag = 1;
                    break;
                }                   
            }
            if(flag == 0){                  
                jsonInside['indexVar'] = insideIndex;
                jsonInside[fieldName] = valueActionOrder;
                savedActionOrderRecord.push(jsonInside);
                
            }   
            component.set("v.savedActionOrderRecord",savedActionOrderRecord);
        }else{
            var newListOne = [] ;
            jsonInside['indexVar'] = insideIndex;
            jsonInside[fieldName] = valueActionOrder;
            newListOne.push(jsonInside);  
            component.set("v.savedActionOrderRecord",newListOne);
            
        }
        console.log('final result ' +  JSON.stringify(component.get("v.savedActionOrderRecord")));    
    },
    
    
    recordEditVaccine :	function(component,event,helper){
        component.set("v.saveValVaccine" , true);
        component.set("v.checkSave" , false);
        var index = event.getSource().get('v.name');
        var value = event.getSource().get("v.value");
        var array = index.split('$');
        var upperIndex = array[0];
        var fieldName = array[1];
        var flag=0;
        var savedListVaccine = component.get("v.savedListVaccine");
        var jsonListVaccine = JSON.parse(JSON.stringify(component.get("v.jsonListVaccine")));
        var newList = component.get("v.vaccineToRemove");
        var jsonInside = jsonListVaccine[upperIndex];
        var indexToSplice =  jsonListVaccine[upperIndex]['indexOfDay'];
        
        if(value=="false"){
            jsonInside['IsNotRegistered']=true;
        }
        
        console.log('arrived'+JSON.stringify(jsonInside));
        if(! newList.includes(upperIndex)){
            newList.push(upperIndex);
        }
        if(!$A.util.isUndefinedOrNull(savedListVaccine) && !$A.util.isEmpty(savedListVaccine) && savedListVaccine.length>0){
            console.log('if');
            for(var rec in savedListVaccine){
                
                if(savedListVaccine[rec].id == jsonInside['id'] && indexToSplice == savedListVaccine[rec]['indexOfDay']){
                    console.log('saidshfdb');
                    savedListVaccine[rec][fieldName] = value; 
                    savedListVaccine[rec]['indexVar'] = indexToSplice;
                    flag = 1;
                    console.log('ndide if');
                    break;
                }                   
            }
            if(flag == 0){
                jsonInside['indexVar'] = indexToSplice;
                jsonInside[fieldName] = value;
                savedListVaccine.push(jsonInside);
                
            }
            component.set("v.savedListVaccine",savedListVaccine);
            
        }else{
            var newListOne = [] ;
            jsonInside['indexVar'] = indexToSplice;
            jsonInside[fieldName] = value;
            newListOne.push(jsonInside);  
            component.set("v.savedListVaccine",newListOne);
            
        }
    },
    procedureValidity  : function(component ,event ,helper){
        var valid = true;
        valid = helper.helperMethod(component , valid);
    },
    // for both prn and taper + action Order
    
    handleConfirmDialogNo:function(component, event, helper) {
        component.set("v.showConfirmDialog",false);
        
    },
    
    handleConfirmDialogYes :  function(component, event, helper) {
        
        var valid = true;
        
        var procedureStartCmp = component.find("procedure-start_time");
        var strtProcedureTime = procedureStartCmp.get('v.value');
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get('v.value');
        if(endProcedureTime == null )
        {
            var today = new Date();
            endProcedureTime = today; 
        }
        if(valid == true){
            var taperToRemove = component.get("v.tapersToRemove");
            var PRNToRemove = component.get("v.PRNToRemove");
            var ActionOrdersToRemove = component.get("v.ActionOrdersToRemove");
            console.log('$ S',PRNToRemove);
            var saveTime = component.get("v.time");
            var json = component.get("v.jsonListTaper");
            var jsonPRN = component.get("v.jsonList");
            var jsonActionOrder = component.get("v.jsonListActionOrder")
            console.log('action order' , jsonActionOrder);
            var recordTaper = component.get("v.savedListRecord") ;
            var recordPRN = component.get("v.savedListRecordPRN") ;
            var recordActionOrder = component.get("v.savedActionOrderRecord");
            var collectiveecord = recordTaper.concat(recordPRN,recordActionOrder);
            console.log('Save time '+JSON.stringify(saveTime));
            helper.filterMissedMedications(component,recordTaper);
            console.log('Taper came '+JSON.stringify(recordTaper));
            console.log('PRN bid goodbye '+JSON.stringify(recordPRN));
            console.log('Action order died '+JSON.stringify(recordActionOrder));
            console.log('All dosage records  '+JSON.stringify(component.get("v.allDataForMissedMedication")));
            console.log('missedMedicationJSON '+JSON.stringify(helper.filterMissedMedications(component,collectiveecord)));
            var action = component.get("c.saveData");
            component.set("v.loaded",false);
            action.setParams({ 
                jsonList : JSON.stringify(recordTaper),
                recordPRN : JSON.stringify(recordPRN),
                recordActionOrder : JSON.stringify(recordActionOrder),
                accountId : component.get("v.recordVal"),
                saveTimeVal : saveTime ,
                allDosageRecords : JSON.stringify(component.get("v.allDataForMissedMedication")),
                missedMedicationJSON : JSON.stringify(helper.filterMissedMedications(component,recordTaper)),
                starttimeProcedure : component.get('v.todayString'),
                endtimeProcedure : endProcedureTime,
                notRegisteredMedications :  JSON.stringify(helper.flagNotRegisteredMedication(component,collectiveecord))
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    console.log('Success');
                    var recordToSplice = response.getReturnValue();
                    console.log('map values' , recordToSplice);
                    console.log('before ',taperToRemove);
                    taperToRemove.sort(function(a, b){
                        return b-a;
                    });
                    console.log('after ',taperToRemove);
                    for(var ObjRec in taperToRemove){
                        json.splice(taperToRemove[ObjRec],1);
                    }
                    console.log('PRN before ',PRNToRemove);
                    PRNToRemove.sort(function(a, b){
                        return b-a;
                    });
                    console.log('after ',PRNToRemove);
                    for(var ObjRec in PRNToRemove){
                        jsonPRN.splice(PRNToRemove[ObjRec],1);
                    }
                    
                    
                    ActionOrdersToRemove.sort(function(a, b){
                        return b-a;
                    });
                    console.log('after ',ActionOrdersToRemove);
                    for(var ObjRec in ActionOrdersToRemove){
                        jsonActionOrder.splice(ActionOrdersToRemove[ObjRec],1);
                    }
                    component.set("v.savedListRecord",[]);
                    component.set("v.savedListRecordPRN",[]);
                    component.set("v.savedActionOrderRecord",[]);
                    component.set("v.tapersToRemove",[]);
                    component.set("v.PRNToRemove",[]);
                    component.set("v.ActionOrdersToRemove",[]);
                    console.log('%%ENd%');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : 'success' ,
                        "message": "The medication has been administered successfully."
                    });
                    toastEvent.fire();
                    helper.ReInit(component , event,helper);    
                    component.set("v.jsonList" , jsonPRN) ;
                    console.log('cjhvkhb', component.get("v.jsonList"));
                    component.set("v.jsonListTaper" , json);
                    component.set("v.jsonListActionOrder", jsonActionOrder );
                    console.log('taper data', component.get("v.jsonListTaper"));
                    component.set("v.checkSave" , true);
                    component.set("v.loaded",true);
                    
                    
                }
                else if(state ==="ERROR"){
                    console.log('Failure');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "No Medication Selected!",
                        "message": "Please Select a Medication to Administer.",
                        "type" : "error"
                    });
                    toastEvent.fire();
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
            
        }
        component.set("v.showConfirmDialog",false);
        
    },
    
    saveMarRecord : function(component,event,helper){
        console.log('saveMarRecord is called ');
        var valid = true;
        valid = helper.helperMethod(component , valid);
        console.log('valid value is '+valid);
        var procedureStartCmp = component.find("procedure-start_time");
        var strtProcedureTime = procedureStartCmp.get('v.value');
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get('v.value');
        if(endProcedureTime == null )
        {
            component.set("v.showConfirmDialog",true); 
        }
        else {
            if(valid == true){
                var taperToRemove = component.get("v.tapersToRemove");
                var PRNToRemove = component.get("v.PRNToRemove");
                var ActionOrdersToRemove = component.get("v.ActionOrdersToRemove");
                console.log('$ S',PRNToRemove);
                var saveTime = component.get("v.time");
                // var indexVal = component.get("v.index1");
                var json = component.get("v.jsonListTaper");
                var jsonPRN = component.get("v.jsonList");
                var jsonActionOrder = component.get("v.jsonListActionOrder")
                console.log('action order' , jsonActionOrder);
                var recordTaper = component.get("v.savedListRecord") ;
                var recordPRN = component.get("v.savedListRecordPRN") ;
                var recordActionOrder = component.get("v.savedActionOrderRecord");
                var collectiveecord = recordTaper.concat(recordPRN,recordActionOrder);
                console.log('Save time '+JSON.stringify(saveTime));
                helper.filterMissedMedications(component,recordTaper);
                console.log('Taper came '+JSON.stringify(recordTaper));
                console.log('PRN bid goodbye '+JSON.stringify(recordPRN));
                console.log('Action order died '+JSON.stringify(recordActionOrder));
                console.log('All dosage records  '+JSON.stringify(component.get("v.allDataForMissedMedication")));
                console.log('missedMedicationJSON '+JSON.stringify(helper.filterMissedMedications(component,collectiveecord)));
                component.set("v.loaded",false);
                var action = component.get("c.saveData");
                console.log('All Taper records '+JSON.stringify(recordTaper));
                    console.log('All PRN records '+JSON.stringify(recordPRN));
                action.setParams({ 
                    jsonList : JSON.stringify(recordTaper),
                    recordPRN : JSON.stringify(recordPRN),
                    recordActionOrder : JSON.stringify(recordActionOrder),
                    accountId : component.get("v.recordVal"),
                    saveTimeVal : saveTime ,
                    allDosageRecords : JSON.stringify(component.get("v.allDataForMissedMedication")),
                    missedMedicationJSON : JSON.stringify(helper.filterMissedMedications(component,recordTaper)),
                    starttimeProcedure : component.get('v.todayString'),
                    endtimeProcedure : component.get('v.endString'),
                    notRegisteredMedications :  JSON.stringify(helper.flagNotRegisteredMedication(component,collectiveecord))
                });
                
                action.setCallback(this, function(response){
                    var state = response.getState();
                    console.log('state state '+state);
                    if(state === "SUCCESS"){
                        component.set("v.loaded",true);
                        console.log('Success');
                        
                        var recordToSplice = response.getReturnValue();
                        console.log('map values' , recordToSplice);
                        console.log('before ',taperToRemove);
                        taperToRemove.sort(function(a, b){
                            return b-a;
                        });
                        console.log('after ',taperToRemove);
                        for(var ObjRec in taperToRemove){
                            json.splice(taperToRemove[ObjRec],1);
                        }
                        console.log('PRN before ',PRNToRemove);
                        PRNToRemove.sort(function(a, b){
                            return b-a;
                        });
                        console.log('after ',PRNToRemove);
                        for(var ObjRec in PRNToRemove){
                            jsonPRN.splice(PRNToRemove[ObjRec],1);
                        }
                        
                        
                        ActionOrdersToRemove.sort(function(a, b){
                            return b-a;
                        });
                        console.log('after ',ActionOrdersToRemove);
                        for(var ObjRec in ActionOrdersToRemove){
                            jsonActionOrder.splice(ActionOrdersToRemove[ObjRec],1);
                        }
                        component.set("v.savedListRecord",[]);
                        component.set("v.savedListRecordPRN",[]);
                        component.set("v.savedActionOrderRecord",[]);
                        component.set("v.tapersToRemove",[]);
                        component.set("v.PRNToRemove",[]);
                        component.set("v.ActionOrdersToRemove",[]);
                        console.log('%%ENd%');
                       
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type" : 'success' ,
                            "message": "The medication has been administered successfully."
                        });
                        toastEvent.fire();
                        helper.ReInit(component , event,helper);    
                        component.set("v.jsonList" , jsonPRN) ;
                        console.log('cjhvkhb', component.get("v.jsonList"));
                        component.set("v.jsonListTaper" , json);
                        component.set("v.jsonListActionOrder", jsonActionOrder );
                        console.log('taper data', component.get("v.jsonListTaper"));
                        component.set("v.checkSave" , true);
                        
                        
                    }
                    else if(state ==="ERROR"){
                        console.log('Failure');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "No Medication Selected!",
                            "message": "Please Select a Medication to Administer."
                        });
                        toastEvent.fire();
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
                
            }
        }
    },
    
    handleChangeReason : function(component,event,helper){
        
    },
    
    toggleSection : function(component, event, helper) {     
        
        var sectionAuraId = event.target.getAttribute("data-auraId");
        var sectionDiv = component.find(sectionAuraId).getElement();
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-close'); 
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }
    },
    handleClick : function(component , event , helper){
        component.get("v.recordVal");
        component.set("v.openVitalSign",true);
    },
    
    saveVaccineRecord : function(component,event,helper){
        
        var valid = true;
           if(valid == true){
                var vaccineToRemove = component.get("v.vaccineToRemove");
               console.log('vaccineToRemove'+vaccineToRemove);
                var jsonListVaccine = component.get("v.jsonListVaccine");
               console.log('jsonListVaccine'+jsonListVaccine);
                var recordToSaveVaccine = component.get("v.savedListVaccine");
               console.log('recordToSaveVaccine'+jsonListVaccine);
                
                component.set("v.loaded",false);
                var action = component.get("c.saveDataVaccine");
                action.setParams({ 
                    recordToSaveVaccine : JSON.stringify(recordToSaveVaccine),
                    accountId : component.get("v.recordVal")
                     
                    
                });
                
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        component.set("v.loaded",true);
                        var recordToSplice = response.getReturnValue();
                        
                        vaccineToRemove.sort(function(a, b){
                            return b-a;
                        });
                        for(var ObjRec in vaccineToRemove){
                            jsonListVaccine.splice(vaccineToRemove[ObjRec],1);
                        }
                        component.set("v.savedListVaccine",[]);
                        component.set("v.vaccineToRemove",[]);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type" : 'success' ,
                            "message": "The medication has been administered successfully."
                        });
                        
                        toastEvent.fire();
                       
                        //  helper.ReInit(component , event,helper);    
                        component.set("v.jsonListVaccine", jsonListVaccine );
                        component.set("v.checkSave" , true);
                    }
                    
                    else if(state ==="ERROR"){
                        console.log('Failure');
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "No Medication Selected!",
                            "message": "Please Select a Medication to Administer."
                        });
                        toastEvent.fire();
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
            }
      
    
    }
    
})