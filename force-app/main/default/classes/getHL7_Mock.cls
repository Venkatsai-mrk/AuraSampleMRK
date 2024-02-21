public class getHL7_Mock implements HttpCalloutMock{
    
    public HTTPResponse respond(HTTPRequest getTestHttpRequest) {
        String reqBody = getTestHttpRequest.getBody();
        if((reqBody.contains('name="reportdoc"')) &&(reqBody.contains('op="search"'))){
            HttpResponse res = new HttpResponse();
            String httpBody='<?xml version=\'1.0\'?><RESULT sessionid="p_mirketa1458a00453d0c6ca5|459a3fc9c291bd90|435fd03f0bf2a880|42dfd03f0bf2a880|">     <OBJECT name="reportdoc" op="search">         <sequence>1</sequence>         <clinicalreport>3007902524</clinicalreport>         <body_text>MSH|^~\\&amp;|H_DX|8001265|QUEST|MET|202209140055|24577^COS_WS02_1^STANDARD|ORM^O01|3005100226|P|2.3&#13;PID|1|0010P000016XA0KAAA|0010P000016XA0KAAA^^^^PAN^MIRKETA INC TEST SITE||POPLI^RAGHAV||19990527|M|||34/10 OLD RAJINDER NAGAR,1ST-F^^NEW DELHI^DE^11002^^^^NASSAU||8447809279^PRN^PH^^^844^7809279||||||111223333&#13;ORC|NW|66702^H_DX|||||||202209140055|P_MIRKETA1||1528251113^APPLE^ANNA^^^^^^^^^^NPI||||C|||||MIRKETA INC TEST SITE|11501 DUBLIN BOULEVARD SUITE 2^^DUBLIN^CA^94583&#13;OBR|1|66702||10107^BLADDER CANCER, FISH^MET|||202209141324||||||||^^RANDOM|1528251113^APPLE^ANNA^^^^^^^^^^NPI&#13;DG1|1||E08.3211^^I10</body_text>         <mime_type>text/HL7</mime_type>         <document>716543726851087</document>         <clearance></clearance>         <format_hl7></format_hl7>         <ownerid></ownerid>         <emr_ready_only>Y</emr_ready_only>     </OBJECT> </RESULT>';
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(httpBody);
            res.setStatus('OK');
            res.setStatusCode(200);
            return res;
        }
        else if((reqBody.contains('name="clinicalreport"')) &&(reqBody.contains('op="get"'))){
            HttpResponse res = new HttpResponse();
            String httpBody='<?xml version=\'1.0\'?><RESULT sessionid="p_mirketa1459adc06bd1def08|458b7071dfcd25d3|435fd011c2aeac00|42dfd011c2aeac00|">     <OBJECT name="clinicalreport" op="get">         <lab_code></lab_code>         <ordering_cg_fname>Anna</ordering_cg_fname>         <person_suffix></person_suffix>         <clinicalreport>3007902524</clinicalreport>         <psc_orders_created></psc_orders_created>         <receiving_cg_lname>Apple</receiving_cg_lname>         <reports_count></reports_count>         <receivingorganization>3004423326</receivingorganization>         <ordering_cg_suffix></ordering_cg_suffix>         <expiration_date>3/13/2023 12:55 AM</expiration_date>         <person_account_number>0010p000016xa0kAAA</person_account_number>         <content_expiration_date>1/12/2023 12:55 AM</content_expiration_date>         <is_abnormal>N</is_abnormal>         <reports_undelivered></reports_undelivered>         <sponsor_name></sponsor_name>         <reports_forwarded></reports_forwarded>         <person_last_name>Popli</person_last_name>         <placer_order_number>66702</placer_order_number>         <previousreport>3007902524</previousreport>         <is_downloaded>N</is_downloaded>         <creation_date>9/13/2022 10:00 PM</creation_date>         <is_forwarded>Y</is_forwarded>         <organization_name></organization_name>         <report_type>ORDER</report_type>         <ordering_cg_mname></ordering_cg_mname>         <ownerid>3004423326</ownerid>         <forwarded>N</forwarded>         <orderresult></orderresult>         <sequence></sequence>         <is_annotated>N</is_annotated>         <filler_order_number></filler_order_number>         <reports_printed></reports_printed>         <person>3006825426</person>         <receiving_cg_mname></receiving_cg_mname>         <reports_delivered></reports_delivered>         <is_latest>Y</is_latest>         <sponsor>2701389</sponsor>         <is_viewed>Y</is_viewed>         <document></document>         <report_status>NA</report_status>         <receiving_client_id>8001265</receiving_client_id>         <ordering_cg_lname>Apple</ordering_cg_lname>         <person_middle_name></person_middle_name>         <report_priority></report_priority>         <clearance>10</clearance>         <creation_datetime>9/14/2022 12:55 AM</creation_datetime>         <has_external_content></has_external_content>         <is_printed>N</is_printed>         <receiving_cg_fname>Anna</receiving_cg_fname>         <abnormals_count></abnormals_count>         <report_service_date>9/14/2022 12:55 AM</report_service_date>         <orders_transmitted></orders_transmitted>         <report_subject>HL7 Order Copy</report_subject>         <ordering_client_id>8001265</ordering_client_id>         <originalreport>3007902524</originalreport>         <report_request_date>9/14/2022  1:24 PM</report_request_date>         <std_orders_created></std_orders_created>         <receiving_cg_suffix></receiving_cg_suffix>         <person_first_name>Raghav</person_first_name>         <reports_viewed></reports_viewed>     </OBJECT> </RESULT>';        
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody(httpBody);
            res.setStatus('OK');
            res.setStatusCode(200);
            return res;
        }
        return null;
    }
}