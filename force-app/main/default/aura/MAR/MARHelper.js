({
    helperMethod : function(component , valid) {
        var procedureStartCmp = component.find("procedure-start_time");
        var strtProcedureTime = procedureStartCmp.get('v.value');
        
        var procedureEndCmp = component.find("procedure-end_time");
        var endProcedureTime = procedureEndCmp.get('v.value');
        
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
    refreshValidity : function(component, event, helper) {
        var procedureEndCmp = component.find("procedure-end_time");
        procedureEndCmp.setCustomValidity("");
        procedureEndCmp.reportValidity();
    },
    SearchHelperNew: function(component, event, helper) {
        // show spinner message
        console.log('ghj');
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var allData = component.get('v.allData');
        var searchKeyWord = component.get("v.searchKeyword"); 
        var nameSpace = 'ElixirSuite__' ;
        var DrugName =  nameSpace.concat('Drug_Name__c'); 
        
        var fillData = allData.filter(function(dat) {
            return (dat.DrugName.toLowerCase()).startsWith(searchKeyWord.toLowerCase());
        });
        
        component.find("Id_spinner").set("v.class" , 'slds-hide');
        //  component.set("v.totalPages", Math.ceil(fillData.length/component.get("v.pageSize")) > 0 ? Math.ceil(fillData.length/component.get("v.pageSize")) : 1);
        component.set("v.allData", fillData);
        // component.set("v.currentPageNumber",1);
        //   helper.buildData(component, helper);
    },
    doSort: function(array) {
        array.sort(function(a , b){
            
            const bandA = a.Record[0].times;
            const bandB = b.Record[0].times;
            
            let comparison = 0;
            if (bandA > bandB) {
                comparison = 1;
            } else if (bandA < bandB) {
                comparison = -1;
            }
            return comparison;
        });
        console.log('doSort',array);
    },
    filterMissedMedications: function(component, PRNjson) {
        console.log('for missed '+JSON.stringify(component.get("v.allDataForMissedMedication")));
        var arrMissedMeications  =[]; 
        var recInside = {'dosageID' :'' ,
                         'parentID' : '',
                         'timings' : []};  
        
        if(!$A.util.isEmpty(PRNjson)) {
            for(var rec in PRNjson) {                               
                for(var exists in arrMissedMeications) {
                    if(arrMissedMeications[exists].dosageID==PRNjson[rec].dosageId) {
                        arrMissedMeications[exists].timings.push(PRNjson[rec].indexForInspection);                       
                    }                                     
                }                
                if(recInside.dosageID!=PRNjson[rec].dosageId) {
                    recInside = {'dosageID' :'' ,
                                 'parentID' : '',
                                 'timings' : []};        
                    recInside.dosageID=PRNjson[rec].dosageId;
                    recInside.parentID=PRNjson[rec].id ,
                        recInside.timings.push(PRNjson[rec].indexForInspection);
                    arrMissedMeications.push(recInside);
                }
                
            }
        }
        console.log('missed medication '+JSON.stringify(arrMissedMeications));
        return arrMissedMeications;
    },
    
    flagNotRegisteredMedication: function(component, listOfMedicines) {
        var arrOfNotRegisteredRecords=  [];
        for(var rec in listOfMedicines){
            if(!$A.util.isUndefinedOrNull(listOfMedicines[rec].IsNotRegistered && listOfMedicines[rec].IsNotRegistered)){                 
                arrOfNotRegisteredRecords.push(listOfMedicines[rec]);                  
            }
        }
        console.log('NOT REGISTERED records  '+JSON.stringify(arrOfNotRegisteredRecords));
        return arrOfNotRegisteredRecords;
    },
    ReInit : function(component , event,helper){
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
                var nameSpace = 'ElixirSuite__';
                component.set("v.nameSpace",allData.nameSpace);
                console.log('data--='+JSON.stringify(allData));
                component.set("v.allData" , allData.morDataPrn);
                component.set("v.data" , allData.morDataPrn);
                component.set("v.allDataTaper" , allData.morDataTaper);
                component.set("v.dataTaper" , allData.morDataTaper);
                component.set("v.allDataActionOrder" , allData.morDataActionOrder);
                component.set("v.dataTaperActionOrder" , allData.morDataActionOrder);
                if($A.util.isEmpty(allData.morDataActionOrder)){
                    component.set("v.messege" , true);
                }
                if($A.util.isEmpty(allData.morDataPrn)){
                    component.set("v.messegePrn" , true);
                }
                if($A.util.isEmpty(allData.morDataTaper)){
                    component.set("v.messegeTaper" , true);
                }
                var recToSplice = allData.RecordToSplice;
                component.set("v.searchKeyword",'');
                component.set("v.vitalStatus" , allData.checkStatus);
                console.log('the val is',allData);
                var listLength = allData.morDataPrn.length;
                var taperLength = allData.morDataTaper.length ;
                var actionOrderLength = allData.morDataActionOrder.length ;
                var jsonList = [];
                var jsonList2 = [] ;
                var jsonList3 = [];
                var sortTimeList = [];
                console.log('PRN listLength', listLength);
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
                                                           
                                                           //alert(allData.morDataPrn[i][nameSpace + 'Frequency__r'][0].Id);
                                                           insideJson = {"id" : allData.morDataPrn[i].Id,
                                                                         "dosageId" : allData.morDataPrn[i][nameSpace + 'Frequency__r'][0].Id,
                                                                         "medicationName" : allData.morDataPrn[i][nameSpace + 'Drug_Name__c'],
                                                                         "patientAccount" : allData.morDataPrn[i][nameSpace + 'Account__c'],
                                                                         "Type" : allData.morDataPrn[i][nameSpace + 'Type__c'],
                                                                         "Start_Date"  : allData.morDataPrn[i][nameSpace + 'Start_Date__c'],
                                                                         "DispenseExpectedSupplyDuration" : allData.morDataPrn[i][nameSpace + 'Number_of_Times_Days_Weeks__c'],
                                                                         "After_Discharge" : allData.morDataPrn[i][nameSpace + 'After_Discharge__c'],
                                                                         "Route" : allData.morDataPrn[i][nameSpace + 'Route_New__c'],
                                                                         "Dosage_Form" : allData.morDataPrn[i][nameSpace + 'Dosage_Form__c'] ,
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
                                                                         "allStrength" : newStr,
                                                                         // "indexForInspection" : p,
                                                                         
                                                                        }  
                                                           //  console.log('gvnhv' , insideJson);
                                                           completeJson.push(insideJson);
                                                           console.log(console.log('complete',completeJson));
                                                          }
                        var rec ={};
                        rec = {"id" : allData.morDataPrn[i].Id,
                               "dosageInstId" : allData.morDataPrn[i][nameSpace + 'Frequency__r'][0].Id,
                               "MedicationName" : allData.morDataPrn[i][nameSpace + 'Drug_Name__c'] ,
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
                    for(var p=1;p<= parseInt(countOfRepeat);p++){
                        
                        var str1 = allStrengths[p-1];
                        var dosa1 = allDosages[p-1];
                        var unit1 = allUnits[p-1] ;
                        var rout1 = allData.morDataTaper[m][nameSpace+'Route_New__c'] ;
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
                        if($A.util.isUndefinedOrNull(dosa1))
                            dosa1 = ' ';
                        var newStr1 = dosa1 + ' ' + multiply11 + ' ' + str1 + comma11 + rout1 + comma12 + unit1 ;
                        //     console.log('atr' , newStr1);
                        insideJson1 = {"id" : allData.morDataTaper[m].Id,
                                       "dosageId" : allData.morDataTaper[m][nameSpace + 'Frequency__r'][0].Id,
                                       "medicationName" : allData.morDataTaper[m][nameSpace + 'Drug_Name__c'],
                                       "patientAccount" : allData.morDataTaper[m][nameSpace + 'Account__c'],
                                       "Type" : allData.morDataTaper[m][nameSpace + 'Type__c'],
                                       "Start_Date" : allData.morDataTaper[m][nameSpace + 'Start_Date__c'],
                                       "DispenseExpectedSupplyDuration" : allData.morDataTaper[m][nameSpace + 'Number_of_Times_Days_Weeks__c'],
                                       "After_Discharge" : allData.morDataTaper[m][nameSpace + 'After_Discharge__c'],
                                       "Route" : allData.morDataTaper[m][nameSpace + 'Route_New__c'],
                                       "Dosage_Form" : allData.morDataTaper[m][nameSpace + 'Dosage_Form__c'] ,
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
                            "MedicationName" : allData.morDataTaper[m][nameSpace + 'Drug_Name__c'] ,
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
                    for(var g=1;g<= tempDataActionOrder;g++){
                        
                        insideJsonActionOrder = {"id" : allData.morDataActionOrder[f].Id,
                                                 "dosageId" : allData.morDataActionOrder[f][nameSpace + 'Frequency__r'][0].Id,
                                                 "medicationName" : allData.morDataActionOrder[f][nameSpace + 'Drug_Name__c'],
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
                                      "MedicationName" : allData.morDataActionOrder[f][nameSpace + 'Drug_Name__c'] ,
                                      "Record" : JSON.parse(JSON.stringify(completeJsonActionOrder))
                                     };
                    jsonList3.push(recActionOrder);
                    //helper.doSort(jsonList3);
                }
                // console.log('dnjwq' , JSON.stringify(jsonList2));
                //      console.log('dnjwq' , JSON.stringify(jsonList));
                // Action order ends
                
                var keysRec=Object.keys(recToSplice);
                for(var w=0 ; w<jsonList2.length ; w++){
                    var val1 = jsonList2[w].Record ; 
                    console.log(recToSplice);
                    var dosageId=jsonList2[w].dosageInstId;
                    if(keysRec.includes(dosageId)){
                        if (!$A.util.isUndefinedOrNull(recToSplice[dosageId])){
                            // helper.doSort(recToSplice[dosageId]);
                            recToSplice[dosageId].sort(function(a, b){
                                return b-a;
                            });
                            for(var p in recToSplice[dosageId]){
                                for(var forIndex in jsonList2[w].Record){
                                    console.log('undefy ',jsonList2[w].Record[forIndex].indexOfDay);
                                    if(recToSplice[dosageId][p].toString()==jsonList2[w].Record[forIndex].indexOfDay.toString()){
                                        jsonList2[w].Record.splice(forIndex , 1);
                                        console.log('sds',JSON.stringify(jsonList2));
                                        //helper.doSort(jsonList2);
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
                    //  console.log(recToSplice);
                    var dosageId11=jsonList[wa].dosageInstId;
                    if(keysRecPRN.includes(dosageId11)){
                        
                        if (!$A.util.isUndefinedOrNull(recToSplice[dosageId11])){
                            recToSplice[dosageId11].sort(function(a, b){
                                return b-a;
                            });
                            for(var pa in recToSplice[dosageId11]){
                                for(var forIndex1 in jsonList[wa].Record){
                                    // console.log(jsonList[wa].Record[forIndex1].indexOfDay);
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
                    //    var val3 = jsonList3[ao].Record ; 
                    //   console.log(recToSplice);
                    var dosageId3=jsonList3[ao].dosageInstId;
                    if(keysRecActionOrder.includes(dosageId3)){
                        if (!$A.util.isUndefinedOrNull(recToSplice[dosageId3])){
                            for(var pao in recToSplice[dosageId3]){
                                for(var forIndex3 in jsonList3[ao].Record){
                                    //  console.log(jsonList2[w].Record[forIndex].indexOfDay);
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
                console.log('finaljson---', JSON.parse(JSON.stringify(finalListForTaper)));
                console.log('finaljson', JSON.parse(JSON.stringify(finalListForPRN)));
                console.log('finaljson', JSON.parse(JSON.stringify(finalListForActionOrder)));
                component.set("v.jsonListTaper" ,JSON.parse(JSON.stringify(finalListForTaper)));
                console.log('fhewbei	wmqn ' , component.get("v.jsonListTaper"));
                component.set("v.jsonListTaperCopy" ,JSON.parse(JSON.stringify(finalListForTaper)));
                // component.set("v.jsonListTaper" ,jsonList2 );
                component.set("v.jsonList",JSON.parse(JSON.stringify(finalListForPRN)));
                //component.set("v.jsonListTaperCopy" ,jsonList2 );
                component.set("v.jsonListCopy",JSON.parse(JSON.stringify(finalListForPRN)));
                component.set("v.jsonListActionOrder" , JSON.parse(JSON.stringify(finalListForActionOrder)));
                component.set("v.jsonListActionOrderCopy" , JSON.parse(JSON.stringify(finalListForActionOrder)));
                //component.set("v.allDataForMissedMedication",JSON.parse(JSON.stringify(jsonList2)));
                //  console.log('allDataForMissedMedication '+JSON.stringify(component.get("v.allDataForMissedMedication")));
                var onlyDosageRecords = [];
                var taperRecords  = JSON.parse(JSON.stringify(jsonList2));
                // console.log('taper records '+JSON.stringiify(taperRecords));
                for(var rec in taperRecords ){
                    if(!$A.util.isUndefinedOrNull(taperRecords[rec])) {
                        onlyDosageRecords = onlyDosageRecords.concat(taperRecords[rec].Record);
                    }
                }
                console.log('onlyDosageRecords '+JSON.stringify(onlyDosageRecords));
                var allExistingDosageRecords = helper.filterMissedMedications(component, onlyDosageRecords);
                component.set("v.allDataForMissedMedication",allExistingDosageRecords);
                console.log('allExistingDosageRecords '+JSON.stringify(allExistingDosageRecords));
                //   var recordTaper = component.get("v.savedListRecord") ;
                //     console.log('bfhb' , recordTaper);
                
                
                //   var recordPRN = component.get("v.savedListRecordPRN") ;
                //  var recordActionOrder = component.get("v.savedActionOrderRecord");
                //  console.log('action order final data', component.get("v.jsonListActionOrder"))
                var  dataTaper = component.get("v.jsonListTaperCopy");
                var  dataPRN = component.get("v.jsonListCopy");
                var  dataAO = component.get("v.jsonListActionOrderCopy");
                var allData = dataTaper.concat(dataPRN,dataAO);
                if($A.util.isEmpty(allData)){
                    component.set("v.hidesearch",true);
                }
            }
            
        });
        $A.enqueueAction(action);
    },
    
    removeDuplicates : function (component,records){
        var filteredRecords = [];
        var duplicateRecords = [];
        for (var rec in records) {
            if(!filteredRecords.includes(records[rec].medicationName)){
                filteredRecords.push(records[rec]);
            }
            duplicateRecords.push(records[rec].medicationName);
        }
        console.log('filtered records  records  '+JSON.stringify(filteredRecords));
        
    }
    
})