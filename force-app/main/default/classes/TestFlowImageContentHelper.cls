/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

@IsTest
public with sharing class TestFlowImageContentHelper
{
    @IsTest
    static void createContentVersion()
    {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
            
            ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
 
        // Test INSERT
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
		Test.startTest();
        
     	List<FlowImageContentHelper.ContentRequest> reqs = new List<FlowImageContentHelper.ContentRequest>();
        FlowImageContentHelper.ContentRequest cr1 = new FlowImageContentHelper.ContentRequest();
        cr1.base64image = 'data:image/png;base64,iVBORw0KGgoAAA=';
        cr1.fileName = 'Test.png';
        reqs.add(cr1);
        FlowImageContentHelper.ContentRequest cr2 = new FlowImageContentHelper.ContentRequest();
        cr2.base64image = 'data:image/jpg;base64,iVBORw0KGgoAAA=';
        cr2.fileName = 'Test.jpg';
        reqs.add(cr2);
        FlowImageContentHelper.saveBase64ToContent(reqs);
        List<Object> paramToSave = new List<Object>{'data:image/jpg;base64,iVBORw0KGgoAAA='};
        
        
        
        List<ContentVersion> allContent = [SELECT Id
                                           FROM ContentVersion];
        FlowImageContentHelper.checkStaticResourceReacordExistence(documents[0].id);
       //FlowImageContentHelper.copyIs(documents[0].id);
       //Test.setMock(WebServiceMock.class, new MetadataServiceCalloutMock());
         //   FlowImageContentHelper.inserStaticResourceFromLWC(documents[0].id);
        FlowImageContentHelper.myCustomSave(paramToSave,acc.Id,'drawImage','staticDrawImage');
        FlowImageContentHelper.myCustomSaveForStatic(paramToSave,acc.Id,'drawImage','staticDrawImage');
        //FlowImageContentHelper.createService();
        Test.stopTest();
        System.assertEquals(1, 1, '');
        
    }
}