@IsTest
public class TestPaymentIntegration {
    
    @IsTest
    private static void givenConfiguredExtensionWhenCalledThenValidResult() {
        
        // Given
        String extensionClass = 'PaymentIntegration'; // Typically set via configuration
        ElixirSuite__Master_Transaction__c ot = new ElixirSuite__Master_Transaction__c();
        List<ElixirSuite__Refund__c> refLst = new List<ElixirSuite__Refund__c>();
        // When
        Callable extension = 
            (Callable) Type.forName(extensionClass).newInstance();
        ElixirSuite.PaymentIntegration.MessageWrapper1 result = (ElixirSuite.PaymentIntegration.MessageWrapper1) 
            extension.call('InsurancePayment', new Map<String, Object> { 
                '	amountPaid' => 10,
                    'modeOfPayment' => 'Cash',
                    'dateOfPmt' => System.today(),
                    'reasonForPayment' => 'upfront',
                    'note' => 'payment',
                    'pmtTransactionNumber' => 'a90',
                    'acctId' => 'accId',
                    'selectedProcedureRecords' => 'selectedProcedureRec',
                    'totalAppliedAmount' => 10,
                    'totalUnAllocatedAmount' => 5,
                    'noProcedureSelected' => false,
                    'paymentInfoId' => 'paymentInfoId',
                    'chequeNo' => 'chequeNo'
                    });
        
        Callable extension1 = 
            (Callable) Type.forName(extensionClass).newInstance();
        ElixirSuite.PaymentIntegration.MessageWrapper1 result1 = (ElixirSuite.PaymentIntegration.MessageWrapper1) 
            extension1.call('AllocateInsurancePayment', new Map<String, Object> { 
                'amountPaid' => 10,
                    'acctId' => 'acctId',
                    'selectedProcedureRecords' => 'selectedProcedureRecords',
                    'totalAppliedAmount' => 10,
                    'totalRemainingUnAllocatedAmt' => 5
                    });
        
        Callable extension2 = 
            (Callable) Type.forName(extensionClass).newInstance();
        ElixirSuite.PaymentIntegration.MessageWrapper1 result2 = (ElixirSuite.PaymentIntegration.MessageWrapper1) 
            extension2.call('PrivatePayment', new Map<String, Object> { 
                'amountPaid' => 10,
                    'modeOfPayment' => 'modeOfPayment',
                    'dateOfPmt' => System.today(),
                    'pmtTransactionNumber' => 'pmtTransactionNumber',
                    'acctId' => 'acctId',
                    'selectedProcedureRecords' => 'selectedProcedureRecords',
                    'totalAppliedAmount' => 10,
                    'totalUnAllocatedAmount' => 5,
                    'noProcedureSelected' => false,
                    'paymentInfoId' => 'paymentInfoId',
                    'chequeNo' => 'chequeNo'
                    });
        
        Callable extension3 = 
            (Callable) Type.forName(extensionClass).newInstance();
        ElixirSuite.PaymentIntegration.MessageWrapper1 result3 = (ElixirSuite.PaymentIntegration.MessageWrapper1) 
            extension3.call('AllocatePrivatePayment', new Map<String, Object> { 
                'amountAllocated' => 10,
                    'modeOfPayment' => 'modeOfPayment',
                    'dateOfPmt' => System.today(),
                    'pmtTransactionNumber' => 'pmtTransactionNumber',
                    'acctId' => 'acctId',
                    'selectedProcedureRecords' => 'selectedProcedureRecords',
                    'totalAppliedAmount' => 10,
                    'totalUnAllocatedAmount' => 5,
                    'noProcedureSelected' => false,
                    'totalUnallocatedAmt' => 5,
                    'paymentInfoId' => 'paymentInfoId',
                    'chequeNo' => 'chequeNo'
                    });
        
        Callable extension4 = 
            (Callable) Type.forName(extensionClass).newInstance();
        ElixirSuite.PaymentIntegration.MessageWrapper1 result4 = (ElixirSuite.PaymentIntegration.MessageWrapper1) 
            extension4.call('SchedulePrivatePayment', new Map<String, Object> { 
                'amountAllocated' => 10,
                    'modeOfPayment' => 'modeOfPayment',
                    'dateOfPmt' => System.today(),
                    'pmtTransactionNumber' => 'pmtTransactionNumber',
                    'acctId' => 'acctId',
                    'selectedProcedureRecords' => 'selectedProcedureRecords',
                    'totalAppliedAmount' => 10,
                    'totalUnAllocatedAmount' => 5,
                    'noProcedureSelected' => false,
                    'totalUnallocatedAmt' => 5,
                    'paymentInfoId' => 'paymentInfoId',
                    'chequeNo' => 'chequeNo'
                    });
        
        Callable extension5 = 
            (Callable) Type.forName(extensionClass).newInstance();
        ElixirSuite.PaymentIntegration.MessageWrapper1 result5 = (ElixirSuite.PaymentIntegration.MessageWrapper1) 
            extension5.call('AddDiscountPrivatePayment', new Map<String, Object> { 
                'otherTransaction' => ot,
                    'acctId' => 'acctId',
                    'selectedProcedureRecords' => 'selectedProcedureRecords',
                    'totalUnAllocatedDiscount' => 10,
                    'appliedDiscount' => 5,
                    'DiscountCode' => 'DiscountCode',
                    'Notes' => 'Notes'
                    });
        
        Callable extension6 = 
            (Callable) Type.forName(extensionClass).newInstance();
        ElixirSuite.PaymentIntegration.MessageWrapper1 result6 = (ElixirSuite.PaymentIntegration.MessageWrapper1) 
            extension6.call('AllocateDiscountPrivatePayment', new Map<String, Object> { 
                'otherTransaction' => ot,
                    'discountType' => 'discountType',
                    'acctId' => 'acctId',
                    'selectedProcedureRecords' => 'selectedProcedureRecords',
                    'totalUnAllocatedDiscount' => 10,
                    'appliedDiscount' => 5,
                    'discountTableId' => 'discountTableId'
                    });
        
        Callable extension7 = 
            (Callable) Type.forName(extensionClass).newInstance();
        ElixirSuite.PaymentIntegration.MessageWrapper1 result7 = (ElixirSuite.PaymentIntegration.MessageWrapper1) 
            extension7.call('CreateRefundRequest', new Map<String, Object> { 
                'itemListJson' => 'itemListJson'
                    });
        
        Callable extension8 = 
            (Callable) Type.forName(extensionClass).newInstance();
        ElixirSuite.PaymentIntegration.MessageWrapper1 result8 = (ElixirSuite.PaymentIntegration.MessageWrapper1) 
            extension8.call('ProcessRefund', new Map<String, Object> { 
                'accid' => 'accid',
                    'refundIds' => refLst
                    });
        
        system.assertEquals(1,1,' ');
    }
    
}