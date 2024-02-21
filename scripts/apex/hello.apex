
String approvedValues = '[ {"approvalLevel":1,"comments":"comm1","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T06:49:54.434Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"}, {"approvalLevel":2,"comments":"comm 2","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T06:50:01.211Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"}, {"approvalLevel":3,"comments":"comm3","customLabel":"Aditya-user","dateOfApproval":"2023-04-20T06:50:07.962Z","signatureContentDocumentId":"069N0000002DHmcIAG","userName":"User User","userRole":"CEO"} ]';

List<SignAndAprroveData> approvedValuesObj = (List<SignAndAprroveData>)JSON.deserializeStrict(approvedValues, List<SignAndAprroveData>.class);
System.debug(approvedValuesObj[0].dateOfApproval);

public class SignAndAprroveData {
    public Datetime dateOfApproval;
    public Integer approvalLevel;
    public String userName;
    public String userRole;
    public String signatureAttachmentId;
    public String signatureContentDocumentId;
    public String patientName;
    public String customLabel;
    public String comments;
}