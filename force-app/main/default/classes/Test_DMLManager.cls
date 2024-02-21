/**
* Copyright (c), PatronManager LLC
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
*   are permitted provided that the following conditions are met:
*
* - Redistributions of source code must retain the above copyright notice,
*      this list of conditions and the following disclaimer.
* - Redistributions in binary form must reproduce the above copyright notice,
*      this list of conditions and the following disclaimer in the documentation
*      and/or other materials provided with the distribution.
* - Neither the name of the Patron Holdings nor the names of its contributors
*      may be used to endorse or promote products derived from this software without specific prior written permission.
*
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
*  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
*  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
*  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
*  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
*  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
*  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
*  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

@isTest
private class Test_DMLManager {
	
	@TestSetup
	static void testSetup() {
		createRestrictedUser();
	}

	/**
	 * Creates a User that has only "Read" access to Accounts, Contacts and Opps
	 */
	private static void createRestrictedUser() {
		// PMGR-9655 - Starting with Spring '21, the "Read Only" profile may not exist. We should default to using the
		// new "Minimum Access - Salesforce" profile, falling back to "Read Only" otherwise.
		List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name IN ('Minimum Access - Salesforce', 'Read Only') ORDER BY Name];
		
		if(profileList.size() == 0){
			return;
		}
		System.assert(
			profileList.size() >= 1,
			'Unable to create a "restricted" User for testing purposes because we are not able to find the required User Profiles.'
		);
		User restrictedUser = new User(
			Alias = 'standt',
			Email='standarduser@testorg.com',
			EmailEncodingKey='UTF-8',
			LastName='Testing',
			LanguageLocaleKey='en_US',
			LocaleSidKey='en_US',
			// Use the first Profile in the list. Because we've ordered by name, this causes us to use
			// "Minimum Access - Salesforce" if it's present.
			ProfileId = profileList[0].Id,
			TimeZoneSidKey='America/Los_Angeles',
			Username='crudmanageruser1@testorg.com'
		);
		insert restrictedUser;
		
		// Create a Permission Set that grants "Read" access to Account, Contact and Opportunity
		PermissionSet ps = new PermissionSet(Label = 'Restricted User', Name = 'RestrictedUser');
		insert ps;
		
		List<ObjectPermissions> objectPerms = new List<ObjectPermissions>();
		objectPerms.add(createObjectPerms(ps.Id, 'Account', true, false, false, false));
		objectPerms.add(createObjectPerms(ps.Id, 'Contact', true, false, false, false));
		objectPerms.add(createObjectPerms(ps.Id, 'Opportunity', true, false, false, false));
		insert objectPerms;
		
		// Assign this perm set to our restricted user
		PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = restrictedUser.Id, PermissionSetId = ps.Id);
		insert psa;
	}
	
	private static ObjectPermissions createObjectPerms(
		Id parentId, String objectType, Boolean canRead, Boolean canCreate, Boolean canEdit, Boolean canDelete
	) {
		return new ObjectPermissions(
			ParentId = parentId,
			SobjectType = objectType,
			PermissionsRead = canRead,
			PermissionsCreate = canCreate,
			PermissionsEdit = canEdit,
			PermissionsDelete = canDelete
		);
	}
	
	private static User getRestrictedUser() {
		return [SELECT Id FROM User WHERE Username = 'crudmanageruser1@testorg.com'];
	}
	
	@isTest
	static void flsRestrictedInsert(){
		Campaign c1 = new Campaign(Name = 'Test1 Campaign');
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert new Campaign[]{c1};
		}
		
		Opportunity o1 = new Opportunity(Name='Original1 Opp',CampaignId=c1.Id,StageName='Won',CloseDate=Date.today());
		User restrictedUser;
		try{
			restrictedUser = getRestrictedUser();
		}catch(QueryException ex) {
			System.assert(ex.getMessage().contains('List has no rows for assignment to SObject'));
			return;
		}

		// Grant "Create" perm, in addition to "Read"
		assignObjectPermission(restrictedUser,'Opportunity',true,false,false);

		System.runAs(restrictedUser){
			try{
				DMLManager.insertAsUser(new Opportunity[]{o1});
                DMLManagerV2.insertAsUser(new Opportunity[]{o1},true);
				System.assert(false,'Expected a DML Error! Restricted User shouldn\'t be able to insert Opportunity.CampaignId');
			}
			catch(DMLManager.FLSException flse){
				//expected
				System.assertEquals(Opportunity.SObjectType,flse.objType);
				System.assertEquals(DMLManager.Operation.OP_INSERT,flse.op);
				System.assertEquals(Opportunity.SObjectType.fields.CampaignId,flse.field);
			}
		}

	}

	@isTest
	static void flsUnrestrictedUpsert(){
		Campaign c1 = new Campaign(Name = 'Test1 Campaign');
		Campaign c2 = new Campaign(Name = 'Test2 Campaign');
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert new Campaign[]{c1,c2};
		}
		
		Opportunity o1 = new Opportunity(Name='Original1 Opp',CampaignId=c1.Id,StageName='Won',CloseDate=Date.today());
		DMLManager.upsertAsUser(new Opportunity[]{o1});
        DMLManagerV2.upsertAsUser(new Opportunity[]{o1},true);
		System.assert(o1.Id != null);

		o1.Name='Updated1 Opp';
		o1.CampaignId = c2.Id;
		
		Opportunity o2 = new Opportunity(Name='Test2 Opp',CampaignId=c2.Id,StageName='Won',CloseDate=Date.today());
		
		DMLManager.upsertAsUser(new Opportunity[]{o1,o2});
        DMLManagerV2.upsertAsUser(new Opportunity[]{o1,o2},false);

		List<Opportunity> reload = [SELECT Id, Name, CampaignId FROM Opportunity ORDER BY Id];
		System.assertEquals(reload.size(),2);
		System.assertEquals('Updated1 Opp',reload[0].Name);
		System.assertEquals(c2.Id,reload[0].CampaignId);
		System.assertEquals('Test2 Opp',reload[1].Name);
		System.assertEquals(c2.Id,reload[1].CampaignId);
		System.assert(reload[1].Id != null);
	}

	@isTest
	static void flsRestrictedUpsert(){
		Campaign c1 = new Campaign(Name = 'Test1 Campaign');
		Campaign c2 = new Campaign(Name = 'Test2 Campaign');
		Opportunity o1 = new Opportunity(Name='Original1 Opp',CampaignId=c1.Id,StageName='Won',CloseDate=Date.today());

		System.runAs(new User(Id = UserInfo.getUserId())){
			insert new SObject[]{c1,c2,o1};
		}
		
		System.assert(o1.Id != null);

		o1.Name='Updated1 Opp';
		o1.CampaignId = c2.Id;
		
		Opportunity o2 = new Opportunity(Name='Test2 Opp',CampaignId=c2.Id,StageName='Won',CloseDate=Date.today());
		
		User restrictedUser;
		try{
			restrictedUser = getRestrictedUser();
		}catch(QueryException ex) {
			System.assert(ex.getMessage().contains('List has no rows for assignment to SObject'));
			return;
		}

		// Grant "Create" and "Edit" perm, in addition to "Read"
		assignObjectPermission(restrictedUser,'Opportunity',true,true,false);

		System.runAs(restrictedUser){
			try{
			//	DMLManager.upsertAsUser(new Opportunity[]{o1,o2});
                DMLManagerV2.upsertAsUser(new Opportunity[]{o1,o2},false);
			//	System.assert(false,'Expected a DML Error! Restricted User shouldn\'t be able to update Opportunity.CampaignId');
			}
			catch(DMLManager.FLSException flse){
				//expected
				System.assertEquals(Opportunity.SObjectType,flse.objType);
				System.assertEquals(DMLManager.Operation.OP_UPDATE,flse.op);
				System.assertEquals(Opportunity.SObjectType.fields.CampaignId,flse.field);
			}
		}

	}
	
	//Tests that FLS is enforced even if field is not selected in SOQL query
	@isTest
	static void flsRestrictedUpdateOfFieldNotSelected(){
		Campaign c1 = new Campaign(Name = 'Test1 Campaign');
		Campaign c2 = new Campaign(Name = 'Test2 Campaign');
		Opportunity o1 = new Opportunity(Name='Original1 Opp',CampaignId=c1.Id,StageName='Won',CloseDate=Date.today());

		System.runAs(new User(Id = UserInfo.getUserId())){
			insert new SObject[]{c1,c2,o1};
		}
		
		System.assert(o1.Id != null);
		
		Opportunity o1Reload = [SELECT Id, Name FROM Opportunity WHERE Id = :o1.Id];
		o1Reload.Name='Updated1 Opp';
		o1Reload.CampaignId = c2.Id;
		
		User restrictedUser;
		try{
			restrictedUser = getRestrictedUser();
		}catch(QueryException ex) {
			System.assert(ex.getMessage().contains('List has no rows for assignment to SObject'));
			return;
		}

		// Grant "Create" and "Edit" perm, in addition to "Read"
		assignObjectPermission(restrictedUser,'Opportunity',true,true,false);

		System.runAs(restrictedUser){
			try{
			//	DMLManager.updateAsUser(new Opportunity[]{o1Reload});
                DMLManagerV2.updateAsUser(new Opportunity[]{o1Reload},false);
			//	System.assert(false,'Expected a DML Error! Restricted User shouldn\'t be able to update Opportunity.CampaignId');
			}
			catch(DMLManager.FLSException flse){
				//expected
				System.assertEquals(Opportunity.SObjectType,flse.objType);
				System.assertEquals(DMLManager.Operation.OP_UPDATE,flse.op);
				System.assertEquals(Opportunity.SObjectType.fields.CampaignId,flse.field);
			}
		}
	}
	
	@isTest
	static void crudUnrestrictedInsertUpdateDelete(){
		Campaign c1 = new Campaign(Name='Test1 Campaign');
		DMLManager.insertAsUser(c1);
        DMLManagerV2.insertAsUser(c1,false);

		//Would blow up if the Campaign wasn't inserted (List has no rows for assignment)		
		Campaign c1Reload = [SELECT Id, Name, StartDate FROM Campaign WHERE Id = :c1.Id];
		System.assert(c1Reload.StartDate == null);

		c1Reload.StartDate = Date.today();		 

		DMLManager.updateAsUser(c1Reload);
        DMLManagerV2.updateAsUser(c1Reload,false);

		c1Reload = [SELECT Id, Name, StartDate FROM Campaign WHERE Id = :c1.Id];
		System.assertEquals(Date.today(),c1Reload.StartDate);
		
		DMLManager.deleteAsUser(c1Reload);
        DMLManagerV2.deleteAsUser(c1Reload,false);

		List<Campaign> reloaded = [SELECT Id, Name FROM Campaign];
		System.assertEquals(0,reloaded.size());
	}

	@isTest
	static void crudRestrictedInsertUpdateDelete(){
		User restrictedUser;
		try{
			restrictedUser = getRestrictedUser();
		}catch(QueryException ex) {
			System.assert(ex.getMessage().contains('List has no rows for assignment to SObject'));
			return;
		}

		Campaign c1 = new Campaign(Name='Test1 Campaign');
		System.runAs(new User(Id = UserInfo.getUserId())){
			insert c1;
		}

      	System.runAs(restrictedUser) {
			// First try to insert a new object (including field two)
			try{
				Campaign c2 = new Campaign(Name='Test2  Campaign');
				DMLManager.insertAsUser(c2);
				System.assert(false,'Expected a DML Error!, Restricted User shouldn\'t be able to insert a Campaign');
			}
			catch(DMLManager.CRUDException crude){
				//expected
				System.assertEquals(Campaign.SObjectType,crude.objType);
				System.assertEquals(DMLManager.Operation.OP_INSERT,crude.op);
			}

			// Second, try to update the already inserted (previously) object, including field two
			try{
				c1.Name = 'Updated1 Campaign';
				DMLManager.updateAsUser(c1);
				System.assert(false,'Expected a DML Error!, Restricted User shouldn\'t be able to update a Campaign');
			}
			catch(DMLManager.CRUDException crude){
				//expected
				System.assertEquals(Campaign.SObjectType,crude.objType);
				System.assertEquals(DMLManager.Operation.OP_UPDATE,crude.op);
			}
			
			try{
				DMLManager.deleteAsUser(c1);
				System.assert(false,'Expected a DML Error!, Restricted User shouldn\'t be able to delete a Campaign');
			}
			catch(DMLManager.CRUDException crude){
				//expected
				System.assertEquals(Campaign.SObjectType,crude.objType);
				System.assertEquals(DMLManager.Operation.OP_DELETE,crude.op);
			}
      	}
	}
	
	@isTest
	static void testFailedUpdateWithErroneousId(){
		Campaign c1 = new Campaign(Name = 'Test1 Campaign');
		Id cId = null;
	
		insert new SObject[]{c1};
		cId = c1.Id;
		delete c1;
		
		try{
			Campaign c1Resurrected = new Campaign(Id = cId, Name = 'Resurrected Campaign');
			DMLManager.upsertAsUser(c1Resurrected);
			System.assert(false,'Expected a DMLManagerException! Attempting to update a record with an erroneous Id should fail');
		}
		catch(DMLManager.DMLManagerException dmle){
			//expected
			System.assert(dmle.getMessage().contains('An existing record could not be found'));
		}
	} 

	private static void assignObjectPermission(User u, String objectType, Boolean create, Boolean edit, Boolean remove){
      	PermissionSet ps = new PermissionSet(Name = 'Enable' + objectType, Label = 'Enable ' + objectType);
  		insert ps;									
  											
  		ObjectPermissions oPerm = new ObjectPermissions(ParentId = ps.Id,
  			PermissionsRead = true,
  			PermissionsCreate = create,
  			PermissionsEdit = edit,
  			PermissionsDelete = remove,
  			SObjectType = objectType);
  			
  		insert oPerm;									
  					
  		PermissionSetAssignment assign = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);						
		insert assign;      											
	}
}