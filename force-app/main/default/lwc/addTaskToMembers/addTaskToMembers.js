import { LightningElement, api, wire, track } from 'lwc';
import getCallMembersList from '@salesforce/apex/FirstClass.getCallMembersList';


export default class AddTaskToMembers extends LightningElement {
    @api recordId;
    @track CallMembers = [];


    @wire(getCallMembersList, { callId: "$recordId" })
    callMembersList({ error, data }) {
      if (data) {
        this.CallMembers = data;
        this.error = undefined;
      } else if (error) {
        this.error = error;
        this.CallMembers = undefined;
      }
    }

    get comms() {
        let alist = [];
        this.CallMembers.forEach(function(element) {
          alist.push({ label: element["Id"], value: element["Name"] });
        });
        return alist;
      }
}