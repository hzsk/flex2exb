# flex2exb
This is a web application which does the FLEx to EXB conversion, using primarily XSL developed by Alexandre Arkhipov (https://github.com/sarkipo/xsl4interlinear)

The idea is that one could specify the language specific settings and just use the web service to do the conversion. One could add a drag-and-drop kind of user interface and get back from that a zip file with all converted files.

What makes the conversion language specific is that the XML nodes can be selected from FLEx XML export only by the language id's and those are different in each project.

User could also specify what kind of tiers they want, but this should be done in an abstract manner so that there would be no touching of tier settings, just selection of what is wanted and program knows what to insert.

## Example

![Example](https://raw.githubusercontent.com/hzsk/flex2exb/master/rest_client_example.png)