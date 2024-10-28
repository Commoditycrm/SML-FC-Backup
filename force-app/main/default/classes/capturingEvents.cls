public class capturingEvents {
    Public Static void parseEventDataMethod(List<object> eventList,asset ast){
        system.debug('astcapture2');
        list<Asset_History_custom__c> ahhisold = [SELECT Id, Asset__c, Start_Time__c, End_Time__c,RecentHistory__c FROM Asset_History_custom__c where RecentHistory__c=true AND Asset__c =: ast.id];
        integer lsttime1;  
        integer lsttime2; 
        datetime movementTime;
        DateTime movementEndTIme;
        Datetime movementTimeAst;//movement
        DateTime movementEndTimeAst;//movementend 
        Datetime checkpastdate = DateTime.parse('01/01/2021, 12:00 AM');//To check and Avoid Past Date
        Boolean checkFutureTsMoment;//Future ts
        Boolean checkFutureTsMomentEnd;//future ts
        list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
        list<datetime> moveLT = new list<datetime>();    // Stores movement date/time value in user time zone(Local Time)
        list<datetime> moveendLT = new list<datetime>(); // Stores movementEnd date/time value in user time zone(Local Time)
        string jsonstring = Json.serialize(eventList);
        system.debug(jsonstring);
        List<eventParsing> outputdata=(List<eventParsing>)JSON.deserializeStrict(jsonstring, List<eventParsing>.class); 
        system.debug('outputdata---'+outputdata);
        system.debug('outputdataSize---'+outputdata.size());
        map<id,Asset_History_custom__c> astHisMap = new map<id,Asset_History_custom__c>();
        for(Asset_History_custom__c astHis : [SELECT Id, Asset__c, Start_Time__c, End_Time__c,RecentHistory__c FROM Asset_History_custom__c where RecentHistory__c=true AND Asset__c =: ast.id]){
            astHisMap.put(astHis.Asset__c,astHis );
        }
        
        integer loopValue = 1;
        for(eventParsing asp:outputdata)
        {  
            //Asset list
            if(asp.eventName == 'movement')
            {
                datetime listadd=utilityTS.convertTS(asp.ts);
                boolean futuretschk=utilityTS.futueTs(listadd);
                if(listadd > checkpastdate && !futuretschk ){
                    moveLT.add(listadd);
                }
            }  
            if(asp.eventName == 'movementEnd')
            {
                datetime listadd2=utilityTS.convertTS(asp.ts);
                boolean futuretschk2=utilityTS.futueTs(listadd2);
                if(listadd2 > checkpastdate && !futuretschk2 ){
                    moveendLT.add(listadd2);
                }
            } 
            //Asset History
            system.debug('asp'+asp.ts);
            if(asp.eventName=='movementEnd'){
                
                system.debug('asp22'+asp.ts);
                
                if(asp.ts!=null){
                    movementEndTIme =utilityTS.convertTS(asp.ts);
                    checkFutureTsMomentEnd=utilityTS.futueTs(movementEndTIme);
                    
                }
                //Response starts with MovementEnd | Response contains only one movementEND
                if(loopValue == 1){
                    if(astHisMap.containskey(ast.id)){
                        Asset_History_custom__c ahhis1 = astHisMap.get(ast.id);
                        
                        if(movementEndTIme >= ahhis1.Start_Time__c && movementEndTIme > checkpastdate && !checkFutureTsMomentEnd){
                            system.debug('movementEndTIme4'+movementEndTIme);
                            
                            //Asset_History_custom__c ahhis1 = astHisMap.get(ast.id);
                            ahhis1.End_Time__c = movementEndTIme;
                            ahhis1.RecentHistory__c = false;
                            ahlist.add(ahhis1);
                            movementEndTIme = null;
                        }
                    }
                }
            }
            if(asp.eventName=='movement'){
                system.debug('asp222'+asp.ts);
                if(asp.ts!= null){
                    movementTime = utilityTS.convertTS(asp.ts);
                    checkFutureTsMoment=utilityTS.futueTs(movementTIme);
                }
                //Response contains consecutive movement without receiving movementend eg:({eventName=movement, ts=1639971329}),({eventName=movement, ts=1640007645})
                if(loopValue == 1){
                    Asset_History_custom__c ahhis1 = astHisMap.get(ast.id);
                    if(astHisMap.containskey(ast.id)){
                        if(movementTIme > ahhis1.Start_Time__c && movementTIme > checkpastdate && !checkFutureTsMoment && ahhis1.End_Time__c==null)
                        {
                            ahhis1.End_Time__c = movementTIme;
                            ahhis1.RecentHistory__c = false;
                            ahlist.add(ahhis1);
                        }
                        
                    }
                }
                //Response only contains Movement eg:({eventName=movement, ts=1639922216})
                
                if(outputdata.size()==1 ){
                    system.debug('movementTime2'+movementTime);
                    system.debug('ahhisold'+ahhisold);
                    if(ahhisold.size() == 0 || movementTime > ahhisold[0].Start_Time__c){
                                                    system.debug('futurecheck1'+checkFutureTsMoment);

                        if( movementTime > checkpastdate && !checkFutureTsMoment){
                            system.debug('futurecheck'+checkFutureTsMoment);
                        Asset_History_custom__c ahhis=new Asset_History_custom__c();
                        ahhis.Start_Time__c=movementTime;
                        ahhis.RecentHistory__c=true;
                        ahhis.Asset__c=ast.id;
                        ahhis.RecordTypeId = Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByDevelopername().get('Events').getRecordTypeId();
                        ahlist.add(ahhis);
                        system.debug('ahlistnew'+ahlist);
                        }
                    }
                }
                
                //Response Ends with Movement
                
                else if(outputdata.size()== loopValue){
                    system.debug('movementTime3'+movementTime);
                    if(movementTime > checkpastdate && !checkFutureTsMoment){
                        if(ahhisold.size() == 0 || movementTime > ahhisold[0].Start_Time__c){
                            Asset_History_custom__c ahhis=new Asset_History_custom__c();
                            ahhis.Start_Time__c=movementTime;
                            ahhis.RecentHistory__c=true;
                            ahhis.Asset__c=ast.id;
                            ahhis.RecordTypeId = Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByDevelopername().get('Events').getRecordTypeId();
                            ahlist.add(ahhis);
                        }
                    }
                }
            }
            //Response comes with cached response 
            if(movementEndTIme != null && movementTime!= null && ahhisold.size() == 0 && movementEndTIme >= movementTime || movementEndTIme != null && movementTime!= null && movementEndTIme >= movementTime && movementTime >= ahhisold[0].Start_Time__c){
                system.debug('movementTime1'+movementTime);
                system.debug('movementEndTIme1'+movementEndTIme);
                if(movementTime > checkpastdate && movementEndTIme > checkpastdate && !checkFutureTsMoment && !checkFutureTsMomentend){
                    Asset_History_custom__c ahhis=new Asset_History_custom__c();
                    ahhis.Start_Time__c=movementTime;
                    ahhis.End_Time__c = movementEndTIme;
                    ahhis.RecentHistory__c=true;
                    ahhis.Asset__c=ast.id;
                    ahhis.RecordTypeId = Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByDevelopername().get('Events').getRecordTypeId();
                    ahlist.add(ahhis);
                    movementTime = null;
                    movementEndTIme = null;
                }
            }
            loopValue++;  
            
        }
        //Asset Object Updation
        if(moveLT.size() > 0)
        {
            moveLT.sort();
            system.debug('movement User-Timezone' + moveLT);
            List<datetime> Descmovelist = new List<datetime>();
            for(Integer i = moveLT.size()-1; i>=0;i--) // To Sort Movement-list in descending order 
            {
                Descmovelist.add(moveLT.get(i));
            }
            movementTimeAst = Descmovelist[0];
            System.debug('Recent Movement Date/Time -->'+ movementTimeAst); // Sorted highest movement date/time 
        }
        if(moveendLT.size() > 0)
        {
            moveendLT.sort();
            system.debug('movementEnd User-Timezone' + moveendLT);
            List<datetime> Descmoveendlist = new List<datetime>();
            for(Integer i = moveendLT.size()-1; i>=0;i--)  // To Sort Movement End-list in descending order 
            {
                Descmoveendlist.add(moveendLT.get(i)); 
            }
            movementEndTimeAst = Descmoveendlist[0];
            System.debug('Recent MovementEnd Date/Time -->'+ movementEndTimeAst);  // Sorted highest movementEnd date/time 
        }
        if(ast.Movement__c == null  && movementTimeAst != null)
        {
            ast.Movement__c = movementTimeAst;
        }
        if(ast.Movement__c != null && movementTimeAst == null && movementEndTimeAst != null)
        {
            ast.Movement_End__c = movementEndTimeAst;
        }
        if(ast.Movement__c != null &&  movementTimeAst != null && movementEndTimeAst == null && movementTimeAst > ast.Movement__c)
        {
            ast.Movement__c = movementTimeAst;
            ast.Movement_End__c = null;
        }
        if(ast.Movement__c != null &&  movementTimeAst == null && movementEndTimeAst != null && movementEndTimeAst > ast.Movement__c && ast.Movement__c!=null )
        {
            ast.Movement_End__c = movementEndTimeAst;
        }
        if(ast.Movement__c != null &&  movementTimeAst != null && movementEndTimeAst != null && movementEndTimeAst > ast.Movement__c &&  movementEndTimeAst > movementTimeAst && movementTimeAst > ast.Movement__c)
        {
            ast.Movement__c = movementTimeAst;
            ast.Movement_End__c = movementEndTimeAst;
        }
        if(ast.Movement__c != null &&  movementTimeAst != null && movementEndTimeAst != null && movementEndTimeAst > ast.Movement__c &&  movementEndTimeAst < movementTimeAst && movementTimeAst > ast.Movement__c)
        {
            ast.Movement__c = movementTimeAst;
            ast.Movement_End__c = null;
        }
        if(ast.Movement__c != null &&  ast.Movement_End__c != null && movementTimeAst != null && movementEndTimeAst != null && movementEndTimeAst > ast.Movement_End__c &&  movementEndTimeAst > movementTimeAst && movementTimeAst > ast.Movement__c)
        {
            ast.Movement__c = movementTimeAst;
            ast.Movement_End__c = movementEndTimeAst;
        }
        if(ast.Movement__c != null &&  ast.Movement_End__c != null && movementTimeAst != null && movementEndTimeAst != null && movementEndTimeAst > ast.Movement_End__c &&  movementEndTimeAst < movementTimeAst && movementTimeAst > ast.Movement__c)
        {
            ast.Movement__c = movementTimeAst;
            ast.Movement_End__c = null;
        }
        
        
        if(ahlist != null && ahlist.size()>0){
            upsert ahlist; 
        }
        
    }  
    
    
    Public Static void parseEventDataMethodNimblink(List<object> eventList,asset ast, DateTime respCreatedDate){
        system.debug('astcapture2');
        list<Asset_History_custom__c> ahhisold = [SELECT Id, Asset__c, Start_Time__c, End_Time__c,RecentHistory__c FROM Asset_History_custom__c where RecentHistory__c=true AND Asset__c =: ast.id];
        integer lsttime1;  
        integer lsttime2; 
        datetime movementTime;
        DateTime movementEndTIme;
        Datetime movementTimeAst;//movement
        DateTime movementEndTimeAst;//movementend 
        Datetime checkpastdate = DateTime.parse('01/01/2021, 12:00 AM');//To check and Avoid Past Date
        Boolean checkFutureTsMoment;//Future ts
        Boolean checkFutureTsMomentEnd;//future ts
        list<Asset_History_custom__c> ahlist=new list<Asset_History_custom__c>();
        list<datetime> moveLT = new list<datetime>();    // Stores movement date/time value in user time zone(Local Time)
        list<datetime> moveendLT = new list<datetime>(); // Stores movementEnd date/time value in user time zone(Local Time)
        string jsonstring = Json.serialize(eventList);
        system.debug(jsonstring);
        List<eventParsing> outputdata=(List<eventParsing>)JSON.deserializeStrict(jsonstring, List<eventParsing>.class); 
        system.debug('outputdata---'+outputdata);
        system.debug('outputdataSize---'+outputdata.size());
        map<id,Asset_History_custom__c> astHisMap = new map<id,Asset_History_custom__c>();
        for(Asset_History_custom__c astHis : [SELECT Id, Asset__c, Start_Time__c, End_Time__c,RecentHistory__c FROM Asset_History_custom__c where RecentHistory__c=true AND Asset__c =: ast.id]){
            astHisMap.put(astHis.Asset__c,astHis );
        }
        
        integer loopValue = 1;
        for(eventParsing asp:outputdata)
        {  
            //Asset list
            if(asp.eventName == 'movement')
            {
                datetime listadd=utilityTS.convertTS(asp.ts);
                boolean futuretschk= listadd > respCreatedDate.AddDays(1); //utilityTS.futueTs(listadd);
                if(listadd > checkpastdate && !futuretschk ){
                    moveLT.add(listadd);
                }
            }  
            if(asp.eventName == 'movementEnd')
            {
                datetime listadd2=utilityTS.convertTS(asp.ts);
                boolean futuretschk2= listadd2 > respCreatedDate.AddDays(1);  //utilityTS.futueTs(listadd2);
                if(listadd2 > checkpastdate && !futuretschk2 ){
                    moveendLT.add(listadd2);
                }
            } 
            //Asset History
            system.debug('asp'+asp.ts);
            if(asp.eventName=='movementEnd'){
                
                system.debug('asp22'+asp.ts);
                
                if(asp.ts!=null){
                    movementEndTIme =utilityTS.convertTS(asp.ts);
                    checkFutureTsMomentEnd= movementEndTIme > respCreatedDate.AddDays(1);  //utilityTS.futueTs(movementEndTIme);
                    
                }
                //Response starts with MovementEnd | Response contains only one movementEND
                if(loopValue == 1){
                    if(astHisMap.containskey(ast.id)){
                        Asset_History_custom__c ahhis1 = astHisMap.get(ast.id);
                        
                        if(movementEndTIme >= ahhis1.Start_Time__c && movementEndTIme > checkpastdate && !checkFutureTsMomentEnd){
                            system.debug('movementEndTIme4'+movementEndTIme);
                            
                            //Asset_History_custom__c ahhis1 = astHisMap.get(ast.id);
                            ahhis1.End_Time__c = movementEndTIme;
                            ahhis1.RecentHistory__c = false;
                            ahlist.add(ahhis1);
                            movementEndTIme = null;
                        }
                    }
                }
            }
            if(asp.eventName=='movement'){
                system.debug('asp222'+asp.ts);
                if(asp.ts!= null){
                    movementTime = utilityTS.convertTS(asp.ts);
                    checkFutureTsMoment= movementTIme > respCreatedDate.AddDays(1); // utilityTS.futueTs(movementTIme);
                }
                //Response contains consecutive movement without receiving movementend eg:({eventName=movement, ts=1639971329}),({eventName=movement, ts=1640007645})
                if(loopValue == 1){
                    Asset_History_custom__c ahhis1 = astHisMap.get(ast.id);
                    if(astHisMap.containskey(ast.id)){
                        if(movementTIme > ahhis1.Start_Time__c && movementTIme > checkpastdate && !checkFutureTsMoment && ahhis1.End_Time__c==null)
                        {
                            ahhis1.End_Time__c = movementTIme;
                            ahhis1.RecentHistory__c = false;
                            ahlist.add(ahhis1);
                        }
                        
                    }
                }
                //Response only contains Movement eg:({eventName=movement, ts=1639922216})
                
                if(outputdata.size()==1 ){
                    system.debug('movementTime2'+movementTime);
                    system.debug('ahhisold'+ahhisold);
                    if(ahhisold.size() == 0 || movementTime > ahhisold[0].Start_Time__c){
                                                    system.debug('futurecheck1'+checkFutureTsMoment);

                        if( movementTime > checkpastdate && !checkFutureTsMoment){
                            system.debug('futurecheck'+checkFutureTsMoment);
                        Asset_History_custom__c ahhis=new Asset_History_custom__c();
                        ahhis.Start_Time__c=movementTime;
                        ahhis.RecentHistory__c=true;
                        ahhis.Asset__c=ast.id;
                        ahhis.RecordTypeId = Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByDevelopername().get('Events').getRecordTypeId();
                        ahlist.add(ahhis);
                        system.debug('ahlistnew'+ahlist);
                        }
                    }
                }
                
                //Response Ends with Movement
                
                else if(outputdata.size()== loopValue){
                    system.debug('movementTime3'+movementTime);
                    if(movementTime > checkpastdate && !checkFutureTsMoment){
                        if(ahhisold.size() == 0 || movementTime > ahhisold[0].Start_Time__c){
                            Asset_History_custom__c ahhis=new Asset_History_custom__c();
                            ahhis.Start_Time__c=movementTime;
                            ahhis.RecentHistory__c=true;
                            ahhis.Asset__c=ast.id;
                            ahhis.RecordTypeId = Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByDevelopername().get('Events').getRecordTypeId();
                            ahlist.add(ahhis);
                        }
                    }
                }
            }
            //Response comes with cached response 
            if(movementEndTIme != null && movementTime!= null && ahhisold.size() == 0 && movementEndTIme >= movementTime || movementEndTIme != null && movementTime!= null && movementEndTIme >= movementTime && movementTime >= ahhisold[0].Start_Time__c){
                system.debug('movementTime1'+movementTime);
                system.debug('movementEndTIme1'+movementEndTIme);
                if(movementTime > checkpastdate && movementEndTIme > checkpastdate && !checkFutureTsMoment && !checkFutureTsMomentend){
                    Asset_History_custom__c ahhis=new Asset_History_custom__c();
                    ahhis.Start_Time__c=movementTime;
                    ahhis.End_Time__c = movementEndTIme;
                    ahhis.RecentHistory__c=true;
                    ahhis.Asset__c=ast.id;
                    ahhis.RecordTypeId = Schema.SObjectType.Asset_History_custom__c.getRecordTypeInfosByDevelopername().get('Events').getRecordTypeId();
                    ahlist.add(ahhis);
                    movementTime = null;
                    movementEndTIme = null;
                }
            }
            loopValue++;  
            
        }
        //Asset Object Updation
        if(moveLT.size() > 0)
        {
            moveLT.sort();
            system.debug('movement User-Timezone' + moveLT);
            List<datetime> Descmovelist = new List<datetime>();
            for(Integer i = moveLT.size()-1; i>=0;i--) // To Sort Movement-list in descending order 
            {
                Descmovelist.add(moveLT.get(i));
            }
            movementTimeAst = Descmovelist[0];
            System.debug('Recent Movement Date/Time -->'+ movementTimeAst); // Sorted highest movement date/time 
        }
        if(moveendLT.size() > 0)
        {
            moveendLT.sort();
            system.debug('movementEnd User-Timezone' + moveendLT);
            List<datetime> Descmoveendlist = new List<datetime>();
            for(Integer i = moveendLT.size()-1; i>=0;i--)  // To Sort Movement End-list in descending order 
            {
                Descmoveendlist.add(moveendLT.get(i)); 
            }
            movementEndTimeAst = Descmoveendlist[0];
            System.debug('Recent MovementEnd Date/Time -->'+ movementEndTimeAst);  // Sorted highest movementEnd date/time 
        }
        if(ast.Movement__c == null  && movementTimeAst != null)
        {
            ast.Movement__c = movementTimeAst;
        }
        if(ast.Movement__c != null && movementTimeAst == null && movementEndTimeAst != null)
        {
            ast.Movement_End__c = movementEndTimeAst;
        }
        if(ast.Movement__c != null &&  movementTimeAst != null && movementEndTimeAst == null && movementTimeAst > ast.Movement__c)
        {
            ast.Movement__c = movementTimeAst;
            ast.Movement_End__c = null;
        }
        if(ast.Movement__c != null &&  movementTimeAst == null && movementEndTimeAst != null && movementEndTimeAst > ast.Movement__c && ast.Movement__c!=null )
        {
            ast.Movement_End__c = movementEndTimeAst;
        }
        if(ast.Movement__c != null &&  movementTimeAst != null && movementEndTimeAst != null && movementEndTimeAst > ast.Movement__c &&  movementEndTimeAst > movementTimeAst && movementTimeAst > ast.Movement__c)
        {
            ast.Movement__c = movementTimeAst;
            ast.Movement_End__c = movementEndTimeAst;
        }
        if(ast.Movement__c != null &&  movementTimeAst != null && movementEndTimeAst != null && movementEndTimeAst > ast.Movement__c &&  movementEndTimeAst < movementTimeAst && movementTimeAst > ast.Movement__c)
        {
            ast.Movement__c = movementTimeAst;
            ast.Movement_End__c = null;
        }
        if(ast.Movement__c != null &&  ast.Movement_End__c != null && movementTimeAst != null && movementEndTimeAst != null && movementEndTimeAst > ast.Movement_End__c &&  movementEndTimeAst > movementTimeAst && movementTimeAst > ast.Movement__c)
        {
            ast.Movement__c = movementTimeAst;
            ast.Movement_End__c = movementEndTimeAst;
        }
        if(ast.Movement__c != null &&  ast.Movement_End__c != null && movementTimeAst != null && movementEndTimeAst != null && movementEndTimeAst > ast.Movement_End__c &&  movementEndTimeAst < movementTimeAst && movementTimeAst > ast.Movement__c)
        {
            ast.Movement__c = movementTimeAst;
            ast.Movement_End__c = null;
        }
        
        
        if(ahlist != null && ahlist.size()>0){
            upsert ahlist; 
        }
        
    }
}