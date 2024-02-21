/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-09-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class CreateTerminalCheckout {
    public String customerId;
    public Decimal totalAmount;
    public String deviceId;
    public String checkOutId;
    public List<String> PaymentIds;
    
    
    public static String activateTerminal(String recordId, Decimal totalAmount){
        return '##';
    }
    public static String terminalCheckout(Decimal totalAmount, String deviceId){
       
        return '';
    }
    public static void getTerminalCheckout(String checkOutId){
      
    }
    public static String cancelTerminalPayment(String checkOutId){
        
         return '';
    }
    public static String getPaymentInfo(String paymentId){
        
         return '';
    }
}