public class kultBotApex {
    public class timeOutput{
        @InvocableVariable
        public Boolean isInWorkingHour;
    }
    
    @InvocableMethod(label='Get Working Hour') 
    public static List<timeOutput> isInWorkHours(){
        try{
            List<Working_Hour__mdt> workHour = [SELECT Id, Label, Start_Time__c, End_Time__c FROM Working_Hour__mdt WHERE Label='Chat Support Team'];
            List<timeOutput> toList = new List<timeOutput>();
            timeOutput to = new timeOutput();
            if(workHour.Size()>0){
                Working_Hour__mdt whRec = workHour[0];
                List<String> startTimeSplit = whRec.Start_Time__c.split(':');
                List<String> endTimeSplit = whRec.End_Time__c.split(':');
                Time startTime = Time.newInstance(Integer.valueOf(startTimeSplit[0]), Integer.valueOf(startTimeSplit[1]), 0, 0);
                Time endTime = Time.newInstance(Integer.valueOf(endTimeSplit[0]), Integer.valueOf(endTimeSplit[1]), 0, 0);
                Time currentTime = System.Now().time();
                
                System.debug('startTime==> ' + startTime);
                System.debug('endTime==> ' + endTime);
                System.debug('currentTime==> ' + currentTime); 
                System.debug(currentTime>= startTime && currentTime <= endTime);
                if(currentTime>= startTime && currentTime <= endTime){
                    to.isInWorkingHour = true;
                    toList.add(to);
                 	return toList;   
                }else{
                    to.isInWorkingHour = false;
                    toList.add(to);
                 	return toList;
                }
            }
            return null;
        }catch(exception e){
            System.debug('Error Message:: ' + e.getMessage() + ' at line number:: ' + e.getLineNumber());
            return null;
        }
    }
}