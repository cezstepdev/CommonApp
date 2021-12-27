public class TaskTriggerHandler extends TriggerHandler {
    private List<Task__c> newList;
    private List<Task__c> oldList;
    private Map<Id, Task__c> newMap;
    private Map<Id, Task__c> oldMap;

    public TaskTriggerHandler () {
        this.newList = Trigger.new;
        this.oldList = Trigger.old;
        this.newMap = (Map<Id, Task__c>)Trigger.newMap;
        this.oldMap = (Map<Id, Task__c>)Trigger.oldMap;
    }

    public override void afterInsert() {
        handleTasksChange();
    }

    public override void afterUpdate() {
        handleTasksChange();
    }

    public override void afterDelete() {
        handleTasksChange();
    }

    public override void afterUndelete() {
        handleTasksChange();
    }

    public void handleTasksChange(){
        
        String fieldDef = '{"Metadata":{"customValue":[';
        fieldDef += getValuesAsReques();
        fieldDef += '],"description":null,"masterLabel":"CurrentTask","sorted":false,"urls":null},"FullName":"CurrentTask"}';
        HttpRequest req = new HttpRequest();
        req.setBody(fieldDef);
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');      
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v41.0/tooling/sobjects/GlobalValueSet');
        req.setMethod('POST');
        Http httpreq = new Http();
        HttpResponse res  = httpreq.send(req);
    }

    public String getValuesAsReques(){
        String outputString = '';
        for(Task__c task : newList){
            String curr = '{"color":null,"default":false,"description":null,"isActive":null,"label":"'+task.Name+'","urls":null,"valueName":"'+task.Name+'"}';
            outputString += curr;
        }
        return outputString;
    }
}
