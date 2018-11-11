var system = require('system');
var args = system.args;
var title = encodeURI( args[1] );
var title_spaced = title.replace(/\s/g, '+');
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
page.open('https://www.scopus.com/results/results.uri?numberOfFields=0&src=s&clickedLink=&edit=&editSaveSearch=&origin=searchbasic&authorTab=&affiliationTab=&advancedTab=&scint=1&menu=search&tablin=&searchterm1=Deriving+Complete+Inference+Systems+for+a+Class+of+GSOS+Languages+Generating+Regular+Behaviours&field1=TITLE_ABS_KEY&dateType=Publication_Date_Type&yearFrom=Before+1960&yearTo=Present&loadDate=7&documenttype=All&accessTypes=All&resetFormLink=&st1=' + title + '&st2=&sot=b&sdt=b&sl=110&s=TITLE-ABS-KEY%28' + title + '%29&sid=88cd1ed9419b0286525a87a83bd07e1a&searchId=88cd1ed9419b0286525a87a83bd07e1a&txGid=676f0629f459c311eeaea7c01a95ae5a&sort=plf-f&originationType=b&rr=', 
  function() {
    page.includeJs("https://code.jquery.com/jquery-3.3.1.min.js", function() {
      var text = page.evaluate( function() { return $("#resultDataRow0 > td:nth-child(6) > a").text() });
      console.log( text.trim() );
      phantom.exit(0);
  });
});