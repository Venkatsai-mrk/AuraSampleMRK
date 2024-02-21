import { LightningElement , api , wire , track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInventoryType from '@salesforce/apex/InventoryController.getInventoryType';
//import getAvailableUnit from '@salesforce/apex/InventoryController.getAvailableUnit';
import getLotAvailable from '@salesforce/apex/InventoryController.getLotAvailable';
import getLotId from '@salesforce/apex/InventoryController.getLotId';
//import getLot from '@salesforce/apex/InventoryController.getLot';
import getInventoryNames from '@salesforce/apex/InventoryController.getInventoryNames';
import getInventoryLotNumber from '@salesforce/apex/InventoryController.getInventoryLotNumber';

export default class EditInventory extends LightningElement {

    @api column=[];

    @track invcolumn;

    @api index;
    @api comboCheck;
    @api recordId;

    @api isShowModal;
    @api options=[];
    @api lotRequired;

    @track required;
    @track prevrequired;
    @track lotfil;
    @track invtype;
    @track procedureId;
    @track available;
    @track eqid;
    @track invName;
    itemList1 = [];
    key = 1;
    

    @wire(getInventoryType) act;

    @wire(getInventoryLotNumber,{procId:'$procedureId'}) lt;

    @wire(getInventoryNames,{strInventoryType:'$invtype' }) inventoryItem;

    connectedCallback(){
        this.invcolumn = JSON.parse(JSON.stringify(this.column));
                console.log('column*****',JSON.stringify(this.column));
                this.invtype = this.invcolumn[0].Type;
                this.available = this.invcolumn[0].Avail;
                this.required = this.invcolumn[0].req;
                this.lotfil = this.invcolumn[0].Lot;
                this.prevrequired = this.invcolumn[0].req;
                this.eqid = this.invcolumn[0].eid;
                this.invName = this.invcolumn[0].Name;
                this.procedureId = this.invcolumn[0].proid;
            }



    getPicklist1(obj)
    {
        getAvailableUnit({ ty : obj})
        .then(result => {
           if(result)
           {

            this.options = [];
                
                    console.log('id=getAvailableUnit' + result);
                    this.invcolumn[0].Avail =  result;
                    console.log('this.column[0].Avail' +this.column[0].Avail);
                   this.available = result;
                this.error = undefined;
            }
        })
        .catch(error => {
            this.message = undefined;
            this.error = error;
        });
    }

    getNamelist(obj)
    {
        getInventoryNames({ strInventoryType : obj})
        .then(result => {
           if(result)
           {

            this.options = [];
                
                    console.log('id=getAvailableUnit' + result);
                    this.invcolumn[0].Name =  result;
                    console.log('this.column[0].Avail' +this.column[0].Avail);
                   this.invName = result;
                this.error = undefined;
            }
        })
        .catch(error => {
            this.message = undefined;
            this.error = error;
        });
    }

    handleNameChange(event){

        this.invName =  event.detail.value;
    }

    getPicklist2(obj,obj1,obj2)
    {
        getLotAvailable({ ty : obj,lt : obj1,invName : obj2})
        .then(result => {
           if(result)
           {

            this.options = [];
                
                    console.log('id=getLotAvailable' + result);
                    this.invcolumn[0].Avail =  result;
                    this.available = result;
                   // this.options = [{value: result[i] , label: result[i]}];                                 
                     
                this.error = undefined;
            }
        })
        .catch(error => {
            this.message = undefined;
            this.error = error;
        });
    }


    getPicklist3(obj,obj1)
    {
        getLotId({ ty : obj,lt : obj1})
        .then(result => {
           if(result)
           {

            this.options = [];
                
                    console.log('id=getLotAvailable' + result);
                    this.eqid = result;
                   // this.options = [{value: result[i] , label: result[i]}];                                 
                     
                this.error = undefined;
            }
        })
        .catch(error => {
            this.message = undefined;
            this.error = error;
        });
    }


    get options1() {

        //var i = 0;
        //var l = this.act.length;
        var opt = [];

        if(this.act.data){
            this.act.data.forEach(ele =>{
                opt.push({label:ele , value:ele});
            }); 
        }

        return opt;
    }

    get options2() {

        var lotnum = [];

        if(this.lt.data){
            this.lt.data.forEach(ele =>{
                lotnum.push({label:ele , value:ele});
            }); 
        }


        console.log('lotnum',JSON.stringify(lotnum));

        return lotnum;

    }

    get options3() {

        var invItemName = [];

        if(this.inventoryItem.data){
            this.inventoryItem.data.forEach(ele =>{
                invItemName.push({label:ele , value:ele});
            }); 
        }


        console.log('invItemName',JSON.stringify(invItemName));

        return invItemName;

    }

    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;

        var visMod = true;

        const valueChangeEvent = new CustomEvent("closechange", {
            
            detail: {visMod}
                 
          });
          // Fire the custom event
          this.dispatchEvent(valueChangeEvent);
    }

    handleChange(event) {
        this.invtype =  event.detail.value;

        var idx = 0;

        console.log('edit inventory invtype:',this.invtype);

       // this.getPicklist(this.invtype,idx);

      //  this.getPicklist1(this.invtype);
        this.getNamelist(this.invtype);
        
    }

    handlebathChange(event){

        this.lotfil = event.detail.value;

        this.getPicklist2(this.invtype,this.lotfil,this.invName);

        this.getPicklist3(this.invtype,this.lotfil);

    }

    handleAvailableChange(event){


    }

    handleReqChange(event){

        this.required = event.detail.value;

    }

    editRecord(event){

        console.log('editrecord required',this.required);
        console.log('editrecord available',this.available);

        

        if(this.required>this.available){

           // this.reqcheck = true;

            const event = new ShowToastEvent({
                title: 'Unit Required cannot be greater then Unit Available ',
                message: ' ',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            return;

        }

        var newItem = { Type: this.invtype , Lot: this.lotfil , Avail:this.available , req:this.required , eid:this.eqid ,modetype:'edit' ,previousreq: this.prevrequired  ,rid:this.recordId, Name : this.invName};

        console.log('newitem in edit lwc',newItem);

        var ind = this.index;

        const valueChangeEvent = new CustomEvent("valuechange", {
            
            detail: {type: newItem,
            model:ind}
                 
          });
          // Fire the custom event
          this.dispatchEvent(valueChangeEvent);

          this.isShowModal = false;

        
    }

}