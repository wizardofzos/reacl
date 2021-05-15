# reacl.sh

### Sometimes you just don't have the time to mess about

And then there's no -R option for the setfacl command. Mainly this is a good thing.
If somehow you decide your ACL's should be diffirent than from what you've set them initially you should ask yourself the "7 W's" about 3 times?

But when you realise this needs to be done, it's a major drag to provide all existing files with the correct ACL's.
Sure, one can 'reallocate' all the files into a new directory (with correct ACL's) then delete the old directory and rename the new one to the old one.

This reacl.sh script has a somewhat other approach :)

*WARNING* 

reacl.sh will alter all files in the provided directory "as if they were just created" with the new ACL's in place.
It will *not* take into account any default ACL changes 'down the tree'.

Did I say *WARNING* yet?

Anyway, future commits will have some more info on usage and results. Oh and by the way,
this version is *not production proof*, use it at your own risk.

