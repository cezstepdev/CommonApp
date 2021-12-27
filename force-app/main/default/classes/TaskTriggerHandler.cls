public class TaskTriggerHandler extends TriggerHandler {
    List<Task__c> newList;
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

    @future(callout= true)
    public static void handleTasksChange(){
        
        String fieldDef = '{"Metadata":{"customValue":[';
        fieldDef += getValuesAsReques();
        fieldDef += '],"description":null,"masterLabel":"CurrentTask","sorted":false,"urls":null},"FullName":"CurrentTask"}';
        HttpRequest req = new HttpRequest();
        req.setBody(fieldDef);
        System.debug(fieldDef);
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');      
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm()+'/services/data/v41.0/tooling/sobjects/GlobalValueSet/0Nt7Q000000kNAXSA2?_HttpMethod=PATCH');
        req.setMethod('POST');
        //req.setHeader('X-HTTP-Method-Override','PATCH');
        Http httpreq = new Http();
        HttpResponse res  = httpreq.send(req);
        system.debug(res.getBody());
    }

    public static String getValuesAsReques(){
        String outputString = '';
        for(Task__c task : [SELECT Id,Name FROM Task__c]){
            String curr = '{"color":null,"default":false,"description":null,"isActive":null,"label":"'+task.Name+'","urls":null,"valueName":"'+task.Name+'"},';
            outputString += curr;
        }
        return outputString.substring(0,outputString.length()-1);
    }
}
