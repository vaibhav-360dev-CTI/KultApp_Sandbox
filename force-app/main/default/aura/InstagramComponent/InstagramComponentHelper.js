({
    doInithelper : function(component, event, helper) {
        var recId = component.get("v.recordId");
        var action = component.get("c.getCaseDetails");
        
        action.setParams({
            recordId: recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var paginationList = [];
                var temResult=[];
                var temResultSize;
                console.log(serverresponse);
                var serverresponse = response.getReturnValue();
                component.set("v.totalCount",serverresponse.length);
                component.set("v.tweetDescription",serverresponse[0].postCaption);
                component.set("v.urlToPost",serverresponse[0].PostUrl);
                component.set("v.typeOfPost",serverresponse[0].postType);
                component.set("v.relatedCommentList",serverresponse);
                component.set("v.showSpinner",false);
                //Pgaination logic
                var lengthVar = component.get("v.relatedCommentList").length;
                component.set("v.totalRecords",lengthVar); 
                var perPage = component.get("v.perPageSize");
                var values=[];
                if(lengthVar >= perPage){
                    for(var i=0;i<perPage;i++){
                        values.push(response.getReturnValue()[i]);
                    }
                }else{
                    for(var i=0;i<lengthVar;i++){
                        values.push(response.getReturnValue()[i]);
                    }
                }
                component.set("v.PaginationList",values);
                component.set("v.startValue",0);
                if(lengthVar <= (component.get("v.startValue")+perPage)){
                    component.set("v.isLastPage",true);
                }
                component.set("v.endValue",component.get("v.startValue")+perPage-1);
            }else{
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action); 
    }
})