# flex2exb
This is a web application which does the FLEx to EXB conversion, using primarily XSL developed by Alexandre Arkhipov (https://github.com/sarkipo/xsl4interlinear) and having some parts of the code taken from EXMARaLDA project. The long term plan is to integrate this functionality somehow also into EXMARaLDA, as Partitur Editor is the main tool to work with the files produced by this web service.

The idea is that additional parameters would not need to be specified, as the language attribute is already present in incoming FLEXTEXT file and the settings used in INEL project for different languages can be automatically selected based on this. The model for adding new languages is still being developed, but ideally one could just add the language to the settings file.
