public with sharing class AnnotationHandler {
    @AuraEnabled
    public static void saveDrawData(
        List<Object> imageParametre,String imageFileName,
        String staticImageName,Object staticImageParam,List<String> contentIDsToDel ,
        List<String> staticResToDel,String acocuntID)
    {
        try{
            if(contentIDsToDel.size()>0 && contentIDsToDel!=null){
                delete [SELECT ID,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = : acocuntID AND  ContentDocumentId IN:contentIDsToDel];
            }
            if(imageParametre.size()>0 && imageParametre!=null){               
                FlowImageContentHelper.myCustomSave(imageParametre,acocuntID,imageFileName,staticImageName); 
            }
            if(String.isNotBlank(String.valueOf(staticImageParam))){
                FlowImageContentHelper.myCustomSaveForStatic(staticImageParam,acocuntID,staticImageName,staticImageName); 
            }
            if(staticResToDel.size()>0 && staticResToDel!=null){
                System.debug('staticResToDel '+staticResToDel);
                FlowImageContentHelper.delResourceDrawforAnnotation(staticResToDel);
            }
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
    }
    @AuraEnabled
    public static WrapperForInit initBuild (Id recId)
    {
        WrapperForInit toRet = new WrapperForInit();
        try{
            System.debug('RECEIVED ID OS'+recId);
            list<ContentDocumentLink> relatedImages = [SELECT ID,ContentDocument.title,ContentDocumentId FROM ContentDocumentLink where LinkedEntityId = :recId AND (ContentDocument.title LIKE '%draw%' OR ContentDocument.title LIKE '%staticDraw%' ) WITH SECURITY_ENFORCED];
            System.debug('RECEIVED data '+relatedImages);
            lIST<ID> cdIDS = new lIST<ID>();
            for(ContentDocumentLink myCustomIDS : relatedImages){
                cdIDS.ADD(myCustomIDS.id);
            }
           // WrapperForInit toRet = new WrapperForInit();
            toRet.cdLinks = relatedImages;
            return toRet;
        }
        catch(Exception e){
            ExceptionLog.logError(e);
        }
        return toRet;
        //return null;
    }
    public class WrapperForInit{
        @AuraEnabled public list<ContentDocumentLink> cdLinks;
    }
    @AuraEnabled
    public static void deleteImageFromCanvas (String imageId,String acocuntID)
    {
        try{
            if(String.isNotBlank(imageId)){
                delete [SELECT ID,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = : acocuntID AND  ContentDocumentId =:imageId];
            }
        }
        catch(Exception e){
        ExceptionLog.logError(e);
        }
    }
}