trigger TaskTrigger on Task__c (after insert, after update, after delete, after undelete) {
    new TaskTriggerHandler().run();
}