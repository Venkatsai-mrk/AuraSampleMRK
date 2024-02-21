/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-14-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Hl7MessageParsing {
       
    //function for Parsing Hl7 Message
    public static void parse(HL7__c mssg){
        
        String labOrderId = mssg.Order_ID__c;
        
        //fetching Hl7 message      
        String message=(String)mssg.Full_HL7_Dump_Message__c;   
        //Spliting the message into different segments \n for manually and \r for using apex	
        List<String> segment= Message.split('\r');
        List<List<String>> info=new List<List<String>>(); 
        Hl7Message hl7msg=new Hl7Message();
        String messageHeader;
        String patientIdentification;
        String orc;
        //Spliting information present in different segments
        for(string s:Segment){
            List<String> temp=s.split('\\|',-1);
            info.add(temp);
        }
        
        try{
            Integer key = 0;
            for(integer i=0;i<info.size();i++){
                
                if(info[i][0]=='MSH')
                {   
                    MessageHeader=Segment[i];
                    Hl7msg.msh.sendingApplication=info[i][2];
                    Hl7msg.msh.sendingFacility=info[i][3];
                    Hl7msg.msh.receivingApplication=info[i][4];
                    Hl7msg.msh.receivingFacility=info[i][5];
                    Hl7msg.msh.dateTimeofMessage=info[i][6];
                    Hl7msg.msh.messageType=info[i][8];
                    Hl7msg.msh.messageControlID=info[i][9];
                    Hl7msg.msh.processingID=info[i][10];
                    Hl7msg.msh.versionID=info[i][11];  
                    
                }
                if(info[i][0]=='PID')
                {   
                    PatientIdentification=Segment[i];
                    Hl7msg.pid.setID=info[i][1];
                    Hl7msg.pid.patientID=info[i][2];
                    Hl7msg.pid.patientIdentifierList=info[i][3];               
                    Hl7msg.pid.patientName=info[i][5];
                    
                    //checking condition of size for optional information that may or may not come                    
                    if(info[i].size()>7){
                        Hl7msg.pid.dateofBirth=info[i][7];
                    }
                    if(info[i].size()>8){
                        Hl7msg.pid.sex=info[i][8];
                    }
                    if(info[i].size()>11){
                        Hl7msg.pid.patientAddress=info[i][11];
                    }               
                    if(info[i].size()>13){
                        Hl7msg.pid.phoneNumberHome=info[i][13];
                    }
                    if(info[i].size()>19){
                        Hl7msg.pid.ssnPatient=info[i][19];
                    }
                    
                    //for storing NTE related to PID
                    i=i+1;
                    while(i<info.size()&&info[i][0]=='NTE'){
                        
                        Hl7Message.nteHl7 curNTE=new Hl7Message.nteHl7();
                        CurNTE.setID=info[i][1];
                        CurNTE.sourceofComment=info[i][2];
                        CurNTE.comment=info[i][3];                       
                        Hl7msg.pid.NTE.add(CurNTE);
                        i=i+1;
                    }                    
                    i=i-1;  
                }
                if(info[i][0]=='PV1'){
                    Hl7msg.pv1.containInfo=1;
                    Hl7msg.pv1.setID=info[i][1];
                    
                    //checking condition of size for optional information that may or may not come
                    
                    if(info[i].size()>2){
                        Hl7msg.pv1.patientClass=info[i][2];
                    }
                    if(info[i].size()>3){
                        Hl7msg.pv1.attendingPhysician=info[i][3];
                    }
                    if(info[i].size()>4){
                        Hl7msg.pv1.referringPhysician=info[i][4];
                    }
                    if(info[i].size()>5){
                        Hl7msg.pv1.consultingPhysician=info[i][5];
                    }
                    if(info[i].size()>6){
                        Hl7msg.pv1.admittingPhysician=info[i][6];
                    }
                    if(info[i].size()>7){
                        Hl7msg.pv1.encounterID=info[i][7];
                    }
                    if(info[i].size()>8){
                        Hl7msg.pv1.primaryPhysician=info[i][8];
                    }
                    
                }
                
                if(info[i][0]=='ORC'){
                    
                    ORC=Segment[i];
                    Hl7msg.orc.containInfo=1;
                    Hl7msg.orc.orderControl=info[i][1];
                    Hl7msg.orc.placerOrderNumber=info[i][2];
                    Hl7msg.orc.fillerOrderNumber=info[i][3];
                    Hl7msg.orc.orderStatus=info[i][5];
                    Hl7msg.orc.dateTimeofTransaction=info[i][9];
                    
                    //checking condition of size for optional information that may or may not come                    
                    if(info[i].size()>12){
                        Hl7msg.orc.orderingProvider=info[i][12];}
                    
                }
                
                if(info[i][0]=='OBR'){
                    key=key+1;
                    Hl7Message.obrHl7 curOBR=new Hl7Message.obrHl7();
                    CurOBR.setID=info[i][1];
                    CurOBR.placerOrderNumber=info[i][2];
                    CurOBR.fillerOrderNumber=info[i][3];
                    CurOBR.universalServiceID=info[i][4];
                    CurOBR.observationDateTime=info[i][7];
                    CurOBR.specimenReceivedDateTime=info[i][14];
                    CurOBR.specimenSource=info[i][15];
                    CurOBR.orderingProvider=info[i][16];
                    CurOBR.resultsRptStatusChangeDateTime=info[i][22];    
                    CurOBR.diagnosticServSectID=info[i][24];
                    CurOBR.resultStatus=info[i][25];
                    
                    //checking condition of size for optional information that may or may not come                    
                    if(info[i].size()>26){
                        CurOBR.parentResult=info[i][26];}
                    if(info[i].size()>27){
                        CurOBR.quantityTiming=info[i][27];}
                    if(info[i].size()>29){
                        CurOBR.parent=info[i][29];}
                    if(info[i].size()>31){
                        CurOBR.reasonforStudy=info[i][31];}
                    
                    //for storing NTE related to OBR
                    i=i+1;
                    while(i<info.size()&&info[i][0]=='NTE'){
                        
                        Hl7Message.nteHl7 curNTE=new Hl7Message.nteHl7();
                        CurNTE.setID=info[i][1];
                        CurNTE.sourceofComment=info[i][2];
                        CurNTE.comment=info[i][3];                        
                        CurOBR.NTE.add(CurNTE);
                        i=i+1;
                    }                                        
                    //for storing OBX related to OBR
                    
                    while(i<info.size()&&info[i][0]=='OBX'){
                        Hl7Message.obxHl7 curOBX=new Hl7Message.obxHl7();
                        CurOBX.setID=info[i][1]; 
                        CurOBX.valueType=info[i][2];
                        CurOBX.observationIdentifier=info[i][3];
                        CurOBX.observationSubID=info[i][4];
                        CurOBX.observationValue=info[i][5];
                        CurOBX.obrSetNo=key;
                        
                        if(info[i].size()>6){
                            CurOBX.units=info[i][6];
                        }
                        if(info[i].size()>7){
                            CurOBX.referencesRange=info[i][7];
                        }
                        if(info[i].size()>8){
                            CurOBX.abnormalFlags=info[i][8];
                        }
                        if(info[i].size()>11){
                            CurOBX.observResultStatus=info[i][11];
                        }
                        
                        //checking condition of size for optional information that may or may not come
                        
                        if(info[i].size()>14){
                            CurOBX.dateTimeoftheObservation=info[i][14];
                        }
                        if(info[i].size()>15){
                            CurOBX.producerID=info[i][15];
                        }                                               
                        //for storing NTE related to OBX
                        i=i+1;
                        
                        while(i<info.size()&&info[i][0]=='NTE'){
                            
                            Hl7Message.nteHl7 curNTE=new Hl7Message.nteHl7();
                            CurNTE.setID=info[i][1];
                            CurNTE.sourceofComment=info[i][2];
                            if(info[i].size()>3){
                                CurNTE.comment=info[i][3];}
                            
                            Curobx.NTE.add(CurNTE);
                            i=i+1;
                        }                        
                        CurOBR.obx.add(Curobx);                        
                    }                    
                    i=i-1; 
                    Hl7msg.obr.add(CurOBR);                    
                }
                
                if(info[i][0]=='TQ1'){
                    
                    Hl7msg.tq1.containInfo=1;
                    Hl7msg.tq1.setID=info[i][1];
                    
                    //checking condition of size for optional information that may or may not come                    
                    if(info[i].size()>2){
                        Hl7msg.tq1.quantity=info[i][2];}
                    if(info[i].size()>5){
                        Hl7msg.tq1.relativeTimeandUnits=info[i][5];}
                    if(info[i].size()>6){
                        Hl7msg.tq1.serviceDuration=info[i][6];}
                    if(info[i].size()>7){
                        Hl7msg.tq1.startdatetime=info[i][7];}
                    if(info[i].size()>8){
                        Hl7msg.tq1.enddatetime=info[i][8];}
                    if(info[i].size()>13){
                        Hl7msg.tq1.occurrenceduration=info[i][13];}
                }
                if(info[i][0]=='SPM'){
                    Hl7msg.spm.containInfo=1;
                    Hl7msg.spm.setID=info[i][1];
                    Hl7msg.spm.specimenID=info[i][2];
                    Hl7msg.spm.specimenType=info[i][4];
                    
                    //checking condition of size for optional information that may or may not come                   
                    if(info[i].size()>8){
                        Hl7msg.spm.specimenSourceSite=info[i][8];}
                    if(info[i].size()>10){
                        Hl7msg.spm.specimenCollectionSite=info[i][10];}                    
                }
            }
        }
        catch(ListException e){
            ExceptionLog.logError(e);
        }
        
        //Now Storing Hl7 Message segment:MSH,PID,ORC
        mssg.Patient_Identification__c=patientIdentification;
        mssg.Message_Header__c=messageHeader;
        mssg.Observation_Request__c=orc;
        //List to store all Obr
        // List<LabOrder_Hl7_Results_Tests_Info__c> allOBR=new List<LabOrder_Hl7_Results_Tests_Info__c>();
        //List to store all Obx
        List<Test_Result_Detail__c> allOBX=new List<Test_Result_Detail__c>();
        //Fetching Json for OBR_ResultStatus
        String parameter2='OBR_ResultStatus';        
        List<HL7_CustomMetaDataTypes__mdt> obsrVal1=[Select ValuesJSON__c from HL7_CustomMetaDataTypes__mdt where HL7_ParameterName__c=:Parameter2 WITH SECURITY_ENFORCED];
        //Fetching Json for Observation ResultStatus
        String parameter1='ObservResultStatus';
        Map<String, Lab_Order__c> testNameToLabOrderMap = new Map<String, Lab_Order__c>();
        List<Lab_Order__c> labOrder = [Select Id, Test_Name__c from Lab_Order__c where Id=:labOrderId WITH SECURITY_ENFORCED];
        for(Lab_Order__c l : labOrder){
            if(String.isNotBlank(l.Test_Name__c)){
                String testName = l.Test_Name__c.toLowerCase();
                testNameToLabOrderMap.put(testName, l);
            }
        }
        
        // List<LabOrder_Hl7_Results_Tests_Info__c> resultTestInfoLst  = new List<LabOrder_Hl7_Results_Tests_Info__c>();
        List<Lab_Order__c> labOrderToUpdate = new List<Lab_Order__c>();
        Map<Id, String> labOrderMap = new Map<Id, String>();
         List<HL7_CustomMetaDataTypes__mdt> fetchStatus=[Select ValuesJSON__c from HL7_CustomMetaDataTypes__mdt where HL7_ParameterName__c=:Parameter1 WITH SECURITY_ENFORCED];
        //Fetching Json for Abnormal Flag
        String parameter='Abnormal Flag';
        List<HL7_CustomMetaDataTypes__mdt> obsrVal=[Select ValuesJSON__c from HL7_CustomMetaDataTypes__mdt where HL7_ParameterName__c=:Parameter WITH SECURITY_ENFORCED];
        List<Test_Result_Detail__c> oldObx = [Select Id from Test_Result_Detail__c where Test_ResultId__c=:labOrderId WITH SECURITY_ENFORCED];
        Map<Id, Test_Result_Detail__c> obxToDelete = new  Map<Id, Test_Result_Detail__c>();
        Map<String, String> loincMap = new Map<String, String>();
        Id recordTypeId = Schema.SObjectType.Master_Object__c.getRecordTypeInfosByDeveloperName().get('Test_Result').getRecordTypeId();
        List<Master_Object__c> masterData = [SELECT Id, Coding_System_Value__c, Coding_System__c
                                             FROM Master_Object__c
                                             WHERE Coding_System__c = 'LOINC'
                                             AND RecordTypeId =:recordTypeId WITH SECURITY_ENFORCED];
        if(masterData!=null && masterData.size()>0){
            // Will our loinc codes unique in master data
            for(Master_Object__c data : masterData){
                loincMap.put(data.Coding_System_Value__c, data.Id);                
            }            
        }
        
        for(Hl7Message.obrHl7 curobr:Hl7msg.obr){           
            
            
            //get the lab test name
            List<String> getTestName=(Curobr.universalServiceID).split('\\^');
            //get specific labOrder with testName
            Lab_Order__c ordr = testNameToLabOrderMap.get(getTestName[1].toLowerCase());
            if(ordr!=null){
                ordr.Test_Result_Name__c = getTestName[1];
                ordr.Universal_Service_ID__c = Curobr.universalServiceID;
                String resultObsDateAndTime = Curobr.observationDateTime;
                if(String.isNotBlank(ResultObsDateAndTime)){
                    ordr.Observation_Date_Time__c = Datetime.newInstance((integer.valueOf(ResultObsDateAndTime.substring(0,4))),(integer.valueOf(ResultObsDateAndTime.substring(4,6))),(integer.valueOf(ResultObsDateAndTime.substring(6,8))),(integer.valueOf(ResultObsDateAndTime.substring(8,10))),(integer.valueOf(ResultObsDateAndTime.substring(10,12))),0);                    
                }
                ordr.Set_ID__c = Curobr.setID;
                ordr.Placer_Order_Number__c = Curobr.placerOrderNumber;
                mssg.Placer_Order__c = Curobr.placerOrderNumber;
                ordr.Filler_Order_Number__c = Curobr.fillerOrderNumber;
                ordr.Specimen_Source__c = Curobr.specimenSource;
                String specimnReceivedDateTime = Curobr.specimenReceivedDateTime;
                if(String.isNotBlank(specimnReceivedDateTime)){
                    ordr.Specimen_Received_Date_Time__c = Datetime.newInstance((integer.valueOf(specimnReceivedDateTime.substring(0,4))),(integer.valueOf(specimnReceivedDateTime.substring(4,6))),(integer.valueOf(specimnReceivedDateTime.substring(6,8))),(integer.valueOf(specimnReceivedDateTime.substring(8,10))),(integer.valueOf(specimnReceivedDateTime.substring(10,12))),0);
                }
                ordr.OrderingProvider__c = Curobr.orderingProvider;                
                String resultStatDateTime=Curobr.resultsRptStatusChangeDateTime;
                if(String.isNotBlank(ResultStatDateTime)){
                    ordr.Results_Rpt_Status_Change_Date_Time__c = Datetime.newInstance((integer.valueOf(ResultStatDateTime.substring(0,4))),(integer.valueOf(ResultStatDateTime.substring(4,6))),(integer.valueOf(ResultStatDateTime.substring(6,8))),(integer.valueOf(ResultStatDateTime.substring(8,10))),(integer.valueOf(ResultStatDateTime.substring(10,12))),0);
                }
                ordr.Diagnostic_Serv_Sect_ID__c = Curobr.diagnosticServSectID;
                String flag2=Curobr.resultStatus;
                if(flag2=='F'){
                    ordr.Status__c = 'Results Received';
                }
                else{
                    ordr.Status__c = 'Results Received (Partial)';
                }
                if(ObsrVal1.size()>0)
                {
                    String jsonMessage=ObsrVal1[0].ValuesJSON__c;                 
                    ordr.Result_Status__c=HL7Utils.RetrieveValueFromJSON(JsonMessage,Flag2);                                                                      
                }
                ordr.Quantity_Timing__c = Curobr.quantityTiming;
                ordr.Parent_Result__c = Curobr.parentResult;
                
                String parentInfo=Curobr.parent;
                if(String.isNotBlank(parentInfo)){
                   ordr = nestedIfElse(ordr, parentInfo);
                } 
                
                String reasnForStudy=Curobr.reasonforStudy;
                if(String.isNotBlank(reasnForStudy)){    
                    ordr = nestedIfElse2(ordr, reasnForStudy);
                }    
                
                labOrderToUpdate.add(ordr);
                labOrderMap.put(ordr.Id, ordr.Set_ID__c);
            }
            
            //Storing OBR data 
            /*LabOrder_Hl7_Results_Tests_Info__c ResultTestInfo=new LabOrder_Hl7_Results_Tests_Info__c(); 
            ResultTestInfo.LabOrder_HL7_Results_ID__c=mssg.id;
            String ResObsDateAndTime=Curobr.observationDateTime;
            if(ResObsDateAndTime!=''&& ResObsDateAndTime!=null)
            {   try{
                ResultTestInfo.Observation_Date_Time__c=Datetime.newInstance((integer.valueOf(ResObsDateAndTime.substring(0,4))),(integer.valueOf(ResObsDateAndTime.substring(4,6))),(integer.valueOf(ResObsDateAndTime.substring(6,8))),(integer.valueOf(ResObsDateAndTime.substring(8,10))),(integer.valueOf(ResObsDateAndTime.substring(10,12))),0);
            }
             catch(Exception e){
                 system.debug(e);
             }             
            }
            List<String> fetchTestName=(Curobr.universalServiceID).split('\\^');
            try{
                ResultTestInfo.Test_Result_Name__c=fetchTestName[1];
            }
            catch(ListException e){
                system.debug(e);
            }
            ResultTestInfo.Universal_Service_ID__c=Curobr.universalServiceID;
            ResultTestInfo.Set_ID__c=Curobr.setID;
            ResultTestInfo.Placer_Order_Number__c=Curobr.placerOrderNumber;
            ResultTestInfo.Filler_Order_Number__c=Curobr.fillerOrderNumber;
            ResultTestInfo.Specimen_Source__c=Curobr.specimenSource;
            String spRDateTime=Curobr.specimenReceivedDateTime;
            if(spRDateTime!=''&& spRDateTime!=null)
            {   try{
                ResultTestInfo.Specimen_Received_Date_Time__c=Datetime.newInstance((integer.valueOf(spRDateTime.substring(0,4))),(integer.valueOf(spRDateTime.substring(4,6))),(integer.valueOf(spRDateTime.substring(6,8))),(integer.valueOf(spRDateTime.substring(8,10))),(integer.valueOf(spRDateTime.substring(10,12))),0);
            }
             catch(Exception e){
                 system.debug(e);
             }            
            }
            ResultTestInfo.Ordering_Provider__c=Curobr.orderingProvider;
            String ResStatDateTime=Curobr.resultsRptStatusChangeDateTime;
            if(ResStatDateTime!=''&& ResStatDateTime!=null)
            {   try{
                ResultTestInfo.Results_RptStatus_Change_Date_Time__c=Datetime.newInstance((integer.valueOf(ResStatDateTime.substring(0,4))),(integer.valueOf(ResStatDateTime.substring(4,6))),(integer.valueOf(ResStatDateTime.substring(6,8))),(integer.valueOf(ResStatDateTime.substring(8,10))),(integer.valueOf(ResStatDateTime.substring(10,12))),0);
            }
             catch(Exception e){
                 system.debug(e);
             }
             
            }
            ResultTestInfo.Diagnostic_Serv_Sect_ID__c=Curobr.diagnosticServSectID;                       
            String Flag2=Curobr.resultStatus;
            if(ObsrVal1.size()>0)
            {
                String JsonMessage=ObsrVal1[0].ValuesJSON__c;                 
                ResultTestInfo.Result_Status__c=HL7Utils.RetrieveValueFromJSON(JsonMessage,Flag2);                                                                      
            }
            ResultTestInfo.Quantity_Timing__c=Curobr.quantityTiming;
            ResultTestInfo.Parent_Result__c=Curobr.parentResult;
            String parentInf=Curobr.parent;
            if(parentInf!=Null && parentInf!='')
            {    
                try{                   
                    List<String> ListParent=parentInf.split('\\^');
                    if(ListParent.size()>0)
                        ResultTestInfo.Requisition_Number__c=ListParent[0];
                    if(ListParent.size()>1)
                        ResultTestInfo.Assigning_Application__c=ListParent[1];
                    if(ListParent.size()>2)
                        ResultTestInfo.Accession_Number__c=ListParent[2];
                    if(ListParent.size()>3)
                        ResultTestInfo.Regional_lab_hospital_identifier__c=ListParent[3];                                         
                }
                catch(ListException e){
                    System.debug(e);
                }
            } 
            String reasonForStudy=Curobr.reasonforStudy;
            if(reasonForStudy!=Null && reasonForStudy!='')
            {    
                try{                   
                    List<String> ListRStudy=reasonForStudy.split('\\^');
                    if(ListRStudy.size()>0)
                        ResultTestInfo.Result_Profile_Code__c=ListRStudy[0];
                    if(ListRStudy.size()>1)
                        ResultTestInfo.Result_Profile_Description__c=ListRStudy[1];                      
                }
                catch(ListException e){
                    System.debug(e);
                }
            }                
            //adding current obr to the list for insertion.
            //allOBR.add(ResultTestInfo);
            
            
            //insert ResultTestInfo;
            
            ResultTestInfoLst.add(ResultTestInfo);*/           
            
            
            for(Hl7Message.obxHl7 curobx:Curobr.obx){
                List<String> obserIdentity=(Curobx.observationIdentifier).split('\\^');
                String pdfReport;
                if(obserIdentity.size()>0){
                    pdfReport = obserIdentity[0];
                }
                String obrSetNum = labOrderMap.get(labOrderId);
                
                if(String.isNotBlank(obrSetNum) && String.valueOf(curobx.obrSetNo) == obrSetNum || pdfReport == 'PDFReport1' || pdfReport == 'ClinicalPDFReport1'){
                
                if(oldObx!=null && oldObx.size()>0){
                    obxToDelete.putAll(oldObx);
                }

                //Storing Current obx data
                Test_Result_Detail__c oBXObj=new Test_Result_Detail__c();
                OBXObj.Set_ID_OBX__c=Curobx.setID;
                OBXObj.Test_ResultId__c=labOrderId; 
                for(Hl7Message.nteHl7 curnte:Curobx.NTE){
                    
                 OBXObj.Notes__c+=Curnte.comment;
                    OBXObj.Notes__c+='\n';
                }
                    if(OBXObj.Notes__c!=null && OBXObj.Notes__c.startsWith('null')){
                        OBXObj.Notes__c = OBXObj.Notes__c.removeStart('null');
                    }
                    
                List<String> obserIden=(Curobx.observationIdentifier).split('\\^');
                try{
                    if(ObserIden.size()>0){
                    OBXObj.Observation_Identifier_Analyte_Code__c=ObserIden[0];}
                    if(ObserIden.size()>1){
                    OBXObj.Observation_Identifier_Analyte_Descrip__c=ObserIden[1];}
                    if(ObserIden.size()>3){
                        OBXObj.Test_Result_Detail_Id__c=ObserIden[3];
                        if(loincMap!=null && loincMap.containsKey(ObserIden[3])){
                            OBXObj.Result__c = loincMap.get(ObserIden[3]);
                        }
                    }
                    if(ObserIden.size()>4){
                        OBXObj.Test_Result_Detail_Name__c=ObserIden[4];
                    }
                }
                catch(ListException e){
                    ExceptionLog.logError(e);
                }
                if(Curobx.units!=Null && Curobx.units!=''){
                    OBXObj = nestedIfElse3(OBXObj, Curobx.units);
                }
                OBXObj.Observation_Value_type__c=Curobx.valueType;
                String status=Curobx.observResultStatus;
                if(fetchStatus.size()>0)
                   	{
                        String jsonMessage1=fetchStatus[0].ValuesJSON__c;                   
                        OBXObj.Observe_Result_Status__c=HL7Utils.RetrieveValueFromJSON(JsonMessage1,Status);
                                                                      
                   }
                OBXObj.References_Range__c=Curobx.ReferencesRange;                
                String obsDateAndTime=Curobx.DateTimeoftheObservation;
                if(ObsDateAndTime!=''&& ObsDateAndTime!=null){
                    OBXObj.Date_Time_Of_Observation__c=Datetime.newInstance((integer.valueOf(ObsDateAndTime.substring(0,4))),(integer.valueOf(ObsDateAndTime.substring(4,6))),(integer.valueOf(ObsDateAndTime.substring(6,8))),(integer.valueOf(ObsDateAndTime.substring(8,10))),(integer.valueOf(ObsDateAndTime.substring(10,12))),0);
                }
                OBXObj.Abnormal_Flag__c=Curobx.abnormalFlags; 
                String flag=Curobx.abnormalFlags;                
                   if(ObsrVal.size()>0)
                   	{
                        String jsonMessage=ObsrVal[0].ValuesJSON__c;                   
                        OBXObj.Observation_Value__c=HL7Utils.RetrieveValueFromJSON(JsonMessage,flag);                                                                      
                   }
                                
                OBXObj.HL7_Id__c=mssg.Id;               
                 if(Curobx.ValueType=='ST'){
                    OBXObj.Observation_Value_Text__c=Curobx.observationValue;}
                 else if(Curobx.ValueType=='TX'){
                    OBXObj.Observation_Value_TextAREA__c=Curobx.observationValue;}
                 else if(Curobx.ValueType=='NM')
                 {   try{                     
                     	OBXObj.Observation_Value_Numeric__c=Decimal.ValueOf(Curobx.observationValue);
                            
                 }
                  catch(Exception e){
                      ExceptionLog.logError(e);
                  }
                 }
                 else if(Curobx.ValueType=='ED')
                 {  
                    
                    List<String> obsrvalImg=(Curobx.observationValue).split('\\^'); 
                    try{
                        OBXObj.Observation_Value_Image_Data_type__c=ObsrvalImg[1];
                        OBXObj.Observation_Value_Image_Data_subtype__c=ObsrvalImg[2];    
                 		OBXObj.Observation_Value_Image__c=ObsrvalImg[4];
                    }
                     catch(ListException e){
                        ExceptionLog.logError(e);
                     }                        
                 }
            //adding current obx to the list for insertion 
              allOBX.add(OBXObj);
                }       
            }     
        }
        
        //DMLManager.insertAsUser(ResultTestInfoLst);
        //for(Test_Result_Detail__c trd : allOBX){
        //    trd.Test_Result_Id__c=ResultTestInfoLst[0].id; 
       // }
       if(obxToDelete!=null && obxToDelete.size()>0){
        DMLManager.deleteAsUser(obxToDelete.values());
       }
        DMLManager.insertAsUser(allOBX);
        //insert allOBX;
        
        if(labOrderToUpdate!=null){
            DMLManager.updateAsUser(labOrderToUpdate);
        }
        
        //function call to save information of MSH,PID and ORC related to Hl7 message
        createRelatedInfo(Hl7msg,mssg);
    }
    

    public static Lab_Order__c nestedIfElse(Lab_Order__c ordr, String parentInfo){        
                         
            List<String> parentList=parentInfo.split('\\^');
            if(parentList.size()>0){
                ordr.Requisition_Number__c=parentList[0];}
            if(parentList.size()>1){
                ordr.Assigning_Application__c=parentList[1];}
            if(parentList.size()>2){
                ordr.Accession_Number__c=parentList[2];}
            if(parentList.size()>3){
                ordr.Regional_lab_hospital_identifier__c=parentList[3];} 
           
            return ordr;
       
    }

    public static Lab_Order__c nestedIfElse2(Lab_Order__c ordr, String reasnForStudy){
            List<String> rStudyList = reasnForStudy.split('\\^');
            if(RStudyList.size()>0){
                ordr.Result_Profile_Code__c=RStudyList[0];}
            if(RStudyList.size()>1){
                ordr.Result_Profile_Description__c=RStudyList[1];}                      
            return ordr;
    }

    public static Test_Result_Detail__c nestedIfElse3(Test_Result_Detail__c oBXObj, String curobxUnits){        
        List<String> getUnit=(CurobxUnits).split('\\^');
        if(GetUnit.size()>1){
            OBXObj.Units__c=GetUnit[1];}

            return oBXObj;
    }
    
     //function to save information of MSH,PID and ORC related to Hl7 message
    public static void createRelatedInfo(Hl7Message hl7msg,HL7__c mssg){
        
           Info_Related_To_Hl7Result__c relatedResults=new Info_Related_To_Hl7Result__c(); 
           RelatedResults.LabOrder_HL7_Results_ID__c=mssg.id;
           RelatedResults.MSH_Receiving_Application__c=Hl7msg.msh.receivingApplication;
           RelatedResults.MSH_Sending_Application__c=Hl7msg.msh.sendingApplication;
           RelatedResults.MSH_Sending_Facility__c=Hl7msg.msh.sendingFacility;
 		   RelatedResults.MSH_Receiving_Facility__c=Hl7msg.msh.receivingFacility; 		 
 		   String dateMsg=Hl7msg.msh.dateTimeofMessage;
           if(DateMsg!=''&& DateMsg!=null)
            {   try{
                	RelatedResults.MSH_DateTime_of_Message__c=Datetime.newInstance((integer.valueOf(DateMsg.substring(0,4))),(integer.valueOf(DateMsg.substring(4,6))),(integer.valueOf(DateMsg.substring(6,8))),(integer.valueOf(DateMsg.substring(8,10))),(integer.valueOf(DateMsg.substring(10,12))),0);
                 }
             catch(Exception e){
                ExceptionLog.logError(e);
             }             
            }
 		   RelatedResults.MSH_Message_Type__c=Hl7msg.msh.messageType;
 		   RelatedResults.MSH_Message_Control_ID__c=Hl7msg.msh.messageControlID;
 		   RelatedResults.MSH_Processing_ID__c=Hl7msg.msh.processingID;
 		   RelatedResults.MSH_Version_ID__c=Hl7msg.msh.versionID;
 		   RelatedResults.ORC_Filler_Order_Number__c=Hl7msg.orc.fillerOrderNumber;
 		   RelatedResults.ORC_Placer_Order_Number__c=Hl7msg.orc.placerOrderNumber;
           RelatedResults.ORC_Order_Status__c=Hl7msg.orc.orderStatus;
           
           String dateTran=Hl7msg.orc.dateTimeofTransaction;
           if(DateTran!=''&& DateTran!=null)
            {   try{
                	RelatedResults.ORC_DateTime_of_Transaction__c=Datetime.newInstance((integer.valueOf(DateTran.substring(0,4))),(integer.valueOf(DateTran.substring(4,6))),(integer.valueOf(DateTran.substring(6,8))),(integer.valueOf(DateTran.substring(8,10))),(integer.valueOf(DateTran.substring(10,12))),0);
                 }
             catch(Exception e){
                ExceptionLog.logError(e);
             }            
            }
          
            String ordrPro=Hl7msg.orc.orderingProvider;
           if(OrdrPro!=Null && OrdrPro!='')
           {    
               try{
                   List<String> listProvider=OrdrPro.split('\\^');
                   if(ListProvider.size()>0){
                       RelatedResults.ORC_Physician_identifier__c=ListProvider[0];}                 
                   if(ListProvider.size()>2){
                       RelatedResults.ORC_PhysicianFirstName__c=ListProvider[2];}
                   if(ListProvider.size()>2){
                       RelatedResults.ORC_PhysicianLastName__c=ListProvider[1];}
                   
               }
            catch(ListException e){
                ExceptionLog.logError(e);
            }
            }
           RelatedResults.PID_Set_ID_Patient_ID__c=Hl7msg.pid.setID;  
           RelatedResults.PID_Patient_ID_External_ID__c=Hl7msg.pid.patientID;
           RelatedResults.PID_Gender__c=Hl7msg.pid.sex;
           String phnNum=Hl7msg.pid.phoneNumberHome;
           
           try{
               RelatedResults.PID_Phone_Number_Home__c=PhnNum.replaceAll('\\^','');  
           }
           catch(Exception e){
           		ExceptionLog.logError(e);
           }
           String dateofBirth=Hl7msg.pid.dateofBirth;
           if(DateofBirth!=''&& DateofBirth!=null)
            {   try{
                	RelatedResults.PID_Date_of_Birth__c=Date.newInstance((integer.valueOf(DateofBirth.substring(0,4))),(integer.valueOf(DateofBirth.substring(4,6))),(integer.valueOf(DateofBirth.substring(6,8))));
                 }
             catch(Exception e){
                ExceptionLog.logError(e);
             }
             
            }
           String parameter='ORC_Order_Status';
           String flag=Hl7msg.orc.orderStatus;
           List<HL7_CustomMetaDataTypes__mdt> obsrVal=[Select ValuesJSON__c from HL7_CustomMetaDataTypes__mdt where HL7_ParameterName__c=:Parameter WITH SECURITY_ENFORCED];

                   if(ObsrVal.size()>0)
                   	{
                        String jsonMessage=ObsrVal[0].ValuesJSON__c;                   
                        RelatedResults.ORC_Order_Status__c=HL7Utils.RetrieveValueFromJSON(JsonMessage,flag );                                                                      
                   }
           String fullName=Hl7msg.pid.patientName;
           if(FullName!=Null && FullName!='')
           {    
               try{
                   List<String> listName=FullName.split('\\^');
                   if(ListName.size()>0){
                       RelatedResults.PID_Patient_Last_Name__c=ListName[0];}
                   if(ListName.size()>1){
                       RelatedResults.PID_Patient_First_Name__c=ListName[1];}
                   if(ListName.size()>2){
                       RelatedResults.PID_Patient_Middle_Name__c=ListName[2];}
                   if(ListName.size()>3){
                       RelatedResults.PID_Patient_Salutation__c=ListName[3];}
               }
            catch(ListException e){
                ExceptionLog.logError(e);
            }
            }
           String fullAddress=Hl7msg.pid.patientAddress;
           
           if(FullAddress!=Null && FullAddress!='')
           {    
               try{                   
                   List<String> listAddress=FullAddress.split('\\^');
                   if(ListAddress.size()>0){
                       RelatedResults.PID_Patient_Street_Address__c=ListAddress[0];}
                   if(ListAddress.size()>1){
                       RelatedResults.PID_Address2__c=ListAddress[1];}
                   if(ListAddress.size()>2){
                       RelatedResults.PID_City__c=ListAddress[2];}
                   if(ListAddress.size()>3){
                       RelatedResults.PID_State__c=ListAddress[3];}
                   if(ListAddress.size()>4){
                       RelatedResults.PID_Zip_Code__c=ListAddress[4];}                       
               }
               catch(ListException e){
                ExceptionLog.logError(e);
            }
           }        
        RelatedResults.PID_SSN_Patient__c=Hl7msg.pid.ssnPatient;
     
           //insert RelatedResults;   
        DMLManager.insertAsUser(RelatedResults);
           
  
    }      
}