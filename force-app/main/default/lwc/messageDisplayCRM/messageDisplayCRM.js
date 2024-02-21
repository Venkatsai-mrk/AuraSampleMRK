import { LightningElement,api} from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

export default class MessageDisplayCRM extends NavigationMixin(LightningElement) {
   
   @api recordId
   
   @api contentId = {};
   
   @api templateMap = {};
  

}