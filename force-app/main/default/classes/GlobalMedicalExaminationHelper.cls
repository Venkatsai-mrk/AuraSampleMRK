Global with sharing virtual class GlobalMedicalExaminationHelper {
    global virtual void medExaminationInsert(List<ElixirSuite__Medical_Examination__c> lstMedExaminationRecords){
        MedExam_Handler.createProcMed(lstMedExaminationRecords);

    }
    global virtual void medExaminationUpdate(List<ElixirSuite__Medical_Examination__c> medExaminationList){
        MedExam_Handler.updateProcMed(medExaminationList);

    }
    global virtual void medExaminationModify(ElixirSuite__Medical_Examination__c[] medicalExamList){
        MedExam_Handler.populateCareEpisode(medicalExamList);

    }
}