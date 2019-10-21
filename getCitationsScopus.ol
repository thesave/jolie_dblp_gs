include "console.iol"
include "string_utils.iol"
include "file.iol"
include "exec.iol"

define process_year {
	println@Console( "Processing " + i )();
		readFile@File( { .filename = "json_archive/concur" + i + ".json", .format = "json" } )( bib );
		for ( hit in bib.result.hits.hit ) {
			if( is_defined( hit.info.doi ) ){
				println@Console( hit.info.doi )();
				exec@Exec( "node"
				{
					.args[0] = "scopus_doi.js",
					.args[1] = hit.info.doi,
					.waitFor = 1
				})( result );
				if( result.exitCode > 0 ){
					println@Console( "DOI search found no match, looking for citations with title" )()
					undef( result )
					println@Console( hit.info.title )();
					if( is_defined( hit.info.title ) ){
					exec@Exec( "node"
					{
						.args[0] = "scopus_title.js",
						.args[1] = hit.info.title,
						.waitFor = 1
					})( result )
					}
				};
				undef( result.exitCode )
			}
			if( is_defined( result ) ){
				trim@StringUtils( result )( citations )
			}
			if( citations != "" ){
				hit.info.citations = citations
			} else {
				hit.info.citations = "Not Found"
			};
			println@Console( hit.info.citations )()
		};
		write.content << bib;
		write.filename = filename;
		write.format = "json";
		writeFile@File( write )();
		undef( bib )
}

main
{
	for ( i=1990, i<2020, i++ ) {
		filename = "json_archive_cit/concur" + i + ".json";
		exists@File( filename )( exists )
		if( exists ){
			println@Console( "Year " + i + " already processed, skipping" )()
		} else {
			process_year
		}
		
	}

}
