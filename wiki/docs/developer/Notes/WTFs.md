

RdfTemplates.n3 is separately managed in the plugin repo and here. 
Ideally, we'd put it into a new common repo, and mange it with git-subrepo, which is pure bash, but it should't be a problem to run it on a windows machine.

xsd files are managed separately and, in this repo, have been reorganized, cleaned up, extended. Probably we'll just outphase support for xml request and response files altogether. 

servicemanager: my friend wrote this so i used it. I tried out supervisord and i think servicemanager is slightly superior. Something with pure python configuration like django has would be nice, because there is a lot of repetition in our configurations. Would be easily added feature to servicemanager.

