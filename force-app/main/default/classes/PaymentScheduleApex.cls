/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-21-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing  class PaymentScheduleApex {
    @AuraEnabled
    public static void fetchData( string accId){
        
        
    }
    @AuraEnabled
    public static List<opportunity> FetchOppdataForPayment( string opid ){
        //Query payment responsibility
        //Now Query Products Total and Initial Agreement Amount
        List<Opportunity> Opplist=new List<Opportunity>();
        if(Schema.sobjecttype.opportunity.isAccessible()
                          && Schema.sObjectType.opportunity.fields.Instalments_by_Frequency__c.isAccessible()
           && Schema.sObjectType.opportunity.fields.Patient_Responsibility__c.isAccessible() && Schema.sObjectType.opportunity.fields.Initial_Agreement_Amount__c.isAccessible()){ 
        Opplist=[select id,Instalments_by_Frequency__c,Patient_Responsibility__c,ElixirSuite__Initial_Agreement_Amount__c,Payment_Amount_curr__c,Payment_Date__c,Payment_Frequency__c,LOC__c from opportunity where id=:opid];
        }
            for(Opportunity o:Opplist){
            if(o.LOC__c=='Sober Living'){
                 o.addError('For Sober Living Level of Care, the Payment Schedule can not be Generated');
            }
        }
        return Opplist;
    }
    @AuraEnabled
    public static Account getOutstanding(String accountId){
        Account patient = new Account();
        patient = [SELECT id , 	Name,	Age__c , AccountNumber,	First_Name__c,	Gender__c,	Last_Name__c,	MRN_Number__c,	Outstanding_Amount__c,
                   birthdate__c,	Phone,	Unallocated_Amount__c,Profile_Picture__c,Total_Patient_Responsibility__c
                   FROM  Account where id=: accountId 
                   WITH SECURITY_ENFORCED
                   limit 1];
       
        return patient ;
    }
    
     @AuraEnabled
    public static License_Class LicensBasdPermission()
    {
        Id currentUid = UserInfo.getUserId();
        String AvailLicense = [Select Id,ElixirSuite__License_Type__c,Username,Name
         from User 
         where Id =:currentUid
         WITH SECURITY_ENFORCED].ElixirSuite__License_Type__c;
        List<String> lst_availLicense = new List<String>();
        lst_availLicense = AvailLicense.split(';');
        License_Class lCls = new License_Class();
        for(String str : lst_availLicense)
        {
            if(str == 'Elixir EHR')
            {
                lCls.isEhr = True;
                continue;
            }
           
            if(str == 'Elixir Contact Center')
            {
                lCls.isContactCenter = True;
                continue;
            }
             
            if(str == 'Elixir RCM')
            {
                lCls.isRcm = True;
                continue;
            }
        }
        return lCls;
    }
    public class License_Class
    {
        @AuraEnabled public Boolean isEhr;
        @AuraEnabled public Boolean isRcm;
        @AuraEnabled public Boolean isContactCenter;
    }
    
    
    @AuraEnabled
    public static void saveData(string ids  , String scheduleData , String totalPlanAmount , String frequencyRate , String installmentAmt , Boolean isCheck){
        system.debug('recordId'+totalPlanAmount);
        system.debug('recordId'+frequencyRate);
        system.debug('recordId'+installmentAmt);
        system.debug('recordId'+scheduleData);
        List<Payment_Schedule__c> allSchedules = new List<Payment_Schedule__c>();
        Id masterRecordTypeId = Schema.SObjectType.Payment_Schedule__c.getRecordTypeInfosByDeveloperName().get('Master_Payment_Schedule').getRecordTypeId();
        Id childRecordTypeId = Schema.SObjectType.Payment_Schedule__c.getRecordTypeInfosByDeveloperName().get('Sub_Payment_Schedule').getRecordTypeId();
        
        Map<String, Object> jsonSchedule =(Map<String, Object>)JSON.deserializeUntyped(scheduleData);
        List<Object> listOfPatSchedules = (List<Object>) jsonSchedule.get('keysToSaveSchedule');
        
        Payment_Schedule__c masterSched = new Payment_Schedule__c();
        masterSched.Installment_Amount__c = Decimal.valueOf(installmentAmt) ;
        masterSched.Pay_Frequency__c = frequencyRate;
        masterSched.Net_Balance__c = Decimal.valueOf(totalPlanAmount);
        masterSched.Remaining_Amount__c = Decimal.valueOf(totalPlanAmount);
        masterSched.RecordTypeId = masterRecordTypeId;
        masterSched.Payment_Status__c = 'Active';
        System.debug('isCheck*****'+isCheck); 
        if(isCheck == true)
        {
            masterSched.Status__c = 'Active';
        }
        else
        {
            masterSched.Status__c = 'Inactive';
        }
        
        masterSched.Account__c = ids ;
        if(Schema.sObjectType.Payment_Schedule__c.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.Installment_Amount__c.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.Pay_Frequency__c.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.Net_Balance__c.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.Remaining_Amount__c.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.RecordTypeId.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.Account__c.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.Status__c.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.Payment_Status__c.isCreateable()){
        insert masterSched;
            }
    
        
        system.debug('bsjqn' + listOfPatSchedules);
        
        for(Object payScheded : listOfPatSchedules){
            system.debug('wdb' + payScheded);
             Payment_Schedule__c paySched = new Payment_Schedule__c();
            Map<String, Object> mapofSchedules = (Map<String, Object>)payScheded;
            system.debug('the map is' + mapofSchedules);
            paySched.Installment_Amount__c = Decimal.valueOf(String.valueOf(mapofSchedules.get('instAmt'))); 
            paySched.Net_Balance__c = Decimal.valueOf(totalPlanAmount);
            paySched.Payment_Schedule__c = masterSched.id ; 
            paySched.Remaining_Amount__c = Decimal.valueOf(String.valueOf(mapofSchedules.get('instAmt')));
            paySched.Account__c = ids ;
            paySched.RecordTypeId = childRecordTypeId;
            paySched.ElixirSuite__Payment_Status__c = 'Active';
            if(isCheck == true)
            {
                paySched.Status__c = 'Active';
            }
            else
            {
                paySched.Status__c = 'Inactive';
            }
            if(String.isNotBlank((String)mapofSchedules.get('DD'))){
                List<String> dateSplit = (List<String>) String.valueOf(mapofSchedules.get('DD')).split('/');
                system.debug('dateSplit' +dateSplit);
                if(dateSplit.size() > 0)
                {
                    //Added by sagili siva
                    integer myIntDate=integer.valueOf(dateSplit[1]);
                    integer myIntMonth=integer.valueOf(dateSplit[0]);
                    integer myIntYear=integer.valueOf(dateSplit[2]);
                    Date mydate=date.newInstance(myIntYear, myIntMonth, myIntDate);
                   //Commented by sagili siva because it accepting only MM/DD/YYYY values
                  // Date mydate = date.parse(dateSplit[0]+'/'+dateSplit[1]+'/'+dateSplit[2]);
                    system.debug('mydate' +mydate);
                	paySched.ElixirSuite__Due_Date__c = mydate;
                }
               
            }
            allSchedules.add(paySched);
        }
        system.debug('the list is' + allSchedules);
        if(Schema.sObjectType.Payment_Schedule__c.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.Installment_Amount__c.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.Pay_Frequency__c.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.Net_Balance__c.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.Remaining_Amount__c.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.RecordTypeId.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.ElixirSuite__Due_Date__c.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.Status__c.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.Account__c.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.Payment_Schedule__c.isCreateable() &&
        Schema.sObjectType.Payment_Schedule__c.fields.ElixirSuite__Payment_Status__c.isCreateable()){
        insert allSchedules;
         }
    }
        
        //  system.debug('abc'+scheduleData);
        /*   system.debug('recordId'+ids);

List<Opportunity> OppoList=[select id,Installments_Per_Month__c,Patient_Responsibility__c,Initial_Agreement_Amount__c,Products_Total__c,Payment_Amount__c,Payment_Date__c,Payment_Frequency__c,LOC__c,AVSFQB__Total_Amount__c from Opportunity where id=:ids];
// Change here to change between Patient Responsibility vs QuickBook Total Amount
// Change here between patient responsibility vs Products total
Decimal remainingAmount=(OppoList[0].Products_Total__c-OppoList[0].Initial_Agreement_Amount__c); //Change Patient_Responsibility__c from AVSFQB__Total_Amount__c
//Change Products total from Patient_Responsibility__c
Decimal TotalDuration=remainingAmount/OppoList[0].Installments_Per_Month__c;
integer modulo=math.mod(remainingAmount.intValue(), OppoList[0].Installments_Per_Month__c.intvalue());
integer iteration=TotalDuration.round(system.RoundingMode.FLOOR).intValue();
integer iteration1=TotalDuration.round(system.RoundingMode.CEILING).intValue();

//TotalDuration
system.debug('TotalTime'+TotalDuration);

List<Payment_Schedule__c> PaymentList=[select id,Admission__c,Due_Date__c,Installment_Amount__c,LOC__c,Status__c from Payment_Schedule__c where Admission__c =:ids];
system.debug('paymentlist'+PaymentList);
List<Payment_Schedule__c> PaymentListUpdate=new List<Payment_Schedule__c>();

if(PaymentList.size()>0){
for(opportunity o: OppoList){
o.addError('Payment is already scheduled for this patient' );

}

}
else { 
if(OppoList[0].Initial_Agreement_Amount__c!=0){
Payment_schedule__c p=new Payment_schedule__c();
p.Admission__c=OppoList[0].id;
p.Installment_Amount__c=OppoList[0].Initial_Agreement_Amount__c;
p.Due_Date__c=OppoList[0].payment_Date__c;
p.LOC__c=OppoList[0].LOC__c;
p.Status__c='Paid';
p.Plan_description__c='Upfront Collected By Admission';
PaymentListUpdate.add(p);
}
for(Opportunity o:OppoList){

system.debug('inside for opportunity');
for(Integer i=1;i<=iteration;i+=1){
system.debug('inside iteration');
if(o.Payment_Frequency__c=='Daily'){

system.debug('isnide daily if');
Payment_Schedule__c p=new Payment_Schedule__c();
p.Admission__c=o.id;
p.Due_Date__c=system.today().addDays(i);
p.Installment_Amount__c=o.Installments_Per_Month__c;
p.LOC__c=o.LOC__c;
p.Status__c='Active';

PaymentListUpdate.add(p);
}
if(o.Payment_Frequency__c=='Weekly'){

system.debug('isnide Weekly if');
Payment_Schedule__c p=new Payment_Schedule__c();
p.Admission__c=o.id;
p.Due_Date__c=system.today().addDays(7*i);
p.Installment_Amount__c=o.Installments_Per_Month__c;
p.LOC__c=o.LOC__c;
p.Status__c='Active';
PaymentListUpdate.add(p);
}
if(o.Payment_Frequency__c=='Monthly'){

system.debug('isnide Monthly if');
Payment_Schedule__c p=new Payment_Schedule__c();
p.Admission__c=o.id;
p.Due_Date__c=system.today().addDays(30*i);
p.Installment_Amount__c=o.Installments_Per_Month__c;
p.LOC__c=o.LOC__c;
p.Status__c='Active';
PaymentListUpdate.add(p);

}
}
if(modulo!=0){
Decimal residue=remainingAmount-iteration*o.Installments_Per_Month__c;           
Payment_Schedule__c p=new Payment_Schedule__c();

if(o.Payment_Frequency__c=='Daily'){
p.Due_Date__c=system.today().addDays(iteration1);  
}
if(o.Payment_Frequency__c=='Weekly'){
p.Due_Date__c=system.today().addDays(iteration1*7); 
}
if(o.Payment_Frequency__c=='Monthly'){
p.Due_Date__c=system.today().addDays(iteration1*30);   
}
p.Admission__c=o.id;
p.LOC__c=o.LOC__c;
p.Status__c='Active';
p.Installment_Amount__c=residue;
p.Plan_description__c='N/A';
PaymentListUpdate.add(p);
}
// system.debug('Payment Schedule'+PaymentListUpdate);
if(PaymentListUpdate.size()>0){
insert PaymentListUpdate;
}
}
} 
}*/
 }
    
