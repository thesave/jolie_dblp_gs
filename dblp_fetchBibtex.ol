include "console.iol"
include "string_utils.iol"
include "file.iol"
include "exec.iol"

constants {
	Attrs = "@Attributes",
	PublicationType_InProceedings = 1,
	PublicationType_Article = 2
}

type _DBLP_GetPersonPublicationsRequest:void {
	.nameKey:string
	.initial:string
}

interface DBLPServerInterface {
RequestResponse:
	getPersonPublications(_DBLP_GetPersonPublicationsRequest)(undefined),
	getBibtex(string)(string)
}

outputPort DBLPServer {
Location: "socket://dblp.uni-trier.de:443/"
Protocol: https {
	.osc.getPersonPublications.alias = "pers/xk/%{initial}/%{nameKey}.xml";
	.osc.getBibtex.alias = "rec/bib2/%!{$}.bib";
	.format -> format;
	.method -> method;
	.keepAlive = false // DBLP does not like reusing connections
}
Interfaces: DBLPServerInterface
}

main
{
	if ( #args != 3 ) {
		println@Console( "[ERROR] Must specify three arguments: <initial> <name key> <output filename>" )();
		throw( InvalidArgs )
	};

	format = "xml";
	method = "get";

	request.initial = args[0];
	request.nameKey = args[1];

	println@Console( "Requesting list of publications for " + request.nameKey )();
	getPersonPublications@DBLPServer( request )( response );

	conference = "conf/concur";
	replaceAll@StringUtils( request.nameKey { .regex = ":", .replacement = " "} )( author );

	format = "html";
	for( i = k = 0, i < #response.dblpkey, i++ ) {
		contains@StringUtils( response.dblpkey[i] { .substring = conference } )( conf );
		if ( conf && !is_defined( response.dblpkey[i].(Attrs) ) ) {
			k++;
			// It's a publication key
			println@Console( "Fetching bibtex for publication " + response.dblpkey[i] )();
			getBibtex@DBLPServer( response.dblpkey[i] )( bibtex );
			replaceAll@StringUtils( bibtex { .regex = "\\s+", .replacement = " "} )( bibtex );
			find@StringUtils( bibtex { .regex = "title\\s*=\\s*\\{(.+?)\\},"} )( found );
			title = found.group[1];
			scope( gs )
			{
				install( ServiceError => 
					println@Console( "Service Error: " + gs.ServiceError )() );
				getOnScholar@GSWrapper( title { .author = author } )( gs_res );
				getScholarTitle@GSWrapper( gs_res )( gs_title );
				getScholarTitle@GSWrapper( gs_res )( gs_cites );
				println@Console( bibitex )()  
			}
		};
		fileOut.content += bibtex
	};
	fileOut.filename = args[2];
	println@Console( "Writing output to file " + fileOut.filename )();
	writeFile@File( fileOut )()
}

type gsSearch: string {
	  .author?: string
	}

interface GSWrapperInterface {
	  RequestResponse: 
		getOnScholar( gsSearch )( string ) throws ServiceError( string ), 
		getScholarTitle( string )( string ), 
		getScholarCitations ( string )( string )
	}	

service GSWrapper 
{
	Interfaces: GSWrapperInterface
	main 
	{
		[ getOnScholar( req )( res ){
					println@Console( "Looking for \"" + req + "\"" )();
					with( cmd ){
					  .args[#.args] = "scholar.py";
					  .args[#.args] = "-c";
					  .args[#.args] = "1";
					  .args[#.args] = "--all";
					  .args[#.args] = "\"" + req + "\"";
					  if( is_defined( req.author ) ){
					  	.args[#.args] = "--author";
					  	.args[#.args] = "\"" + req.author + "\""
					  };
					  .args[#.args] = "-d";.args[#.args] = "-d";
					  .args[#.args] = "-d";.args[#.args] = "-d";
		    		.waitFor = 1
					};
					cmd = "python3";
					exec@Exec( cmd )( res );
					if ( is_defined( res.stderr ) ){
						find@StringUtils( res.stderr { .regex = "(retrieval failed: .+)"} )( error );
						if ( is_defined( error.group[1] ) ){
							throw( ServiceError, error.group[1] )
						}
					};
					println@Console( res )()
		} ]
		[ getScholarTitle( req )( res ){
			find@StringUtils( result { .regex = "Title\\s*(.+)"} )( gs_title );
			res = gs_title.group[1];
			println@Console( "Found: \"" + gs_title + "\" on Google Scholar" )()
		} ]
		[ getScholarCitations( req )( res ){
			find@StringUtils( result { .regex = "Citations\\s*(\\d+)"} )( gs_cites );
			res = gs_cites.group[1];
			println@Console( "Citations: " + gs_cites )()
		} ]
	}
}
