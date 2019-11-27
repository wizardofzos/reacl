#!/bin/bash
#
## reacl.sh - the -R option for setfacl
#             use with care :)
#
#  version 0.3 (minor commits not versioned)
#  added non-interactive mode with autorun=no or autorun=yes
#  autorun=yes runs reacl and automatically executes .fixscript
#  autorun=no runs reacl and does not run .fixscript

# Check number of parameters

if [ $# -lt 1 ]; then
  echo "Usage : `basename $0` {directory}"
  echo ""
  exit 100
fi

# Check ownership
rootsowner=
# Check UID (problems can occur if not root)
uid=`id -u`
if [ $uid  != "0" ]; then
  echo "REACL : You're not root. Autorisation errors might occur"
  if [[ $* != *--autorun* ]]; then
    echo "        Press [ENTER] key to continue"
    read cont
  else
    if [[ $* = *--autorun=yes* ]] || [[ $* = *--autorun=no* ]]; then
      echo "REACL : Running non-interactive. Good luck."
    else
      echo "REACL : Invalid value for autorun, use yes or no"
      exit 1
    fi
  fi
fi


root=$1

# Start with a sanity-check
# If dir has no default acls's it's useless to continue
check=`getfacl -dfco $root`
if [ ! $check ]; then
  echo "REACL : The given directory ($root) has no default ACL's set. Program terminated"
  exit 1
fi

# Check for setfacl and getfacl

# There we go
echo "REACL : Starting.....`date`"

# Init script file
echo "#!/bin/bash" > $HOME/.fixscript

# Get our input strings
dcom=`getfacl -dcom $root`
fcom=`getfacl -fcom $root`

# Set the parm to execute when files are bad
filesetfaclparm=$(echo $fcom | sed 's/fdefault://g')

# Format our (z/OS only) find parameters
fstring=$(echo $fcom | sed 's/,/ -acl_entry /g')
fstring=" -acl_entry $fstring"
dstring=$(echo $dcom | sed 's/,/ -acl_entry /g')
dstring=" -acl_entry $dstring"
astring=$(echo $fcom | sed 's/,/ -acl_entry /g')
astring=$(echo $astring | sed 's/fdefault://g')
astring=" -acl_entry $astring"
inheritfromdstring=$(echo $dstring | sed 's/default://g')
fixinherit=$(echo $inheritfromdstring | sed 's/-acl_entry/,/g')

# Find all good files
find $root $astring -type f > $HOME/.goodfiles
echo "REACL : All correct files listed `date`"

# Find all good dirs
okdirarg="$fstring $dstring $inheritfromdstring"
find $root $okdirarg -type d > $HOME/.gooddirs
echo "REACL : All correct directories listed `date`"

# Find all files
find $root -type f > $HOME/.allfiles
echo "REACL : All files listed `date`"

# Find all dirs
find $root -type d > $HOME/.alldirs
echo "REACL : All directories listed `date`"

# Substract the good from all, leaving the bad
cat $HOME/.allfiles $HOME/.goodfiles | sort | uniq -u > $HOME/.todofiles
cat $HOME/.alldirs $HOME/.gooddirs | sort | uniq -u > $HOME/.tododirs
echo "REACL : All bad directories and files determined `date`"

# Generate our fixscript
echo "REACL : Generating FixScript"
cat $HOME/.todofiles | sed "s/.*/setfacl -m '$filesetfaclparm' '&'/" >> $HOME/.fixscript
cat $HOME/.tododirs | sed "s/.*/setfacl -m '$fcom,$dcom $fixinherit' '&'/" >> $HOME/.fixscript

# Make it executable
chmod +x $HOME/.fixscript

# Some eyecandy
echo "REACL : Done. `date`"
len=`cat $HOME/.fixscript | wc -l`

if [ $len = "1" ]; then
  echo "REACL : Nothing needs fixed."
  echo "REACL : Finished"
  exit 0
fi

if [[ $* != *--autorun* ]]; then
  echo "REACL : Type RUNIT followed by [ENTER] to fix the ACLs now"
  echo "REACL : Press [ENTER] to manually run the script"
  read doit
elif [[ $* = *--autorun=yes* ]]; then
  doit="RUNIT"
fi

if [ ! $doit ]; then
  echo "REACL : Not running the script as requested"
  echo "REACL : Run $HOME/.fixscript to fix your ACL's"
  echo "REACL : Finished"
  exit 0
fi

if [ $doit = "RUNIT" ]; then
  echo "REACL : Running generated script as requested"
  $HOME/.fixscript
  echo "REACL : Script completed"
  echo "REACL : Finished"
fi
