public class csOutboundCallController {

    @AuraEnabled(cacheable=true)
    public static List<String> getCaseFieldSetValues(){
        try{
            List<String> caseFieldSetList = new List<String>();
            List<Schema.FieldSetMember> FieldSetListFromCase  = SobjectType.Case.FieldSets.Field_Set_for_CS_Outbound_Calls.getFields();
            for(Schema.FieldSetMember fieldsToAdd : FieldSetListFromCase){
                System.debug('Fields === >'+String.valueOf(fieldsToAdd.sobjectfield));
                caseFieldSetList.add(String.valueOf(fieldsToAdd.sobjectfield));
            }
            if(caseFieldSetList.size()>0){
                return caseFieldSetList;
            }
        }catch(Exception e){
            System.debug('The Error ::' + e.getMessage() + ' AND Error Line No :' + e.getLineNumber());
        }
        return null;
    }
}