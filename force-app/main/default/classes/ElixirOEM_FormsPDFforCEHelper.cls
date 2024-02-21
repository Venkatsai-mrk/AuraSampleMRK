public with sharing class ElixirOEM_FormsPDFforCEHelper {
    public String renderedPage { get; set; }
    public String accId { get; set; }
    public String formName { get; set; }
    public String formuniqueID { get; set; }
    public String changedFormName { get; set; }
    public   Object dummyString;
    public static  Map<Decimal,String> colMap {get;set;}
    public static  String category {get;set;}
    public List<sObjectSchemaWrapper> cssRecords {get;set;}
    public List<Medical_Examination__c> vitalData{get; set;}
    public List<Medical_Examination__c> allergyData{get; set;}
    public List<Prescription_Order__c> medicationData{get;set;}
    public List<Medical_Examination__c> glucoseObservation{get;set;}
    public List<Form_Value__c> approvalList{get;set;}
    public Date currentDate {get;set;}
    public Map<Id,String> imageData {get;set;}
    public ElixirOEM_FormsPDFforCEHelper(){  
        renderedPage='Constructor';
        system.debug('dummy string '+dummyString);
        //   init();
        //Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + changedFormName + '.pdf');    
    }
    
    public void setdummyString(Object value) {
        System.debug('Only value  '+value);
        if(String.isNotBlank(String.valueOf(value))){
            formuniqueID   = ((String)value).split('&')[0];
            formName = ((String)value).split('&')[1];
            changedFormName   = ((String)value).split('&')[2];
            accId = ((String)value).split('&')[3];
            
            try{
                //init();
            }
            catch (Exception e){
                System.debug('error as data is incorrect!');
            }
        }
    }
    public class CareEpisodePDFWrapper {
        public String fName {get;set;}
        public String fCName {get;set;}
        public String formUniqueID {get;set;}
        public String accountRecordID {get;set;}
        public String joinedValue {get;set;}
    }
    public Object getdummyString() {
        return this.dummyString;
    }
    public void init(){
        renderedPage = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxx';
        try{
        //    try{
        currentDate = System.today();
        /*  String accId = ApexPages.currentPage().getParameters().get('aId');
String formName = ApexPages.currentPage().getParameters().get('fName');
string formuniqueID = ApexPages.currentPage().getParameters().get('fId');
String changedFormName = ApexPages.currentPage().getParameters().get('fCName'); */
        // RecordTypeName - RT name : Changed Form Nae = Chaned Form Name // Type of Object 1
        system.debug('meghna test');
        system.debug(accId);
        system.debug(formName);
        system.debug(formuniqueID);
        system.debug(changedFormName);
        this.changedFormName = changedFormName;
        glucoseObservation = [SELECT Id,Intervention__c,Type_of_check__c,
                              Note__c,Glucose_Reading__c
                              FROM Medical_Examination__c where  Account__c=:accId and
                              RecordType.developerName = 'Glucose' WITH SECURITY_ENFORCED
                              order by CreatedDate asc];
        allergyData = [SELECT Substance__c,Substance_Code__c,Reaction__c
                       FROM Medical_Examination__c 
                       where  Account__c = : accId and RecordType.DeveloperName= 'Allergy' 
                       AND (Substance__c!=NULL OR Substance_Code__c!=NULL OR Reaction__c!=NULL)
                       WITH SECURITY_ENFORCED];          
        vitalData =  [select id, Blood_Pressure_Systolic__c,Blood_Pressure_diasystolic__c,Temperature__c,  
                      Pulse__c, createdDate, /*HealthCloudGA__Respiration__c*/
                      Oxygen_Saturation__c FROM Medical_Examination__c where
                      Account__c=:accId and  RecordType.DeveloperName='Vital_Sign' 
                      AND Blood_Pressure_Systolic__c!=null WITH SECURITY_ENFORCED];// And createdDate>TODAY and createdDate<TOMORROW];
        medicationData = [SELECT Drug_Name__c,Id,Number_of_Times_Days_Weeks__c,Reason_new__c,
                          Ferquency__c,Route_New__c,Reason__c,Type__c,Dosage_Form__c,(select Strength__c,Dosage_Instruction__c,Repeat__c
                                                                                      from Frequency__r)
                          FROM Prescription_Order__c where  Account__c=:accId
                          WITH SECURITY_ENFORCED
                          order by CreatedDate asc limit 110];
        Set<Id> sectionsIds = new Set<Id>();
        FormUpdateClass.FormSchema schemaVar =  FormUpdateClass.buildForm(formName,accID,formuniqueID);
        List<Object_1_css__c> cssRecords1 = schemaVar.cssRecords;
        List<FormRenderUtility.FieldSchema> allFields = schemaVar.allFields;
        Map<String,FormRenderUtility.FieldSchema> allFieldsMap = new Map<String,FormRenderUtility.FieldSchema>();
        // IMAGE HANDLING
        Map<String,List<ContentVersion>> versionBasedOnUniqueName = schemaVar.versionBasedOnUniqueName;
        // END
        for(FormRenderUtility.FieldSchema rec :allFields){
            allFieldsMap.put(rec.apiName, rec);
        }
        
        List<sObjectSchemaWrapper> cssRecords = (List<sObjectSchemaWrapper>) JSON.deserialize(JSON.serialize(cssRecords1),List<sObjectSchemaWrapper>.class);
        
        Integer parentRow = 0;
        //AutoText - START
        List<Form_Value__c> autoTexts = [SELECT Id, Blue_Print__c, Section_Number__c, Is_AutoText__c, Auto_Text__c FROM Form_Value__c
                                         WHERE Is_AutoText__c = true AND Form_Id__c=:formuniqueID
                                         AND Account__c=:accId WITH SECURITY_ENFORCED];
        Map<Decimal,String> texts = new Map<Decimal,String>();
        if(autoTexts!=null && autoTexts.size()>0){
            for(Form_Value__c autoText :autoTexts){
                texts.put(autoText.Section_Number__c, autoText.Auto_Text__c);
            }
        }
        //AutoText - END      
        for(Object_1_css__c objRec :cssRecords1){
            sectionsIds.add(objRec.Id);
            cssRecords[parentRow].sObjectRefrence = objRec;
            //AutoText - START
            Decimal secNo = objRec.Section_Number__c;
            if(texts.containsKey(secNo)){
                String textForAuto  = texts.get(secNo);
                textForAuto = textForAuto.replaceAll('[{]', '');
                textForAuto = textForAuto.replaceAll('[}]', '');
                cssRecords[parentRow].AutoText = textForAuto;
            }
            //AutoText - END
            if(objRec.Object_1_css__r!=null){
                system.debug(objRec.Object_1_css__r.size());
                for(Object_1_css__c childRec :objRec.Object_1_css__r){
                    if(cssRecords[parentRow].Object_1_css_r == null){
                        cssRecords[parentRow].Object_1_css_r = new List<Object_1_css_r>();
                    }
                    Object_1_css_r childRef = new Object_1_css_r();
                    childRef.sObjectChildRefrence = childRec;
                    cssRecords[parentRow].Object_1_css_r.add(childRef);
                }  
            }
            parentRow++;
        }
        system.debug('cssRecords1 '+cssRecords);
        Map<String, sObject> objToValues = schemaVar.objToValues;
        Map<Decimal, Map<Decimal, List<Form_Value__c>>> sec_row_columns = schemaVar.sec_row_columns;
        String labelstoShow = schemaVar.labelstoShow;
        system.debug('objToValues '+objToValues);
        Map<String,Map<String,String>> obj;
        if(String.isNotBlank(labelstoShow)){
            labelstoShow = labelstoShow.replaceAll('&quot;_reg_','"');
            system.debug('labelstoShow '+labelstoShow);
            obj = (Map<String,Map<String,String>>) JSON.deserialize(labelstoShow,Map<String,Map<String,String>>.class);
        }
        colMap = new Map<Decimal,String>{ 1  => 'width:676px;vertical-align: top;',
            2 => 'width:338px;vertical-align: top;',
            3 => 'width:202px;vertical-align: top;',
            4 => 'width:169px;vertical-align: top;', //25 - 3/12
            6 => 'width:114px;vertical-align: top;'  }; //17 -- 2/12
                if(cssRecords.size()>0 && cssRecords!=null){
                    for(sObjectSchemaWrapper record : cssRecords){  
                        if(String.isNotBlank(record.sObjectRefrence.ElixirSuite__Indentation__c)){
                            String indent = record.sObjectRefrence.ElixirSuite__Indentation__c;
                            if(indent.toLowerCase() == 'heading'){
                                record.sObjectRefrence.ElixirSuite__Css__c += ';margin-left:25px';
                            }
                            else if(indent.toLowerCase() == 'subheading'){
                                record.sObjectRefrence.ElixirSuite__Css__c += ';margin-left:50px';
                            }
                        }
                        if(String.isNotBlank(record.sObjectRefrence.ElixirSuite__Form_Category__c)){
                            category = record.sObjectRefrence.ElixirSuite__Form_Category__c;
                        }    
                        List<Object_1_css_r> section = record.Object_1_css_r;
                        Decimal columnsInSection = record.sObjectRefrence.Columns_In_Section__c;
                        Integer oldRowNumber = -1;
                        Integer oldRow = 0;
                        if(section!=null && section.size()>0){          
                            for(Integer rowParent=0 ;rowParent<section.size(); rowParent++){
                                system.debug('rowParent '+rowParent);
                                Boolean escapeFToFpass = false;
                                //Object - Form values - START
                                //Default values - END
                                //FORM LABEL - START
                                String objectName = section[rowParent].sObjectChildRefrence.Object_Name__c;
                                String fieldName = section[rowParent].sObjectChildRefrence.Field_Name__c;
                                System.debug('**' +obj);
                                System.debug('***'+objectName);
                                if(obj!=null && obj.size()> 0 && String.isNotBlank(objectName) && String.isNotBlank(String.valueOf(section[rowParent].sObjectChildRefrence)) &&
                                   obj.get(objectName)!=null && obj.get(objectName).size()>0){
                                       if(String.isNotBlank(obj.get(objectName).get(fieldName))){
                                           section[rowParent].sObjectChildRefrence.ElixirSuite__Field_Label_Long__c = obj.get(objectName).get(fieldName);
                                       }
                                   }
                                //FORM LABEL - END
                                //CONSENT FORM - START
                                if(sec_row_columns!=null && sec_row_columns.size()>0){
                                    Decimal rowNumber = section[rowParent].sObjectChildRefrence.ElixirSuite__Row__c;
                                    Decimal columnNo = section[rowParent].sObjectChildRefrence.ElixirSuite__Column__c;
                                    Boolean isConsent = section[rowParent].sObjectChildRefrence.ElixirSuite__Is_Consent__c;
                                    Decimal sectionNo = record.sObjectRefrence.ElixirSuite__Section_Number__c;
                                    
                                    if(isConsent && String.isNotBlank(String.valueOf(sectionNo))){
                                        if(sec_row_columns.get(sectionNo).size()>0 && sec_row_columns.get(sectionNo)!=null){
                                            if(sec_row_columns.get(sectionNo).get(rowNumber).size()>0){
                                                List<Form_Value__c> cols = sec_row_columns.get(sectionNo).get(rowNumber);
                                                for(Form_Value__c z : cols){
                                                    if(z.ElixirSuite__Column_Number__c == columnNo){
                                                        section[rowParent].sObjectChildRefrence.ElixirSuite__Default_text__c = z.ElixirSuite__Consent_Text__c;
                                                    }
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                //CONSENT FORM - END
                                
                                
                                Integer row = rowParent;
                                Integer rowAdd = 0;
                                for(Integer i=0;i<columnsInSection;i++){
                                    if(section.size()<=rowParent+i || section[rowParent+i]==null){
                                        system.debug('SAVIOUR');
                                        continue; // Saviour
                                    }
                                    system.debug('OUTSIDE SAVIOUR');
                                    //Object - Form values - END
                                    
                                    Decimal rowNumber = section[rowParent+i].sObjectChildRefrence.ElixirSuite__Row__c;
                                    if(rowNumber ==0){
                                        rowAdd++;
                                        continue;
                                    }
                                    if(section[row].Columns==null){
                                        section[row].Columns = new List<Columns_Z>();
                                    }
                                    FormRenderUtility.FieldSchema fetchField;
                                    if(section[rowParent+i].sObjectChildRefrence.ElixirSuite__Field_Label_Long__c != 'nbsp' && String.isNotBlank(section[rowParent+i].sObjectChildRefrence.ElixirSuite__Field_Name__c)){
                                        String fieldNameFromObj = section[rowParent+i].sObjectChildRefrence.ElixirSuite__Field_Name__c;
                                        if(allFieldsMap.containsKey(fieldNameFromObj)){
                                            fetchField = allFieldsMap.get(fieldNameFromObj);
                                        }
                                    }
                                    
                                    //CONSENT FORM - START
                                    if(sec_row_columns.size()>0 && sec_row_columns!=null){
                                        rowNumber = section[rowParent + i].sObjectChildRefrence.ElixirSuite__Row__c; // can take a new variable
                                        Decimal columnNo = section[rowParent + i].sObjectChildRefrence.ElixirSuite__Column__c;
                                        Boolean isConsent = section[rowParent + i].sObjectChildRefrence.ElixirSuite__Is_Consent__c;
                                        Decimal sectionNo = record.sObjectRefrence.ElixirSuite__Section_Number__c;
                                        if(isConsent && String.isNotBlank(String.valueOf(sectionNo))){
                                            if(sec_row_columns.get(sectionNo).size()>0 && sec_row_columns.get(sectionNo)!=null){
                                                if(sec_row_columns.get(sectionNo).get(rowNumber).size()>0){
                                                    List<Form_Value__c> cols = sec_row_columns.get(sectionNo).get(rowNumber);
                                                    for(Form_Value__c z : cols){
                                                        if(z.ElixirSuite__Column_Number__c == columnNo){
                                                            system.debug(z.ElixirSuite__Consent_Text__c);
                                                            section[rowParent+i].sObjectChildRefrence.ElixirSuite__Default_text__c = z.ElixirSuite__Consent_Text__c;
                                                        }
                                                    }
                                                }
                                                
                                            }
                                        }
                                    }
                                    //CONSENT FORM - END
                                    //FORM LABEL - START
                                    system.debug('LABELLING');
                                    
                                    objectName =  section[rowParent+i].sObjectChildRefrence.ElixirSuite__Object_Name__c; // Duplicate var
                                    fieldName = section[rowParent+i].sObjectChildRefrence.ElixirSuite__Field_Name__c; // Duplicate var            
                                    
                                    if(obj!=null && String.isNotBlank(objectName) && String.isNotBlank(String.valueOf(section[rowParent+i].sObjectChildRefrence)) &&
                                       obj.get(objectName)!=null){
                                           system.debug('objectName**' +obj.get(objectName));
                                           if(obj.get(objectName).get(fieldName)!=null){
                                               system.debug('fieldName**' +obj.get(objectName).get(fieldName));
                                               section[rowParent+i].sObjectChildRefrence.ElixirSuite__Field_Label_Long__c = obj.get(objectName).get(fieldName);
                                           }
                                       }
                                    //FORM LABEL - END
                                    
                                    if(fetchField != null){
                                        String dataTypeValue = fetchField.dataType.toUpperCase();
                                        String formDataType = section[rowParent+i].sObjectChildRefrence.ElixirSuite__Form_Data_Type__c;
                                        if(dataTypeValue == 'PICKLIST' && formDataType != 'Radio'){
                                            section[rowParent+i].picklistValuesText = new List<String>();
                                            section[rowParent+i].picklistValuesText = fetchField.picklistValues;
                                        }
                                        else if(formDataType == 'Radio'){
                                            section[rowParent+i].PicklistValues = new List<PicklistValues>();
                                            List<String> picklistValues = fetchField.picklistValues;
                                            for(String pickValue : picklistValues){
                                                PicklistValues toAddPckLst = new PicklistValues();
                                                toAddPckLst.value = pickValue;
                                                toAddPckLst.label = pickValue;
                                                section[rowParent+i].PicklistValues.add(toAddPckLst);
                                            }
                                        }
                                        else if(dataTypeValue == 'MULTIPICKLIST'){
                                            section[rowParent+i].PicklistValues = new List<PicklistValues>();
                                            List<String> picklistValues = fetchField.picklistValues;
                                            for(String pickValue : picklistValues){
                                                PicklistValues toAddPckLst = new PicklistValues();
                                                toAddPckLst.value = pickValue;
                                                toAddPckLst.label = pickValue;
                                                section[rowParent+i].PicklistValues.add(toAddPckLst);
                                            }
                                            section[rowParent+i].values = new List<String>();
                                            
                                        }
                                        String objName = section[rowParent+i].sObjectChildRefrence.ElixirSuite__Object_Name__c;
                                        fieldName = section[rowParent+i].sObjectChildRefrence.ElixirSuite__Field_Name__c; // duplicate variable
                                        system.debug('obj'+objName);
                                        system.debug('fld'+fieldName);
                                        if(objToValues.get(objName)!=null && objToValues.get(objName).get(fieldName)!=null){
                                            Object sObjValue = objToValues.get(objName).get(fieldName);
                                            String objValues = String.valueOf(sObjValue);
                                            system.debug('sObjValue'+sObjValue);
                                            if(dataTypeValue == 'MULTIPICKLIST'){
                                                List<String> values = new List<String>();
                                                values = objValues.split( ';');                                                  
                                                section[rowParent+i].values = values;
                                            }else{
                                                section[rowParent+i].value = objValues;
                                            }
                                        }
                                    }    
                                    Integer currentRow = -1;
                                    system.debug(section[row+i]);
                                    if(section[row+i] != null
                                       && (currentRow == -1 || currentRow == section[row+i].sObjectChildRefrence.Row__c)){
                                           currentRow = Integer.valueOf(section[row+i].sObjectChildRefrence.Row__c);
                                           //Handling NO Label - START
                                           if(section[row+i].sObjectChildRefrence.No_Label__c){
                                               section[row+i].sObjectChildRefrence.Field_Label_Long__c = '';
                                           }
                                           //Handling NO Label - END
                                           section[row+i].colsize = fetchColSize(columnsInSection, colMap);
                                           section[row].Columns.add((Columns_Z) JSON.deserialize(JSON.serialize(section[row+i]), Columns_Z.class));
                                           Integer columnsSize = section[row].Columns.size();
                                           system.debug(columnsSize);
                                           section[row].Columns[columnsSize-1].sObjectColumnRefrence = section[row+i].sObjectChildRefrence;
                                           rowAdd++;
                                       }
                                }
                                rowParent = rowParent + rowAdd - 1;
                            }
                        }
                    }
                }
        
        attachImageData(cssRecords,versionBasedOnUniqueName);
        imgData(sectionsIds, formUniqueId);
        this.cssRecords = cssRecords;
        List<Form_Value__c> approvedValues = new List<Form_Value__c>();
        SObjectAccessDecision decisionApproved = Security.stripInaccessible(AccessType.READABLE,
                                                                            [SELECT Id, ElixirSuite__Is_External_Signature__c,Account__c, Is_Approver__c, Date_Of_Approval__c,
                                                                             User__r.Name, Approval_Level__c, Comment__c, Form_Name__c, Approved_Signature__c,
                                                                             Signed_Patient__r.Name,ElixirSuite__Signed_Patient__c FROM Form_Value__c
                                                                             WHERE Is_Approver__c=true AND Form_Id__c= :formuniqueID
                                                                             ORDER BY Approval_Level__c]);
        approvedValues = decisionApproved.getRecords();
        this.approvalList = approvedValues;
        }catch(Exception e){
        }
        //  }catch(Exception e){
        //    ExceptionLog.logError(e);
        //     }
    }
    public void imgData(Set<Id> sectionsIds, String formId){
        imageData = new Map<Id,String>();
        List<ContentVersion> documents = [SELECT Id, ContentDocumentId,Form_css_id__c
        FROM ContentVersion 
        WHERE Form_Id__c= :formId AND Form_css_id__c IN :sectionsIds WITH SECURITY_ENFORCED];
        for(ContentVersion version :documents){
            Blob data = version.VersionData;
            String paramValue = EncodingUtil.base64Encode(data);
            imageData.put(version.Form_css_id__c, 'data:image/png;base64,'+paramValue);
        }
    }
    public void attachImageData(List<sObjectSchemaWrapper> cssRecords, Map<String,List<ContentVersion>> versionBasedOnUniqueName){
        for(sObjectSchemaWrapper objInstance : cssRecords){
            if(objInstance.Object_1_css_r!=null){
                for(Object_1_css_r childInstance : objInstance.Object_1_css_r){
                    if(childInstance.Columns!=null){
                        for(Columns_Z nestedchild : childInstance.Columns){
                            if(String.isNotBlank(nestedchild.sObjectColumnRefrence.ElixirSuite__IMG_Default_Button_Label__c)){
                                //    System.debug('77 '+nestedchild.sObjectColumnRefrence.ElixirSuite__IMG_Default_Button_Label__c);
                                //    System.debug('map therre '+versionBasedOnUniqueName.get(nestedchild.sObjectColumnRefrence.ElixirSuite__IMG_Default_Button_Label__c));
                                List<ContentVersion> uploadedFiles =  versionBasedOnUniqueName.get(nestedchild.sObjectColumnRefrence.ElixirSuite__IMG_Default_Button_Label__c);
                                List<ImageFileWrapper> imgLst = new List<ImageFileWrapper>();
                                if(uploadedFiles!=null){
                                    for(ContentVersion imgFileInstance : uploadedFiles){
                                        ImageFileWrapper imgSingleObjInstance = new ImageFileWrapper();
                                        imgSingleObjInstance.recordContentVersionId = imgFileInstance.ContentDocumentId;
                                        imgSingleObjInstance.nameOfImageFile  = imgFileInstance.ElixirSuite__File_Name__c;
                                        imgLst.add(imgSingleObjInstance);
                                    }
                                    nestedchild.imgFileDemographics = imgLst;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public String fetchColSize(Decimal columnsInSection,Map<Decimal,String> colMap){
        
        if(colMap.get(columnsInSection)!=null){
            return colMap.get(columnsInSection);
        }
        else {
            return '6';
        }
        
    }
    public class sObjectSchemaWrapper {
        public  ElixirSuite__Object_1_css__c sObjectRefrence {get;set;}      
        public String autoText {get;set;}
        public List<Object_1_css_r> Object_1_css_r {get;set;}      
        
    }
    
    public class Object_1_css_r {
        public  ElixirSuite__Object_1_css__c sObjectChildRefrence {get;set;}            
        public List<Columns_Z> Columns {get;set;}      
        public List<String> PicklistValuesText {get;set;}      
        public List<PicklistValues> PicklistValues {get;set;}      
        public List<String> values {get;set;}      
        public String value {get;set;}      
        public String colsize {get;set;}      
    }
    
    public class Columns {
        String colDem {get;set;}      
    }
    
    public class PicklistValues {
        public String value {get;set;}      
        public String label {get;set;}      
    }
    
    public class Columns_Z {
        public  ElixirSuite__Object_1_css__c sObjectColumnRefrence {get;set;}        
        public List<Columns> Columns {get;set;}      
        public List<String> PicklistValuesText {get;set;}      
        public List<PicklistValues> PicklistValues {get;set;}      
        public List<String> values {get;set;}      
        public String value {get;set;}    
        public List<ImageFileWrapper> imgFileDemographics {get;set;}  
        public String colsize {get;set;}      
    }
    public class ImageFileWrapper {
        public String recordContentVersionId {get;set;}    
        public String nameOfImageFile {get;set;}  
        public String nameOfImageFileAsLabel {get;set;}  
    }
}