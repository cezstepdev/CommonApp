public with sharing class ContactTriggerHandler extends TriggerHandler {
    private List<Contact> newList;
    private List<Contact> oldList;
    private Map<Id, Contact> newMap;
    private Map<Id, Contact> oldMap;
    private List<MemberTask__c> memberTasksToAdd = new List<MemberTask__c>();
    private List<MemberTask__c> memberTasksToUpdate = new List<MemberTask__c>();

    public ContactTriggerHandler () {
        this.newList = Trigger.new;
        this.oldList = Trigger.old;
        this.newMap = (Map<Id, Contact>)Trigger.newMap;
        this.oldMap = (Map<Id, Contact>)Trigger.oldMap;
    }

    public override void afterInsert() {
        handleAccountNameChange();
    }
    
    public override void beforeUpdate() {
        handleAccountNameChange();
        handleTaskChange();
    }

    public void handleInactive() {
        for(Integer i = 0; i < newList.size(); i++) {
            if(newList[i].Inactive__c != oldList[i].Inactive__c) {
                if(newList[i].Inactive__c) {
                    newList[i].Inactive_Start_Date__c = Date.today();
                }
                else {
                    newList[i].Absent_Time__c = newList[i].Inactive_Start_Date__c.daysBetween(Date.today());
                }
            }
        }
    }

    public void handleAccountNameChange() {
        if(newList.get(0).AccountId != null) {
            Account account = [SELECT Name FROM Account WHERE Id = :newList.get(0).AccountId];
            account.Name = '';

            for (Contact contact : [SELECT FirstName FROM Contact WHERE AccountId = :account.Id]) {
                account.Name += contact.FirstName + ' ';
            }
            update account;
        }
    }

    public void handleTaskChange() {
        List<Id> contactsId = new List<Id>();

        for(Contact contact : newList) {
            contactsId.add(contact.Id);
        }

        List<MemberTask__c> memberTasks = [
            SELECT Id, TaskStart__c, Task_End__c, Task_Due_Date__c, Contact__c
            FROM MemberTask__c
            WHERE Contact__c IN :contactsId 
        ];

        checkTasks(memberTasks);

        if(memberTasksToUpdate.size() > 0) {
            update memberTasksToUpdate;
        }

        if(memberTasksToAdd.size() > 0) {
            insert memberTasksToAdd;
        }
    }

    private void checkTasks(List<MemberTask__c> memberTasks) {
        Integer points = 0;

        Map<String, Id> taskMap = new Map<String, Id>();
        for(Task__c task : [SELECT Id, Name FROM Task__c]) {
            taskMap.put(task.Name, task.Id);
        }

        for(Integer i = 0; i < newList.size(); i++) {
            if(newList[i].Current_Task__c == 'Bench' || 
            (oldList[i].Current_Task__c == 'Bench' && [SELECT Id FROM MemberTask__c WHERE Contact__c = :newList[i].Id].size() > 0)) {
                continue;
            }

            if(newList[i].Current_Task__c != oldList[i].Current_Task__c) {
                for(MemberTask__c member : memberTasks) {
                    if(member.Contact__c == newList[i].Id && member.Task_End__c == null) {
                        member.Task_End__c = Date.today();
                        points = member.Task_End__c.daysBetween(member.Task_Due_Date__c);
                        if(member.Task_Due_Date__c < member.Task_End__c) {
                            points *= -1;
                        }
                        newList[i].Absent_Time__c = 0;
                        newList[i].Points__c += points; 
                        memberTasksToUpdate.add(member);
                    }
                }

                MemberTask__c memberTask = new MemberTask__c();
                memberTask.Contact__c = newList[i].Id;
                memberTask.Task__c = taskMap.get(newList[i].Current_Task__c);
                memberTasksToAdd.add(memberTask);
            }
        }
    }
}
