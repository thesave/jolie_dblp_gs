const puppeteer = require('puppeteer-core');

const options = { 
	"executablePath" : "/usr/local/Caskroom/google-chrome/latest/Google\ Chrome.app/Contents/MacOS/Google\ Chrome" 
	// ,headless : false
}

const title = encodeURI( process.argv[ 2 ] )
	.replace(/\(.+\)/g,'')
	.replace(/\s/g, '+');

const url = 
'https://www.scopus.com/results/results.uri?numberOfFields=0&src=s&clickedLink=&edit=&editSaveSearch=&origin=searchbasic&authorTab=&affiliationTab=&advancedTab=&scint=1&menu=search&tablin=&searchterm1=' + title + '&field1=TITLE&dateType=Publication_Date_Type&yearFrom=Before+1960&yearTo=Present&loadDate=7&documenttype=All&accessTypes=All&resetFormLink=&st1=' + title + '.&st2=&sot=b&sdt=b&sl=54&s=TITLE%28' + title + '%29&sid=27b325506daa367b9eacbd539c9169a8&searchId=27b325506daa367b9eacbd539c9169a8&txGid=13d76f13e33385a837fa4d4faa4b9e90&sort=plf-f&originationType=b&rr='

const userAgent = 'Mozilla/5.0 (X11; Linux x86_64)' +
  'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.39 Safari/537.36';

async function getData() {
	const browser = await puppeteer.launch( options );
	const page = await browser.newPage();
	await page.setUserAgent(userAgent);
	await page.evaluateOnNewDocument(() => {
		Object.defineProperty(navigator, 'webdriver', {
			get: () => false,
		});
		Object.defineProperty(navigator, 'languages', {
			get: () => ['en-US', 'en'],
		});
		const originalQuery = window.navigator.permissions.query;
		return window.navigator.permissions.query = (parameters) => (
			parameters.name === 'notifications' ?
				Promise.resolve({ state: Notification.permission }) :
				originalQuery(parameters)
		);
	});
	// page.on('console', consoleObj => console.log(consoleObj.text()));
  await page.goto( url );
	citations = await page.evaluate( async () => {
		const c = document.querySelector("#resultDataRow0 > td:nth-child(6)");
		if( c != null ){
			return c.textContent
		} else {
			return ""
		}
	}).catch((error) => {
		console.log( error );
		return "";
	});
	citations = citations.trim();
	if( citations.length > 0 ){
		console.log( citations );
		await browser.close();
		process.exit( 0 );
	} else {
		await browser.close();
		process.exit( 1 );
	}
}

getData();