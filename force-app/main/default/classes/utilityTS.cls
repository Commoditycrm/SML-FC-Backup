public class utilityTS 
{
    public static datetime convertTS(long inputtimestamp)
    {
        integer integerTS;
        
        if(inputtimestamp != null)
        {
            integerTS =(Integer)inputtimestamp; 
             system.debug('type casted integer TS-test:'+integerTS + 'Response TS-test:' + inputtimestamp );
        }
        integer year;
        integer month;
        integer day;
        integer hour;
        integer min;
        integer sec;
        
        TimeZone tz = UserInfo.getTimeZone();
        system.debug(tz.getDisplayName());  
        system.debug('Timestamp in Response'+integerTS);  
        system.debug('System Date Time '+System.now());
        if(tz.getDisplayName().contains('(GMT-05:00)'))
        {
            year = 1969;
            month = 12;
            day = 31;
            hour = 23;
        } 
        else if(tz.getDisplayName().contains('(GMT-06:00)')){
            year = 1970;
            month = 1;
            day = 1;
            hour = 0;  
        }
        DateTime epochDate = DateTime.newInstance(year,month,day,hour,0,0);
        datetime t;
        DateTime outputtime;
        
        if(integerTS != null)
        {
            system.debug('type casted integer TS:'+integerTS + 'Response TS:' + inputtimestamp );
            t = epochDate.addSeconds(integerTS);   
            system.debug('epochDate_addSeconds:'+t);
        }
        if(t != null)
        {
            outputtime = t.AddSeconds(tz.getOffset(t)/1000); ///User zone time
        }
        system.debug('outputtime -' + outputtime);
        return outputtime;
        
    }
    
    // This method returns true if TS is future date, else false if TS is <= system date
    public static boolean futueTs(datetime inputtimestamp)//user time zone
    {
        system.debug('inputtimestamp'+inputtimestamp);
        boolean tsboolean;
        datetime serverTime;
        datetime systemtime=system.now().AddDays(1);//gmt 
        system.debug('systemtime'+systemtime);
        if( inputtimestamp > systemtime){//if this condition is passed we get future time in response
            tsboolean=true;
        }else{
            tsboolean=false; // acceptable timestamp
        }
        system.debug('futureTs -' + tsboolean);
        return tsboolean;
    }
    
}