package Wais;

require Exporter;
require DynaLoader;
@ISA = qw(Exporter DynaLoader);
# Items to export into callers namespace by default
@EXPORT = qw();
# Other items we are prepared to export if requested
@EXPORT_OK = qw(maxdoc recsep fldsep search retrieve dictionary 
                list_offset postings document);

$version = '';                  # make perl -w happy
bootstrap Wais;

1;
