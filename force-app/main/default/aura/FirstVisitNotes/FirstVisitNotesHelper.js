({
    addNotesHelper : function(component, event, helper){
        var myVal = component.get("v.myVal");
        var medications = component.get("v.medications");
        var problemsToSave = component.get("v.problemsToSave") || [];
        for(let medicine in medications){
            console.log('medicine ',medicine);
            if(myVal.includes('Problems:')){
                let splitMyval = [];
                splitMyval = myVal.split('Problems:</b>');
                splitMyval[0]+=  medications[medicine].FieldName+ ' - ' + medications[medicine].Description;
               // splitMyval[0]+= 'Problems:</b>';
              //  splitMyval[0]+= '<br/>' + medications[medicine].FieldName+ ' - ' + medications[medicine].Description;
                myVal = splitMyval.join();
            }else{
                
                myVal+=' <b style="color:#493266;font-size:15px;">Problems:</b><br/>'+medications[medicine].FieldName + ' - ' + medications[medicine].Description ;        	
            }
            problemsToSave.push(JSON.parse(JSON.stringify(medications[medicine])));
        }
        component.set("v.myVal",myVal);
        var column = component.get("v.column");
        column['problemNote'] = component.get("v.myVal");
        component.set("v.problemsToSave",problemsToSave);
        column['problemNoteList'] = component.get("v.problemsToSave");
          component.set("v.medications",[]);
         component.set("v.Vital",false);
                              component.set("v.isDietary",false);
                              component.set("v.isPrescriptions",false);
                              component.set("v.isChiefComplaints",false);
                              component.set("v.PrescriptionsList",[]);
                              component.set("v.EhrConditions",[]);
                              component.set("v.isWeightHistory",false);
                              component.set("v.weightHistory",[]);
                              component.set("v.dietaryHistory",[]);
                              component.set("v.measurements",[]);
                              component.set("v.isMeasurement",false);
                              component.set("v.newVitalSign",[]);
                              component.set("v.additionalNotes",'');
                              component.set("v.description",'');
                              component.set("v.frequency",'');
                              component.set("v.testName",'');
                              component.set("v.labName",'');
                              component.set("v.statByPhone",'');
                              component.set("v.statByFax",'');
    },
    addNotesHelperDiagnosis : function(component, event, helper){
        var myVal = component.get("v.myVal");
        var diagnosisf = component.get("v.diagnosis");
        var diagnosisToSave = component.get("v.diagnosisToSave") || [];
        for(let diagnosis in diagnosisf){
            if(myVal.includes('Diagnosis:')){
                let splitMyval = [];
                splitMyval = myVal.split('Diagnosis:</b>');
              //  splitMyval[0]+= 'Diagnosis:</b>';
                splitMyval[0]+= diagnosisf[diagnosis].FieldName+ ' - ' + diagnosisf[diagnosis].Description;
                myVal = splitMyval.join();
            }else{
                
                myVal+=' <b style="color:#493266;font-size:15px;">Diagnosis:</b><br/>'+diagnosisf[diagnosis].FieldName + ' - ' + diagnosisf[diagnosis].Description ;        	
            }
            diagnosisToSave.push(JSON.parse(JSON.stringify(diagnosisf[diagnosis])));
        }
        component.set("v.myVal",myVal);
        var column = component.get("v.column");
        column['diagnosisNote'] = component.get("v.myVal");
        component.set("v.diagnosisToSave",diagnosisToSave);
        column['diagnosisList'] = component.get("v.diagnosisToSave");
        console.log('ehhe' + column['diagnosisList']);
          component.set("v.diagnosis",[]);
         component.set("v.Vital",false);
                              component.set("v.isDietary",false);
                              component.set("v.isPrescriptions",false);
                              component.set("v.isChiefComplaints",false);
                              component.set("v.PrescriptionsList",[]);
                              component.set("v.EhrConditions",[]);
                              component.set("v.isWeightHistory",false);
                              component.set("v.weightHistory",[]);
                              component.set("v.dietaryHistory",[]);
                              component.set("v.measurements",[]);
                              component.set("v.isMeasurement",false);
                              component.set("v.newVitalSign",[]);
                              component.set("v.additionalNotes",'');
                              component.set("v.description",'');
                              component.set("v.frequency",'');
                              component.set("v.testName",'');
                              component.set("v.labName",'');
                              component.set("v.statByPhone",'');
                              component.set("v.statByFax",'');
    },
    
     addNotesHelperProcedure : function(component, event, helper){
        var myVal = component.get("v.myVal");
        var proceduref = component.get("v.procedure");
        var procedureToSave = component.get("v.procedureToSave") || [];
        for(let procedure in proceduref){
            if(myVal.includes('Procedures:')){
                let splitMyval = [];
                splitMyval = myVal.split('Procedures:</b>');
              //  splitMyval[0]+= 'Procedures:</b>';
                splitMyval[0]+=  proceduref[procedure].FieldName+ ' - ' + proceduref[procedure].Description;
                myVal = splitMyval.join();
            }else{
                
                myVal+=' <b style="color:#493266;font-size:15px;">Procedures:</b><br/>'+proceduref[procedure].FieldName + ' - ' + proceduref[procedure].Description ;        	
            }
            procedureToSave.push(JSON.parse(JSON.stringify(proceduref[procedure])));
        }
        component.set("v.myVal",myVal);
        var column = component.get("v.column");
        column['procedureNote'] = component.get("v.myVal");
        component.set("v.procedureToSave",procedureToSave);
        column['procedureList'] = component.get("v.procedureToSave");
        console.log('ehhe' + column['procedureList']);
          component.set("v.procedure",[]);
         component.set("v.Vital",false);
                              component.set("v.isDietary",false);
                              component.set("v.isPrescriptions",false);
                              component.set("v.isChiefComplaints",false);
                              component.set("v.PrescriptionsList",[]);
                              component.set("v.EhrConditions",[]);
                              component.set("v.isWeightHistory",false);
                              component.set("v.weightHistory",[]);
                              component.set("v.dietaryHistory",[]);
                              component.set("v.measurements",[]);
                              component.set("v.isMeasurement",false);
                              component.set("v.newVitalSign",[]);
                              component.set("v.additionalNotes",'');
                              component.set("v.description",'');
                              component.set("v.frequency",'');
                              component.set("v.testName",'');
                              component.set("v.labName",'');
                              component.set("v.statByPhone",'');
                              component.set("v.statByFax",'');
    },
    checkUndefined :function(value){
        if(value!=undefined){
            return value;
        }
        return '';
    },
    initHelper : function(component, event, helper){
       var action = component.get("c.getAcctSpecificProblem");
        component.set("v.ROSDisplayData",{});
        action.setParams({
            acctId : component.get("v.accountId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                helper.pushDietType(component);
                component.set("v.measurements","{'weight': 00,'height' : 00,'gWeight': 00,'BMI': 00}");
                var resp = response.getReturnValue();  
                component.set("v.ROSData",resp.formFields);
                component.set("v.currentMedi" , resp.currentMed);
                var nameSpace= component.set("v.nameSpace",resp.nameSpace);
                if(!$A.util.isUndefinedOrNull(resp.medHistorySocial)){
                    component.set("v.newSocial" , JSON.stringify(resp.medHistorySocial[0].ElixirSuite__Description__c));
                    
                }
                if(!$A.util.isUndefinedOrNull(resp.medHistoryFamily)){
                    
                    component.set("v.newFamily" , JSON.stringify(resp.medHistoryFamily[0].ElixirSuite__Description__c));
                    
                }
                if(!$A.util.isUndefinedOrNull(resp.medHistoryPast)){
                    
                    component.set("v.newhealthDiagnosis" , JSON.stringify(resp.medHistoryPast[0].ElixirSuite__Description__c));
                }
                var data1= resp.currentMed ;
                var arr = [];
                for(let rec in data1){
                    if(!$A.util.isUndefinedOrNull(data1[rec].ElixirSuite__Drug_Name__c)){
                        arr.push(data1[rec]); 
                    }
                }
                data1 = arr;
                var selections1 = '';
                var i = 0 ;
                data1.forEach(option => {
                    i++ ;
                    
                    selections1 += i+'.'+' ' + option.ElixirSuite__Drug_Name__c+'\n';
                });
                    component.set("v.newc" ,selections1);
                    //alert('data-- '+JSON.stringify(resp.currentMed));
                    
                }else{    
                    var errors = response.getError();
                    if (errors) {
                    if (errors[0]) {
                    console.log("Error message: " +
                    errors[0].message);
                }        }
                }
                    
                });
                $A.enqueueAction(action);  
    },
    addLabOrdersHelper: function(component, event, helper){
        var myVal = component.get("v.myVal");
        var labOrders = component.get("v.labOrders");
        var labOrdersToSave = component.get("v.labOrdersToSave") || [] ;
        for(let labOrder in labOrders){
            if(myVal.includes('Lab Orders:')){
                let splitMyval = [];
                splitMyval = myVal.split('Lab Orders:</b>');
                splitMyval[0]+= 'Lab Orders:</b>';
                splitMyval[0]+= '<br/>' + labOrders[labOrder].FieldName+ ' - ' + labOrders[labOrder].Description;
                myVal = splitMyval.join();
            }else{
                myVal+=' <b style="color:#493266;font-size:15px;">Lab Orders:</b><br/>'+labOrders[labOrder].FieldName + ' - ' + labOrders[labOrder].Description;        	
            }
            labOrdersToSave.push(JSON.parse(JSON.stringify(labOrders[labOrder])));
        }
        component.set("v.myVal",myVal);
        component.set("v.labOrdersToSave",labOrdersToSave);
        component.set("v.labOrders",[]);
    },
    addVitalsHelper :function(component, event, helper){
        var myVal = component.get("v.myVal");
        var vitals = component.get("v.newVitalSign");
        var heightVal = component.get("v.newVitalSign.height");
        var weightVal = component.get("v.newVitalSign.weight");
        var sysVal = component.get("v.newVitalSign.bpSys");
        var diasVal = component.get("v.newVitalSign.bpDias");
        var tempVal = component.get("v.newVitalSign.temp");
        var pulseVal = component.get("v.newVitalSign.pulse");
        var oxySatVal = component.get("v.newVitalSign.oxySat");
        if(component.get("v.isVital") == true){
            if(myVal.includes('Vitals:')){
                let splitMyval = [];
                splitMyval = myVal.split('Vitals:</b>');
                splitMyval[0]+= 'Vitals:</b>';
                splitMyval[0]+= '<br/>' + 'Height:' +  heightVal + ' '+ 'cm' + '  ,'+ 'Weight:' +  weightVal + ' '+ 'kg'+ '  ,'+ 'BP Systolic:' +  sysVal + ' '+ 'mm[Hg]' + '  ,'+ 'BP Diastolic:' +  diasVal + ' '+ 'mm[Hg]' + '  ,'+  '<br/>'+ 'Temperature:' +  tempVal + ' '+ 'celsius(degree)' + '  ,'+ 'Pulse:' +  pulseVal + ' '+ '/min' + '  ,'+ 'Oxygen Saturation:' +  oxySatVal + ' '+ '%' + '<br/>'      ;      
                myVal = splitMyval.join();
            }else{
                myVal+=' <b style="color:#493266;font-size:15px;">Vitals:</b><br/>'+ 'Height:' +  heightVal + ' '+ 'cm' + '  ,'+ 'Weight:' +  weightVal + ' '+ 'kg'+ '  ,'+ 'BP Systolic:' +  sysVal + ' '+ 'mm[Hg]' + '  ,'+ 'BP Diastolic:' +  diasVal + ' '+ 'mm[Hg]' + '  ,'+  '<br/>'+ 'Temperature:' +  tempVal + ' '+ 'celsius(degree)' + '  ,'+ 'Pulse:' +  pulseVal + ' '+ '/min' + '  ,'+ 'Oxygen Saturation:' +  oxySatVal + ' '+ '%' + '<br/>'      ;      
            }
        }
        component.set("v.myVal",myVal);  
        component.set("v.isVital",false);
        component.set("v.newVitalSign",'');
    },
    addLabOrders :function(component, event, helper){
        var myVal = component.get("v.myVal");
        var additionalNotes = '';
        var description = '';
        var frequency = '';
        var testName = '';
        var labName = '';
        var statByPhone = '';
        var statByFax = '';
        
        additionalNotes = component.get("v.additionalNotes");
        description = component.get("v.description");
        frequency = component.get("v.frequency");
        testName = component.get("v.testName");
        labName = component.get("v.labName");
        statByPhone = component.get("v.statByPhone");
        statByFax = component.get("v.statByFax");

        
        if(component.get("v.isLab") == true){
            if(myVal.includes('Lab Order:'))
            {
                let splitMyval = [];
                splitMyval = myVal.split('Lab Orders:</b>');
                splitMyval[0]+= '<b>Lab Order:</b>';
                splitMyval[0]+= '<br/>' + 'labName:' +  labName + '<br/>'+ 'Test Name:' +  testName + '<br/>'+ 'Frequency:' + frequency+  '<br/>'+'Description:'+description+'<br/>'+'AdditionalNotes: '+additionalNotes+'<br/>';
                myVal = splitMyval.join();
            }  
           
            else 
            {
                 myVal+= '<b style="color:#493266;font-size:15px;">Lab Order:</b><br/>'+'labName:' +  labName + '<br/>'+ 'Test Name:' +  testName + '<br/>'+ 'Frequency:' + frequency+  '<br/>'+'Description:'+description+'<br/>'+'AdditionalNotes: '+additionalNotes+'<br/>';
            }
        }
        component.set("v.myVal",myVal);  
        component.set("v.isLab",false);
        component.set("v.Vital" , false);
        component.set("v.additionalNotes",'');
        component.set("v.description",'');
        component.set("v.frequency",'');
        component.set("v.testName",'');
        component.set("v.labName",'');
        component.set("v.statByPhone",'');
        component.set("v.statByFax",'');
    },
    
    arrangeCareplandata :function(component, event, helper){
          var careplanData  = component.get("v.parentProblemTable");    
         console.log('my vlaue to save '+JSON.stringify(careplanData));
        var careplanString = '\r';
        for(var rec in careplanData){
             careplanString+='<b>'
            careplanString+=careplanData[rec].selectedProblem;
             careplanString+='</b>'
             careplanString+='<b>PLANS : </b>';
            careplanString+='\r';
            var childJSON = careplanData[rec].selectedObservation
            for(var childRec in childJSON){
                  careplanString+=childJSON[childRec].Name;
                 careplanString+='\r';
            }
        }
       // component.set("v.myVal",careplanString);
      return careplanString;
    },
    
    addCurrentMedicationsHelper:function(component, event, helper){
        var myVal = component.get("v.myVal");
        if(component.get("v.CM")==true){
            if(myVal.includes('Current Medications:')){      
                let splitMyval = [];
                splitMyval = myVal.split('Current Medications:</b>');
                splitMyval[0]+= 'Current Medications:</b>';
                splitMyval[0]+= '<br/>' + component.get("v.newc")
                myVal = splitMyval.join();
            }
            else{     
                myVal+='<b style="color:#493266;font-size:15px;">Current Medications</b><br/>'+component.get("v.newc")+'';        
            }
            
            component.set("v.myVal",myVal);
            component.set("v.newc",'');
        }
    },
    addHPIHelper :function(component, event, helper){
        var myVal = component.get("v.myVal");
        if(component.get("v.HPI") == true){
            let HPIvalue ='<b style="color:#493266;font-size:15px;">History of Present Illness</b><br/>'+component.get("v.HpiInput")+'';
          //  var res = myVal.concat(HPIvalue);// concat existing value
          myVal = myVal + HPIvalue ;
            component.set("v.myVal",myVal);  
            component.set("v.HPI",false);
            component.set("v.Vital" , false);
            component.set("v.HpiInput" , '');
        }
    },
    addRosHelper :function(component, event, helper){
        var myVal = component.get("v.myVal");
        console.log('JSON --- '+JSON.stringify(component.get("v.ROSDisplayData")));
        var orignaldata= component.get("v.ROSData");
        var Nochange ={};
        for(var i in orignaldata){
            var key =orignaldata[i].ElixirSuite__Field_Name__c;
            var value =orignaldata[i].ElixirSuite__MultiSelectPicklist_values__c;
            Nochange[key] = value;
        }       
        let RosValues ='<b style="color:#493266;font-size:15px;">Review of System</b><br/>';
        var data =component.get("v.ROSDisplayData");
        for (var key in Nochange) {
            for (var key1 in data) {
                if(key == key1){
                    Nochange[key]=data[key];
                }
                else{
                    Nochange[key]=Nochange[key];
                }
            }
        }
        if(component.get("v.ROS") == true){ 
                for (var key in Nochange) {
                    if (Nochange.hasOwnProperty(key)) {
                        RosValues += '<b>'+key+'</b>'+' : '+Nochange[key]+'<br/>';  
                        console.log(key + ":" + Nochange[key]);
                    }  
                var res = myVal.concat(RosValues);// concat existing value
                component.set("v.myVal",res);  
                component.set("v.ROS",false);
                component.set("v.Vital" , false);
                component.set("v.ROSDisplayData" , '');    
            }     
        }
    },
    
    createChiefComplaintsObjectData: function(component, event) {
      
       var Id = component.get("v.recordId");
        var RowItemList = component.get("v.EhrConditions");
        RowItemList.push({
            'sobjectType': 'ElixirSuite__Dataset1__c',
            'ElixirSuite__Problem_Name__c':'',
            'ElixirSuite__Notes__c': '',
            'ElixirSuite__Account__c' : Id
        });
        component.set("v.EhrConditions", []);      
        component.set("v.EhrConditions", RowItemList);
        
      },
    addChiefComplaintsHelper : function(component, event)
    {
        var EhrConditions = component.get('v.EhrConditions');
        var myVal = component.get("v.myVal");
        if(component.get("v.isChiefComplaints") == true){
            var action = component.get("c.addChiefComplaintsRec");
            action.setParams({
                ehrCondList : EhrConditions
            });
            action.setCallback(this,function(resp){
                if(resp.getState() == 'SUCCESS')
                {
                    if(resp.getReturnValue() == 'SUCCESS')
                    {
                        if(myVal.includes('Chief Complaints:')){
                                let splitMyval = [];
                                splitMyval = myVal.split('Chief Complaints:</b>');
                                splitMyval[0]+= 'Chief Complaints:</b><br/>';
                                //splitMyval[0]+= '<br/>' + 'Height:' +  heightVal + ' '+ 'cm' + '  ,'+ 'Weight:' +  weightVal + ' '+ 'kg'+ '  ,'+ 'BP Systolic:' +  sysVal + ' '+ 'mm[Hg]' + '  ,'+ 'BP Diastolic:' +  diasVal + ' '+ 'mm[Hg]' + '  ,'+  '<br/>'+ 'Temperature:' +  tempVal + ' '+ 'celsius(degree)' + '  ,'+ 'Pulse:' +  pulseVal + ' '+ '/min' + '  ,'+ 'Oxygen Saturation:' +  oxySatVal + ' '+ '%' + '<br/>'      ;      
                                for(var i in EhrConditions)
                                {
                                    if(EhrConditions[i].ElixirSuite__Problem_Name__c != null && EhrConditions[i].ElixirSuite__Problem_Name__c != '')
                                    {
                                        splitMyval[0]+= 'Problem Name:' + EhrConditions[i].ElixirSuite__Problem_Name__c + ', ';
                                    }
                                    if(EhrConditions[i].ElixirSuite__Notes__c != null && EhrConditions[i].ElixirSuite__Notes__c != '')
                                    {
                                        splitMyval[0]+= 'Description:' + EhrConditions[i].ElixirSuite__Notes__c + '<br/>';
                                    }
                                }
                                myVal = splitMyval.join();
                            }else{
                                myVal+=' <b style="color:#493266;font-size:15px;">Chief Complaints:</b><br/>';
                                for(var i in EhrConditions)
                                {
                                    if(EhrConditions[i].ElixirSuite__Problem_Name__c != null && EhrConditions[i].ElixirSuite__Problem_Name__c != '')
                                    {
                                        myVal = myVal + 'Problem Name:' + EhrConditions[i].ElixirSuite__Problem_Name__c + ', ';
                                    }
                                    if(EhrConditions[i].ElixirSuite__Notes__c != null && EhrConditions[i].ElixirSuite__Notes__c != '')
                                    {
                                        myVal = myVal + 'Description:' + EhrConditions[i].ElixirSuite__Notes__c + '<br/>';
                                    }
                                }
                            }
                        //alert('myval : ' + myVal);
                        component.set("v.myVal",myVal);
                        }
                        
                    }
                    else{
                        let errors = resp.getError();
                		if (errors && Array.isArray(errors) && errors.length > 0) {
                        	var message = errors[0].message;
                            
                            
                        }
                    }
            });
            $A.enqueueAction(action);
            console.log('#### myVal after : ' + myVal);
            component.set('v.EhrConditions',[]);
            component.set("v.isVital",false);
            component.set("v.isChiefComplaints",false);
            component.set("v.Vital" , false);
    	}
    },
    createPrescriptionsObjectData: function(component, event) {
      
       var Id = component.get("v.recordId");
        var RowItemList = component.get("v.PrescriptionsList");
        RowItemList.push({
              'sobjectType': 'ElixirSuite__Prescription_Order__c',
           // 'MedicationName__c':'',
           // 'Frequency_for_jumpstartmd__c': '',
            'ElixirSuite__Type__c':'PRN',
            'ElixirSuite__Account__c' : Id
        });

 

        component.set("v.PrescriptionsList", []);      
        component.set("v.PrescriptionsList", RowItemList);
        
      },
    
    addPrescriptionsHelper : function(component, event)
    {
        var PrescriptionsList = component.get('v.PrescriptionsList');
        var PrescriptionsToSave = component.get('v.PrescriptionsToSave');
        PrescriptionsToSave.push.apply(PrescriptionsToSave, PrescriptionsList);
        component.set('v.PrescriptionsToSave',PrescriptionsToSave);
        console.log('PrescriptionsToSave --- ' , PrescriptionsToSave);
        var myVal = component.get("v.myVal");
        if(component.get("v.isPrescriptions") == true){
            if(myVal.includes('Prescriptions:')){
                let splitMyval = [];
                splitMyval = myVal.split('Prescriptions:</b><br/>');
                splitMyval[0]+= 'Prescriptions:</b><br/>';
                for(var i in PrescriptionsList)
                {
                    if(PrescriptionsList[i].ElixirSuite__MedicationName__c != null && PrescriptionsList[i].ElixirSuite__MedicationName__c != '')
                    {
                        splitMyval[0]+= 'Name:' + PrescriptionsList[i].ElixirSuite__MedicationName__c + ', ';
                    }
                    if(PrescriptionsList[i].ElixirSuite__Frequency_for_jumpstartmd__c != null && PrescriptionsList[i].ElixirSuite__Frequency_for_jumpstartmd__c != '')
                    {
                        splitMyval[0]+= 'Frequency:' + PrescriptionsList[i].ElixirSuite__Frequency_for_jumpstartmd__c + '<br/>';
                    }
                }
                myVal = splitMyval.join();
            }else{
                myVal+=' <b style="color:#493266;font-size:15px;">Prescriptions:</b><br/>';
                for(var i in PrescriptionsList)
                {
                    if(PrescriptionsList[i].ElixirSuite__MedicationName__c != null && PrescriptionsList[i].ElixirSuite__MedicationName__c != '')
                    {
                        myVal = myVal + 'Name:' + PrescriptionsList[i].ElixirSuite__MedicationName__c + ', ';
                    }
                    if(PrescriptionsList[i].ElixirSuite__Frequency_for_jumpstartmd__c != null && PrescriptionsList[i].ElixirHC__Frequency_for_jumpstartmd__c != '')
                    {
                        myVal = myVal + 'Frequency:' + PrescriptionsList[i].ElixirSuite__Frequency_for_jumpstartmd__c + '<br/>';
                    }
                }
            }
            //alert('myval : ' + myVal);
            component.set("v.myVal",myVal);
        }
        console.log('#### myVal after : ' + myVal);
        component.set("v.isVital",false);
        component.set("v.isPrescriptions",false);
        component.set("v.Vital" , false);
        component.set('v.PrescriptionsList',[]);
    },
    addSocialHelper :function(component, event, helper){
        var myVal = component.get("v.myVal");
        if(component.get("v.isSocial") == true && component.get("v.newSocial") != null && component.get("v.newSocial") != ''){
            myVal =myVal+'<b style="color:#493266;font-size:15px;">Social History</b><br/>'+component.get("v.newSocial")+'';
            component.set("v.myVal",myVal);  
            component.set("v.isSocial",false);
            component.set("v.Vital" , false);
            component.set("v.newSocial" , '');
        }
   },
    addFamilyHelper :function(component, event, helper){
         var myVal = component.get("v.myVal");
        if(component.get("v.isFamily") == true && component.get("v.newFamily") != null && component.get("v.newFamily") != '' && component.get("v.newFamily") != 'undefined'){
            myVal =myVal+'<b style="color:#493266;font-size:15px;">Family History</b><br/>'+component.get("v.newFamily")+'';
            component.set("v.myVal",myVal);  
            component.set("v.isFamily",false);
            component.set("v.Vital" , false);
            component.set("v.newFamily" , '');
        } 
       
    },
    createPastData: function(component, event) {
        var Id = component.get("v.recordId");
        var RowItemList = component.get("v.MedicalHistory");
        RowItemList.push({
            'sobjectType': 'ElixirSuite__Medical_History__c',
            'Name':'',
            'ElixirSuite__Description__c': '',
            'ElixirSuite__Account__c' : Id
        });
	   component.set("v.MedicalHistory", []);      
       component.set("v.MedicalHistory", RowItemList);

      },
    addPastMedicalHelperTable : function(component, event)
    {
       var medicalHistList = component.get('v.MedicalHistory');
        var myVal = component.get("v.myVal");
        if(component.get("v.ishealthDiagnosis") == true && component.get("v.newhealthDiagnosis") != null && component.get("v.newhealthDiagnosis") != ''){
            if(component.get("v.newhealthDiagnosis") != ''){
                myVal =myVal+'<b style="color:#493266;font-size:15px;">Past Medical/Surgical History:</b><br/>'+component.get("v.newhealthDiagnosis")+'<br/>';
            }
           // component.set("v.myVal",myVal);  
            
            if(myVal.includes('Past Medical/Surgical History:')){
                let splitMyval = [];
                splitMyval = myVal.split('Past Medical/Surgical History:</b><br/>');
                splitMyval[0]+= 'Past Medical/Surgical History:</b><br/>';
                for(var i in medicalHistList)
                {
                    if(medicalHistList[i].Name != null && medicalHistList[i].Name != '')
                    {
                        splitMyval[0]+= 'Name:' + medicalHistList[i].Name + ', ';
                    }
                    if(medicalHistList[i].ElixirSuite__Description__c != null && medicalHistList[i].ElixirSuite__Description__c != '')
                    {
                        splitMyval[0]+= 'Description:' + medicalHistList[i].ElixirSuite__Description__c + '<br/>';
                    }
                }
                // alert('myval : ' + myVal);
                myVal = splitMyval.join();
            }else{
                myVal+=' <b style="color:#493266;font-size:15px;">Past Medical/Surgical History:</b><br/>';
                for(var i in medicalHistList)
                {
                    if(medicalHistList[i].Name != null && medicalHistList[i].Name != '')
                    {
                        myVal = myVal + 'Name:' + medicalHistList[i].Name + ', ';
                    }
                    if(medicalHistList[i].ElixirSuite__Description__c != null && medicalHistList[i].ElixirSuite__Description__c != '')
                    {
                        myVal = myVal + 'Description:' + medicalHistList[i].ElixirSuite__Description__c + '<br/>';
                    }
                }
            }
            component.set("v.myVal",myVal);
        }
        component.set('v.MedicalHistory',[]);
        component.set("v.isVital",false);
        component.set("v.ishealthDiagnosis",false);
        component.set("v.Vital" , false);
    	
    },
    pushDietType : function(component){
        var diets = [];
        var dietList = [];
        dietList.push('Jenny Craig');
        dietList.push('Nutri System ');
        dietList.push('Weight Watchers ');
        dietList.push('Opti Fast ');
        dietList.push('Medi Fast ');
        dietList.push('Fen/Phen ');
        dietList.push('Redux');
        dietList.push('Meridia');
        dietList.push('Xenical');
        dietList.push('OTC Diet Pills ');
        dietList.push('T.O.P.S');
        dietList.push('Curves');
        dietList.push('O.A.');
        dietList.push('Metabolife');
        dietList.push('Acupuncture');
        dietList.push('Hypnosis');
        dietList.push('Atkins Diet');
        dietList.push('Work w/Dietician');
        for(var rec in dietList){
            diets.push({'dietType':dietList[rec],
                       'yesno':false});
        }
        component.set("v.dietaryHistory",diets);
    },
    addDietHelper :function(component, event, helper){
        var myVal = component.get("v.myVal");
        var labOrders = component.get("v.dietaryHistory");
        var labOrdersToSave = component.get("v.labOrdersToSave") || [] ;
        for(let labOrder in labOrders){
            if(labOrders[labOrder].yesno == false){
                continue;
            }
            if(myVal.includes('Dietary History:')){
                let splitMyval = [];
                splitMyval = myVal.split('Dietary History:</b>');
                splitMyval[0]+= 'Dietary History:</b>';
                splitMyval[0]+= '<br/>' + labOrders[labOrder].dietType+ ' - Duration:' + labOrders[labOrder].duration + ' - Weight Loss:' + labOrders[labOrder].weightloss;
                myVal = splitMyval.join();
            }else{
                myVal+=' <b style="color:#493266;font-size:15px;">Dietary History:</b><br/>'+labOrders[labOrder].dietType + ' - Duration:' + labOrders[labOrder].duration + ' - Weight Loss:' + labOrders[labOrder].weightloss;
            }
            labOrdersToSave.push(JSON.parse(JSON.stringify(labOrders[labOrder])));
        }
        component.set("v.myVal",myVal);
        component.set("v.labOrdersToSave",labOrdersToSave);
        component.set("v.dietaryHistory",[]);
        component.set("v.isDietary",false);
        helper.pushDietType(component);
        
    },
     addMeasurementHelper :function(component, event, helper){
        console.log('&&',component.get("v.measurements"));
	    var myVal = component.get("v.myVal");
        if(component.get("v.isMeasurement") == true){
            myVal =myVal+'<b style="color:#493266;font-size:15px;">Measurements</b><br/> Weight:'+component.get("v.measurements").weight+ '- Height:'+component.get("v.measurements").height + ' - Goal Weight:'+ +component.get("v.measurements").gWeight;
            component.set("v.myVal",myVal);  
            component.set("v.isMeasurement",false);
            component.set("v.measurements",[]);
        }
   },
    addWeightHistoryHelper:function(component, event, helper){
        console.log('&&',component.get("v.weightHistory"));
        var myVal = component.get("v.myVal");
       
        if(component.get("v.isWeightHistory") == true){
            
            if($A.util.isUndefinedOrNull(component.get("v.weightHistory").first))
            {
                component.set(component.get("v.weightHistory").first,'');
            }
            if($A.util.isUndefinedOrNull(component.get("v.weightHistory").second))
            {
                component.set(component.get("v.weightHistory").second,'');
            }
            myVal =myVal+'<b style="color:#493266;font-size:15px;">Weight History</b><br/> '+component.get("v.weightHistory").first+ '<br/>'+component.get("v.weightHistory").second ;
            component.set("v.myVal",myVal);  
            component.set("v.isWeightHistory",false);
            component.set("v.weightHistory",[]);
           
        }
         
        
   }
})