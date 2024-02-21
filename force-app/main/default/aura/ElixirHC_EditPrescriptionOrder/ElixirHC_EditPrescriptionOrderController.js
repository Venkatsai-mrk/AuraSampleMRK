({
    
    //Querying all data from Medication and segringating it to set in PRN and TAPER tab
    //Conactinating all fields 
    doInit: function(component, event, helper) {
        console.log(' insideinit');
        //   var nspc = component.get("v.orgWideValidNamespace");
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
                                var size = row[nspc + 'Frequency__r'].length - 1;
                                var str3 = row[nspc + 'Frequency__r'][size][nspc+'Dosage_Instruction__c'];
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
                        
                        var size = row[nspc + 'Frequency__r'].length - 1;
                        row.ElixirSuite__Frequency_Unit__c = row[nspc + 'Frequency__r'][size][nspc + 'Frequency_Unit__c']
                        row.ElixirSuite__Frequency_Value__c = row[nspc + 'Frequency__r'][size][nspc + 'Frequency_Value__c']
                        
                        
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
    
    //handle opening/closing of modal
    cancel: function(component, event, helper) {
        component.set("v.isOpen", false);
        var modal = component.find("exampleModal");
        // alert('ss'+modal);
        //$A.util.addClass(modal, 'hideDiv');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    
    //Set rows for TAPER tab
    //Set rows for TAPER tab
    onPrnTabActive: function(component, event) {
        console.log('hello inside PRN');
        component.set("v.ShowFooter", true);
        component.set("v.searchKeyword", "");
        component.set("v.ShowSearchBar", true);
        var nspc = 'ElixirSuite__' ; 
        
        component.set('v.columns', [{
            label: 'Medication Name',
            fieldName: nspc + 'Drug_Name__c',
            type: 'text'
        }, {
            label: 'Frequency',
            fieldName: 'ElixirSuite__Frequency__c',
            type: 'text'
        }, {
            label: 'Dosage Quantity Unit',
            fieldName:  'ElixirSuite__Frequency_Unit__c',
            type: 'text'
        }, {
            label: 'Dosage Quantity Value',
            fieldName:  'ElixirSuite__Frequency_Value__c',
            type: 'text'
        },
                                    
                                    {
                                        label: 'Number of Times/Days/Weeks',
                                        fieldName: 'ElixirSuite__dispenceSupplyCustomForPRN__c',
                                        type: 'Text'
                                    }, {
                                        label: 'Reason',
                                        fieldName: nspc + 'Reason_new__c',
                                        type: 'text'
                                    }, {
                                        label: 'Route',
                                        fieldName: nspc + 'Route_New__c',
                                        type: 'text'
                                    },
                                    
                                    
                                    {
                                        fieldName: nspc + "After_Discharge__c",
                                        label: "After Discharge",
                                        type: "boolean",
                                        cellAttributes: {
                                            iconName: {
                                                fieldName: nspc + "After_Discharge__c"
                                            },
                                            iconPosition: "left"
                                        }
                                    }
                                    
                                   ]);
        
        
        
    },
    
    onActionOrderTabActive :function(component, event, helper) {
        
        component.set("v.ShowFooter", true);
        component.set("v.searchKeyword", "");
        component.set("v.ShowSearchBar", true);
        // var nspc = component.get("v.orgWideValidNamespace") ;
        var nspc = 'ElixirSuite__' ;
        component.set('v.columns', [{
            label: 'Medication Name',
            fieldName: nspc + 'Drug_Name__c',
            type: 'text'
        }, 
                                    
                                    {
                                        fieldName: nspc + "MAR_Display__c",
                                        label: "MAR Display",
                                        type: "boolean",
                                        cellAttributes: {
                                            iconName: {
                                                fieldName: nspc + "MAR_Display__c"
                                            },
                                            iconPosition: "left"
                                        }
                                    },
                                    
                                    {             
                                        label: 'Start Date',
                                        fieldName: nspc + 'Start_Date__c',
                                        type: 'text'
                                    }, {
                                        label: 'Days',
                                        fieldName: nspc + 'daysActionOrder__c',
                                        type: 'text'
                                    }
                                    
                                   ]);
        
        
    },
    
    //function to search the data + blocking out special characters
    
    Search: function(component, event, helper) {
        var inputCmp = component.find("searchField");
        
        
        var re = /^[a-zA-Z0-9_]*$/
        if(event.getSource().get("v.value")!=' ') {
            if(!re.test(event.getSource().get("v.value"))) {
                
                inputCmp.setCustomValidity("Special characters not allowed!");
            }
            else {
                
                
                inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
            }
            inputCmp.reportValidity(); // Tells lightning:input to show the error right away without needing interaction
        }
        
        
        
        helper.SearchHelper(component, event);
        
    },
    
    //Handling visibility of Search bar and footer
    onNewMedicationActive: function(component, event) {
        component.set("v.ShowSearchBar", false);
        component.set("v.ShowFooter", false);
        
        
    },
    
    //Set rows from PRN tab
    onTapersTabActive: function(component, event) {
        component.set("v.searchKeyword", "");
        component.set("v.ShowFooter", true);
        // var nspc = component.get("v.orgWideValidNamespace") ;
        var nspc = 'ElixirSuite__' ;
        console.log('TAPER SELECTED ' + JSON.stringify(component.get("v.selected")));
        component.set("v.ShowSearchBar", true);
        component.set('v.columns', [{
            label: 'Medication Name',
            fieldName: nspc + 'Drug_Name__c',
            type: 'text'
        },
                                    
                                    
                                    {
                                        label: 'Reason Label',
                                        fieldName: nspc + 'Reason_new__c',
                                        type: 'text'
                                    }, {
                                        label: 'Strength',
                                        fieldName: 'Strength',
                                        type: 'text'
                                    }, {
                                        label: 'Route',
                                        fieldName: nspc + 'Route_New__c',
                                        type: 'text'
                                    }, {
                                        label: 'Start Date',
                                        fieldName: nspc + 'Start_Date__c',
                                        type: 'date'},
                                    
                                    {
                                        label: 'Number of days',
                                        fieldName: 'ElixirSuite__dispenceSupplyCustom__c',
                                        type: 'text'
                                    },
                                    
                                    
                                    {
                                        fieldName: nspc + "After_Discharge__c",
                                        label: "After Discharge",
                                        type: "boolean",
                                        cellAttributes: {
                                            iconName: {
                                                fieldName: nspc + "After_Discharge__c"
                                            },
                                            iconPosition: "left"
                                        }
                                    }
                                    
                                   ]);
        
        console.log('in here' + component.get("v.columns"));
        
    },
    
    //Function to accumulate all the selected records from Medication Data.
    updateSelectedText: function(component, event,helper) {
        console.log(' already selected data  ' + JSON.stringify(component.get("v.selected")));
        var selectedRowsEvt = event.getParam('selectedRows');
        helper.handleUncheckInList(component, event,helper,selectedRowsEvt);
        //  console.log('345-> '+JSON.stringify(selectedRows));
        /* if(selectedRowsEvt.length==0) {
            component.set("v.selected", "");            
        }*/
        /*if($A.util.isEmpty(selectedRowsEvt)){
       		helper.emptyArrayHandle(component,event,helper);
        }
        var selectedRows =  helper.filterAllDuplicate(component,event.getParam('selectedRows'));
        component.set('v.selectedRowsCount', selectedRows.length);
        console.log('selected values ' + JSON.stringify(selectedRows));
        var setRows = component.get("v.selected");
        for (var i = 0; i < selectedRows.length; i++) {
            
            setRows.push(selectedRows[i]);
            
        }
        component.set("v.selected", helper.filterAllDuplicate(component,setRows));
        console.log(' after set data  ' + JSON.stringify(component.get("v.selected")));
       */
        
    },
    
    //Function to filter all the data selected from PRN and TAPER and remove duplicates (if present) on basis of ID
    handleReviewOrder: function(component, event, helper) {
        var PRNData = component.get("v.bufferPRNLst");
        var actionOrder  = component.get("v.bufferActionOrderLst");
        var taperData = component.get("v.bufferTaperLst") ;
        var finalDataToSend  = [];
        finalDataToSend = PRNData.concat(actionOrder,taperData);
        if($A.util.isEmpty(finalDataToSend)){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : "warning",
                "title": "NOTHING SELECTED!",
                "message": "Please select something to move forward!"
            });
            toastEvent.fire(); 
        }
        else {
            //Get the event using registerEvent name. 
            component.set("v.selected", finalDataToSend);
            var cmpEvent = component.getEvent("changehandlerEvent"); 
            //Set event attribute value
            cmpEvent.setParams({recordList : finalDataToSend}); 
            cmpEvent.fire();
            component.set("v.isOpen", false);
        }
        
    }
    
    
});