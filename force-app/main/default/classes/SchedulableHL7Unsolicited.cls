global with sharing class SchedulableHL7Unsolicited implements Schedulable{
	global void execute(SchedulableContext sc) {
        String batchSizeStr  = System.Label.UnsolicitedClinicalReportResultBatchSize;
        Integer batchSize = Integer.valueOf(batchSizeStr);
        GetHL7UnsolicitedBatch b = new GetHL7UnsolicitedBatch();
        Database.executeBatch(b, batchSize);
    }
}