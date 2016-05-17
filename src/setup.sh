#!/bin/sh

echo "Star Micronics"
echo "starcupsdrv-3.5.0 installer"
echo "---------------------------------------"
echo ""
echo "Models included:"
echo "                 TUP900"
echo "                 TUP500"
echo "                 TSP1000"
echo "                 TSP828L"
echo "                 TSP800II"
echo "                 TSP700II"
echo "                 TSP650 Cutter (TSP654)"
echo "                 TSP650 Tear Bar (TSP651)"
echo "                 TSP650II Cutter (TSP654II)"
echo "                 TSP100 Cutter"
echo "                 TSP100 Tear Bar"
echo "                 TSP100GT Cutter"
echo "                 TSP100GT Tear Bar"
echo "                 TSP100LAN Cutter"
echo "                 TSP100LAN Tear Bar"
echo "                 SP700 Cutter (SP747)"
echo "                 SP700 Tear Bar (SP717)"
echo "                 SP700 Cutter (SP742)"
echo "                 SP700 Tear Bar (SP712)"
echo "                 SP500 Cutter"
echo "                 SP500 Tear Bar"
echo "                 HSP7000"
echo "                 FVP10"
echo ""

ROOT_UID=0

if [ -z $RPMBUILD ] && [ "$UID" -ne "$ROOT_UID" ]
then
    echo "This script requires root user access."
    echo "Re-run as root user."
    exit 1
fi

if [ ! -z $DESTDIR ]
then
    echo "DESTDIR set to $DESTDIR"
    echo ""
fi

SERVERROOT=$(grep '^ServerRoot' /etc/cups/cupsd.conf | awk '{print $2}')

if [ -z $FILTERDIR ] || [ -z $PPDDIR ]
then
    echo "Searching for ServerRoot, ServerBin, and DataDir tags in /etc/cups/cupsd.conf"
    echo ""

    if [ -z $FILTERDIR ]
    then
        SERVERBIN=$(grep '^ServerBin' /etc/cups/cupsd.conf | awk '{print $2}')

        if [ -z $SERVERBIN ]
        then
            echo "ServerBin tag not present in cupsd.conf - using default"
            FILTERDIR=usr/lib/cups/filter
        elif [ ${SERVERBIN:0:1} = "/" ]
        then
            echo "ServerBin tag is present as an absolute path"
            FILTERDIR=$SERVERBIN/filter
        else
            echo "ServerBin tag is present as a relative path - appending to ServerRoot"
            FILTERDIR=$SERVERROOT/$SERVERBIN/filter
        fi
    fi

    echo ""

    if [ -z $PPDDIR ]
    then
        DATADIR=$(grep '^DataDir' /etc/cups/cupsd.conf | awk '{print $2}')

        if [ -z $DATADIR ]
        then
            echo "DataDir tag not present in cupsd.conf - using default"
            PPDDIR=/usr/share/cups/model/star
        elif [ ${DATADIR:0:1} = "/" ]
        then
            echo "DataDir tag is present as an absolute path"
            PPDDIR=$DATADIR/model/star
        else
            echo "DataDir tag is present as a relative path - appending to ServerRoot"
            PPDDIR=$SERVERROOT/$DATADIR/model/star
        fi
    fi

    echo ""

    echo "ServerRoot = $SERVERROOT"
    echo "ServerBin  = $SERVERBIN"
    echo "DataDir    = $DATADIR"
    echo ""
fi

echo "Copying rastertostar filter to $DESTDIR/$FILTERDIR"
mkdir -p $DESTDIR/$FILTERDIR
chmod +x rastertostar
cp rastertostar $DESTDIR/$FILTERDIR
echo ""

echo "Copying rastertostarlm filter to $DESTDIR/$FILTERDIR"
mkdir -p $DESTDIR/$FILTERDIR
chmod +x rastertostarlm
cp rastertostarlm $DESTDIR/$FILTERDIR
echo ""

echo "Copying model ppd files to $DESTDIR/$PPDDIR"
mkdir -p $DESTDIR/$PPDDIR
cp *.gz $DESTDIR/$PPDDIR
echo ""

if [ -z $RPMBUILD ]
then
    echo "Restarting CUPS"
    if [ -x /etc/software/init.d/cups ]
    then
        /etc/software/init.d/cups stop
        /etc/software/init.d/cups start
    elif [ -x /etc/rc.d/init.d/cups ]
    then
        /etc/rc.d/init.d/cups stop
        /etc/rc.d/init.d/cups start
    elif [ -x /etc/init.d/cups ]
    then
        /etc/init.d/cups stop
        /etc/init.d/cups start
    elif [ -x /sbin/init.d/cups ]
    then
        /sbin/init.d/cups stop
        /sbin/init.d/cups start
    elif [ -x /etc/software/init.d/cupsys ]
    then
        /etc/software/init.d/cupsys stop
        /etc/software/init.d/cupsys start
    elif [ -x /etc/rc.d/init.d/cupsys ]
    then
        /etc/rc.d/init.d/cupsys stop
        /etc/rc.d/init.d/cupsys start
    elif [ -x /etc/init.d/cupsys ]
    then
        /etc/init.d/cupsys stop
        /etc/init.d/cupsys start
    elif [ -x /sbin/init.d/cupsys ]
    then
        /sbin/init.d/cupsys stop
        /sbin/init.d/cupsys start
    else
        echo "Could not restart CUPS"
    fi
    echo ""
fi

echo "Install Complete"
echo "Add printer queue using OS tool, http://localhost:631, or http://127.0.0.1:631"
echo ""

