@IsTest
public class InstaDMWrapperTest {
    @IsTest
    static void testDeserialization() {
        // The JSON string
        String jsonResponse = '{' +
            '  "data": [' +
            '    {' +
            '      "message_count": 43,' +
            '      "messages": {' +
            '        "data": [' +
            '          {' +
            '            "message": "Perfecto.. ❣️❣️",' +
            '            "id": "m_zk_yX77f4wfo19RXbt7T3GeWoab2xwE0I2Q6gkqWrzCdyXNrkAf38P4LU_lFvCUEf2Yw2HvBqVJEJIGWQW8Eqw",' +
            '            "thread_id": "t_7896332630396959",' +
            '            "created_time": "2024-04-23T10:59:40+0000",' +
            '            "from": {' +
            '              "name": "Shubham Kumar",' +
            '              "email": "25002797006001335@facebook.com",' +
            '              "id": "25002797006001335"' +
            '            }' +
            '          },' +
            '          {' +
            '            "message": "107238405785525 107238405785525 107238405785525",' +
            '            "id": "m_C-_JjfOriV58DkQXwRGzkWeWoab2xwE0I2Q6gkqWrzA3OzjEe46qLiLW5IU2OJ2wdhoINz30Gs9eAtk04mD6Kg",' +
            '            "thread_id": "t_7896332630396959",' +
            '            "created_time": "2024-04-23T10:58:48+0000",' +
            '            "from": {' +
            '              "name": "Lets Hyphen",' +
            '              "email": "107238405785525@facebook.com",' +
            '              "id": "107238405785525"' +
            '            }' +
            '          },' +
            '          {' +
            '            "message": "Hello team..",' +
            '            "id": "m_6qn9EjvEUpphaBw2YefT52eWoab2xwE0I2Q6gkqWrzB9YkCk_DyROCBKNZ3vhp_6dXJNUN96VZoEhKkInpYUNQ",' +
            '            "thread_id": "t_7896332630396959",' +
            '            "created_time": "2024-04-23T10:54:19+0000",' +
            '            "from": {' +
            '              "name": "Shubham Kumar",' +
            '              "email": "25002797006001335@facebook.com",' +
            '              "id": "25002797006001335"' +
            '            }' +
            '          }' +
            '        ],' +
            '        "paging": {' +
            '          "cursors": {' +
            '            "before": "QVFIUnBad2RkVWZAWQTBxVlBNb2tmMnFkNXctS0s1dlVMdVNzSENzZAXdVc1ZAuZAi1WLWdOc0lZAWUdVRlQtWVZA6TkhDNWlyR19ndFdZAeXhTLUtMLUFkY0Qzam1ETEp3ZAWdSOUtpQzBNLTFKQ1Q0ODNrdW5zbzZAST3FiR3UwcDY4MGVWMlJN",' +
            '            "after": "QVFIUlVvTG01LS1FRE5ubG8zMUx2ODdHUm0yeUh0NDBPN2NreWJSZAmU5TE5iVmRSRUROX0hjRUNhVF83VE52RldDN1RGT2UySGxiR29Ram9JQmtpQjRBMzg3NjlXSHVONWl5VXQwN3dDa1hTNVdvb0RTNnhsWmxtLUw4TzlDQlpEcTk3"' +
            '          },' +
            '          "next": "https://graph.facebook.com/v17.0/t_7896332630396959/messages?access_token=EAAVh021BZCJsBO3TBwMISFowlLGSsfxd8ccxiJXxsWnuFBPmA8DjEBdAMKZA9eLxNo5Osq3o32TpMTyTZC9GY2Indd3uEzZAs3uw80UtjQcyJUsIRPRO8LtfvCJefKJ4y4ZBXo0edQI6skkJEZBYAqnQKK3uydnZAIkGdgQqz7jQ1RbTLqZBS7UtXsiD2DktMqlwLs552hPRZALaZBuRdPuAHBZBqUcR6eW4UGj9gZDZD&pretty=0&fields=message%2Cid%2Cthread_id%2Ccreated_time%2Cfrom&limit=25&after=QVFIUlVvTG01LS1FRE5ubG8zMUx2ODdHUm0yeUh0NDBPN2NreWJSZAmU5TE5iVmRSRUROX0hjRUNhVF83VE52RldDN1RGT2UySGxiR29Ram9JQmtpQjRBMzg3NjlXSHVONWl5VXQwN3dDa1hTNVdvb0RTNnhsWmxtLUw4TzlDQlpEcTk3"' +
            '        }' +
            '      },' +
            '      "id": "t_7896332630396959",' +
            '      "can_reply": true,' +
            '      "senders": {' +
            '        "data": [' +
            '          {' +
            '            "name": "Shubham Kumar",' +
            '            "email": "25002797006001335@facebook.com",' +
            '            "id": "25002797006001335"' +
            '          },' +
            '          {' +
            '            "name": "Lets Hyphen",' +
            '            "email": "107238405785525@facebook.com",' +
            '            "id": "107238405785525"' +
            '          }' +
            '        ]' +
            '      }' +
            '    }' +
            '  ]' +
            '}';
        
        // Replace "from" with "fromDetails" in the JSON string
        //jsonResponse = jsonResponse.replaceAll('"from"', '"fromDetails"');
        
        // Deserialize the JSON string into the wrapper class
        InstaDMWrapper wrapperInstance = (InstaDMWrapper) JSON.deserialize(jsonResponse, InstaDMWrapper.class);
        InstaDMWrapper.paging pageRec    = new InstaDMWrapper.paging();
        
        InstaDMWrapper.Cursors cursorRec = new InstaDMWrapper.Cursors();
        cursorRec.before = 'QVFIUnBad2RkVWZAWQTBxVlBNb2tmMnFkNXctS0s1dlVMdVNzSENzZAXdVc1ZAuZAi1WLWdOc0lZAWUdVRlQtWVZA6TkhDNWlyR19ndFdZAeXhTLUtMLUFkY0Qzam1ETEp3ZAWdSOUtpQzBNLTFKQ1Q0ODNrdW5zbzZAST3FiR3UwcDY4MGVWMlJN';
        cursorRec.after = 'QVFIUlVvTG01LS1FRE5ubG8zMUx2ODdHUm0yeUh0NDBPN2NreWJSZAmU5TE5iVmRSRUROX0hjRUNhVF83VE52RldDN1RGT2UySGxiR29Ram9JQmtpQjRBMzg3NjlXSHVONWl5VXQwN3dDa1hTNVdvb0RTNnhsWmxtLUw4TzlDQlpEcTk3'; 
        
        pageRec.cursors = cursorRec;
        pageRec.next = 'https://graph.facebook.com/v17.0/t_7896332630396959/messages?access_token=EAAVh021BZCJsBO3TBwMISFowlLGSsfxd8ccxiJXxsWnuFBPmA8DjEBdAMKZA9eLxNo5Osq3o32TpMTyTZC9GY2Indd3uEzZAs3uw80UtjQcyJUsIRPRO8LtfvCJefKJ4y4ZBXo0edQI6skkJEZBYAqnQKK3uydnZAIkGdgQqz7jQ1RbTLqZBS7UtXsiD2DktMqlwLs552hPRZALaZBuRdPuAHBZBqUcR6eW4UGj9gZDZD&pretty=0&fields=message%2Cid%2Cthread_id%2Ccreated_time%2Cfrom&limit=25&after=QVFIUlVvTG01LS1FRE5ubG8zMUx2ODdHUm0yeUh0NDBPN2NreWJSZAmU5TE5iVmRSRUROX0hjRUNhVF83VE52RldDN1RGT2UySGxiR29Ram9JQmtpQjRBMzg3NjlXSHVONWl5VXQwN3dDa1hTNVdvb0RTNnhsWmxtLUw4TzlDQlpEcTk3';
        wrapperInstance.Paging = pageRec;
        
        InstaDMWrapper.SenderData senderRec = new InstaDMWrapper.SenderData();
        senderRec.name = 'Shubham Kumar';
        senderRec.email = '25002797006001335@facebook.com';
        senderRec.id = '25002797006001335';
        
        List<InstaDMWrapper.SenderData> senderDataList = new List<InstaDMWrapper.SenderData>();
        senderDataList.add(senderRec);
        
        InstaDMWrapper.Data Datarec = new InstaDMWrapper.Data();
        Datarec.can_reply = true;
        Datarec.id = '25002797006001335';
        Datarec.message_count = 23;
        //Datarec.messages = 
        
        InstaDMWrapper.Messages messageRec = new InstaDMWrapper.Messages();
        messageRec.paging = pageRec;
        
        //wrapperInstance.Messages = messageRec;
        
        /*InstaDMWrapper.fromDetails senderRecFrom = new InstaDMWrapper.fromDetails();
        senderRecFrom.name = 'Shubham Kumar';
        senderRecFrom.email = '25002797006001335@facebook.com';
        senderRecFrom.id = '25002797006001335';*/
        
        system.debug('wrapperInstance==>'+wrapperInstance);
        // Assertions to verify the deserialization
        System.assertNotEquals(null, wrapperInstance);
        System.assertEquals(1, wrapperInstance.data.size());
        
        InstaDMWrapper.Data conversation = wrapperInstance.data[0];
        System.assertEquals('t_7896332630396959', conversation.id);
        System.assertEquals(43, conversation.message_count);
        
        InstaDMWrapper.MessageData messageDataRec = new InstaDMWrapper.MessageData();
        messageDataRec.message  = 'new messageRec.MessageData';
        messageDataRec.id = 'adasd';
        messageDataRec.thread_id = 'adasd';
        messageDataRec.created_time = 'adasd';
        //messageDataRec.fromDetails = senderRecFrom;
    }
}