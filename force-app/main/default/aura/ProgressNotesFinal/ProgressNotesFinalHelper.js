({
    addNotesHelper : function(component, event, helper){
        var myVal = component.get("v.myVal");
        var medications = component.get("v.medications");
        var medicationsToSave = component.get("v.medicationsToSave") || [];
        for(let medicine in medications){
            console.log('medicine ',medicine);
            if(myVal.includes('Medications:')){
                let splitMyval = [];
                splitMyval = myVal.split('Medications:</b>');
                splitMyval[0]+= 'Prescriptions:</b>';
                splitMyval[0]+= '<br/>' + medications[medicine].FieldName+ ' - ' + medications[medicine].Description + ' times a day';
                myVal = splitMyval.join();
            }else{
                
                myVal+=' <b style="color:#493266;font-size:15px;">Medications:</b><br/>'+medications[medicine].FieldName + ' - ' + medications[medicine].Description +' times a day' ;        	
            }
            medicationsToSave.push(JSON.parse(JSON.stringify(medications[medicine])));
        }
        component.set("v.myVal",myVal);
        component.set("v.medicationsToSave",medicationsToSave);
        component.set("v.medications",[]);
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
    },
    addLabOrders :function(component, event, helper){
        var myVal = component.get("v.myVal");
        
        var additionalNotes = component.get("v.additionalNotes");
        var description = component.get("v.description");
        var frequency = component.get("v.frequency");
        var testName = component.get("v.testName");
        var labName = component.get("v.labName");
        var statByPhone = component.get("v.statByPhone");
        var statByFax = component.get("v.statByFax");

        
        if(component.get("v.isLab") == true){
           if(myVal.includes('Lab Order:')){
            let splitMyval = [];
            splitMyval = myVal.split('Lab Orders:</b>');
            splitMyval[0]+= '<b>Lab Order:</b>';
            splitMyval[0]+= '<br/>' + 'labName:' +  labName + '<br/>'+ 'Test Name:' +  testName + '<br/>'+ 'Frequency:' + frequency+  '<br/>'+'Description:'+description+'<br/>'+'AdditionalNotes: '+additionalNotes+'<br/>';
            myVal = splitMyval.join();
           }  
        
        else{
            myVal+= '<b style="color:#493266;font-size:15px;">Lab Order:</b><br/>'+'labName:' +  labName + '<br/>'+ 'Test Name:' +  testName + '<br/>'+ 'Frequency:' + frequency+  '<br/>'+'Description:'+description+'<br/>'+'AdditionalNotes: '+additionalNotes+'<br/>';

        }
        }
        component.set("v.myVal",myVal);  
        component.set("v.isLab",false);
        component.set("v.Vital" , false);
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
         console.log('JSON After '+JSON.stringify(Nochange));
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
            }     
        }
    },
    
    createChiefComplaintsObjectData: function(component, event) {
      
       var Id = component.get("v.recordId");
        var RowItemList = component.get("v.EhrConditions");
        RowItemList.push({
            'sobjectType': 'ElixirSuite__EhrCondition__c',
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
            'sobjectType': 'ElixirSuite__EhrMedicationPrescription__c',
            'ElixirSuite__MedicationName__c':'',
            'ElixirSuite__Frequency_for_jumpstartmd__c': '',
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
                    if(PrescriptionsList[i].ElixirSuite__Frequency_for_jumpstartmd__c != null && PrescriptionsList[i].ElixirSuite__Frequency_for_jumpstartmd__c != '')
                    {
                        myVal = myVal + 'Frequency:' + PrescriptionsList[i].ElixirSuite__Frequency_for_jumpstartmd__c + '<br/>';
                    }
                }
            }
            //alert('myval : ' + myVal);
            component.set("v.myVal",myVal);
        }
        console.log('#### myVal after : ' + myVal);
        component.set('v.PrescriptionsList',[]);
        component.set("v.isVital",false);
        component.set("v.isPrescriptions",false);
        component.set("v.Vital" , false);
    	
    },
    addSocialHelper :function(component, event, helper){
        var myVal = component.get("v.myVal");
        if(component.get("v.isSocial") == true){
            myVal =myVal+'<b style="color:#493266;font-size:15px;">Social History</b><br/>'+component.get("v.newSocial")+'';
            component.set("v.myVal",myVal);  
            component.set("v.isSocial",false);
            component.set("v.Vital" , false);
        }
   },
    addFamilyHelper :function(component, event, helper){
         var myVal = component.get("v.myVal");
        if(component.get("v.isFamily") == true){
            myVal =myVal+'<b style="color:#493266;font-size:15px;">Family History</b><br/>'+component.get("v.newFamily")+'';
            component.set("v.myVal",myVal);  
            component.set("v.isFamily",false);
            component.set("v.Vital" , false);
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
        if(component.get("v.ishealthDiagnosis") == true){
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
    	
    }
})