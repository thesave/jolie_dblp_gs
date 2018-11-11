// 10.1007%2FBFb0039051
var system = require('system');
var args = system.args;
var doi = encodeURI( args[1] );
var fs = require('fs');
var CookieJar = "cookies.json";
if(fs.isFile(CookieJar))
    Array.prototype.forEach.call(JSON.parse(fs.read(CookieJar)), function(x){
        phantom.addCookie(x);
    });
var page = require('webpage').create();
page.onError = function(msg, trace) {
    var msgStack = ['ERROR: ' + msg];
    if (trace && trace.length) {
        msgStack.push('TRACE:');
        trace.forEach(function(t) {
            msgStack.push(' -> ' + t.file + ': ' + t.line + (t.function ? ' (in function "' + t.function + '")' : ''));
        });
    }
    // uncomment to log into the console 
    // console.error(msgStack.join('\n'));
};
page.open('https://www.scopus.com/results/results.uri?numberOfFields=0&src=s&clickedLink=&edit=&editSaveSearch=&origin=searchbasic&authorTab=&affiliationTab=&advancedTab=&scint=1&menu=search&tablin=&searchterm1=10.1007%2FBFb0039051&field1=DOI&dateType=Publication_Date_Type&yearFrom=Before+1960&yearTo=Present&loadDate=7&documenttype=All&accessTypes=All&resetFormLink=&st1=' + doi +'&st2=&sot=b&sdt=b&sl=23&s=DOI%28' + doi + '%29&sid=6382380b611de74e9ed124d18bce708c&searchId=6382380b611de74e9ed124d18bce708c&txGid=bcc4b1d91ee4c25d29c7d4b04c385409&sort=plf-f&originationType=b&rr=', 
  function() {
    page.includeJs("https://code.jquery.com/jquery-3.3.1.min.js", function() {
      var text = page.evaluate( function() { return $("#resultDataRow0 > td:nth-child(6) > a").text() });
      console.log( text.trim() );
      phantom.exit(0);
  });
});