import { LightningElement, api, wire, track } from 'lwc';
import getCallMembersList from '@salesforce/apex/TaskController.getCallMembersList';


export default class AddTaskToMembers extends LightningElement {
    @api recordId;
    @track CallMembers = [];
    @track value = ["Option1"];
    @track error;

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
          alist.push({ label: element["Contact__r"]["Name"], value: element["Contact__r"]["Name"] });
        });
        return alist;
      }

      handleChange(e) {
        this.value = e.detail.value;
      }
}