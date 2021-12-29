public with sharing class TaskController {
    public TaskController() {

    }

    @AuraEnabled(cacheable=true)
    public static List<CallMember__c> getCallMembersList(Id callId) {
        try {
            return [
                SELECT Id, Call__c, Contact__r.Name
                FROM CallMember__c
                WHERE Call__r.Id =: callId
            ];
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
