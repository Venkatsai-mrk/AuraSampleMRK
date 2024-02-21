import { wire, api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import getGuarantorDetailsPicklist from '@salesforce/apex/OrderAPICallouts.getGuarantorDetailsPicklist';
import getGuarantorList from '@salesforce/apex/OrderAPICallouts.getGuarantorList';
import getVOBList from '@salesforce/apex/OrderAPICallouts.getVOBList';
import getPayorDetail from '@salesforce/apex/OrderAPICallouts.getPayorDetail';
import getVOBDetail from '@salesforce/apex/OrderAPICallouts.getVOBDetail';
import addOrder from '@salesforce/apex/OrderAPICallouts.addOrder';
import getLabs from '@salesforce/apex/OrderAPICallouts.getLabs';
import getFacilities from '@salesforce/apex/OrderAPICallouts.getFacilities';
import getPhysicians from '@salesforce/apex/OrderAPICallouts.getPhysicians';
import getTests from '@salesforce/apex/OrderAPICallouts.getTests';
import getInHouseTests from '@salesforce/apex/OrderAPICallouts.getInHouseTests';
import getICDs from '@salesforce/apex/OrderAPICallouts.getICDs';
//import getNameSpace from '@salesforce/apex/OrderAPICallouts.getNameSpace';
import { publish, MessageContext } from 'lightning/messageService';
import fetchRecordIdMC from '@salesforce/messageChannel/FetchLabRecordId__c';
import { NavigationMixin } from 'lightning/navigation';
//import { getRecord } from 'lightning/uiRecordApi';
//import { refreshApex } from '@salesforce/apex';
import testsBasedOnDiagnosis from '@salesforce/apex/LabTestRecommendations.testsBasedOnDiagnosis';
import getCredentials from '@salesforce/apex/OrderAPICallouts.getCredentials';
import updateOrderStatus from '@salesforce/apex/OrderAPICallouts.updateOrderStatus';
import updateOrderStatusInhouse from '@salesforce/apex/InHouseLabOrder.updateOrderStatusInHouse';

export default class AddOrderForm extends NavigationMixin(LightningElement) {
    //initializing variables
    //current account id
    @api newid;

    @api recordId;
    @track nameSpace = 'ElixirSuite__';
    ElixirSuite__Insurance_Provider__c;
    code;
    policy;
    insuranceId;
    group;
    @api rId;

    @track
    selectedinsuranceValue = '';

    sfdcBaseURL;
    error = '';

    @wire(MessageContext)
    messageContext;

    @track
    emptyValue = '';
    @track showSpinner = false;
    @track labs = [];
    @track defaultLab = [];
    @track insuranceData = [];
    @track selectedLab = '';
    @track selectTest='';
    @track labLabel = '';
    @track guarantorEditDisabled = false;
    @track insuranceEditDisabled = false;
    @track facilities = [];
    @track selectedFacility = '';
    @api wiredLaborderList = [];
    @track physicians = '';
    @track enteredBy = '';
    @track verifiedBy = '';
    @track selectedPhysician = '';
    @track selectedEnteredBy = '';
    @track selectedVerifiedBy = '';
    @track physicianId = '';
    @track enteredById = '';
    @track verifiedById = '';
    @track selectedLabDefault;
    @track selectedLabel;
    @track collectionTime = this.getDateTime();
    @track ExpectedDateTime = this.getDateTime();
    @track validationCollection;
    @track todayDate = this.getDateTime();
    @track billTypePatient = false;
    @track tests = [];
    @track selectedTests = [];
    @track ICDs = [];
    @track selectedICDs = [];
    @track orderTypeValue = 'Standard';
    @track billvalue = 'C';
    @track billValueShow = false;
    @track orderTypeVisible = false;
    @track recordId = '';
    @track returnedOrderID = '';
    refresTable;
    @track relationshipValue;
    @track lastName;
    relationship;
    @track firstName;
    @track guarantorValue;
    @track guarantorData = [];
    @track selectedGuarantorValue = '';
    @track errorList = [];
   
    @track insertedRecordIds = [];
    @track orderId;

    renderedCallback() {
        this.sfdcBaseURL = window.location.origin;
        if (this.recordId === '') {
            this.recordId = this.recordIdFromState;
            console.log(this.recordId);
            //call apex after this.recordId has value
        }

    }

    records;
    wiredRecords;
    lengthOfTests;
    @wire( getCredentials )  
    wiredRecs( value ) {
 
        this.wiredRecords = value;
        const { data, error } = value;
 
        if ( data ) {
            this.records = data;
            console.log("ahdbjshbfjhsbfsbfjsbfsjbfsijbsbf = " + JSON.stringify(this.records.ElixirSuite__Callout_Limit__c))
            this.lengthOfTests = this.records.ElixirSuite__Callout_Limit__c;
            console.log('this.lengthOfTests' + this.lengthOfTests);
            this.error = undefined;
 
        } else if ( error ) {
            this.error = error;
            this.records = undefined;
 
        }

    }




    // wire method to get current page reference
    @wire(CurrentPageReference)
    currentPageReference;

    get recordIdFromState() {
        return this.currentPageReference &&
            this.currentPageReference.state.c__recordId;
    }
    // renderedCallback() {
    //     if (this.recordId === '') {
    //         this.recordId = this.recordIdFromState;
    //         console.log(this.recordId);
    //         //call apex after this.recordId has value
    //     }
    // }

    //Method to get lab data from Lab object
    @wire(getLabs)
    wiredLabs({ error, data }) {

        var i = 0;
        if (data) {
            this.labs = [];
            this.defaultLab = [];
            this.Type=[];
            
            for (i = 0; i < data.length; i++) {

                this.labs = [...this.labs, { value: data[i][this.nameSpace + 'Lab_Id__c'], label: data[i].Name  ,type:data[i][this.nameSpace + 'Lab_Type__c']}];
                this.Type = [...this.Type, { value: data[i][this.nameSpace + 'Lab_Type__c'], label: data[i].Name }];
                
            }
            console.log("labs>>> " + JSON.stringify(this.labs));
        
           
            this.error = undefined;
            if (data.length == 1) {
               this.selectedLab = this.labs[0].value;
                
               

                getFacilities({ labId: this.selectedLab }) // method to get facility data on the basis of labs
                    .then((result) => {
                        var i = 0;

                        this.error = undefined;
                        this.facilities = [];

                        for (i = 0; i < result.length; i++) {

                            this.facilities = [...this.facilities, { value: result[i][this.nameSpace + 'Facility_Id__c'], label: result[i].Name }];
                        }
                        if (this.facilities.length == 1) {

                            this.selectedFacility = this.facilities[0].value;

                        }

                    })
                    .catch((error) => {
                        this.error = error;
                        this.showErrorToast(error.body.message);
                    });

                   
                getTests({ labId: this.selectedLab }) //method to get list of tests on the basis of labs
                    .then((result) => {
                        var i = 0;

                        this.error = undefined;
                        this.tests = [];
                        for (i = 0; i < result.length; i++) {

                            this.tests = [...this.tests, { value: result[i][this.nameSpace + 'Test_Id__c'], label: result[i][this.nameSpace + 'Test_Name__c'] }];

                        }

                    })
                    .catch((error) => {
                        this.error = error;
                        this.showErrorToast(error.body.message);

                    });

                

            }



        } else if (error) {
            this.error = error;
            this.showErrorToast(error.body.message);

        }
    }



    //Handling billoptions as client,Patient,Insurance
    get billoptions() {
        return [
            { label: 'Client', value: 'C' },
            { label: 'Patient', value: 'P' },
            { label: 'Third-Party', value: 'T' },
        ];
    }

    get orderTypeOptions() {
        return [
            { label: 'Standard', value: 'Standard' },
            { label: 'PSC', value: 'PSC' },


        ];
    }

    // method to get list of existing insurance
    handleInsuranceList() {
        getVOBList({ accountid: this.newid })
            .then((result) => {
                var i = 0;
                this.error = undefined;
                for (i = 0; i < result.length; i++) {
                    this.insuranceData = [...this.insuranceData, { value: result[i].Id, label: result[i].Name }];

                }
                if (this.insuranceValue == '') {
                    this.insuranceEditDisabled = true;
                }
                if (result.length == 1) {
                    this.insuranceValue = result[0].Id;
                    this.insuranceOnChange();
                }

            })
            .catch((error) => {
                this.error = error;
                this.showErrorToast(error.body.message);
            });

    }

    //method to set Insurance ID in Picklist
    get insuranceOptions() {

        return this.insuranceData;

    }

    isInsuranceSelected = false;
    selectedInsuranceData;

    // method to get selected Insurance value
    insuranceOnChange(event) {
        this.showSpinner = true;
        if (this.insuranceData.length == 1) {
            this.selectedinsuranceValue = this.insuranceValue;
            this.insuranceEditDisabled = false;

        } else {
            this.selectedinsuranceValue = event.detail.value;
            this.insuranceEditDisabled = false;
        }
        getVOBDetail({ accountid: this.newid, parentid: this.selectedinsuranceValue }) //method to get selected insurance details
            //getInsuranceDetails()
            .then((result) => {

                this.isInsuranceSelected = true;
                this.selectedInsuranceData = result;
                this.code = result[this.nameSpace + 'Payer__r'][this.nameSpace + 'Payer_Code__c'];
                this.policy = result[this.nameSpace + 'Insurance_Policy_ID__c'];
                console.log('VALUE FOR POLICY'+this.policy);
                console.log('DOB FOR VOB = '+result[this.nameSpace + 'Date_Of_Birth__c']);
                this.group = result[this.nameSpace + 'Insurance_Group_Number__c'];
                this.insuranceId = result.Id;
                this.error = undefined;
                this.showSpinner = false;
                //Error toast for selected Insurance if its empty
                // if(this.policy == undefined){
                //     this.showErrorToast('Please provide Primary Insurance Policy ID for selected Insurance');
                // }
                // else if(this.code == undefined){
                //     this.showErrorToast('Please provide payer code for selected Insurance');
                // }
                // else if(this.group == undefined){
                //     this.showErrorToast('Please provide Primary Insurance group number for selected Insurance');
                // }
                // else if(result[this.nameSpace + 'Date_Of_Birth__c'] == undefined){
                //     this.showErrorToast('Please provide DOB for selected Insurance');
                // }
                // else if(result[this.nameSpace + 'Insured_Last_Name__c'] == undefined){
                //     this.showErrorToast('Please provide Last name for selected Insurance');
                // }
                // else if(result[this.nameSpace + 'Insured_First_Name__c'] == undefined){
                //     this.showErrorToast('Please provide First name for selected Insurance');
                // }
                // else if(result[this.nameSpace + 'Insured_Zipcode__c'] == undefined || result[this.nameSpace + 'Insured_Zipcode__c'].length() !=5 || result[this.nameSpace + 'Insured_Zipcode__c'].length() !=9){
                //     this.showErrorToast('ZipCode length should be 5 or 9');
                // }
                // else if(result[this.nameSpace + 'Gender__c'] == undefined){
                //     this.showErrorToast('Please provide Gender for selected Insurance');
                // }
                // else if(result[this.nameSpace + 'InsPhone__c'] == undefined || result[this.nameSpace + 'InsPhone__c'].length() != 10){
                //     this.showErrorToast('Phone length should be 10');
                // }

            })
            .catch((error) => {
                this.error = error;
                this.data = undefined;
                this.showErrorToast(error.body.message);

            });
        //this.handleFieldChangeLwc();
    }

    //method to get list of existing guarantor
    handleGuarantorList() {
        getGuarantorList({ accId: this.newid })
            .then((result) => {
                var i = 0;

                this.error = undefined;

                for (i = 0; i < result.length; i++) {
                    this.guarantorData = [...this.guarantorData, { value: result[i].Id, label: result[i].Name }];
                }

                if (this.guarantorValue == '') {
                    this.guarantorEditDisabled = true;
                }
                if (result.length == 1) {
                    this.guarantorValue = result[0].Id;
                    console.log('this.guarantorValue '+this.guarantorValue);
                    this.guarantorOnChange();
                }
            })
            .catch((error) => {
                this.error = error;
                this.showErrorToast(error.body.message);
            });

    }

    //method used to set the existing guarantor ID into picklist
    get guarantorOptions() {
        return this.guarantorData;
    }

    //method used to get selected guarantor
    guarantorOnChange(event) {
        if (this.guarantorData.length == 1) {
            this.selectedGuarantorValue = this.guarantorValue;

            this.guarantorEditDisabled = false;

        } else {
            this.selectedGuarantorValue = event.detail.value;
            this.guarantorEditDisabled = false;

        }
        getGuarantorDetailsPicklist({ accId: this.newid, guarantorRecordId: this.selectedGuarantorValue }) 
            .then((result) => {
                console.log('resultresult** '+JSON.stringify(result));
                this.relationship = result.ElixirSuite__Relationship__c;
                this.firstName = result.Contact.FirstName;
                console.log('this.firstName '+this.firstName);
                this.lastName = result.Contact.LastName;
                console.log('this.lastName '+this.lastName);
                this.guarantorId = result.ContactId;
            })
            .catch((error) => {
                this.error = error;
                this.data = undefined;
                this.showErrorToast(error.body.message);
                window.console.log(this.error);

            });
        // this.handleFieldChangeLwc();
    }
    orderTypeHandleChange(event) {
        this.orderTypeValue = event.detail.value;


        if (this.orderTypeValue == 'PSC') {
            this.orderTypeVisible = true;
            // this.collectionTime ='';
        } else {
            this.orderTypeVisible = false;
            // this.ExpectedDateTime = '';
        }
        console.log('order type ' + this.orderTypeValue);
    }

    // Hadling the billtype on onChange
    billhandleChange(event) {
        this.billvalue = event.detail.value;
        this.isInsuranceSelected = false;
        // billtype is third-party
        if (this.billvalue == 'T') {
            this.billTypePatient = true;
            this.billValueShow = true;
            this.guarantorData = [];
            this.insuranceData = [];
            this.guarantorValue = [];
            this.relationship = '';
            this.firstName = '';
            this.lastName = '';
            this.insuranceValue = [];
            this.code = '';
            this.policy = '';
            this.group = '';
            this.handleGuarantorList();
            this.handleInsuranceList();
        }

        // billtype is patient
        else if (this.billvalue == 'P') {
            this.billValueShow = false;
            this.billTypePatient = true;
            this.insuranceData = [];
            this.guarantorData = [];
            this.guarantorValue = [];
            this.relationship = '';
            this.firstName = '';
            this.lastName = '';
            this.insuranceValue = [];
            this.code = '';
            this.policy = '';
            this.group = '';
            this.handleGuarantorList();
        } else {
            this.billValueShow = false;
            this.billTypePatient = false;
        }
        this.handleFieldChangeLwc();
    }

    // Handle the guarantor accordian section
    handleToggleSectionGuarantor() {
        getGuarantorDetailsPicklist({ accId: this.newid, guarantorRecordId: this.selectedGuarantorValue })
            .then((result) => {

                //console.log(JSON.stringify(result));
                this.relationship = result.ElixirSuite__Relationship__c;
                this.firstName = result.Contact.FirstName;
                console.log('this.firstName '+this.firstName);
                this.lastName = result.Contact.LastName;
                console.log('this.lastName '+this.lastName);
                this.guarantorId = result.ContactId;

            })
            .catch((error) => {
                this.error = error;
                this.data = undefined;

            });
    }

    // method used to navigate on insurance detail page
    handleInsuranceEdit() {
        if (this.insuranceId != '') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.insuranceId,
                    objectApiName: this.nameSpace + 'VOB__c',
                    actionName: 'view'
                }
            });
        }
    }

    // method used to navigate on guarantor detail page
    handleGuarantorEdit() {
        if (this.guarantorId != '') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.guarantorId,
                    objectApiName: this.nameSpace + 'Guarantor__c',
                    actionName: 'view'
                }
            });
        }
    }

    // method used to navigate on guarantor new page
    handleGuarantorNew() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Contact',
                actionName: 'new'
            }
        });
    }

    // method used to navigate on insurance new page
    handleInsuranceNew() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: this.nameSpace + 'VOB__c',
                actionName: 'new'
            }
        });
    }

    // method will handle insurance accordian section
    handleToggleSection() {
        getPayorDetail()

            .then((result) => {
                console.log(result);
                this.error = undefined;
                console.log(this.code);
            })
            .catch((error) => {
                this.error = error;
                this.data = undefined;
                this.showErrorToast(error.body.message);

            });

    }
       @track Labtype='';
       @track isButtonVisible = true; // Set this based on your condition

       // Your other component logic
   
       // Example of changing visibility dynamically
       ButtonNotVisibility() {
           this.isButtonVisible = false;
       }
       ButtonVisibility() {
        this.isButtonVisible = true;
    }
    //method will handle the lab values on onchange
    handleLabChange(event) {
        console.log("Before Function");
        this.selectedTests = '';
        this.selectedLab = event.detail.value;
        let labError = this.template.querySelector(".labError");
        labError.setCustomValidity("");
        labError.reportValidity();
        console.log("selectedLab..... " + this.selectedLab);
       

        const selectedLabObject = this.labs.find(lab => lab.value === this.selectedLab);
       
        if (selectedLabObject) {
            this.Labtype=selectedLabObject.type;
            console.log("Lab Type:====== " + this.Labtype);
        } else {
            console.log("Lab not found in the labs array.");
        }


        getFacilities({ labId: this.selectedLab }) // fetch facility data on the basis of labs
            .then((result) => {
                var i = 0;
                this.error = undefined;
                this.facilities = [];
                for (i = 0; i < result.length; i++) {

                    this.facilities = [...this.facilities, { value: result[i][this.nameSpace + 'Facility_Id__c'], label: result[i].Name }];
                }
                if (this.facilities.length == 1) {
                    this.selectedFacility = this.facilities[0].value;
                }

            })
            .catch((error) => {
                this.error = error;
                this.showErrorToast(error.body.message);

            });

        // fetch tests data on the basis of labs
        if(this.Labtype=='Manual'){
            this.ButtonNotVisibility();
            getInHouseTests()
            .then((result) => {
                var i = 0;
console.log('Manual test result1'+JSON.stringify(result));
                this.error = undefined;
                this.tests = [];
                for (i = 0; i < result.length; i++) {

                    this.tests = [...this.tests, { value: result[i][this.nameSpace +'Test_Id__c'], label: result[i][this.nameSpace +'Test_Name__c'] }];

                }

            })
            .catch((error) => {
                this.error = error;
                this.showErrorToast(error.body.message);

            });
        }
       else{
        this.ButtonVisibility();
        getTests({ labId: this.selectedLab })
            .then((result) => {
                var i = 0;

                this.error = undefined;
                this.tests = [];
                for (i = 0; i < result.length; i++) {

                    this.tests = [...this.tests, { value: result[i][this.nameSpace + 'Test_Id__c'], label: result[i][this.nameSpace + 'Test_Name__c'] }];

                }

            })
            .catch((error) => {
                this.error = error;
                this.showErrorToast(error.body.message);

            });
        }
        testsBasedOnDiagnosis({ accountid: this.newid, labId: this.selectedLab })
            .then((result) => {
                var selectedRows = result;
                console.log('Parent selectedRecord 1  ', selectedRows[0]);
                var i = 0;
                for (i = 0; i < selectedRows.length; i++) {

                    var flag = 0;
                    var j = 0;
                    for (j = 0; j < this.tests.length; j++) {
                        if (this.tests[j].value == selectedRows[i][this.nameSpace + 'Test_Id__c']) {
                            flag = 1;
                            break;
                        }
                    }
                    if (flag == 0) {
                        this.tests = [...this.tests, { value: selectedRows[i][this.nameSpace + 'Test_Id__c'], label: selectedRows[i][this.nameSpace + 'Test_Name__c'] }];
                    }
                    if (!this.selectedTests.includes(selectedRows[i][this.nameSpace + 'Test_Id__c'])) {
                        this.selectedTests = [...this.selectedTests, selectedRows[i][this.nameSpace + 'Test_Id__c']];
                    }
                }

            })
            .catch((error) => {
                this.error = error;
                this.showErrorToast(error.body.message);

            });


        //Update Child Attribute
        const modal = this.template.querySelector("c-add-more-tests");
        modal.labid = this.selectedLab;
        this.handleFieldChangeLwc();
    }
    //return fetched lab records
    get labOptions() {

        return this.labs;

    }



    handleFacilityChange(event) {
        const selectedOption = event.detail.value;
        this.selectedFacility = selectedOption;
        let facilityError = this.template.querySelector(".facilityError");
        facilityError.setCustomValidity("");
        facilityError.reportValidity();
        this.handleFieldChangeLwc();
    }

    //return fetched facility records
    get facilityOptions() {

        return this.facilities;
    }

    // fetch Physicians data from  Physician Object
    @wire(getPhysicians)
    wiredgetPhysicians({ error, data }) {
        let physicianName;
        var i = 0;
        if (data) {
            this.physicians = [];
            this.enteredBy = [];
            this.verifiedBy = [];
            for (i = 0; i < data.length; i++) {
               /* physicianName = data[i]['FirstName'];
                console.log('physicianName '+physicianName);
                let physicianId = data[i]['Id'];
                console.log('physicianId '+physicianId);
                if (data[i]['LastName']) {
                    physicianName += ',' + data[i]['LastName'];
                }*/
                 //physicianName = data[i]['FirstName'];
                 let physicianId = data[i]['Id'];
                 console.log('physicianId '+physicianId);
             if (data[i]['FirstName']) {
                 physicianName = data[i]['FirstName']+','+data[i]['LastName'];
               }else{
                 physicianName = data[i]['LastName'];
               }
      console.log('physicianName '+physicianName);
      this.physicians = [...this.physicians, { value: physicianName, label: physicianName, phyId: physicianId }];
      this.enteredBy = this.physicians;
      this.verifiedBy = this.physicians;
            }
            console.log('physicianName data.length '+data.length);//physicianName data.length 1
            if (data.length == 1) {
                console.log('physicianName in data.length 1'+physicianName);
                this.selectedPhysician = physicianName;
                this.selectedEnteredBy = physicianName;
                this.selectedVerifiedBy = physicianName;
                this.physicianId = this.getPhysicianIdByName(this.selectedPhysician);
                this.enteredById = this.physicianId
                this.verifiedById = this.physicianId
            }

            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.showErrorToast(error.body.message);

        }
    }
    handleOrderingPhysicianChange(event) {
        const selectedOption = event.detail.value;

        this.selectedPhysician = selectedOption;
        console.log('selectedPhysician '+this.selectedPhysician);
        this.physicianId = this.getPhysicianIdByName(this.selectedPhysician);
        
        console.log('this.physicianId '+this.physicianId);
        let physicianError = this.template.querySelector(".physicianError");
        physicianError.setCustomValidity("");
        physicianError.reportValidity();

        this.handleFieldChangeLwc();

    }
    getPhysicianIdByName(physicianName) {
        for (let i = 0; i < this.physicians.length; i++) {
            if (this.physicians[i].label === physicianName) {
                return this.physicians[i].phyId;
            }
        }
        return null; // Return null if the physician name is not found
    }
    //return fetched Physician records
    handleEnteredByChange(event) {
        console.log('handleEnteredByChange called');
        const selectedOption = event.detail.value;
        console.log('selectedOption in EnteredBy '+selectedOption);
        this.selectedEnteredBy = selectedOption;
        this.enteredById = this.getPhysicianIdByName(this.selectedEnteredBy);
        console.log('this.verifiedById in verified by '+this.enteredById);
        let enteredByError = this.template.querySelector(".enteredByError");
        enteredByError.setCustomValidity("");
        enteredByError.reportValidity();

        this.handleFieldChangeLwc();

    }
    handleVerifiedByChange(event) {
        console.log('handleVerifiedByChange called');
        const selectedOption = event.detail.value;
        console.log('selectedOption in verified by '+selectedOption);
        this.selectedVerifiedBy = selectedOption;
        this.verifiedById = this.getPhysicianIdByName(this.selectedVerifiedBy);
        console.log('this.verifiedById in verified by '+this.verifiedById);
        let verifiedByError = this.template.querySelector(".verifiedByError");
        console.log('verifiedByError '+verifiedByError);
        verifiedByError.setCustomValidity("");
        verifiedByError.reportValidity();

        this.handleFieldChangeLwc();

    }
    get orderingPhysicianOptions() {

        return this.physicians;
    }
    get enteredByOptions() {

        return this.enteredBy;
    }
    get verifiedByOptions() {

        return this.verifiedBy;
    }

    // method stroe the collection data/time value
    handleCollectionTimeChange(event) {
        this.collectionTime = event.target.value;
        this.handleFieldChangeLwc();

    }

    handleExpectedDateTimeChange(event) {
        this.ExpectedDateTime = event.target.value;
        this.handleFieldChangeLwc();
    }

    //return fetched Test records
    get testsOptions() {
        return this.tests;
    }

    handleTestsChange(e) {
        this.selectedTests = e.detail.value;
        console.log('handleTestsChange'+this.selectedTests);
        this.handleFieldChangeLwc();
    }

    // Initialize preferred ICD options from Salesforce ICD object
    @wire(getICDs, {accId: '$newid'})
    wiredgetICDs({ error, data }) {
        console.log('ICD Wire Excecuted');
        console.log('data related to ICD ', JSON.stringify(data));
        var i = 0;
        if (data) {
            this.ICDs = [];
            for (i = 0; i < data.length; i++) {
                //changes done to replace ICD__c with ICD_Codes__c
                // this.ICDs = [...this.ICDs, { value: data[i][this.nameSpace + 'ICD_Id__c'], label: data[i].Name }];
                if(data[i][this.nameSpace + 'Code_Description1__c'] == undefined || data[i][this.nameSpace + 'Code_Description1__c'] == ''){
                    this.ICDs = [...this.ICDs, { value: data[i]['Name'], label: data[i]['Name'] }];
                }else{
                    this.ICDs = [...this.ICDs, { value: data[i]['Name'], label: data[i]['Name'] + ' - ' + data[i][this.nameSpace + 'Code_Description1__c'] }];
                }


            }

            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.showErrorToast(error.body.message);

        }
    }
    //return fetched ICD  records
    get ICD10Options() {


        return this.ICDs;
    }
    // handle icd data on onchange
    handleICD10Change(event) {

        this.selectedICDs = event.detail.value;
        this.handleFieldChangeLwc();
    }

    // success toast message
    showSuccessToast(message) {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    //error toast message
    showErrorToast(message) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }


    // method to create lab order
    handleSubmit() {
        //Checking if all the required fields are filled
        console.log('handle submit selected test =='+ this.selectedTests.length +'lengh=th' +this.lengthOfTests);
        if (this.selectedLab == '' || this.selectedPhysician == '' || this.selectedEnteredBy == '' || this.selectedVerifiedBy == '' || this.selectedTests == '' || this.selectedFacility == '' || (this.billvalue == 'P' && this.selectedGuarantorValue == '') || (this.billvalue == 'T' && this.selectedinsuranceValue == '')) {
            //this.showErrorToast('Please fill in the mandatory Fields');
            if (this.selectedLab == '') {
                let labError = this.template.querySelector(".labError");
                labError.setCustomValidity("This field is mandatory");
                labError.reportValidity();

            }
            if (this.selectedPhysician == '') {
                let physicianError = this.template.querySelector(".physicianError");
                physicianError.setCustomValidity("This field is mandatory");
                physicianError.reportValidity();

            }
            if (this.selectedEnteredBy == '') {
                let physicianError = this.template.querySelector(".enteredByError");
                physicianError.setCustomValidity("This field is mandatory");
                physicianError.reportValidity();

            }
            if (this.selectedVerifiedBy == '') {
                let physicianError = this.template.querySelector(".verifiedByError");
                physicianError.setCustomValidity("This field is mandatory");
                physicianError.reportValidity();

            }
            if (this.selectedFacility == '') {
                let facilityError = this.template.querySelector(".facilityError");
                facilityError.setCustomValidity("This field is mandatory");
                facilityError.reportValidity();

            }
            if (this.selectedTests == '') {
                /*let testError = this.template.querySelector(".testError");
                testError.setCustomValidity("This field is mandatory");
                testError.reportValidity();**/
                this.showErrorToast('Please Select atleast one Test');

            }
            if (this.billvalue == 'P' && this.selectedGuarantorValue == '') {
                let guarantorError = this.template.querySelector(".guarantorError");
                guarantorError.setCustomValidity("This field is mandatory");
                guarantorError.reportValidity();

            }
            if (this.billvalue == 'T' && this.selectedinsuranceValue == '') {
                let insuranceError = this.template.querySelector(".insuranceError");
                insuranceError.setCustomValidity("This field is mandatory");
                insuranceError.reportValidity();

            }

        }
         else {

            let result = '';
            if(this.isInsuranceSelected){
                result = this.selectedInsuranceData;
            }
            if(result!=''){
            if(this.isInsuranceSelected === true && result[this.nameSpace + 'Insurance_Policy_ID__c'] == undefined){
                this.showErrorToast('Please provide Primary Insurance Policy ID for selected Insurance');
                return;
            }
            if(this.isInsuranceSelected === true && result[this.nameSpace + 'Payer__r'][this.nameSpace + 'Payer_Code__c'] == undefined){
                this.showErrorToast('Please provide payer code for selected Insurance');
                return;
            }
            if(this.isInsuranceSelected === true && result[this.nameSpace + 'Date_Of_Birth__c'] == undefined){
                this.showErrorToast('Please provide DOB for selected Insurance');
                return;
            }
            if(this.isInsuranceSelected === true && result[this.nameSpace + 'Insured_Last_Name__c'] == undefined){
                this.showErrorToast('Please provide Last name for selected Insurance');
                return;
            }
            if(this.isInsuranceSelected === true && result[this.nameSpace + 'Insured_First_Name__c'] == undefined){
                this.showErrorToast('Please provide First name for selected Insurance');
                return;
            }
            if(this.isInsuranceSelected === true && result[this.nameSpace + 'Insured_Zipcode__c'] == undefined || result[this.nameSpace + 'Insured_Zipcode__c'].length !=5 && result[this.nameSpace + 'Insured_Zipcode__c'].length !=9){
                this.showErrorToast('Selected Insurance ZipCode length should be 5 or 9');
                return;
            }
            if(this.isInsuranceSelected === true && result[this.nameSpace + 'Gender__c'] == undefined){
                this.showErrorToast('Please provide Gender for selected Insurance');
                return;
            }
            if(this.isInsuranceSelected === true && result[this.nameSpace + 'InsPhone__c'] == undefined || result[this.nameSpace + 'InsPhone__c'].length != 10){
                this.showErrorToast('Selected Insurance Phone length should be 10');
                return;
            }
        }

            if (this.selectedTests.length > parseInt(this.lengthOfTests)) {
                
                this.showErrorToast('Maximum '+parseInt(this.lengthOfTests)+' tests can be selected in one Order');
                return;
            }

            if (this.collectionTime > this.todayDate) {
                this.showErrorToast("Please check the collection date/time");
                let inputText = this.template.querySelector(".inputTextCollection");
                inputText.setCustomValidity("Collection Date/Time Cannot be future Date/Time");
                inputText.reportValidity();
            } else {
                console.log('****this.orderTypeValue '+this.orderTypeValue);
 console.log('****this.newid '+this.newid);
 console.log('****this.billvalue '+this.billvalue);
 console.log('****this.selectedLab '+this.selectedLab);
 console.log('****this.selectedFacility '+this.selectedFacility);
 console.log('****this.selectedPhysician '+this.selectedPhysician);
 console.log('****this.selectedEnteredBy '+this.selectedEnteredBy);
 console.log('****this.selectedVerifiedBy '+this.selectedVerifiedBy);
 console.log('****this.physicianId '+this.physicianId);
 console.log('****this.enteredById '+this.enteredById);
 console.log('****this.verifiedById '+this.verifiedById);
 console.log('****this.selectedTests '+this.selectedTests);
 console.log('****this.selectedICDs '+this.selectedICDs);
 console.log('****this.collectionTime '+this.collectionTime);
 console.log('****this.ExpectedDateTime '+this.ExpectedDateTime);
 console.log('****this.code '+this.code);
 console.log('****this.policy '+this.policy);
 console.log('****this.group '+this.group);
 console.log('****this.selectedinsuranceValue '+this.selectedinsuranceValue);
 console.log('****this.selectedGuarantorValue '+this.selectedGuarantorValue);
                this.showSpinner = true;
                addOrder({ ordertypevalue: this.orderTypeValue, accountid: this.newid, billtype: this.billvalue, labId: this.selectedLab, facilityId: this.selectedFacility, physiciasnName: this.selectedPhysician,selectedEnteredBy: this.selectedEnteredBy,selectedVerifiedBy: this.selectedVerifiedBy,physicianId:this.physicianId,enteredById:this.enteredById,verifiedById:this.verifiedById,  tests: this.selectedTests, ICDs: this.selectedICDs, collectionDateTime: this.collectionTime, DateTimeCollection: this.collectionTime, expectedDateTime: this.ExpectedDateTime, dateTimeExpected: this.ExpectedDateTime, code: this.code, policy: this.policy, groupvalue: this.group, parentInsuranceID: this.selectedinsuranceValue, guarantorRecordId: this.selectedGuarantorValue })


                    .then((result) => {
                        console.log('result'+JSON.stringify(result));
                        if(result[result.length - 1].includes('ERROR'))
                        {
                            this.showErrorToast(result[result.length - 1]);
                        }
                        else{this.showSuccessToast('Order successfully created ');}
                        if(this.Labtype=='Manual'){
                            this.insertedRecordIds = result;
                            console.log('insertedRecordIds'+ this.insertedRecordIds);
                        }else{
                            this.insertedRecordIds = result.slice(0, -1); // Assuming the last element is orderId
                            this.orderId = result[result.length - 1];
                            //this.returnedOrderID = ;
                            //this.error = undefined;
                            console.log('insertedRecordIds'+ this.insertedRecordIds);
                            console.log('orderId'+ this.orderId);
                        }
                                               this.showSpinner = false;
                        this.handleClear();
                        // this.handleClearUnsavedChanges();
                        /*this[NavigationMixin.Navigate]({

                            type: "standard__component",
                            attributes: {
                                componentName: "ElixirSuite__labOrdersCHCSuTab"
                            },
                            state: {
                                c__crecordId: this.newid
                            }
                        });*/
                        var close = true;
                        const closeclickedevt = new CustomEvent('closeclicked', {
                            detail: { close },
                        });
                        // Fire the custom event
                        this.dispatchEvent(closeclickedevt);
                    

                    })
                    .catch((error) => {
                        
                        this.error = error;
                        this.returnedOrderID = undefined;
                        this.showErrorToast(error.body.message);
                    });

                //this.handleCancel();

            }
        }

    }

    //Clear all the values on click of clear button
    handleClear() {
        this.billvalue = 'C';
        this.selectedLab = ' ';
        this.selectedLab = null;
        this.selectedFacility = '';
        this.selectedPhysician = '';
        this.selectedEnteredBy = '';
        this.selectedVerifiedBy = '';
        this.selectedFacility = null;
        this.selectedPhysician = null;
        this.collectionTime = '';
        this.tests = [];
        this.selectedICDs = [];
        this.getDateTime();
        this.insuranceValue = [];
        this.code = '';
        this.policy = '';
        this.group = '';
        this.guarantorValue = [];
        this.relationship = '';
        this.firstName = '';
        this.lastName = '';
        this.billValueShow = false;
        this.billTypePatient = false;

        this.handleClearUnsavedChanges();
        this.handleCancel();


    }

    handleCancel() {
        this[NavigationMixin.Navigate]({

            type: "standard__component",
            attributes: {
                componentName: "ElixirSuite__labOrdersCHCSuTab"
            },
            state: {
                c__crecordId: this.newid
            }
        });

        var close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
        // Fire the custom event
        this.dispatchEvent(closeclickedevt);

        //this.showCreateOrder = false;
        const payload = { createOrder: false };
        publish(this.messageContext, fetchRecordIdMC, payload);

    }
    //Get local current date and time
    getDateTime() {
        var now = new Date();
        console.log('now ' + now);
        var year = now.getFullYear();
        var month = now.getMonth() + 1;
        var day = now.getDate();
        var hour = now.getHours();
        var minute = now.getMinutes();
        var second = now.getSeconds();
        var amPm = 'AM';
        var h = Number(hour.toString());
        if (h >= 12) {

            amPm = 'PM';

        }

        hour = '' + h;


        if (month.toString().length == 1) {
            month = '0' + month;
        }
        if (day.toString().length == 1) {
            day = '0' + day;
        }

        if (minute.toString().length == 1) {
            minute = '0' + minute;
        }
        if (second.toString().length == 1) {
            second = '0' + second;
        }
        if (hour.toString().length == 1) {
            hour = '0' + hour;
        }

        var dateTime = year + '-' + month + '-' + day + 'T' + hour + ':' + minute + ':00Z';
        this.collectionTime = dateTime;
        this.validationCollection = now;
        console.log('validation' + this.validationCollection);
        console.log('collection time' + this.collectionTime);
        window.console.log('DateTime from func: ' + dateTime);
        return dateTime;

    }


    //Modal Functionality for Tests and ICDs

    //Activate Test Modal
    handleShowModal() {
        console.log("function called");
        console.log('Labtype'+this.Labtype);
        const modal = this.template.querySelector("c-add-more-tests");
        modal.labid = this.selectedLab;
        modal.labtype=this.Labtype;
        modal.show();

    }

    //Handle custom onTestAdded Event
    handelTestsAdded(event) {
        var selectedRows = event.detail;
        console.log('Parent selectedRecord 1  ', selectedRows[0]);
        console.log('Test inside handelTestsAdded', this.tests);
        var i = 0;
        for (i = 0; i < selectedRows.length; i++) {

            var flag = 0;
            var j = 0;
            for (j = 0; j < this.tests.length; j++) {
                if (this.tests[j].value == selectedRows[i][this.nameSpace + 'Test_Id__c']) {
                    flag = 1;
                    break;
                }
                
                    
               
            }
            if (flag == 0) {
                console.log('inside handlertestadded type'+this.Labtype);
                if(this.Labtype=='Manual'){
                    this.tests = [...this.tests, { value: selectedRows[i][this.nameSpace + 'Test_Name__c'], label: selectedRows[i][this.nameSpace + 'Test_Name__c'] }];
                }else{
                    this.tests = [...this.tests, { value: selectedRows[i][this.nameSpace + 'Test_Id__c'], label: selectedRows[i][this.nameSpace + 'Test_Name__c'] }];
                }
               
            }
            if (!this.selectedTests.includes(selectedRows[i][this.nameSpace + 'Test_Id__c'])) {
                this.selectedTests = [...this.selectedTests, selectedRows[i][this.nameSpace + 'Test_Id__c']];
            }
            if (!this.selectedTests.includes(selectedRows[i][this.nameSpace + 'Test_Name__c'])) {
                this.selectedTests = [...this.selectedTests, selectedRows[i][this.nameSpace + 'Test_Name__c']];
            }
            console.log('selectedTests'+  this.selectedTests);
        }

    }

    //Activate ICD Modal
    handleICDShowModal() {
        const modal = this.template.querySelector("c-add-more-i-c-ds");
        modal.show();
        const event = new ShowToastEvent({
            message: 'Additional diagnosis codes added will not be added to the patient chart',
            variant: 'info',
			mode : 'dismissible'
        });
        this.dispatchEvent(event);
    }

    //Handle custom onICDAdded Event
    handelICDsAdded(event) {
        var selectedRows = event.detail;
        console.log('Parent ICD selectedRecord 1  ', selectedRows[0]);
        var i = 0;
        for (i = 0; i < selectedRows.length; i++) {

            var flag = 0;
            var j = 0;
            for (j = 0; j < this.ICDs.length; j++) {
                if (this.ICDs[j].value == selectedRows[i]['Name']) {
                    flag = 1;
                    break;
                }
            }
            if (flag == 0) {
                this.ICDs = [...this.ICDs, { value: selectedRows[i]['Name'], label: selectedRows[i][this.nameSpace + 'Code_Description1__c'] }];
            }
            if (!this.selectedICDs.includes(selectedRows[i]['Name'])) {
                this.selectedICDs = [...this.selectedICDs, selectedRows[i]['Name']];
            }
        }

    }


    // Handle unsaved Changes
    handleFieldChangeLwc() {
        const isDirty = true;
        const fieldChangeEvent = new CustomEvent('fieldchange', {

            detail: { isDirty }

        });

        this.dispatchEvent(fieldChangeEvent);

    }
    handleClearUnsavedChanges() {
        //this.handleCancel();
        const isDirty = false;
        const fieldChangeEvent = new CustomEvent('fieldchange', {

            detail: { isDirty }

        });
        this.dispatchEvent(fieldChangeEvent);



    }

    handleGuarantorRefresh() {
        this.guarantorValue = [];
        this.guarantorData = [];
        this.selectedGuarantorValue = '';
        this.relationship = '';
        this.firstName = '';
        this.lastName = '';
        this.handleGuarantorList();
    }
    handleInsuranceRefresh() {
        this.insuranceValue = [];
        this.insuranceData = [];
        this.selectedinsuranceValue = '';
        this.code = '';
        this.policy = '';
        this.group = '';
        this.handleInsuranceList();
    }

    handleSubmitTransmit(){
        console.log('inside handleSubmitTransmit'+this.insertedRecordIds);
        this.Submit();

       
    }

    Submit() {
        //Checking if all the required fields are filled
        console.log('handle submit selected test =='+ this.selectedTests.length +'lengh=th' +this.lengthOfTests);
        if (this.selectedLab == '' || this.selectedPhysician == '' || this.selectedEnteredBy == '' || this.selectedVerifiedBy == '' || this.selectedTests == '' || this.selectedFacility == '' || (this.billvalue == 'P' && this.selectedGuarantorValue == '') || (this.billvalue == 'T' && this.selectedinsuranceValue == '')) {
            //this.showErrorToast('Please fill in the mandatory Fields');
            if (this.selectedLab == '') {
                let labError = this.template.querySelector(".labError");
                labError.setCustomValidity("This field is mandatory");
                labError.reportValidity();

            }
            if (this.selectedPhysician == '') {
                let physicianError = this.template.querySelector(".physicianError");
                physicianError.setCustomValidity("This field is mandatory");
                physicianError.reportValidity();

            }
            if (this.selectedEnteredBy == '') {
                let physicianError = this.template.querySelector(".enteredByError");
                physicianError.setCustomValidity("This field is mandatory");
                physicianError.reportValidity();

            }
            if (this.selectedVerifiedBy == '') {
                let physicianError = this.template.querySelector(".verifiedByError");
                physicianError.setCustomValidity("This field is mandatory");
                physicianError.reportValidity();

            }
            if (this.selectedFacility == '') {
                let facilityError = this.template.querySelector(".facilityError");
                facilityError.setCustomValidity("This field is mandatory");
                facilityError.reportValidity();

            }
            if (this.selectedTests == '') {
                /*let testError = this.template.querySelector(".testError");
                testError.setCustomValidity("This field is mandatory");
                testError.reportValidity();**/
                this.showErrorToast('Please Select atleast one Test');

            }
            if (this.billvalue == 'P' && this.selectedGuarantorValue == '') {
                let guarantorError = this.template.querySelector(".guarantorError");
                guarantorError.setCustomValidity("This field is mandatory");
                guarantorError.reportValidity();

            }
            if (this.billvalue == 'T' && this.selectedinsuranceValue == '') {
                let insuranceError = this.template.querySelector(".insuranceError");
                insuranceError.setCustomValidity("This field is mandatory");
                insuranceError.reportValidity();

            }

        }
         else {

            let result = '';
            if(this.isInsuranceSelected){
                result = this.selectedInsuranceData;
            }
            if(result!=''){
            if(this.isInsuranceSelected === true && result[this.nameSpace + 'Insurance_Policy_ID__c'] == undefined){
                this.showErrorToast('Please provide Primary Insurance Policy ID for selected Insurance');
                return;
            }
            if(this.isInsuranceSelected === true && result[this.nameSpace + 'Payer__r'][this.nameSpace + 'Payer_Code__c'] == undefined){
                this.showErrorToast('Please provide payer code for selected Insurance');
                return;
            }
            if(this.isInsuranceSelected === true && result[this.nameSpace + 'Date_Of_Birth__c'] == undefined){
                this.showErrorToast('Please provide DOB for selected Insurance');
                return;
            }
            if(this.isInsuranceSelected === true && result[this.nameSpace + 'Insured_Last_Name__c'] == undefined){
                this.showErrorToast('Please provide Last name for selected Insurance');
                return;
            }
            if(this.isInsuranceSelected === true && result[this.nameSpace + 'Insured_First_Name__c'] == undefined){
                this.showErrorToast('Please provide First name for selected Insurance');
                return;
            }
            if(this.isInsuranceSelected === true && result[this.nameSpace + 'Insured_Zipcode__c'] == undefined || result[this.nameSpace + 'Insured_Zipcode__c'].length !=5 && result[this.nameSpace + 'Insured_Zipcode__c'].length !=9){
                this.showErrorToast('Selected Insurance ZipCode length should be 5 or 9');
                return;
            }
            if(this.isInsuranceSelected === true && result[this.nameSpace + 'Gender__c'] == undefined){
                this.showErrorToast('Please provide Gender for selected Insurance');
                return;
            }
            if(this.isInsuranceSelected === true && result[this.nameSpace + 'InsPhone__c'] == undefined || result[this.nameSpace + 'InsPhone__c'].length != 10){
                this.showErrorToast('Selected Insurance Phone length should be 10');
                return;
            }
        }

            if (this.selectedTests.length > parseInt(this.lengthOfTests)) {
                
                this.showErrorToast('Maximum '+parseInt(this.lengthOfTests)+' tests can be selected in one Order');
                return;
            }

            if (this.collectionTime > this.todayDate) {
                this.showErrorToast("Please check the collection date/time");
                let inputText = this.template.querySelector(".inputTextCollection");
                inputText.setCustomValidity("Collection Date/Time Cannot be future Date/Time");
                inputText.reportValidity();
            } else {
                console.log('****this.orderTypeValue '+this.orderTypeValue);
 console.log('****this.newid '+this.newid);
 console.log('****this.billvalue '+this.billvalue);
 console.log('****this.selectedLab '+this.selectedLab);
 console.log('****this.selectedFacility '+this.selectedFacility);
 console.log('****this.selectedPhysician '+this.selectedPhysician);
 console.log('****this.selectedEnteredBy '+this.selectedEnteredBy);
 console.log('****this.selectedVerifiedBy '+this.selectedVerifiedBy);
 console.log('****this.physicianId '+this.physicianId);
 console.log('****this.enteredById '+this.enteredById);
 console.log('****this.verifiedById '+this.verifiedById);
 console.log('****this.selectedTests '+this.selectedTests);
 console.log('****this.selectedICDs '+this.selectedICDs);
 console.log('****this.collectionTime '+this.collectionTime);
 console.log('****this.ExpectedDateTime '+this.ExpectedDateTime);
 console.log('****this.code '+this.code);
 console.log('****this.policy '+this.policy);
 console.log('****this.group '+this.group);
 console.log('****this.selectedinsuranceValue '+this.selectedinsuranceValue);
 console.log('****this.selectedGuarantorValue '+this.selectedGuarantorValue);
                this.showSpinner = true;
                addOrder({ ordertypevalue: this.orderTypeValue, accountid: this.newid, billtype: this.billvalue, labId: this.selectedLab, facilityId: this.selectedFacility, physiciasnName: this.selectedPhysician,selectedEnteredBy: this.selectedEnteredBy,selectedVerifiedBy: this.selectedVerifiedBy,physicianId:this.physicianId,enteredById:this.enteredById,verifiedById:this.verifiedById,  tests: this.selectedTests, ICDs: this.selectedICDs, collectionDateTime: this.collectionTime, DateTimeCollection: this.collectionTime, expectedDateTime: this.ExpectedDateTime, dateTimeExpected: this.ExpectedDateTime, code: this.code, policy: this.policy, groupvalue: this.group, parentInsuranceID: this.selectedinsuranceValue, guarantorRecordId: this.selectedGuarantorValue })


                    .then((result) => {
                        if(result[result.length - 1].includes('ERROR'))
                        {
                            this.showErrorToast(result[result.length - 1]);
                        }
                        else{this.showSuccessToast('Order successfully created ');
                        console.log('result'+ result);
                        if(this.Labtype=='Manual'){
                            this.insertedRecordIds = result;
                            console.log('insertedRecordIds'+ this.insertedRecordIds);
                        }else{
                            this.insertedRecordIds = result.slice(0, -1); // Assuming the last element is orderId
                            this.orderId = result[result.length - 1];
                            //this.returnedOrderID = ;
                            //this.error = undefined;
                            console.log('insertedRecordIds'+ this.insertedRecordIds);
                            console.log('orderId'+ this.orderId);
                        }
                        
                        if(this.insertedRecordIds != null){
                            this.handleTransmit();
                        }}
                       // this.handleTransmit();
                        this.showSpinner = false;
                        this.handleClear();
                        // this.handleClearUnsavedChanges();
                        /*this[NavigationMixin.Navigate]({

                            type: "standard__component",
                            attributes: {
                                componentName: "ElixirSuite__labOrdersCHCSuTab"
                            },
                            state: {
                                c__crecordId: this.newid
                            }
                        });*/
                        var close = true;
                        const closeclickedevt = new CustomEvent('closeclicked', {
                            detail: { close },
                        });
                        // Fire the custom event
                        this.dispatchEvent(closeclickedevt);
                    

                    })
                    .catch((error) => {
                        
                        this.error = error;
                        this.returnedOrderID = undefined;
                        this.showErrorToast(error.body.message);
                    });

                //this.handleCancel();

            }
        }

    }

    handleTransmit() {
        console.log('trasmit');
       

            if(this.Labtype=='Manual'){
            updateOrderStatusInhouse({labOrderIds: this.insertedRecordIds}).then((result) => {
                    console.log('Transmit Result Manual'+result);
                    if(result)
                    {
                        this.showSuccessToast1(); 
                    }
                })
                .catch((error) => {
                    console.log('Error in Transmit Result Manual'+error);
                });
        }
    else{
        updateOrderStatus({ orderidvalue: this.orderId, labOrderIds: this.insertedRecordIds })
            //getInsuranceDetails()
            
            .then((result) => {
                console.log('Transmit Result'+result);
            
                if(result[result.length - 1].includes('ERROR'))
                    {
                        this.showErrorToast(result[result.length - 1]);
                    }
                    else{
                        this.showSuccessToast('Lab Order successfully Transmitted');
                    }
               
            })
            .catch((error) => {
                console.log('Error'+error);
               
            });
        }
    }
   
}