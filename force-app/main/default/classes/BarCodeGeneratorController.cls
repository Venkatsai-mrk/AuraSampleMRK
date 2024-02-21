public   with sharing  class BarCodeGeneratorController {
    public List<UA_Sample_Details__c> sampleList{get;set;}
    public List<SampleListAndContainerDivIdClass> sampleListAndContainerDivIdList{set;get;}
    
    public BarCodeGeneratorController(){
        
        String orderId = ApexPages.currentPage().getParameters().get('orderId');
    
        List <UA_Sample_Details__c> allSamples = [select id,Name,Account__r.Name from 
                                                  UA_Sample_Details__c where id=:orderId
                                                  WITH SECURITY_ENFORCED
                                                  ORDER BY Name ASC];
        sampleListAndContainerDivIdList=getsampleList(allSamples);
    }
    
    public List<SampleListAndContainerDivIdClass> getsampleList(List <UA_Sample_Details__c> allSamples){
        sampleList=allSamples;
        List<SampleListAndContainerDivIdClass> sampleListAndContainerDivIdList = new List<SampleListAndContainerDivIdClass>();
        try{
        list<UA_Sample_Details__c> listOfSamples2 = new list<UA_Sample_Details__c>();
        for(Integer i=0;i<allSamples.size();i++){
            listOfSamples2.add(allSamples[i]);
            if(Math.mod(i+1,9)==0){
                SampleListAndContainerDivIdClass sampleListAndContainerDivIdObj = new SampleListAndContainerDivIdClass();
                sampleListAndContainerDivIdObj.listOfSamples = new list<UA_Sample_Details__c>();
                sampleListAndContainerDivIdObj.listOfSamples.addAll(listOfSamples2);
                sampleListAndContainerDivIdObj.divId = String.valueOf(i+1);
                sampleListAndContainerDivIdList.add(sampleListAndContainerDivIdObj);
                listOfSamples2.clear();
            }
            else if(allSamples.size()==(i+1)){
                SampleListAndContainerDivIdClass sampleListAndContainerDivIdObj = new SampleListAndContainerDivIdClass();
                sampleListAndContainerDivIdObj.listOfSamples = new list<UA_Sample_Details__c>();
                sampleListAndContainerDivIdObj.listOfSamples.addAll(listOfSamples2);
                sampleListAndContainerDivIdObj.divId = String.valueOf(i+1);
                sampleListAndContainerDivIdList.add(sampleListAndContainerDivIdObj);
                listOfSamples2.clear();
            }
        }
        }
         catch(Exception e){
         ExceptionLog.logError(e);
        }
        return sampleListAndContainerDivIdList;
    }
    
    public class SampleListAndContainerDivIdClass{
        public List<UA_Sample_Details__c> listOfSamples{set;get;}
        public string divId{get;set;}
    }
}
//