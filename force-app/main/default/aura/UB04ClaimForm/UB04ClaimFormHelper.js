({
 setRevenueData :function(component) {
        let sObj = {'revenueCode' : '',
                    'revenueCodeDescription' : '',
                    'HCPCSRates' : '',
                    'serviceDate' : '',
                    'serviceUnits' : '',
                    'totalCharge' : '',
                    'nonCoveredCharges' : '',
                    'futureUse' : ''
                   };
        component.set("v.revenueData" , sObj);
    }
})