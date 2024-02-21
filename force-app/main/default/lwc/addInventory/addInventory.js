import { LightningElement , api , wire,track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInventoryType from '@salesforce/apex/InventoryController.getInventoryType';
import getInventoryLabel from '@salesforce/apex/InventoryController.getInventoryLabel';
import getInventoryNames from '@salesforce/apex/InventoryController.getInventoryNames';
import getInventoryLotNumber from '@salesforce/apex/InventoryController.getInventoryLotNumber';
//import getAvailableUnit from '@salesforce/apex/InventoryController.getAvailableUnit';
//import getLot from '@salesforce/apex/InventoryController.getLot';
import getLotAvailable from '@salesforce/apex/InventoryController.getLotAvailable';
import getLotId from '@salesforce/apex/InventoryController.getLotId';
//import getTypeId from '@salesforce/apex/InventoryController.getTypeId';
import getProcedureId from '@salesforce/apex/InventoryController.getProcedureId';
import getTotalPrice from '@salesforce/apex/InventoryController.getTotalPrice';
import { refreshApex } from '@salesforce/apex';

export default class AddInventory extends LightningElement {


    @track itemList = [];
    @track itemList1 = [];
    @track itemList3 = [];
    @track index=0;
    @api options=[];
    @api itemOptions=[];
    @api inventaryOptions=[];
    @api column;
    @api inventoryName;
    @api inv;
    defType;
    inventorynametype;
    noLot;
    dupCh;
    requireCh;
    noName;
    @api lotRequired;
    @api defaultLot;
    @api defaultItemName;
    @api defaultAvail;
    @api defaultEqpId;
    @api defaultTyp;
    @api prevLst;
    @api appendCheck;
    
    @track rows;
    @track required;
    @track lotfil;
    @track namefill;
    @track invtype;
    @track invName;
    @track available;
    @track eqid;
    procedureId;
    @track prevTyp;
    @track prevLot = [];
    @track preName;
    @track reqcheck;
    @track lotOptions;
    @track nameOptions;
    @track inventoryLotOptions;
    srnum=0;
    addcheck;

    //options;
    @api isShowModal;
    @api clmode;
    //indx = 1;
    header='';
    invTypHeader='';
    invItemHeader='';

    @wire(getInventoryType) act;

    @wire(getInventoryLabel) 
    invLabel({ data, error }) 
    {
        if (data) {
            console.log('checking the data', data);
            this.header = 'Add '+data +' to Patient File';
            this.invTypHeader = data+' Type';
            this.invItemHeader = data+' Item';
        }
        else if(data==''){

            console.log('empty');
            this.header = 'Add Inventory to Patient File';
            this.invTypHeader = 'Inventory Type';
            this.invItemHeader = 'Inventory Item';

        }
        
        else if (error) {
            console.log('Something went wrong:', error);
            this.header = 'Add Inventory to Patient File';
            this.invTypHeader = 'Inventory Type';
            this.invItemHeader = 'Inventory Item';
        }
    };

    

    keyIndex = 1;

    constructor() {
        super();
       // this.getOriginLot(this.defaultTyp,this.index,this.prevLot);
        console.log('getOriginLot In Constructor');
        
    }
   
   getPicklist(obj,ind,prev)
    {
        getLot({ ty : obj , prevLotNum : prev})
        .then(result => {
            console.log('result****',result);
           if(result)
           {

            this.options = [];
                for(let i=0; i<result.length; i++) {
                    console.log('getPicklist id=' + result[i]);
                    console.log('getPicklist ind=' + ind);
                    this.noLot = false;
                    this.options = [...this.options ,{value: result[i] , label: result[i]}]; 
                    console.log('getPicklist options=' + this.options);
                    this.itemList[ind].options =  this.options;
                    this.lotOptions = this.options;
                    console.log('getPicklist itemlist=' + this.itemList[ind].options);
                    console.log('lotOptions=' + JSON.stringify(this.lotOptions));
                   // this.options = [{value: result[i] , label: result[i]}];                                 
                }     
                this.error = undefined;
            }
            if(result.length==0){
                console.log('else result****',result);
                this.noLot = true;
            }
        })
        .catch(error => {
            this.message = undefined;
            this.error = error;
        });
    }
    getLotlist(obj,ind)
    {
        getInventoryLotNumber({ procId : obj })
        .then(result => {
            console.log('getlotlist****',result);
           if(result)
           {

            this.inventoryLotOptions = [];
                for(let i=0; i<result.length; i++) {
                    console.log('getPicklist getNamelist=' + result[i]);
                    console.log('getPicklist  getNamelistind=' + ind);
                    this.noName = false;
                    this.inventoryLotOptions = [...this.inventoryLotOptions ,{value: result[i] , label: result[i]}]; 
                    console.log('getPicklist inventaryOptions=' + this.inventoryLotOptions);
                    this.itemList[ind].inventoryLotOptions =  this.inventoryLotOptions;
                  //  this.inventoryLotOptions = this.inventaryOptions;
                    console.log('getPicklist inventoryLotOptions itemlist=' + JSON.stringify(this.itemList[ind].inventoryLotOptions));
                    console.log('inventoryLotOptions=' + JSON.stringify(this.inventoryLotOptions));
                   // this.options = [{value: result[i] , label: result[i]}];                                 
                }     
                this.error = undefined;
            }
            if(result.length==0){
                console.log('else result****',result);
                this.noName = true;
            }
        })
        .catch(error => {
            this.message = undefined;
            this.error = error;
        });
    }
    getNamelist(obj,ind,prev)
    {
        getInventoryNames({ strInventoryType : obj  })
        .then(result => {
            console.log('getNamelist****',result);
           if(result)
           {

            this.inventaryOptions = [];
                for(let i=0; i<result.length; i++) {
                    console.log('getPicklist getNamelist=' + result[i]);
                    console.log('getPicklist  getNamelistind=' + ind);
                    this.noName = false;
                    this.inventaryOptions = [...this.inventaryOptions ,{value: result[i] , label: result[i]}]; 
                    console.log('getPicklist inventaryOptions=' + this.inventaryOptions);
                    this.itemList[ind].inventaryOptions =  this.inventaryOptions;
                  //  this.inventoryLotOptions = this.inventaryOptions;
                    console.log('getPicklist getNamelist itemlist=' + this.itemList[ind].inventaryOptions);
                 //   console.log('inventoryLotOptions=' + JSON.stringify(this.inventoryLotOptions));
                   // this.options = [{value: result[i] , label: result[i]}];                                 
                }     
                this.error = undefined;
            }
            if(result.length==0){
                console.log('else result****',result);
                this.noName = true;
            }
        })
        .catch(error => {
            this.message = undefined;
            this.error = error;
        });
    }

    getProcId(obj,ind)
    {
        getProcedureId({ procName : obj  })
        .then(result => {
            console.log('getProcedureId****',result);
            this.procedureId = result;
           if(result)
           {

            this.procedureId = result;
            this.getLotlist(this.procedureId,ind);
           // this.defaultEqpId = this.eqid;
            this.itemList1[ind].proid = result;
    
                this.error = undefined;
            }
            
        })
        .catch(error => {
            this.message = undefined;
            this.error = error;
        });
    }

    handleNameChange(event){
        console.log('handleNameChange');
      //  this.invName =  this.itemList[index].Name;

        //  this.defaultTyp = this.invtype;
  
      //  console.log('handleChange invtype Name****',this.invName);
        
      let index = event.target.dataset.index;
        console.log('itemList index lot',index);
        console.log('itemList3 index',JSON.stringify(this.itemList3));
        this.itemList[index].Name = event.detail.value;
        this.itemList1[index].Name = event.detail.value;
        this.itemList3[index].Name = event.detail.value;
        this.namefill = this.itemList[index].Name;

        this.preName = this.namefill;

        this.dupCh = false;

        console.log('preName****',this.preName);

        this.getProcId(this.preName,index);

      //  console.log('procedureId****',this.procedureId);
       // this.getLotlist(this.procedureId,index);
      //  this.getPicklist1(this.invtype,index,this.preName);
        console.log('itemList in Inventory Name:',this.itemList[index].Name);

    }
    getOriginLot(obj,ind,prev)
    {
        getLot({ ty : obj , prevLotNum : prev})
        .then(result => {
           if(result)
           {

            this.options = [];
                for(let i=0; i<result.length; i++) {
                    console.log('getOriginLot id=' + result[i]);
                    this.options = [...this.options ,{value: result[i] , label: result[i]}]; 
                    this.defaultLotOpt =  this.options;
                    console.log('getOriginLot defaultLotOpt=' + this.defaultLotOpt);
                   // this.options = [{value: result[i] , label: result[i]}];                                 
                }     
                this.error = undefined;
            }
        })
        .catch(error => {
            this.message = undefined;
            this.error = error;
        });
    }


    getPicklist1(obj,ind,obj1)
    {
        getAvailableUnit({ ty : obj, strInventoryName : obj1})
        .then(result => {
           if(result)
           {

            this.options = [];
                
                    console.log('id=getAvailableUnit' + result);
                   // this.options = [...this.options ,{value: result[i] , label: result[i]}]; 
                    this.itemList[ind].Avail =  result;
                    this.available = result;
                  //  this.defaultAvail = result;
                    this.itemList1[ind].Avail = result;
                   // this.options = [{value: result[i] , label: result[i]}];                                 
                     
                this.error = undefined;
            }
        })
        .catch(error => {
            this.message = undefined;
            this.error = error;
        });
    }

    getPicklist2(obj,obj1,ind)
    {
        getLotAvailable({ lotNum : obj , procId : obj1})
        .then(result => {
            refreshApex(result);
           if(result)
           {

            this.options = [];
    
                    console.log('id=getLotAvailable' + result);
                   // this.options = [...this.options ,{value: result[i] , label: result[i]}]; 
                    this.itemList[ind].Avail =  result;
                    this.available = result;
                  //  this.defaultAvail = result;
                    this.itemList1[ind].Avail = result;
                   
                   // this.options = [{value: result[i] , label: result[i]}];                                 
                     
                this.error = undefined;
            }
            if(result==0){

                this.itemList[ind].Avail =  result;
                    this.available = result;
            }
        })
        .catch(error => {
            this.message = undefined;
            this.error = error;
        });
    }

    getPicklist7(obj,obj1,ind)
    {
        getTotalPrice({ procId : obj, unitReq : obj1})
        .then(result => {
            refreshApex(result);
           if(result)
           {

            this.options = [];
    
                    console.log('id=getLotAvailable' + result);
                   // this.options = [...this.options ,{value: result[i] , label: result[i]}]; 
                    this.itemList[ind].totalPrice =  result;
                    this.available = result;
                  //  this.defaultAvail = result;
                    this.itemList1[ind].totalPrice = result;
                    this.itemList3[ind].totalPrice = result;
                   
                   // this.options = [{value: result[i] , label: result[i]}];                                 
                     
                this.error = undefined;
            }
            if(result==0){

                this.itemList[ind].Avail =  result;
                    this.available = result;
            }
        })
        .catch(error => {
            this.message = undefined;
            this.error = error;
        });
    }

    getPicklist3(obj,obj1,ind)
    {
        getLotId({ ty : obj,lt : obj1})
        .then(result => {
           if(result)
           {

            this.options = [];
                
                    console.log('id=getLotAvailable' + result);
                   // this.options = [...this.options ,{value: result[i] , label: result[i]}]; 
                  //  this.itemList[ind].Avail =  result;
                    this.eqid = result;
                    this.defaultEqpId = this.eqid;
                    this.itemList1[ind].eid = result;
                    this.itemList3[ind].eid = result;
                   // this.options = [{value: result[i] , label: result[i]}];                                 
                     
                this.error = undefined;
            }
        })
        .catch(error => {
            this.message = undefined;
            this.error = error;
        });
    }

    getPicklist4(obj,ind)
    {
        getTypeId({ ty : obj})
        .then(result => {
           if(result)
           {

            this.options = [];
                
                    console.log('id=getLotAvailable' + result);
                   // this.options = [...this.options ,{value: result[i] , label: result[i]}]; 
                  //  this.itemList[ind].Avail =  result;
                    this.eqid = result;
                    this.defaultEqpId = this.eqid;
                    this.itemList1[ind].eid = result;
                   // this.options = [{value: result[i] , label: result[i]}];                                 
                     
                this.error = undefined;
            }
        })
        .catch(error => {
            this.message = undefined;
            this.error = error;
        });
    }
    




    addRow() {

        this.index++;

        this.addcheck = true;

       // this.invtype = this.defaultTyp;

        var lotCh;
        var reqCh;//added by Anmol
        //var dupCh;
        var itemCh;
        var indCh=0;
        for(var i=0;i<this.itemList3.length;i++){
            if(this.itemList3[i].req==''){
                reqCh = true;
            }
            if(this.itemList3[i].Lot==''){
                lotCh = true;
            }
            if(this.itemList3[i].Name==''){
                itemCh = true;
            }
        }

        if(this.index>=1){

            if(itemCh){

                this.reqcheck = true;
                this.index--;
                const event = new ShowToastEvent({
                    title: 'Please fill Inventory Item Name',
                    message: ' ',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                return;
    
            }

        if(reqCh){

            this.reqcheck = true;
            this.index--;
            const event = new ShowToastEvent({
                title: 'Please fill Units Required',
                message: ' ',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            return;

        }

        if(this.lotRequired){
        if(lotCh){

            this.reqcheck = true;
            this.index--;
            const event = new ShowToastEvent({
                title: 'Please fill Lot Number',
                message: ' ',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            return;

        }
    }
    }

        if(this.required>this.available){

            this.reqcheck = true;

            const event = new ShowToastEvent({
                title: 'Unit Required cannot be greater then Unit Available ',
                message: ' ',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            return;

        }

      /*  var lotInd = this.index - 1;

        if(lotInd>=1){
            console.log('index*****',lotInd);
            console.log('prevLot*****',this.prevLot);
        this.getPicklist(this.defaultTyp,lotInd,this.prevLot);
        }

        if(this.noLot){

            this.reqcheck = true;

            const event = new ShowToastEvent({
                title: 'There are no Lot Number remaining for this Inventory Type, Please change the Inventory type  ',
                message: ' ',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            return;

        }*/

        this.srnum++;
        var i = this.srnum;

        var newItem = { Type: '' , Lot:'',inventoryLotOptions:'' , inventaryOptions:'' , Avail:''  , req:'' ,totalPrice:'' , Name:'' ,  key : i};

        var newItem1;
 
        if(this.clmode =='edit'){

            newItem1 = { Type: this.invtype , Lot: '' , Avail:this.available , req: '' ,totalPrice:'' , Name:'' , eid:this.eqid , mode:'insert', key : this.srnum };
        }

        else if(this.clmode == 'new'){

            newItem1 = { Type: this.invtype , Lot: '' , Avail:this.available , req: '' ,totalPrice:'' , Name:'' , eid:this.eqid , mode:'new', key : this.srnum}

        }


        this.itemList.push(newItem);
      //  if(i>1){
        this.itemList1.push(newItem1);
        this.itemList3.push(newItem1);
      //  this.options[inventoryLst] = newItem1;
    //    }
        this.available = this.defaultAvail;
        
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

    removeRow(event) {

      //  var index = this.index;

      let rowIndex = event.target.dataset.index;
      console.log('index removeRow',rowIndex);

        this.noLot = false;
        this.dupCh = false;
        this.requireCh = false;
        var selectedRow = event.currentTarget;
        var key = selectedRow.dataset.id;
        console.log('index***',this.index);
        console.log('itemlist***',this.itemList);
        var splInd = this.index - 1;
        //if(this.itemList.length>1){
            this.itemList.splice(rowIndex, 1);
            this.itemList1[rowIndex].mode = 'delete';
            this.itemList3.splice(rowIndex, 1);
            this.prevLot.splice(rowIndex, 1);
            console.log('itemlist1 in removerow',JSON.stringify(this.itemList1));
            this.index--;
            this.srnum--;

            for(var i=0;i<this.itemList.length;i++){
                    this.itemList[i].key = i+1;
                
            }


            //this.indx--;
            //this.isLoaded = false;
       // }
      /*  else if(this.itemList.length == 1){
            
            const event = new ShowToastEvent({
                title: 'Can not delete last row',
                message: ' ',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            return;
        }*/

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


        console.log('opt',JSON.stringify(opt));

        return opt;

    }


    handleChange(event) {

        let index = event.target.dataset.index;
        console.log('index invtype',index);
        this.itemList[index].Type = event.detail.value;
        this.itemList1[index].Type = event.detail.value;

        this.invtype =  this.itemList[index].Type;

        this.dupCh = false;
      //  this.defaultTyp = this.invtype;

      console.log('handleChange invtype****',this.invtype);
       // this.getPicklist(this.invtype,index,this.prevLot);

      //  this.getPicklist1(this.invtype,index);
       // this.getPicklist4(this.invtype,index);
        this.getNamelist(this.invtype,index,this.lotRequired);
        console.log('itemList in invtype', this.itemList[index].Type);

        

        
    }

    handlebathChange(event){

        let index = event.target.dataset.index;
        console.log('itemList index lot',index);
        this.itemList[index].Lot = event.detail.value;
        this.itemList1[index].Lot = event.detail.value;
        this.itemList3[index].Lot = event.detail.value;
        this.lotfil = this.itemList[index].Lot;

        this.dupCh = false;

        this.prevLot.push(this.lotfil);

        this.getPicklist2(this.lotfil,this.procedureId,index);

        this.getPicklist3(this.procedureId,this.lotfil,index);
        console.log('itemList in lot',this.itemList[index].Lot);

    }

    handleAvailableChange(event){


    }

    handleReqChange(event){

        let index = event.target.dataset.index;
        console.log('index req',index);
        this.itemList[index].req = event.detail.value;
        this.itemList1[index].req = event.detail.value;
        this.itemList3[index].req = event.detail.value;

        this.required = this.itemList1[index].req;
        this.procedureId = this.itemList1[index].proid;

        console.log('handleReqChange***procedureId',this.procedureId);
        console.log('handleReqChange***required',this.required);

        this.getPicklist7(this.procedureId,this.required,index);

        console.log('itemList in req',this.itemList);



        this.reqcheck = false;

        var newItem = { Type: this.invtype , Lot: this.lotfil , Avail:this.available , req:this.required };
        //this.itemList1.push(newItem);

        console.log('itemList in handlereqchange',this.itemList1);

    }
    get lot() {

        var lotnum = [];

        if(this.lt.data){
            this.lt.data.forEach(ele =>{
                lotnum.push({label:ele , value:ele});
            }); 
        }


        console.log('lotnum',JSON.stringify(lotnum));

        return lotnum;

    }

    // Method to show a success toast
showSuccessToast() {
    const event = new ShowToastEvent({
        title: 'Success',
        message: 'Record saved successfully',
        variant: 'success',
        mode: 'dismissable'
    });
    this.dispatchEvent(event);
}


    addRecord(event){

        var lotCh;
        var reqCh;
        var itemCh;
        
        for(var i=0;i<this.itemList3.length;i++){
            if(this.itemList3[i].req==''){
                reqCh = true;
            }
            if(this.itemList3[i].Lot==''){
                lotCh = true;
            }
            if(this.itemList3[i].Name==''){
                itemCh = true;
            }
        }

        if(itemCh){

            this.reqcheck = true;

            const event = new ShowToastEvent({
                title: 'Please fill Inventory Item Name',
                message: ' ',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            return;

        }

        if(reqCh){

            this.reqcheck = true;

            const event = new ShowToastEvent({
                title: 'Please fill Units Required',
                message: ' ',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            return;

        }

        if(this.lotRequired){
        if(lotCh){

            this.reqcheck = true;

            const event = new ShowToastEvent({
                title: 'Please fill Lot Number',
                message: ' ',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            return;

        }
    }

        if(this.required>this.available){

            this.reqcheck = true;

            const event = new ShowToastEvent({
                title: 'Unit Required cannot be greater then Unit Available ',
                message: ' ',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            return;

        }

        console.log('dupCh itemlist1****',JSON.stringify(this.itemList3));

        console.log('add index****',this.index);

        const length = this.itemList3.length; 

        if(this.index>=2 || this.appendCheck==true){

            for(let i=0;i<length - 1;i++){
                for (let j = i + 1; j < length; j++) {
                if(this.itemList3[i].eid==this.itemList3[j].eid){
                    this.dupCh = true;
                }
            }
            }
        }
    
            if(this.dupCh){
    
                this.reqcheck = true;
              //  this.index--;
                const event = new ShowToastEvent({
                    title: 'Please remove Duplicate Records',
                    message: ' ',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                return;
    
            }

            for(let i=0;i<length;i++){

                console.log('req****',parseInt(this.itemList1[i].req));
                console.log('avail****',this.itemList1[i].Avail);

                    if(parseInt(this.itemList1[i].req) > this.itemList1[i].Avail ){

                        this.requireCh = true;
                        break;
                    }
                    else{
                        this.requireCh  =false;
                    }

            }

            if(this.requireCh){
    
                this.reqcheck = true;
              //  this.index--;
                const event = new ShowToastEvent({
                    title: 'Unit Required cannot be greater then Unit Available',
                    message: ' ',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                return;
    
            }
    
        

      /*  if(this.noLot){

            this.reqcheck = true;

            const event = new ShowToastEvent({
                title: 'There are no Lot Number remaining for this Inventory Type, Please change the Inventory type  ',
                message: ' ',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            return;

        } */

        
    
       // var jud = 'hello';

       console.log('clmode in addInventory',this.clmode);

       if(this.clmode == 'new'){

        var newItem = { Type: this.defaultTyp , Lot: this.lotfil , Avail:this.available , req:this.required , eid:this.defaultEqpId };
       // this.itemList1.push(newItem);

       console.log('itemList1 in last*****',JSON.stringify(this.itemList1));
        var itemList2 = this.itemList1;
        

        const valueChangeEvent = new CustomEvent("valuechange", {
            
            detail: {itemList2}
                 
          });
          // Fire the custom event
          this.dispatchEvent(valueChangeEvent);

          this.isShowModal = false;

        var visMod = true;
         this.showSuccessToast();

        const valueChangeEvent1 = new CustomEvent("closechange", {
            
            detail: {visMod}
                 
          });
          // Fire the custom event
          this.dispatchEvent(valueChangeEvent1);
          


        }
        else if(this.clmode =='edit'){
            var newItem = { Type: this.invtype , Lot: this.lotfil , Avail:this.available , req:this.required , eid:this.eqid , modetype:'insert' };
       // this.itemList1.push(newItem);

        console.log('inside edit addinventory',this.itemList1);

        var itemList2 = this.itemList1;

            const valueChangeEvent = new CustomEvent("editchange", {
            
                detail: {itemList2}
                     
              });
              // Fire the custom event
              this.dispatchEvent(valueChangeEvent);


        }

          this.isShowModal = false;
          
    }

    connectedCallback(){

     //   window.location.reload();

this.rows = JSON.parse(JSON.stringify(this.column));
        console.log('column*****',JSON.stringify(this.column));
        console.log('prevLst***',JSON.stringify(this.prevLst));
        console.log('appendCheck***',this.appendCheck);

        if(this.appendCheck){

            for(let i=0; i<this.prevLst.length; i++) {

                this.srnum++;

                this.inventoryLotOptions = [];

                this.inventaryOptions = [];

                this.inventoryLotOptions = [...this.inventoryLotOptions ,{value: this.prevLst[i].Lot , label: this.prevLst[i].Lot}]; 

                this.inventaryOptions = [...this.inventaryOptions ,{value: this.prevLst[i].Name , label: this.prevLst[i].Name}]; 

                console.log('inventaryOptions***',this.inventaryOptions);

                console.log('inventoryLotOptions***',this.inventoryLotOptions);

                var newItem = { Type: this.prevLst[i].Type , Lot: this.prevLst[i].Lot ,inventoryLotOptions:this.inventoryLotOptions , inventaryOptions:this.inventaryOptions , Avail: this.prevLst[i].Avail  , req: this.prevLst[i].req , Name:this.prevLst[i].Name , totalPrice: this.prevLst[i].totalPrice,  key : this.srnum};

                var newItem1 = { Type: this.prevLst[i].Type , Lot: this.prevLst[i].Lot , Avail: this.prevLst[i].Avail  , req: this.prevLst[i].req , Name:this.prevLst[i].Name ,  key : this.srnum , proid:this.prevLst[i].proid , mode:'old', eid:this.prevLst[i].eid , totalPrice: this.prevLst[i].totalPrice};

                this.itemList.push(newItem);

                this.itemList1.push(newItem1);

                this.itemList3.push(newItem1);

            }

            this.addcheck = true;

        }
        
     /*   for(let i=0; i<this.defaultLot.length; i++) {
            this.options = [...this.options ,{value: this.defaultLot[i] , label: this.defaultLot[i]}]; 
        this.lotOptions = this.options;
        }

        for(let i=0; i<this.defaultItemName.length; i++) {
            this.itemOptions = [...this.itemOptions ,{value: this.defaultItemName[i] , label: this.defaultItemName[i]}]; 
        this.nameOptions = this.itemOptions;
        }

        this.defType = this.defaultTyp;
      //  this.inventorynametype=this.inventoryName;
        this.invtype = this.defaultTyp;
       // this.invName = this.inventoryName;
        console.log('itemlist options',JSON.stringify(this.itemList.options));
        console.log('defaultavail**',this.defaultAvail); */
        
    }



}