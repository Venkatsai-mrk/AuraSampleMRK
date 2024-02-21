({
    SearchHelper: function(component, event) {
        console.log('helper search');
        component.set("v.DisplayButton", true);
        var allData = component.get("v.AllData");
        console.log('all data ' + JSON.stringify(allData));
        var searchKeyWord = component.get("v.searchKeyword");
        var nspc = 'ElixirSuite__'; 
        
        if (component.get("v.selTabId") == 'taper') {
            console.log('inside search taper ' + allData['prescriptionWithTaper']);
            var fillData = allData['prescriptionWithTaper'].filter(function(dat) {
                return (dat[nspc + 'Drug_Name__c'].toLowerCase()).startsWith(searchKeyWord.toLowerCase());
            });
            
            for (var i = 0; i < fillData.length; i++) {
                
                var rowForTaper = fillData[i];
                
                if (rowForTaper[nspc + 'Frequency__r'] != undefined && rowForTaper[nspc + 'Frequency__r'].length != 0 &&
                    rowForTaper[nspc + 'Frequency__r'][0][nspc + 'Frequency_Unit__c'] != undefined &&
                    rowForTaper[nspc + 'Frequency__r'][0][nspc + 'Frequency_Value__c'] != undefined
                   ) {
                    
                    
                    
                    
                    var fstr = rowForTaper[nspc + 'Frequency__r'][0][nspc + 'Frequency_Unit__c'] + 'X' +
                        rowForTaper[nspc + 'Frequency__r'][0][nspc + 'Frequency_Value__c']
                    
                    console.log('fstr ' + fstr);
                    rowForTaper.Strength = fstr;
                    console.log('def ' + rowForTaper.Strength);
                    
                    
                }
                
            }
            // console.log('new data--------' + JSON.stringify(rows));
            component.set('v.dataForTaper', fillData);
            
        } 
        else if (component.get("v.selTabId") == 'prn') {
            console.log('inside prn ' + allData['prescriptionWithPRN']);
            
            var fillData = allData['prescriptionWithPRN'].filter(function(dat) {
                
                return (dat[nspc + 'Drug_Name__c'].toLowerCase()).startsWith(searchKeyWord.toLowerCase());
            });
            console.log('filldata ' + JSON.stringify(fillData));
            
            for (var i = 0; i < fillData.length; i++) {
                
                var row = fillData[i];
                console.log('row 1234 ' + JSON.stringify(row));
                if (row[nspc + 'Frequency__r'] != undefined && row[nspc + 'Frequency__r'].length != 0 &&
                    row[nspc + 'Frequency__r'][0][nspc + 'Dosage_Instruction__c'] != undefined) {
                    
                    console.log('inside if');
                    var str = row[nspc + 'Frequency__r'][0][nspc + 'Repeat__c'];
                    if (str.startsWith('\'n\' times')) {
                        console.log('row-----' + JSON.stringify(row));
                        var str2 = str;
                        var str3 = row[nspc + 'Frequency__r'][0][nspc + 'Dosage_Instruction__c'];
                        var str4 = str2.replace("\'n\'", str3);
                        
                        row.ElixirSuite__Frequency__c = str4;
                        
                    } else if (str.startsWith('After every')) {
                        var str5 = str;
                        var str6 = row[nspc + 'Frequency__r'][0][nspc + 'Dosage_Instruction__c'];
                        var str7 = str5.replace("\'n\'", str6);
                        row.ElixirSuite__Frequency__c = str7;
                        
                    }
                    
                    
                    row.ElixirSuite__Frequency_Unit__c = row[nspc + 'Frequency__r'][0][nspc + 'Frequency_Unit__c']
                    row.ElixirSuite__Frequency_Value__c = row[nspc + 'Frequency__r'][0][nspc + 'Frequency_Value__c']
                    
                    
                }
                
            }
            component.set('v.dataForPRN', fillData);
            
            
        }
            else if(component.get("v.selTabId")=='Action Order'){
                var fillData = allData['prescriptionActionOrder'].filter(function(dat) {
                    
                    return (dat[nspc + 'Drug_Name__c'].toLowerCase()).startsWith(searchKeyWord.toLowerCase());
                });
                console.log('filldata ' + JSON.stringify(fillData));
                
                for (var i = 0; i < fillData.length; i++) {
                    
                    var row = fillData[i];
                    console.log('row 1234 ' + JSON.stringify(row));
                    if (row[nspc + 'Frequency__r'] != undefined && row[nspc + 'Frequency__r'].length != 0 &&
                        row[nspc + 'Frequency__r'][0][nspc + 'Dosage_Instruction__c'] != undefined) {
                        
                        console.log('inside if');
                        var str = row[nspc + 'Frequency__r'][0][nspc + 'Repeat__c'];
                        if (str.startsWith('\'n\' times')) {
                            console.log('row-----' + JSON.stringify(row));
                            var str2 = str;
                            var str3 = row[nspc + 'Frequency__r'][0][nspc + 'Dosage_Instruction__c'];
                            var str4 = str2.replace("\'n\'", str3);
                            
                            row.ElixirSuite__Frequency__c = str4;
                            
                        } else if (str.startsWith('After every')) {
                            var str5 = str;
                            var str6 = row[nspc + 'Frequency__r'][0][nspc + 'Dosage_Instruction__c'];
                            var str7 = str5.replace("\'n\'", str6);
                            row.ElixirSuite__Frequency__c = str7;
                            
                        }
                        
                        
                        row.ElixirSuite__Frequency_Unit__c = row[nspc + 'Frequency__r'][0][nspc + 'Frequency_Unit__c']
                        row.ElixirSuite__Frequency_Value__c = row[nspc + 'Frequency__r'][0][nspc + 'Frequency_Value__c']
                    }
                }
                component.set('v.dataForActionOrder', fillData);
            }
    },
    
    
    filterAllDuplicate: function(component,updatedArray) {
        console.log('received value '+JSON.stringify(updatedArray));
        console.log('selected value value '+JSON.stringify(component.get("v.selected")));
        var uniqueObjs = {};
        var con = component.get("v.selected");        
        con.forEach(function(conItem) {
            updatedArray[conItem.Id] = conItem;
        });        
        con = [];
        var keys = Object.keys(updatedArray);                
        keys.forEach(function(key) {
            con.push(updatedArray[key]);
        });
        console.log('rerurn value '+JSON.stringify(con));
        var originalCon = con ; 
        var downIteration = JSON.parse(JSON.stringify(originalCon));
        for(var rec in downIteration){
            if(downIteration[rec] == ""){
                originalCon.splice(rec,1);
            }
        }
        return originalCon;
    },
    
    emptyArrayHandle: function(component,event,helper) {
        var getExistingArr = component.get("v.selected");
        var upsideDownIteration = JSON.parse(JSON.stringify(getExistingArr));
        
            if(component.get("v.selTabId") == 'taper') {
                for(var i = getExistingArr.length - 1; i >= 0; i--){
                    if(getExistingArr[i].ElixirSuite__Type__c =="Taper"){
                        getExistingArr.splice(i,1);
                    }
                }  
            }
            if(component.get("v.selTabId") == "prn") {
                for(var i = getExistingArr.length - 1; i >= 0; i--){
                    if(getExistingArr[i].ElixirSuite__Type__c =="PRN"){
                        getExistingArr.splice(i,1);
                    }
                }  
            }
            if(component.get("v.selTabId") == 'Action Order') {
                for(var i = getExistingArr.length - 1; i >= 0; i--){
                    if(getExistingArr[i].ElixirSuite__Type__c =="Action Order"){
                        getExistingArr.splice(i,1);
                    }
                }  
            }
        
    } , 
      handleUncheckInList: function(component,event,helper,selectedArr) {
        
        if(component.get("v.selTabId") == 'taper') {
            component.set("v.bufferTaperLst",selectedArr);
        }
        if(component.get("v.selTabId") == "prn") {
            component.set("v.bufferPRNLst",selectedArr);
            
        }
        if(component.get("v.selTabId") == 'Action Order') {
           component.set("v.bufferActionOrderLst",selectedArr);
        }
    },
    
     doInitReplica: function(component, event, helper) {
     console.log(' insideinit');
        var nspc = 'ElixirSuite__';
        var action = component.get("c.fetchMedications");
         component.find("Id_spinner").set("v.class" , 'slds-show');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 component.find("Id_spinner").set("v.class" , 'slds-hide');
                //alert('inside success');
                component.set("v.AllData",response.getReturnValue());
                var rows = response.getReturnValue().prescriptionWithPRN;
                console.log('All Data'+JSON.stringify(response.getReturnValue()));
                var rowsForTaper = response.getReturnValue().prescriptionWithTaper;
                var rowsForActionOrder = response.getReturnValue().prescriptionActionOrder;
                
                
                for (var i = 0; i < rows.length; i++) {
                    
                    var row = rows[i];
                     if(!$A.util.isUndefinedOrNull(rows[i][nspc + 'Number_of_Times_Days_Weeks__c'])){
                    row['ElixirSuite__dispenceSupplyCustomForPRN__c'] = rows[i][nspc + 'Number_of_Times_Days_Weeks__c'].toString(8);
                    }
                    console.log('row 1234 ' + JSON.stringify(row));
                    if (row[nspc + 'Frequency__r'] != undefined && row[nspc + 'Frequency__r'].length != 0 &&
                        row[nspc + 'Frequency__r'][0][nspc+'Dosage_Instruction__c'] != undefined) {
                        
                        console.log('inside if');
                        var str = row[nspc + 'Frequency__r'][0][nspc+'Repeat__c'];
                        if(!$A.util.isUndefinedOrNull(str)){
                        if (str.startsWith('\'n\' times')) {
                            // console.log('row-----' + JSON.stringify(row));
                            var str2 = str;
                            console.log('str2'+JSON.stringify(str2));
                            var str3 = row[nspc + 'Frequency__r'][0][nspc+'Dosage_Instruction__c'];
                            console.log('str3'+JSON.stringify(str3));
                            var str4 = str2.replace("\'n\'", str3);
                            row.ElixirSuite__Frequency__c = str4;
                            
                        } else if (str.startsWith('After every')) {
                            var str5 = str;
                            var str6 = row[nspc + 'Frequency__r'][0][nspc+'Dosage_Instruction__c'];
                            var str7 = str5.replace("\'n\'", str6);
                            row.ElixirSuite__Frequency__c = str7;
                            
                        }
                        }
                        
                        
                        row.ElixirSuite__Frequency_Unit__c = row[nspc + 'Frequency__r'][0][nspc + 'Frequency_Unit__c']
                        row.ElixirSuite__Frequency_Value__c = row[nspc + 'Frequency__r'][0][nspc + 'Frequency_Value__c']
                        
                        
                    }
                    
                }
                component.set('v.dataForPRN', rows);
                
                var count=0;
                for (var i = 0; i < rowsForTaper.length; i++) {
                    console.log('inside taper for'+rowsForTaper.length);
                    
                    
                    var rowForTaper = rowsForTaper[i];
                    if(!$A.util.isUndefinedOrNull(rowsForTaper[i][nspc + 'Number_of_Times_Days_Weeks__c'])){
                    rowForTaper['ElixirSuite__dispenceSupplyCustom__c'] = rowsForTaper[i][nspc + 'Number_of_Times_Days_Weeks__c'].toString(8);
                    }
                    if (rowForTaper[nspc + 'Frequency__r'] != undefined && rowForTaper[nspc + 'Frequency__r'].length != 0 &&
                        rowForTaper[nspc + 'Frequency__r'][0][nspc + 'Frequency_Unit__c'] != undefined &&
                        rowForTaper[nspc + 'Frequency__r'][0][nspc + 'Frequency_Value__c'] != undefined
                       ) {
                        count++;
                        console.log('inside taper if');
                        
                        
                        
                       // var startDate  = rowForTaper['Frequency__r'][0]['Start_Time_c'];
                        var fstr = rowForTaper[nspc + 'Frequency__r'][0][nspc + 'Frequency_Unit__c'] + 'X' +
                            rowForTaper[nspc + 'Frequency__r'][0][nspc + 'Frequency_Value__c']
                        
                        console.log('fstr ' + fstr);
                        rowForTaper.Strength = fstr;
                        console.log('def ' + rowForTaper.Strength);
                        
                        
                    }
                    else {
                        var unitValueSetDefault = '10X20';
                        rowForTaper.Strength = unitValueSetDefault;
                    }
                    
                }
                console.log('count vlaue'+count);
                
                component.set('v.dataForTaper', rowsForTaper);
                console.log('taper row data' + JSON.stringify(rowForTaper)); //daysActionOrder__c
                
                
                
                    for (var i = 0; i < rowsForActionOrder.length; i++) {
                          var rowForAC = rowsForActionOrder[i];
                          if(!$A.util.isUndefinedOrNull(rowsForActionOrder[i][nspc + 'Number_of_Times_Days_Weeks__c'])){
                    	rowForAC[nspc + 'daysActionOrder__c'] = rowsForActionOrder[i][nspc + 'Number_of_Times_Days_Weeks__c'].toString(8);
                    	}
                    }
                component.set('v.dataForActionOrder', rowsForActionOrder);
                
            }
            component.set("v.showTabs",true);
        });
        $A.enqueueAction(action);
        
        console.log('showTabs--- '+component.get("v.showTabs"));
    },

 });




//--------------------------------------------------------------------------------------------------------------------------		
/*var action = component.get("c.fetchAccount");
		console.log('keyword ' + component.get("v.searchKeyword"));
		action.setParams({
			'searchKeyWord': component.get("v.searchKeyword"),
			'tabName': component.get("v.selTabId")
		});
		action.setCallback(this, function (response) {
			
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set('v.issearching', true);
				setTimeout(function () {
					component.set('v.issearching', false);
				}, 2000);

				var rows = response.getReturnValue();
				


				console.log('1234-----------' + JSON.stringify(rows));
				var d = rows['prescriptionWithPRN']
				if (rows['prescriptionWithPRN']) {
					for (var i = 0; i < rows['prescriptionWithPRN'].length; i++) {
						console.log('value of rows ' + JSON.stringify(rows['prescriptionWithPRN'][i]));

						var row = rows['prescriptionWithPRN'][i];
                         if(row['Frequency__r']!=undefined){
						console.log('row 1234 ' + JSON.stringify(row));

						if (row['Frequency__r'].length!= 0) {


							var str = row['Frequency__r'][0]['Repeat__c'];
							if (str.startsWith('\'n\' times')) {
								console.log('inside n times a day');
								var str2 = str.slice(3);
								var str3 = row['Frequency__r'][0]['Dosage_Instruction__c'];
								var data = str3.concat(str2);
								console.log('DATA ' + data);
								row.Frequency__c = data;

							} else if (str.startsWith('After every')) {
								console.log('AFTER EVERY ');
								var s = str.slice(15);
								console.log('S ' + s);
								var v = 'After every ';

								var e = row['Frequency__r'][0]['Dosage_Instruction__c'];
								var w = v.concat(e);
								console.log('W' + w);
								var n = w.concat(s);
								console.log('W val ' + w);
								var data = n;
								console.log('DATA ' + data);
								row.Frequency__c = data;
							}


							row.Frequency_Unit__c = row['Frequency__r'][0]['Frequency_Unit__c']
							row.Frequency_Value__c = row['Frequency__r'][0]['Frequency_Value__c']

						}
                         }
                          else{
                         row.Frequency_Unit__c='';
                        row.Frequency_Value__c='';
                        row.Frequency__c='';
                    }
					}
				}


				component.set('v.data', rows); // if storeResponse size is 0 ,display no record found message on screen.
				if (storeResponse.length == 0) {
					component.set("v.Message", true);
				} else {
					component.set("v.Message", false);
				}

				// set numberOfRecord attribute value with length of return value from server
				// component.set("v.TotalNumberOfRecord", storeResponse.length);

				// set searchResult list with return value from server.
				// component.set("v.columns", storeResponse); 

			}
		});


		$A.enqueueAction(action);

	}
})*/