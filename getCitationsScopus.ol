include "console.iol"
include "string_utils.iol"
include "file.iol"
include "exec.iol"

main
{
	for ( i=1990, i<2019, i++ ) {
		println@Console( "Processing " + i )();
		readFile@File( { .filename = "json_archive/concur" + i + ".json", .format = "json" } )( bib );
		for ( hit in bib.result.hits.hit ) {
			println@Console( hit.info.doi )();
			exec@Exec( "phantomjs"
			{
				.args[0] = "scopus_doi.js",
				.args[1] = hit.info.doi,
				.waitFor = 1
			})( result );
			undef( result.exitCode );
			trim@StringUtils( result )( citations );
			if( citations == "" ){
				println@Console( "DOI search found no match, looking for citations with title" )();
				exec@Exec( "phantomjs"
				{
					.args[0] = "scopus_title.js",
					.args[1] = hit.info.title,
					.waitFor = 1
				})( result );
				undef( result.exitCode );
				trim@StringUtils( result )( citations )
			};
			if( citations != "" ){
				hit.info.citations = citations
			} else {
				hit.info.citations = "Not Found"
			};
			println@Console( hit.info.citations )()
		};
		write.content << bib;
		write.filename = "json_archive_cit/concur" + i + ".json";
		write.format = "json";
		writeFile@File( write )();
		undef( bib )
	}

}
