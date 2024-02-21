public with sharing class DMLManagerV2 extends DMLManager{ 
    public DMLManagerV2() {
    } 
	
    public static List<Database.SaveResult> insertAsUser(sObject obj,Boolean allOrNone){return performDMLOperationInsertOrUpdate(new List<sObject>{obj},Operation.OP_INSERT, allOrNone);}
	public static List<Database.SaveResult> updateAsUser(sObject obj,Boolean allOrNone){return performDMLOperationInsertOrUpdate(new List<sObject>{obj},Operation.OP_UPDATE, allOrNone);}
	public static List<Database.UpsertResult> upsertAsUser(sObject obj,Boolean allOrNone){return performDMLOperationUpsert(new List<sObject>{obj},Operation.OP_UPSERT, allOrNone);}
	public static List<Database.DeleteResult> deleteAsUser(sObject obj,Boolean allOrNone){return performDMLOperationDelete(new List<sObject>{obj},Operation.OP_DELETE, allOrNone);}
	public static List<Database.SaveResult> insertAsUser(List<SObject> objList,Boolean allOrNone){return performDMLOperationInsertOrUpdate(objList,Operation.OP_INSERT, allOrNone);}
	public static List<Database.SaveResult> updateAsUser(List<SObject> objList,Boolean allOrNone){return performDMLOperationInsertOrUpdate(objList,Operation.OP_UPDATE, allOrNone);}
	public static List<Database.UpsertResult> upsertAsUser(List<SObject> objList,Boolean allOrNone){return performDMLOperationUpsert(objList,Operation.OP_UPSERT, allOrNone);}
	public static List<Database.DeleteResult> deleteAsUser(List<SObject> objList,Boolean allOrNone){return performDMLOperationDelete(objList,Operation.OP_DELETE, allOrNone);}

    
   private static List<Database.SaveResult> performDMLOperationInsertOrUpdate(List<SObject> objList, Operation dmlOperation,Boolean allOrNone){		
		 
		PerformDMLCheck(objList, dmlOperation);
		List<Database.SaveResult> saveResult;
		if(dmlOperation == Operation.OP_INSERT){saveResult = Database.insert(objList,allOrNone);} 
		else if (dmlOperation == Operation.OP_UPDATE){saveResult = Database.update(objList,allOrNone);} 
		return saveResult;		
	}

	private static List<Database.DeleteResult> performDMLOperationDelete(List<SObject> objList, Operation dmlOperation,Boolean allOrNone){		
		 
		PerformDMLCheck(objList, dmlOperation);
		List<Database.DeleteResult>  deleteResult;
		if (dmlOperation == Operation.OP_DELETE){deleteResult = Database.delete(objList,allOrNone);}
		return deleteResult;
	}

	private  static List<Database.UpsertResult> performDMLOperationUpsert(List<SObject> objList, Operation dmlOperation,Boolean allOrNone){		
		 
		PerformDMLCheck(objList, dmlOperation);
		List<Database.UpsertResult> upsertResult;
		if (dmlOperation == Operation.OP_UPSERT){						 
        upsertResult = Database.upsert(objList, allOrNone);
		}
		return upsertResult;			
	}
}