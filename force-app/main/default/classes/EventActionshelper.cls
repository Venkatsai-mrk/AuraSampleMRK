public with sharing class EventActionshelper {
    public static void myaction(list<Event> Evlist){
        Set<Id> accountId = new Set<Id>();
        Set<String> contId = new Set<String>();
        for(Event acc:Evlist){	
            if(acc.WhatId != null && acc.ElixirSuite__Practitioner__c != null){
                accountId.add(acc.WhatId);
                contId.add(acc.ElixirSuite__Practitioner__c);
            }
        }
        List<Account> accounts = [SELECT Id, ElixirSuite__Time_Zone__c FROM Account WHERE Id IN:accountId WITH SECURITY_ENFORCED];
        Map<Id,Account> accountsMap = new Map<Id,Account>(accounts);        
        List<Contact> contacts =[SELECT Id,ElixirSuite__Time_Zone__c FROM Contact WHERE Id IN:contId WITH SECURITY_ENFORCED];
        Map<Id,Contact> contactsMap = new Map<Id,Contact>(contacts);
        
        for(Event evt:Evlist)
        { 
            if(accountsMap.containsKey(evt.WhatId)){  
                Account acc = accountsMap.get(evt.WhatId);
                evt.ElixirSuite__Patient_s_Time_Zone__c = acc.ElixirSuite__Time_Zone__c;
                evt.ElixirSuite__Patient_Start_TIme__c = displayZone(evt.StartDateTime, acc.ElixirSuite__Time_Zone__c);
                evt.ElixirSuite__Patient_End_Time__c = displayZone(evt.EndDate, acc.ElixirSuite__Time_Zone__c);
            }
            if(contactsMap.containsKey(evt.ElixirSuite__Practitioner__c)){
                Contact cont = contactsMap.get(evt.ElixirSuite__Practitioner__c);
                evt.ElixirSuite__Practitioner_s_Time_Zone__c = cont.ElixirSuite__Time_Zone__c;
                evt.ElixirSuite__Practitioner_Start_Time__c = displayZone(evt.StartDateTime, cont.ElixirSuite__Time_Zone__c);
                evt.ElixirSuite__Practitioner_End_Time__c = displayZone(evt.EndDate, cont.ElixirSuite__Time_Zone__c);
            }
        }
    }
    public static String displayZone(Datetime convertData, String zone){
        if(convertData==null || String.isBlank(zone)){
            return '';
        }
        String data = String.valueOf(convertData);
        Datetime dt = convertData;
        TimeZone target = TimeZone.getTimeZone(zone);        
        //return target.format('yyyy-MM-dd HH:ss a z', target.getID()) + ' ' + zone;
        return dt.format('yyyy-MM-dd HH:mm a z',target.getID());
    }
}