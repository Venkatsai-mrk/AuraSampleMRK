({
    init : function(cmp,helper,mapVobFields,obj) {
        var result = new Map();
        var resultMap = obj.result;
        if('elig' in resultMap)
        {
            var eligMap = resultMap.elig;
            console.log('eligMap : ' + JSON.stringify(eligMap));
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "RESULT WILL BE ATTACHED IN ATTACHMENTS OF INSURANCE!",
                "message": "Response PDF will be attached in the ATTACHMENTS section of the Insurance in a while",
                "type" : "info"
            });
            toastEvent.fire();
            
            /*----------Basic response fields Section Mapping------------*/
            
            if('elig_result_date' in eligMap)
            {
                var verifyDateStr = eligMap['elig_result_date'];
                console.log(verifyDateStr);
                var day = parseInt(verifyDateStr.substring(6,8)) +1;
                var month = parseInt(verifyDateStr.substring(4,6)) - 1;
                var year = parseInt(verifyDateStr.substring(0, 4));
                
                console.log('date '+year + '-' + month + '-' + day);
                var verifiedDate = new Date(year,month,day);
                cmp.set("v.verifiedDate",verifiedDate);
                result['ElixirSuite__Eligibility_Result_Date__c'] = verifiedDate;
            }
            if('elig_result_time' in eligMap)
            {
                
                var verifyTimeStr = eligMap['elig_result_time'];
                var hrs = verifyTimeStr.toString().substring(0, 2);
                var mins = verifyTimeStr.toString().substring(2, 4);
                
                var verifiedTime = hrs + ':' + mins;
                result['ElixirSuite__Eligibility_Result_Time_Text__c'] =verifiedTime ;
            } 
            
            if('eligibility_begin_date' in eligMap)
            {
                var verifyDateStr = eligMap['eligibility_begin_date'];
                console.log(verifyDateStr);
                var day = parseInt(verifyDateStr.substring(6,8)) +1;
                var month = parseInt(verifyDateStr.substring(4,6)) - 1;
                var year = parseInt(verifyDateStr.substring(0, 4));
                
                console.log(year + '-' + month + '-' + day);
                var verifiedDate = new Date(year,month,day);
                cmp.set("v.verifiedDate",verifiedDate);
                result['ElixirSuite__Coverage_Date_Start__c'] = verifiedDate;
                console.log('verifiedDate:' +verifiedDate);
            } 
            
            if('plan_begin_date' in eligMap)
            {
                var planDateStr = eligMap['plan_begin_date'];
                console.log(planDateStr);
                if((eligMap['plan_begin_date']).includes('-')){
                    var planDateLst = planDateStr.split('-');
                    var planDateStartStr = planDateLst[0];
                    var planDateEndStr = planDateLst[1];
                    var daySt = parseInt(planDateStartStr.substring(6,8)) + 1;
                    var monthSt = parseInt(planDateStartStr.substring(4,6)) - 1;
                    var yearSt = parseInt(planDateStartStr.substring(0, 4));
                    
                    var dayEd = parseInt(planDateEndStr.substring(6,8)) + 1;
                    var monthEd = parseInt(planDateEndStr.substring(4,6)) - 1;
                    var yearEd = parseInt(planDateEndStr.substring(0, 4));
                    
                    console.log(yearSt + '-' + monthSt + '-' + daySt);
                    console.log(yearEd + '-' + monthEd + '-' + dayEd);
                    var planDateStart = new Date(yearSt,monthSt,daySt);
                    var planDateEnd = new Date(yearEd,monthEd,dayEd);
                    console.log(planDateStart);
                    console.log(planDateEnd);
                    cmp.set("v.plannedStartDate",planDateStart);
                    cmp.set("v.plannedEndDate",planDateEnd);
                    if(planDateStart != null)
                    {
                        result['ElixirSuite__Plan_Begin_Date__c'] = planDateStart;
                    }
                    if(planDateEnd != null)
                    {
                        result['ElixirSuite__Plan_End_Date__c'] = planDateEnd;
                    }
                }
                else{
                    var daySt = parseInt(planDateStr.substring(6,8)) + 1;
                    var monthSt = parseInt(planDateStr.substring(4,6)) - 1;
                    var yearSt = parseInt(planDateStr.substring(0, 4));
                    
                    var planDateStart = new Date(yearSt,monthSt,daySt);
                    cmp.set("v.plannedStartDate",planDateStart);
                    result['ElixirSuite__Plan_Begin_Date__c'] = planDateStart;
                }
            }
            
            if('plan_date' in eligMap)
            {
                var planDateStr = eligMap['plan_date'];
                if((eligMap['plan_date']).includes('-')){
                    var planDateLst = planDateStr.split('-');
                    var planDateStartStr = planDateLst[0];
                    var planDateEndStr = planDateLst[1];
                    var daySt = parseInt(planDateStartStr.substring(6,8)) + 1;
                    var monthSt = parseInt(planDateStartStr.substring(4,6)) - 1;
                    var yearSt = parseInt(planDateStartStr.substring(0, 4));
                    
                    var dayEd = parseInt(planDateEndStr.substring(6,8)) + 1;
                    var monthEd = parseInt(planDateEndStr.substring(4,6)) - 1;
                    var yearEd = parseInt(planDateEndStr.substring(0, 4));
                    
                    console.log(yearSt + '-' + monthSt + '-' + daySt);
                    console.log(yearEd + '-' + monthEd + '-' + dayEd);
                    var planDateStart = new Date(yearSt,monthSt,daySt);
                    var planDateEnd = new Date(yearEd,monthEd,dayEd);
                    console.log(planDateStart);
                    console.log(planDateEnd);
                    cmp.set("v.plannedStartDate",planDateStart);
                    cmp.set("v.plannedEndDate",planDateEnd);
                    if(planDateStart != null)
                    {
                        result['ElixirSuite__Plan_Begin_Date__c'] = planDateStart;
                    }
                    if(planDateEnd != null)
                    {
                        result['ElixirSuite__Plan_End_Date__c'] = planDateEnd;
                    }
                }
                else{
                    var daySt = parseInt(planDateStr.substring(6,8)) + 1;
                    var monthSt = parseInt(planDateStr.substring(4,6)) - 1;
                    var yearSt = parseInt(planDateStr.substring(0, 4));
                    
                    var planbeginDate1 = new Date(yearSt,monthSt,daySt);
                    result['ElixirSuite__Plan_Begin_Date__c'] = planbeginDate1;
                }
            }
            
            if('plan_number' in eligMap)
            {
                result['ElixirSuite__Plan_Number__c'] = eligMap['plan_number'];
            }
            if('group_name' in eligMap)
            {
                result['ElixirSuite__Group_Name__c'] = eligMap['group_name'];
            }
            if('group_number' in eligMap)
            {
                result['ElixirSuite__Group_Number__c'] = eligMap['group_number'];
            }
            if('eligid' in eligMap)
            {
                result.set('ElixirSuite__Elig_Id__c', eligMap['eligid']);
            }
            if('ins_number' in eligMap)
            {
                result['ElixirSuite__Insurance_Number__c'] = eligMap['ins_number'];
            }
            if('ins_name_f' in eligMap)
            {
                result['ElixirSuite__Insured_First_Name__c'] = eligMap['ins_name_f'];
            }
            if('ins_name_l' in eligMap)
            {
                result['ElixirSuite__Insured_Last_Name__c'] = eligMap['ins_name_l'];
            }
            if('ins_dob' in eligMap)
            {
                
                var DateOfBirthStr = eligMap['ins_dob'];
                console.log(DateOfBirthStr);
                
                var day = parseInt(DateOfBirthStr.substring(6,8)) +1;
                var month = parseInt(DateOfBirthStr.substring(4,6)) - 1;
                var year = parseInt(DateOfBirthStr.substring(0, 4));
                
                console.log(year + '-' + month + '-' + day);
                var DateOfBirth = new Date(year,month,day);
                cmp.set("v.DateOfBirth",DateOfBirth);
                result['ElixirSuite__Insured_DOB__c'] = DateOfBirth;
                console.log('DateOfBirth:' +DateOfBirth);
                
            }
            if('ins_sex' in eligMap)
            {
                result['ElixirSuite__Insured_Sex__c'] = eligMap['ins_sex'];
            }
            if('ins_addr_1' in eligMap)
            {
                result['ElixirSuite__Insured_Address__c'] = eligMap['ins_addr_1'];
            }
            if('ins_city' in eligMap)
            {
                result['ElixirSuite__Insured_City__c'] = eligMap['ins_city'];
            }
            if('ins_state' in eligMap)
            {
                result['ElixirSuite__Insured_State__c'] = eligMap['ins_state'];
            }
            if('ins_zip' in eligMap)
            {
                result['ElixirSuite__Insured_Zip__c'] = eligMap['ins_zip'];
            }
            
            var benefitLst = eligMap.benefit;
            console.log('Benefit List: ' +JSON.stringify(benefitLst));
            
            var errorList = eligMap.error;
            if(errorList){
                for(var i=0; i< errorList.length; i++){
                    
                    var errorStr = errorList[i]['error_nesg'];
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": errorStr,
                        "type" : "error",
                        "mode" : "dismissible"
                    });
                    toastEvent.fire();
                    var cmpEvent = cmp.getEvent("IntegCmpEvent"); 
                    //Set event attribute value
                    cmpEvent.setParams({"IntegrationOpen" : true}); 
                    cmpEvent.fire();
                    
                    $A.get("e.force:closeQuickAction").fire();
                    var vob = cmp.get("v.VOB");
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": vob.ElixirSuite__Account__c,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                    
                    
                }
            }
            console.log('Result 282:-'+JSON.stringify(result));
            for(var i=0; i< benefitLst.length; i++)
            {       
                console.log(benefitLst[i]);
                if('benefit_code' in benefitLst[i] && 'benefit_coverage_code' in benefitLst[i])
                {
                    
                    /*----------first Section Mapping------------*/
                    if (benefitLst[0]['benefit_code']){
                        result['ElixirSuite__Benefit_Code__c'] = benefitLst[0]['benefit_code'];
                    }
                    if (benefitLst[0]['benefit_coverage_code']){
                        result['ElixirSuite__Benefit_Coverage_Code__c'] =  benefitLst[0]['benefit_coverage_code'];
                    }
                    if (benefitLst[0]['benefit_coverage_description']){
                        result['ElixirSuite__Benefit_Coverage_Description__c'] =  benefitLst[0]['benefit_coverage_description'];
                    }
                    if (benefitLst[0]['benefit_description']){
                        result['ElixirSuite__Benefit_Description__c'] =  benefitLst[0]['benefit_description'];
                    }
                    if (benefitLst[0]['benefit_notes']){
                        result['ElixirSuite__Benefit_Notes__c'] =  benefitLst[0]['benefit_notes'];
                    }
                    if (benefitLst[0]['insurance_plan']){
                        result['ElixirSuite__Insurance_Plan__c'] =  benefitLst[0]['insurance_plan'];
                    }
                    if (benefitLst[0]['insurance_type_code']){
                        result['ElixirSuite__Insurance_Type_Code__c'] =  benefitLst[0]['insurance_type_code'];
                    }
                    if (benefitLst[0]['insurance_type_description']){
                        result['ElixirSuite__Insurance_Type_Description__c'] =  benefitLst[0]['insurance_type_description'];
                    }
                    if (benefitLst[0]['plan_number']){
                    }
                    
                    console.log('Inside if');
                    /*----Other Fields Mapping--------*/
                    
                    if(benefitLst[i]['benefit_coverage_code'] == 'C' && 
                       benefitLst[i]['benefit_level_code'] == 'FAM' && 
                       benefitLst[i]['benefit_period_code'] == '23' &&
                       benefitLst[i]['inplan_network'] == 'Y' &&
                       benefitLst[i]['benefit_code'] =='30')
                    {
                        result['ElixirSuite__Deductible_Family_In_Network__c'] = benefitLst[i]['benefit_amount'];
                    }
                    
                    else if
                        (benefitLst[i]['benefit_coverage_code'] == 'A' && 
                         benefitLst[i]['benefit_level_code'] == 'FAM' && 
                         benefitLst[i]['inplan_network'] == 'Y' &&
                         benefitLst[i]['benefit_code'] =='30')
                    {
                        result['ElixirSuite__Co_Insurance_Fam_In_Network__c'] = benefitLst[i]['benefit_percent'];
                    }
                    
                        else if
                            (benefitLst[i]['benefit_coverage_code'] == 'A' && 
                             benefitLst[i]['benefit_level_code'] == 'FAM' && 
                             benefitLst[i]['inplan_network'] == 'N' &&
                             benefitLst[i]['benefit_code'] =='30')
                        {
                            result['ElixirSuite__Co_Insurance_Fam_Out_Of_Network__c'] = benefitLst[i]['benefit_percent'];
                        }
                    
                            else if
                                (benefitLst[i]['benefit_coverage_code'] == 'A' && 
                                 benefitLst[i]['benefit_level_code'] == 'IND' && 
                                 benefitLst[i]['inplan_network'] == 'Y' &&
                                 benefitLst[i]['benefit_code'] =='30')
                            {
                                result['ElixirSuite__Co_Insurance_Ind_In_Network__c'] = benefitLst[i]['benefit_percent'];
                            }
                    
                                else if
                                    (benefitLst[i]['benefit_coverage_code'] == 'A' && 
                                     benefitLst[i]['benefit_level_code'] == 'IND' && 
                                     benefitLst[i]['inplan_network'] == 'N' &&
                                     benefitLst[i]['benefit_code'] =='30')
                                {
                                    result['ElixirSuite__Co_Insurance_Ind_Out_Of_Network__c'] = benefitLst[i]['benefit_percent'];
                                }
                    
                                    else if
                                        (benefitLst[i]['benefit_coverage_code'] == 'C' && 
                                         benefitLst[i]['benefit_level_code'] == 'IND' && 
                                         benefitLst[i]['benefit_period_code'] == '23' &&
                                         benefitLst[i]['inplan_network'] == 'Y' &&
                                         benefitLst[i]['benefit_code'] =='30')
                                    {
                                        result['ElixirSuite__Deductible_Individual_In_Network__c'] = benefitLst[i]['benefit_amount'];
                                    }
                                        else if
                                            (benefitLst[i]['benefit_coverage_code'] == 'C' && 
                                             benefitLst[i]['benefit_level_code'] == 'FAM' && 
                                             benefitLst[i]['benefit_period_code'] == '29' &&
                                             benefitLst[i]['inplan_network'] == 'Y' &&
                                             benefitLst[i]['benefit_code'] =='30')
                                        {
                                            result['ElixirSuite__Deductible_Rem_Fam_In_Network__c'] = benefitLst[i]['benefit_amount'];
                                        }
                                            else if
                                                (benefitLst[i]['benefit_coverage_code'] == 'C' && 
                                                 benefitLst[i]['benefit_level_code'] == 'IND' && 
                                                 benefitLst[i]['benefit_period_code'] == '29' &&
                                                 benefitLst[i]['inplan_network'] == 'Y' &&
                                                 benefitLst[i]['benefit_code'] =='30')
                                            { 
                                                result['ElixirSuite__Deductible_Rem_Ind_In_Network__c'] = benefitLst[i]['benefit_amount'];
                                            }
                    
                                                else if(benefitLst[i]['benefit_coverage_code'] == 'G' && 
                                                        benefitLst[i]['benefit_level_code'] == 'FAM' &&
                                                        benefitLst[i]['inplan_network'] == 'Y' &&
                                                        benefitLst[i]['benefit_code'] =='30')
                                                {
                                                    if(benefitLst[i]['benefit_period_code'] == '29'){
                                                        result['ElixirSuite__OOP_Rem_Fam_In_Network__c'] = benefitLst[i]['benefit_amount'];
                                                    }
                                                    else{
                                                        result['ElixirSuite__OOP_Family_In_Network__c'] = benefitLst[i]['benefit_amount'];
                                                    }
                                                }
                                                    else if
                                                        (benefitLst[i]['benefit_coverage_code'] == 'G' && 
                                                         benefitLst[i]['benefit_level_code'] == 'IND' && 
                                                         benefitLst[i]['inplan_network'] == 'Y' &&
                                                         benefitLst[i]['benefit_code'] =='30')
                                                    {
                                                        if(benefitLst[i]['benefit_period_code'] == '29'){
                                                            result['ElixirSuite__OOP_Rem_Ind_In_Network__c'] = benefitLst[i]['benefit_amount'];
                                                        }
                                                        else{
                                                            result['ElixirSuite__OOP_Individual_In_Network__c'] = benefitLst[i]['benefit_amount'];
                                                        }
                                                    }
                                                        else if(benefitLst[i]['benefit_coverage_code'] == 'C' && 
                                                                benefitLst[i]['benefit_level_code'] == 'FAM' && 
                                                                benefitLst[i]['benefit_period_code'] == '23' &&
                                                                benefitLst[i]['inplan_network'] == 'N' &&
                                                                benefitLst[i]['benefit_code'] =='30')
                                                        {
                                                            
                                                            result['ElixirSuite__Deductible_Family_Out_Network__c'] = benefitLst[i]['benefit_amount'];
                                                        }
                                                            else if
                                                                (benefitLst[i]['benefit_coverage_code'] == 'C' && 
                                                                 benefitLst[i]['benefit_level_code'] == 'IND' && 
                                                                 benefitLst[i]['benefit_period_code'] == '23' &&
                                                                 benefitLst[i]['inplan_network'] == 'N' &&
                                                                 benefitLst[i]['benefit_code'] =='30')
                                                            {
                                                                result['ElixirSuite__Deductible_Individual_Out_Network__c'] = benefitLst[i]['benefit_amount'];
                                                            }
                                                                else if
                                                                    (benefitLst[i]['benefit_coverage_code'] == 'C' && 
                                                                     benefitLst[i]['benefit_level_code'] == 'FAM' && 
                                                                     benefitLst[i]['benefit_period_code'] == '29' &&
                                                                     benefitLst[i]['inplan_network'] == 'N' &&
                                                                     benefitLst[i]['benefit_code'] =='30')
                                                                {
                                                                    result['ElixirSuite__Deductible_Rem_Fam_Out_Network__c'] = benefitLst[i]['benefit_amount'];
                                                                }
                                                                    else if
                                                                        (benefitLst[i]['benefit_coverage_code'] == 'C' && 
                                                                         benefitLst[i]['benefit_level_code'] == 'IND' && 
                                                                         benefitLst[i]['benefit_period_code'] == '29' &&
                                                                         benefitLst[i]['inplan_network'] == 'N' &&
                                                                         benefitLst[i]['benefit_code'] =='30')
                                                                    { 
                                                                        result['ElixirSuite__Deductible_Rem_Ind_Out_Network__c'] = benefitLst[i]['benefit_amount'];
                                                                    }  
                    
                                                                        else if(benefitLst[i]['benefit_coverage_code'] == 'G' && 
                                                                                benefitLst[i]['benefit_level_code'] == 'FAM' && 
                                                                                benefitLst[i]['inplan_network'] == 'N' &&
                                                                                benefitLst[i]['benefit_code'] =='30')
                                                                        {
                                                                            if(benefitLst[i]['benefit_period_code'] == '29'){
                                                                                result['ElixirSuite__OOP_Rem_Fam_Out_Network__c'] = benefitLst[i]['benefit_amount'];
                                                                            }
                                                                            else{
                                                                                result['ElixirSuite__OOP_Family_Out_Network__c'] = benefitLst[i]['benefit_amount'];
                                                                            }
                                                                        }
                                                                            else if(benefitLst[i]['benefit_coverage_code'] == 'G' && 
                                                                                    benefitLst[i]['benefit_level_code'] == 'IND' && 
                                                                                    benefitLst[i]['inplan_network'] == 'N' &&
                                                                                    benefitLst[i]['benefit_code'] =='30')
                                                                            {
                                                                                if(benefitLst[i]['benefit_period_code'] == '29'){
                                                                                    result['ElixirSuite__OOP_Rem_Ind_Out_Network__c'] = benefitLst[i]['benefit_amount'];
                                                                                }
                                                                                else{
                                                                                    result['ElixirSuite__OOP_Individual_Out_Network__c'] = benefitLst[i]['benefit_amount'];
                                                                                }
                                                                            }
                    
                    
                                                                                else if(benefitLst[i]['benefit_coverage_code'] == 'A' &&
                                                                                        benefitLst[i]['benefit_level_code'] == 'IND' && 
                                                                                        (benefitLst[i]['benefit_period_code'] == '27' || benefitLst[i]['benefit_period_code'] == '7') &&
                                                                                        benefitLst[i]['inplan_network'] == 'Y' &&
                                                                                        benefitLst[i]['benefit_code'] =='AI' &&
                                                                                        (benefitLst[i]['benefit_notes']).includes('INPATIENT FACILITY'))
                                                                                { 
                                                                                    result['ElixirSuite__Co_insurance_Sub_Abuse_In_Net__c'] = benefitLst[i]['benefit_percent'];
                                                                                    result['ElixirSuite__Place_of_Serv_SubAbu_In_Net__c'] = benefitLst[i]['place_of_service'];
                                                                                } 
                                                                                    else if(benefitLst[i]['benefit_coverage_code'] == 'A' &&
                                                                                            benefitLst[i]['benefit_level_code'] == 'IND' && 
                                                                                            (benefitLst[i]['benefit_period_code'] == '27' || benefitLst[i]['benefit_period_code'] == '7') &&
                                                                                            benefitLst[i]['inplan_network'] == 'Y' &&
                                                                                            benefitLst[i]['benefit_code'] =='CI')
                                                                                    { 
                                                                                        result['ElixirSuite__Co_insurance_Sub_Abuse_Inpatient_In_Net__c'] = benefitLst[i]['benefit_percent'];
                                                                                        result['ElixirSuite__Place_of_Serv_SubAbu_Inpatient_In_Net__c'] = benefitLst[i]['place_of_service'];
                                                                                        
                                                                                    } 
                                                                                        else if(benefitLst[i]['benefit_coverage_code'] == 'A' &&
                                                                                                benefitLst[i]['benefit_level_code'] == 'IND' && 
                                                                                                (benefitLst[i]['benefit_period_code'] == '27' || benefitLst[i]['benefit_period_code'] == '7') &&
                                                                                                benefitLst[i]['inplan_network'] == 'Y' &&
                                                                                                benefitLst[i]['benefit_code'] =='CJ')
                                                                                        { 
                                                                                            result['ElixirSuite__Co_insurance_Sub_Abuse_Outpatient_In_Net__c'] = benefitLst[i]['benefit_percent'];
                                                                                            result['ElixirSuite__Place_of_Serv_SubAbu_Outpatient_In_Net__c'] = benefitLst[i]['place_of_service'];
                                                                                            
                                                                                        } 
                    
                                                                                            else if(benefitLst[i]['benefit_coverage_code'] == 'A' &&
                                                                                                    benefitLst[i]['benefit_level_code'] == 'IND' && 
                                                                                                    (benefitLst[i]['benefit_period_code'] == '27' ||benefitLst[i]['benefit_period_code'] == '7')  &&
                                                                                                    benefitLst[i]['inplan_network'] == 'N' &&
                                                                                                    benefitLst[i]['benefit_code'] =='AI' &&
                                                                                                    (benefitLst[i]['benefit_notes']).includes('INPATIENT FACILITY'))
                                                                                                
                                                                                            { 
                                                                                                result['ElixirSuite__Co_insurance_Sub_Abuse_Out_Net__c'] = benefitLst[i]['benefit_percent'];
                                                                                                result['ElixirSuite__Place_of_Serv_SubAbu_Out_Net__c'] = benefitLst[i]['place_of_service'];
                                                                                            } 
                                                                                                else if(benefitLst[i]['benefit_coverage_code'] == 'A' &&
                                                                                                        benefitLst[i]['benefit_level_code'] == 'IND' && 
                                                                                                        (benefitLst[i]['benefit_period_code'] == '7' || benefitLst[i]['benefit_period_code'] == '27') &&
                                                                                                        benefitLst[i]['inplan_network'] == 'N' &&
                                                                                                        benefitLst[i]['benefit_code'] =='CI')
                                                                                                { 
                                                                                                    result['ElixirSuite__Co_insurance_Sub_Abuse_Inpatient_Out_Net__c'] = benefitLst[i]['benefit_percent'];
                                                                                                    result['ElixirSuite__Place_of_Serv_SubAbu_Inpatient_Out_Net__c'] = benefitLst[i]['place_of_service'];
                                                                                                } 
                                                                                                    else if (benefitLst[i]['benefit_coverage_code'] == 'A' &&
                                                                                                             benefitLst[i]['benefit_level_code'] == 'IND' && 
                                                                                                             (benefitLst[i]['benefit_period_code'] == '7' || benefitLst[i]['benefit_period_code'] == '27') &&
                                                                                                             benefitLst[i]['inplan_network'] == 'N' &&
                                                                                                             benefitLst[i]['benefit_code'] =='CJ')
                                                                                                    { 
                                                                                                        result['ElixirSuite__Co_insurance_Sub_Abuse_Outpatient_Ou_Net__c'] = benefitLst[i]['benefit_percent'];
                                                                                                        result['ElixirSuite__Place_of_Serv_SubAbu_Outpatient_Out_Net__c'] = benefitLst[i]['place_of_service'];
                                                                                                    } 
                    
                }
            }
            cmp.set("v.Result",result);
            helper.callSaveMethod(cmp);
        }
    },
    callSaveMethod : function(cmp){
        
        var saveRes = cmp.get("c.saveResults");
        saveRes.setParams({
            result1 : [cmp.get("v.Result")],
            vobId1 : cmp.get("v.recordId")
        });
        
        saveRes.setCallback(this,function(resSave){
            if(resSave.getState()=== "SUCCESS")
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": 'Patient verified!',
                    "type" : "success",
                    "mode" : "dismissible"
                });
                toastEvent.fire();
                
                var cmpEvent = cmp.getEvent("IntegCmpEvent"); 
                //Set event attribute value
                cmpEvent.setParams({"IntegrationOpen" : true}); 
                cmpEvent.fire(); 
                
            }
            else if (resSave.getState()==='ERROR')
            {
                let errors = resSave.getError();
                let messageErr = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    messageErr = errors[0].message;
                }
                var toastEventError = $A.get("e.force:showToast");
                toastEventError.setParams({
                    "title": "Error",
                    "message": messageErr,
                    "type" : "error",
                    "mode" : "dismissible"
                });
                toastEventError.fire();
                
                var cmpEvent = cmp.getEvent("IntegCmpEvent"); 
                cmpEvent.setParams({"IntegrationOpen" : true}); 
                cmpEvent.fire();
                
            }
        });
        $A.enqueueAction(saveRes);
    }
})