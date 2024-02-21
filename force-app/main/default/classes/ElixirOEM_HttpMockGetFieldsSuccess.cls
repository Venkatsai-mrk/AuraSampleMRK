global class ElixirOEM_HttpMockGetFieldsSuccess implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        // Add a dummy response with a field
        res.setBody('{"fields": [{"aggregatable": true,"aiPredictionField": false,"autoNumber": false,"byteLength": 18,"calculated": false,"calculatedFormula": null,"cascadeDelete": false,"caseSensitive": false,"compoundFieldName": null,"controllerName": null,"createable": true,"custom": false,"defaultValue": null,"defaultValueFormula": null,"defaultedOnCreate": true,"dependentPicklist": false,"deprecatedAndHidden": false,"digits": 0,"displayLocationInDecimal": false,"encrypted": false,"externalId": false,"extraTypeInfo": null,"filterable": true,"filteredLookupInfo": null,"formulaTreatNullNumberAsZero": false,"groupable": true,"highScaleNumber": false,"htmlFormatted": false,"idLookup": false,"inlineHelpText": null,"label": "Owner ID","length": 18,"mask": null,"maskType": null,"name": "OwnerId","nameField": false,"namePointing": true,"nillable": false,"permissionable": false,"picklistValues": [],"polymorphicForeignKey": true,"precision": 0,"queryByDistance": false,"referenceTargetField": null,"referenceTo": ["Group","User"],"relationshipName": "Owner","relationshipOrder": null,"restrictedDelete": false,"restrictedPicklist": false,"scale": 0,"searchPrefilterable": false,"soapType": "tns:ID","sortable": true,"type": "reference","unique": false,"updateable": true,"writeRequiresMasterRead": false}]}');
        res.setStatusCode(200);
        return res;
    }
}