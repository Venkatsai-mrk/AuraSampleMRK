({
    helperInit : function(component , event ,helper){
        
        if($A.util.isUndefinedOrNull(component.get("v.allergyData"))) {
            var allergyData  = {
                'hasValue'  : false,
                'data' : []
            };          
            component.set("v.allergyData",allergyData);           
        }
       
        var allergy  = component.get("v.allergyData");
        var data = component.get("v.showDetail");  
        var arrayForHeight = ['3 "1"','3 "2"','3 "3"','3 "4"','3 "5"','3 "6"','3 "7"','3 "8"','3 "9"','3 "10"','3 "11"','4 "0"',
                              '4 "1"','4 "2"','4 "3"','4"4"','4 "5"','4 "6"','4 "7"','4 "8"','4 "9"','4 "10"','4 "11"','5 "0"',
                              '5 "1"','5 "2"','5 "3"','5 "4"','4 "5"','4 "6"','4 "7"','4 "8"','4 "9"','4 "10"','4 "11"','5 "0"',
                              '4 "1"','4 "2"','4 "3"','4"4"','4 "5"','4 "6"','4 "7"','4 "8"','4 "9"','4 "10"','4 "11"','5 "0"',
                              '4 "1"','4 "2"','4 "3"','4"4"','4 "5"','4 "6"','4 "7"','4 "8"','4 "9"','4 "10"','4 "11"','5 "0"'];
        component.set('v.heightPicklist',arrayForHeight);
       // alert('arrayNew'+JSON.stringify(data));
        var dataMap = component.get("v.selectedValues");//For checkboxes , toggles
        var inputDataMap = component.get("v.inputSelectedValues");//For input
        var inputDateMap = {};// For Date
        var inputTimeMap = {};// For Time
        var inputDateTimeMap = {};//For Date Time
        var matrixCssList = [];
        var styleCssList = [];
        var styleCssMap = {};
        var InputTextareaMap = component.get("v.inputTextAreaSelectedValues");//For input Text Area
        component.set("v.inputFirstCss",'slds-col slds-size_4-of-12');
        component.set("v.inputSecondCss",'slds-col slds-size_4-of-12');
        component.set("v.inputFirstCheckboxClass",'slds-col slds-size_6-of-12');
        component.set("v.inputSecondCheckboxClass",'slds-col slds-size_2-of-12');
        var array = [];
        
        var jsonForCls = { '1' : 'slds-col slds-size_12-of-12',
                          '2'	:	'slds-col slds-size_6-of-12',
                          '3'	: 'slds-col slds-size_4-of-12',
                          '4' : 	'slds-col slds-size_3-of-12',
                          '6'	: 'slds-col slds-size_2-of-12'      
                         };
        var today = new Date();
        component.set('v.today', today.getDate() + "-" + (today.getMonth() + 1) + "-" + today.getFullYear() );
        component.set('v.todayString', today.toISOString());
        
        // Making map fo saving
        var counter = 0;
        var maxCols;
        var isMatrixCompiled = false;
        var ProblemListCompiled = false;
        var histroyListCompiled = false;
        var yesNoCompiled = false;
        var feedbackCompiled = false;
        var isRadioCssCompiled = false;
        var nameSpace = 'ElixirSuite__' ;
        console.log('width'+JSON.stringify(data));
        for(var rec in data){
            
            
            if(data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Text Area (Rich)'){ 
                
                helper.cssHandle(styleCssMap , data[rec]);
                console.log('meg' , data);
                helper.utilityPattern(component , data[rec][nameSpace + 'Field_Name__c'] ,data , rec);
                
            }
            if(data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Toggle' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Multi CheckBox' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Multi checkbox Left' 
               ||   data[rec][nameSpace + 'Data_Entry_Type__c'] == 'checkbox Left' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'checkbox'){
                console.log('Id '+data[rec].Id);
                dataMap[data[rec].Id] = false;               
                data[rec]['value'] = false; 
                
                helper.cssHandle(styleCssMap , data[rec]);
                
            }
            
            else if(data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Input :Text Area' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'input:TextArea(Only)'){              
                if(!( $A.util.isEmpty(data[rec][nameSpace + 'Default_Text_Area__c']) || $A.util.isUndefinedOrNull(data[rec][nameSpace + 'Default_Text_Area__c']))){
                    InputTextareaMap[data[rec].Id] = data[rec][nameSpace + 'Default_Text_Area__c'];
                }
                helper.cssHandle(styleCssMap , data[rec]);
                
            }
                else if(data[rec][nameSpace + 'Data_Entry_Type__c'] == 'input:Date'){
                    inputDateMap[data[rec].Id] = today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate();
                    console.log('Date '+JSON.stringify(inputDateMap));
                    helper.cssHandle(styleCssMap , data[rec]);
                }
                    else if(data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Input:Date/Time'){
                        inputDateTimeMap[data[rec].Id] = today.toISOString();
                        //console.log('Date '+JSON.stringify(inputDateMap));
                        helper.cssHandle(styleCssMap , data[rec]);
                    }
                        else if((data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:Yes/No' ||  data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:Note' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Status_List'
                                 || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'PulseRate_List' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Sweating_List' || data[rec][nameSpace + 'Data_Entry_Type__c']== 'RunnyNoseOrTearing_List'
                                 || data[rec][nameSpace + 'Data_Entry_Type__c']== 'Restlessness_List' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'PupilSize_List'|| data[rec][nameSpace + 'Data_Entry_Type__c'] == 'GIUpset_List'
                                 || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'BoneOrJoint_List' || data[rec][nameSpace + 'Data_Entry_Type__c'] =='Yawning_List' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:Nursing Assessment' ||  data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:Patient awareness'
                                 || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'TremorOutstretched_List' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'AnxietyOrIrritability_List' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:History' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:Facial'
                                 || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:PhysicalTherapist' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'GoosefleshSkin_List' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:FeedbackRating' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:ProblemRating' ) && data[rec][nameSpace + 'Picklist_Values__c']!=''
                                ||data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:RelationshipStatus' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:DischargeValues' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'Picklist:Mobility')  {
                            helper.cssHandle(styleCssMap , data[rec]);
                            helper.StaticPicklistValues(component,data[rec][nameSpace + 'Picklist_Values__c'] , data[rec][nameSpace + 'Data_Entry_Type__c']);
                            
                        }
                            else if(data[rec][nameSpace + 'Data_Entry_Type__c'] == 'input:Text(Only)' || data[rec][nameSpace + 'Data_Entry_Type__c'] == 'blank'){
                                helper.cssHandle(styleCssMap , data[rec]);
                            }
            
            
            if(data[rec][nameSpace + 'style__c'] == 'Credit Card'){
                console.log('credit '+data[rec][nameSpace + 'style__c']);
                component.set("v.inputFirstCss", 'slds-size_3-of-12');
                component.set("v.inputSecondCss", 'slds-size_4-of-12');
                component.set("v.inputFirstCheckboxClass",'slds-col slds-size_3-of-12');
                component.set("v.inputSecondCheckboxClass",'slds-col slds-size_2-of-12');
                
            }
            else if(data[rec][nameSpace + 'style__c'] == 'Credit Card First'){
                component.set("v.inputFirstCss", 'slds-size_1-of-12');
                component.set("v.inputSecondCss", 'slds-size_9-of-12');
                counter = 1;
            }
            
                else if(data[rec][nameSpace + 'style__c'] == 'Pharmacy Credit Card'){
                    component.set("v.inputFirstCheckboxClass", 'slds-size_10-of-12');
                    component.set("v.inputSecondCheckboxClass", 'slds-size_2-of-12');              
                }
            
            
                    else if(data[rec][nameSpace + 'style__c'] == 'MATRIX' && isMatrixCompiled == false){
                        if(data[rec][nameSpace  + 'Maximum_Column_in_each_Section__c']  > 5){
                            for(var i = 0 ; i < data[rec][nameSpace  + 'Maximum_Column_in_each_Section__c'] ; i++){
                                if(i == 0){
                                    matrixCssList.push('slds-size_4-of-12 datetime_input_css textarea_form_element');
                                    styleCssList.push("font-size : 10px ; padding-top: 10px; padding-left : 10px ; width: 23% ");
                                }else{
                                    matrixCssList.push('slds-size_1-of-12 textarea_form_element');
                                    styleCssList.push("font-size : 10px ; padding-top: 10px; padding-left : 10px ; width: 15%");
                                }
                                
                            }  
                        }
                        else{
                            for(var i = 0 ; i < data[rec][nameSpace  + 'Maximum_Column_in_each_Section__c'] ; i++){
                                if(i == 0){
                                    matrixCssList.push('slds-size_3-of-12 datetime_input_css textarea_form_element');
                                    styleCssList.push("padding-top: 10px; padding-left : 10px ");
                                }else{
                                    matrixCssList.push('slds-size_3-of-12 textarea_form_element');
                                    styleCssList.push(" padding-top: 10px; padding-left : 10px");
                                }
                                
                            }  
                        }
                        
                        isMatrixCompiled = true;
                    }
            
            
        }
        if(! $A.util.isEmpty(styleCssMap)){
            console.log('not empty');
            var keys = Object.keys(styleCssMap);
            console.log('not empty'+JSON.stringify(styleCssList));
            for(var key in keys){
                styleCssList.push(styleCssMap[keys[key]]);
            }
        }
        console.log('styling '+JSON.stringify(styleCssList));
        component.set('v.selectedValues',dataMap);
        component.set('v.inputDateSelectedValues',inputDateMap);
        component.set('v.inputDateTimeSelectedValues',inputDateTimeMap);
        component.set('v.inputTextAreaSelectedValues',InputTextareaMap);
        // Ends
        console.log('data size '+data.length);
        var cls;
        var multiCheckBoxCls;
        console.log('showDetail '+JSON.stringify(data));
        if(counter == 1){
            maxCols = 2; 
        }else{
            maxCols = data[0][nameSpace + 'Maximum_Column_in_each_Section__c'];
        }
        
        
        var listOfColumns = [];
        var listOfColumnWiseFields = [];
        var map = new Map();
        console.log('dfghfggggggggg '+JSON.stringify(map.size));
        var key ;
        for(var keys=1; keys<=maxCols; keys++){
            //For css end
            if(isMatrixCompiled == false){
                if(maxCols ==1 || maxCols == 3 ||maxCols == 2 || maxCols == 4 || maxCols== 6){
                    {
                        cls = jsonForCls[maxCols];
                    }       
                }
                else if(maxCols > 7){         
                    cls = 'slds-col slds-size_1-of-12';
                    
                }
                matrixCssList.push(cls);               
            }
            
            //For css end
            var arrayInside = [];
            var nameSpace = 'ElixirSuite__' ;
            for(var rec in data){            
                
                if(data[rec][nameSpace + 'Columns__c'] == keys){
                    
                    if(! map.has(keys)){                
                        arrayInside.push(data[rec]);                
                        map.set(keys,arrayInside);                
                    }else{               
                        map.get(keys).push(data[rec]);
                    }          
                }
                
            }
        }
        
        console.log('gfds'+map.keys());
        var index = 0;
        for(let key of map.keys()){		
            helper.doSort(map.get(key));
            array.push({'css': matrixCssList[index] ,'style': styleCssList[index], 'data' : map.get(key)});
            index++;
        }
        component.set('v.runScroll',true);
        
        component.set('v.matrixCssList',matrixCssList);
        console.log('JSon final New'+JSON.stringify(array).length);
        component.set("v.columnWiseData",JSON.parse(JSON.stringify(array)));
         var todayForDateTime = new Date();
        var colWiseData = component.get("v.columnWiseData");
        for(var rec in  colWiseData){
            var upperParent = colWiseData[rec].data;
            for(var inside in upperParent){
                if(upperParent[inside].ElixirSuite__Data_Entry_Type__c == 'Input:Date/Time'){
                      var dataMap = component.get("v.inputDateTimeselectedValues");
                        dataMap[upperParent[inside].Id] = todayForDateTime.toISOString();
                        component.set("v.inputDateTimeselectedValues",dataMap);
                }
            }
        }
        
    },
    doSort : function(array) {
        array.sort(function(a , b){
            var nameSpace = 'ElixirSuite__'
            const bandA = a[nameSpace + 'Sequence_Order__c'];
            const bandB = b[nameSpace + 'Sequence_Order__c'];
            
            let comparison = 0;
            if (bandA > bandB) {
                comparison = 1;
            } else if (bandA < bandB) {
                comparison = -1;
            }
            return comparison;
        });
    },
    utilityPattern	:	function(component ,data, columnData , rec){
        var accRec = component.get("v.accName");
        var accountName = accRec.accName;
        var locations = accRec.parentAccount;
        var dob = accRec.dob;
        console.log('acc '+accountName);
        console.log('loca '+locations);
        console.log('dob '+dob);
        
        if(! $A.util.isUndefinedOrNull(data)){
            data =  data.split("$$NAME$$").join(accountName);
            data =  data.split("$$LOCATION$$").join(locations);
            data =  data.split("$$DOB$$").join(dob);
            columnData[rec].ElixirSuite__Field_Name__c = data; 
        }
        
    },
    StaticPicklistValues	: function(component , picklistValues , dataEntryType){
        var values;
        var problemListFinal = [];
        
        console.log('FIrst Pick '+JSON.stringify(picklistValues));
        if(! $A.util.isUndefinedOrNull(picklistValues)){
            var array = picklistValues.split(',');
            for(var rec in array){
                values= array[rec].split('=>');
                console.log('Secnd Pick '+JSON.stringify(values));
                problemListFinal.push({'Name':values[0] , 'Value': values[1]});
            }
            
            if(dataEntryType == 'Picklist:ProblemRating'){
                component.set("v.problemList",problemListFinal); 
            }
            else if(dataEntryType == 'Picklist:History'){
                component.set("v.historyList",problemListFinal);
            }
                else if(dataEntryType == 'Picklist:Yes/No'){
                    component.set("v.YesNoList",problemListFinal);
                }
                    else if(dataEntryType == 'Picklist:FeedbackRating'){
                        component.set("v.FeedbackList",problemListFinal);
                    }
                        else if(dataEntryType == 'Picklist:Note'){
                            component.set("v.NoteList",problemListFinal);
                        }
                            else if(dataEntryType == 'Status_List'){
                                component.set("v.StatusList",problemListFinal);
                            }
                                else if(dataEntryType == 'PulseRate_List'){
                                    component.set("v.PulseRate_List",problemListFinal);
                                }
                                    else if(dataEntryType == 'Sweating_List'){
                                        component.set("v.Sweating_List",problemListFinal);
                                    }
                                        else if(dataEntryType == 'Restlessness_List'){
                                            component.set("v.Restlessness_List",problemListFinal);
                                        }
                                            else if(dataEntryType == 'RunnyNoseOrTearing_List'){
                                                component.set("v.RunnyNoseOrTearing_List",problemListFinal);
                                            }
                                                else if(dataEntryType == 'GIUpset_List'){
                                                    component.set("v.GIUpset_List",problemListFinal);
                                                }
                                                    else if(dataEntryType == 'Yawning_List'){
                                                        component.set("v.Yawning_List",problemListFinal);
                                                    }
                                                        else if(dataEntryType == 'TremorOutstretched_List'){
                                                            component.set("v.TremorOutstretched_List",problemListFinal);
                                                        }
                                                            else if(dataEntryType == 'AnxietyOrIrritability_List'){
                                                                component.set("v.AnxietyOrIrritability_List",problemListFinal);
                                                            }
                                                                else if(dataEntryType == 'GoosefleshSkin_List'){
                                                                    component.set("v.GoosefleshSkin_List",problemListFinal);
                                                                }
            
                                                                    else if(dataEntryType == 'PupilSize_List'){
                                                                        component.set("v.PupilSize_List",problemListFinal);
                                                                    }
                                                                        else if(dataEntryType == 'BoneOrJoint_List'){
                                                                            component.set("v.BoneOrJoint_List",problemListFinal);
                                                                        }
                                                                            else if(dataEntryType == 'Picklist:Nursing Assessment'){
                                                                                component.set("v.Nursing_Assessment_List",problemListFinal);
                                                                            }
                                                                                else if(dataEntryType == 'Picklist:Facial'){
                                                                                    component.set("v.Facial_List",problemListFinal);
                                                                                }
                                                                                    else if(dataEntryType == 'Picklist:Patient awareness'){
                                                                                        component.set("v.Patient_awareness_List",problemListFinal);
                                                                                    } 
                                                                                        else if(dataEntryType == 'Picklist:RelationshipStatus'){
                                                                                            component.set("v.RelationshipStatus_List",problemListFinal);
                                                                                        } 
                                                                                            else if(dataEntryType == 'Picklist:DischargeValues'){
                                                                                                console.log('type 4567 '+dataEntryType);
                                                                                                component.set("v.DischargeValues",problemListFinal);
                                                                                            } 
                                                                                               
                                                                                                    else if(dataEntryType == 'Picklist:Mobility'){
                                                                                                        
                                                                                                        component.set("v.MobilityList",problemListFinal);
                                                                                                    } 
            
            
        }
        
        
    },
    cssHandle : function( styleCssMap , data){
        var nameSpace = 'ElixirSuite__' ;
        console.log('1st');
        if(! ( $A.util.isEmpty(data[nameSpace + 'width__c']) || $A.util.isUndefinedOrNull(data[nameSpace + 'width__c']))){
            console.log('2nd');
            styleCssMap[(data[nameSpace + 'Columns__c']).toString()] =  'width : '+data[nameSpace + 'width__c'].toString() +'%';                
        }else{
            console.log('3rd');
            styleCssMap[(data[nameSpace + 'Columns__c']).toString()] =  'default';                
        }
        
        if(! ( $A.util.isEmpty(data[nameSpace + 'css__c']) || $A.util.isUndefinedOrNull(data[nameSpace + 'css__c']))){   
            console.log('4th');
            if(! $A.util.isUndefinedOrNull(styleCssMap[data.Columns__c])){
                console.log('5th');
                styleCssMap[(data[nameSpace + 'Columns__c']).toString()] = styleCssMap[(data[nameSpace + 'Columns__c']).toString()] +';'+data[nameSpace + 'css__c'];      
                
            }   else{
                console.log('6th');
                styleCssMap[(data[nameSpace + 'Columns__c']).toString()] = data[nameSpace + 'css__c'] ;
                
            }                 
            
        }
    },
    /*
      getVitalRecords : function(component, helper) {
        var action = component.get("c.getLimitedVitalRecords");
         
          
        action.setStorable();
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Response Time: '+((new Date().getTime())-requestInitiatedTime));
                 console.log('RESPONSE VITAL RECORDS : '+JSON.stringify( response.getReturnValue()));
               
                component.set("v.totalPages", Math.ceil(response.getReturnValue().length/component.get("v.pageSize")));
                component.set("v.allData", response.getReturnValue());
                component.set("v.currentPageNumber",1);
                helper.buildData(component, helper);
            }
            else{
             
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }        }
            }
        });
        var requestInitiatedTime = new Date().getTime();
        $A.enqueueAction(action);
    },
    */
    
    /*
     * this function will build table data
     * based on current page selection
     * */
    buildData : function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allData");
        var x = (pageNumber-1)*pageSize;
        
        //creating data-table data
        for(; x<=(pageNumber)*pageSize; x++){
            if(allData[x]){
                data.push(allData[x]);
            }
        }
        component.set("v.data", data);
        
        helper.generatePageList(component, pageNumber);
    },
    
    /*
     * this function generate page list
     * */
    generatePageList : function(component, pageNumber){
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        if(totalPages > 1){
            if(totalPages <= 10){
                var counter = 2;
                for(; counter < (totalPages); counter++){
                    pageList.push(counter);
                } 
            } else{
                if(pageNumber < 5){
                    pageList.push(2, 3, 4, 5, 6);
                } else{
                    if(pageNumber>(totalPages-5)){
                        pageList.push(totalPages-5, totalPages-4, totalPages-3, totalPages-2, totalPages-1);
                    } else{
                        pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
    },
    
    
})