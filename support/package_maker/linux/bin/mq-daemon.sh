#!/bin/bash  
#
# Startup script for mq under *nix systems (it works under NT/cygwin too).
#
# Configuration files
#
# /etc/default/mq
#   If it exists, this is read at the start of script. It may perform any 
#   sequence of shell commands, like setting relevant environment variables.
#
# $HOME/.mqrc
#   If it exists, this is read at the start of script. It may perform any 
#   sequence of shell commands, like setting relevant environment variables.
#   
# Configuration variables
#
# JAVA_HOME  
#   Home of Java installation. 
#
# JAVA
#   Command to invoke Java. If not set, $JAVA_HOME/bin/java will be
#   used.
#
# JAVA_OPTIONS
#   Extra options to pass to the JVM
#
# MQ_HOME
#   Where Monad is installed. If not set, the script will try go
#   guess it by first looking at the invocation path for the script.
#   
# MQ_PORT
#   The port used to bind;
#   
# MQ_ARGS
#   The default arguments to pass to mq.
#
# MQ_USER
#   if set, then used as a username to run the server as
#

usage()
{
    echo "Usage: $0 {start|stop|run|restart|check|supervise} [ parameter ... ] "
    exit 1
}

[ $# -gt 0 ] || usage


##################################################
# Some utility functions
##################################################
findDirectory()
{
    OP=$1
    shift
    for L in $* ; do
        [ $OP $L ] || continue 
        echo $L
        break
    done 
}

running()
{
    [ -f $1 ] || return 1
    PID=$(cat $1)
    ps -p $PID >/dev/null 2>/dev/null || return 1
    return 0
}







##################################################
# Get the action & configs
##################################################

ACTION=$1
shift
MQ_ARGS="$*"
CONFIGS=""
NO_START=0
TMP=/tmp

##################################################
# See if there's a default configuration file
##################################################
if [ -f /etc/default/mq ] ; then 
  . /etc/defaultm/mq
fi


##################################################
# See if there's a user-specific configuration file
##################################################
if [ -f $HOME/.mqrc ] ; then 
  . $HOME/.mqrc
fi



##################################################
# MQ's hallmark
##################################################
MQ_INSTALL_TRACE_FILE="doc/README.txt"
TMPJ=$TMP/j$$

##################################################
# Try to determine MQ_HOME if not set
##################################################
if [ -z "$MQ_HOME" ] 
then
    ## resolve links - $0 may be a link to mq's home
    PRG="$0"
    # need this for relative symlinks
    while [ -h "$PRG" ] ; do
        ls=`ls -ld "$PRG"`
        link=`expr "$ls" : '.*-> \(.*\)$'`
        if expr "$link" : '/.*' > /dev/null; then
            PRG="$link"
        else
            PRG="`dirname "$PRG"`/$link"
        fi
    done

    MQ_HOME_1=`dirname "$PRG"`/..

  if [ -f "${MQ_HOME_1}/$MQ_INSTALL_TRACE_FILE" ] ; 
  then 
     MQ_HOME=${MQ_HOME_1} 
  fi
fi

##################################################
# No MQ_HOME yet? We're out of luck!
##################################################
if [ -z "$MQ_HOME" ] ; then
    echo "** ERROR: MQ_HOME not set, you need to set it or install in a standard location" 
    exit 1
fi

cd $MQ_HOME
MQ_HOME=`pwd`


#####################################################
# Check that mq is where we think it is
#####################################################
if [ ! -r $MQ_HOME/$MQ_INSTALL_TRACE_FILE ] 
then
   echo "** ERROR: Oops! mq doesn't appear to be installed in $MQ_HOME"
   echo "** ERROR:  $MQ_HOME/$MQ_INSTALL_TRACE_FILE is not readable!"
   exit 1
fi


#####################################################
# Find a location for the pid file
#####################################################
if [  -z "$MQ_RUN" ] 
then
    MQ_RUN=${MQ_HOME}/var
fi

#####################################################
# Find a PID for the pid file
#####################################################
if [  -z "$MQ_DAEMON_PID" ] 
then
   echo "** ERROR: Oops! unset MQ_DAEMON_PID"
   exit 1
fi
MQ_PID=$MQ_RUN/$MQ_DAEMON_PID
#####################################################
# Find a mq main class 
#####################################################
if [  -z "$MQ_MAIN" ] 
then
   echo "** ERROR: Oops! unset MQ_MAIN"
   exit 1
fi
#####################################################
# Find a mq message 
#####################################################
if [  -z "$MQ_MESSAGE" ] 
then
    MQ_MESSAGE="mq server"
fi



##################################################
# Check for JAVA_HOME
##################################################
if [ -z "$JAVA_HOME" ]
then
    # If a java runtime is not defined, search the following
    # directories for a JVM and sort by version. Use the highest
    # version number.

    # Java search path
    JAVA_LOCATIONS="\
        /usr/java \
        /usr/bin \
        /usr/local/bin \
        /usr/local/java \
        /usr/local/jdk \
        /usr/local/jre \
	/usr/lib/jvm \
        /opt/java \
        /opt/jdk \
        /opt/jre \
    " 
    JAVA_NAMES="java jdk jre"
    for N in $JAVA_NAMES ; do
        for L in $JAVA_LOCATIONS ; do
            [ -d $L ] || continue 
            find $L -name "$N" ! -type d | grep -v threads | while read J ; do
                [ -x $J ] || continue
                VERSION=`eval $J -version 2>&1`       
                [ $? = 0 ] || continue
                VERSION=`expr "$VERSION" : '.*"\(1.[0-9\.]*\)["_]'`
                [ "$VERSION" = "" ] && continue
                expr $VERSION \< 1.2 >/dev/null && continue
                echo $VERSION:$J
            done
        done
    done | sort | tail -1 > $TMPJ
    JAVA=`cat $TMPJ | cut -d: -f2`
    JVERSION=`cat $TMPJ | cut -d: -f1`

    JAVA_HOME=`dirname $JAVA`
    while [ ! -z "$JAVA_HOME" -a "$JAVA_HOME" != "/" -a ! -f "$JAVA_HOME/lib/tools.jar" ] ; do
        JAVA_HOME=`dirname $JAVA_HOME`
    done
    [ "$JAVA_HOME" = "" ] && JAVA_HOME=

    echo "Found JAVA=$JAVA in JAVA_HOME=$JAVA_HOME"
fi


##################################################
# Determine which JVM of version >1.2
# Try to use JAVA_HOME
##################################################
if [ "$JAVA" = "" -a "$JAVA_HOME" != "" ]
then
  if [ ! -z "$JAVACMD" ] 
  then
     JAVA="$JAVACMD" 
  else
    [ -x $JAVA_HOME/bin/jre -a ! -d $JAVA_HOME/bin/jre ] && JAVA=$JAVA_HOME/bin/jre
    [ -x $JAVA_HOME/bin/java -a ! -d $JAVA_HOME/bin/java ] && JAVA=$JAVA_HOME/bin/java
  fi
fi

if [ "$JAVA" = "" ]
then
    echo "Cannot find a JRE or JDK. Please set JAVA_HOME to a >=1.2 JRE" 2>&2
    exit 1
fi

JAVA_VERSION=`expr "$($JAVA -version 2>&1 | head -1)" : '.*1\.\([0-9]\)'`

#####################################################
# See if mq env  is defined
#####################################################
if [ "$MQ_CONFIG_DIR" = "" ]
then
  MQ_CONFIG_DIR="$MQ_HOME/config"
fi
if [ "$MQ_PORT" = "" ]
then
  MQ_PORT="9080"
fi

if [ "$MQ_LOG_DIR" = "" ]
then
  MQ_LOG_DIR="$MQ_HOME/log"
fi

JAVA_OPTIONS="$JAVA_OPTIONS -Dmq.config.dir=$MQ_CONFIG_DIR \
    -Dmq.port=$MQ_PORT \
    -Dmq.log.dir=$MQ_LOG_DIR \
    -Dfile.encoding=utf-8 "
#####################################################
# Are we running on Windows? Could be, with Cygwin/NT.
#####################################################
case "`uname`" in
CYGWIN*) PATH_SEPARATOR=";";;
*) PATH_SEPARATOR=":";;
esac


#####################################################
# Add mq properties to Java VM options.
#####################################################
JAVA_OPTIONS="$JAVA_OPTIONS -Dmq.home=$MQ_HOME -Djava.io.tmpdir=$TMP"


#####################################################
# This is how the mq server will be started
#####################################################

HOME_LIB=$MQ_HOME/lib
for jar in `ls $HOME_LIB/*.jar`
do
    MQ_CP="$MQ_CP:""$jar"
done


RUN_ARGS="$JAVA_OPTIONS -cp $MQ_CP $MQ_MAIN $MQ_ARGS "
RUN_CMD="$JAVA $RUN_ARGS"

#####################################################
# Comment these out after you're happy with what 
# the script is doing.
#####################################################
echo "MQ_HOME = $MQ_HOME"
#echo "MQ_RUN        =  $MQ_RUN"
#echo "MQ_ARGS        =  $MQ_ARGS"
echo "JAVA       = $JAVA"
#echo "MQ_PID         =  $MQ_PID"
#echo "MQ_LOG_DIR     =  $MQ_LOG_DIR"
#echo "MQ_CONFIG_DIR  =  $MQ_CONFIG_DIR"
#echo "JAVA_OPTIONS      =  $JAVA_OPTIONS"


##################################################
# Do the action
##################################################
case "$ACTION" in
  start)
      echo -n "Starting $MQ_MESSAGE .......... "

      if [ "$NO_START" = "1" ]; then 
          echo "Not starting mq - NO_START=1 in /etc/default/Monad6";
          exit 0;
      fi


      if type start-stop-daemon > /dev/null 2>&1 
      then
          [ x$MQ_USER = x ] && MQ_USER=$(whoami)
          [ $UID = 0 ] && CH_USER="-c $MQ_USER"
          if start-stop-daemon -S -p$MQ_PID $CH_USER -d $MQ_HOME -b -m -a $JAVA -- $RUN_ARGS 
          then
              sleep 1
              if running $MQ_PID
              then
                  echo OK
              else
                  echo FAILED
              fi
          fi

      else

          if [ -f $MQ_PID ]
          then
              echo "Already Running!!"
              exit 1
          fi

          if [ x$MQ_USER != x ] 
          then
              touch $MQ_PID
              chown $MQ_USER $MQ_PID
              su - $MQ_USER -c "
              $RUN_CMD &
              PID=\$!
              disown \$PID
              echo \$PID > $MQ_PID"
          else
              $RUN_CMD &
              PID=$!
              disown $PID
              echo $PID > $MQ_PID
          fi

          echo "STARTED mq `date`" 
      fi

      ;;

  stop)
      echo -n "Stopping $MQ_MESSAGE ........ "
      if type start-stop-daemon > /dev/null 2>&1; then
          start-stop-daemon -K -p $MQ_PID -d $MQ_HOME -a $JAVA -s HUP 
          sleep 1
          if running $MQ_PID
          then
              sleep 3
              if running $MQ_PID
              then
                  sleep 30
                  if running $MQ_PID
                  then
                      start-stop-daemon -K -p $MQ_PID -d $MQ_HOME -a $JAVA -s KILL
                  fi
              fi
          fi

          rm -f $MQ_PID
          echo OK
      else
          PID=`cat $MQ_PID 2>/dev/null`
          TIMEOUT=30
          while running $MQ_PID && [ $TIMEOUT -gt 0 ]
          do
              kill $PID 2>/dev/null
              sleep 1
              let TIMEOUT=$TIMEOUT-1
          done

          [ $TIMEOUT -gt 0 ] || kill -9 $PID 2>/dev/null

          rm -f $MQ_PID
          echo OK
      fi
      ;;

  restart)
        MQ_SH=$0
        echo $MQ_SH
        $MQ_SH stop $*
        sleep 5
        $MQ_SH start $*
        ;;

  supervise)
       #
       # Under control of daemontools supervise monitor which
       # handles restarts and shutdowns via the svc program.
       #
         exec $RUN_CMD
         ;;

  run|demo)
        echo "Running $MQ_MESSAGE: "

        if [ -f $MQ_PID ]
        then
            echo "Already Running!!"
            exit 1
        fi

        exec $RUN_CMD
        ;;

  check)
        echo "Checking arguments to $MQ_MESSAGE: "
        echo "MQ_HOME        =  $MQ_HOME"
        echo "MQ_RUN         =  $MQ_RUN"
        echo "MQ_PID         =  $MQ_PID"
        echo "MQ_LOG_DIR     =  $MQ_LOG_DIR"
        echo "MQ_CONFIG_DIR  =  $MQ_CONFIG_DIR"
        echo "JAVA_OPTIONS      =  $JAVA_OPTIONS"
        echo "JAVA              =  $JAVA"
        echo "CLASSPATH         =  $CLASSPATH"
        echo "RUN_CMD           =  $RUN_CMD"
        echo
        
        if [ -f $MQ_PID ]
        then
            echo "mq running pid="`cat $MQ_PID`
            exit 0
        fi
        exit 1
        ;;

*)
        usage
	;;
esac

exit 0


