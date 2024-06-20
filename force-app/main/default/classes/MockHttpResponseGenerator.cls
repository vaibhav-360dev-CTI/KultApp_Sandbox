@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"data": [{"id": "17841405793087218", "message_count": 1, "messages": {"data": [{"id": "17851087209098192", "message": "Awesome!", "thread_id": "thread1", "created_time": "2023-07-29T12:40:00+0000", "fromDetails": {"id": "user1", "name": "User One"}}]}, "senders": {"data": [{"id": "user1", "name": "User One"}]}, "can_reply": true}]}');
        res.setStatusCode(200);
        return res;
    }
}