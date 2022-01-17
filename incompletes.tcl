bind pub - !incompletes inc:inc
bind pub - !incomplete inc:inc
bind pub - !inc inc:inc
bind pub - !sinc inc:sinc
bind pub - !approve inc:approve

proc inc:inc {nick host hand chan arg} {
    set path "/opt/scripts/maw-incompletes/incompletes.py"
    set config "/opt/scripts/maw-incompletes/config.yaml"

    if {[string equal -nocase $chan ${::ngBot::mainchan}]} {
        set chain "TURGEN"
    } elseif {[string equal -nocase $chan ${::ngBot::spamchan}]} {
        set chain "SPAMCHAN"
    } elseif {[string equal -nocase $chan ${::ngBot::staffchan}]} {
        set chain "SYSOP"
    } else {
        return
    }

    if {$arg == 1} {
        exec -- $path $config $chain --silent &
    } else {
        exec -- $path $config $chain &
    }
}

proc inc:sinc {nick host hand chan arg} {
    inc:inc $nick $host $hand $chan 1
}

proc inc:approve {nick uhost hand chan arg} {
    if {![string equal -nocase $chan ${::ngBot::staffchan}]} { return 0 }

    regsub -all {\002|\003(?:\d{1,2}(?:,\d{1,2})?)?|\017|\026|\037|\007|\035|\x22} $arg {} arg

    if {[llength [split $arg]] == 0} {
        putserv "PRIVMSG $chan :USAGE: !approve <release>"
        return 0
    }

    set libSQLite "/usr/lib/tcltk/sqlite3/libtclsqlite3.so"
    set filePath "/opt/glftpd/sitebot/scripts/incompletes.db"

    lassign [split $arg] release
    set unixtime [clock seconds]

    if {[catch {load $libSQLite Tclsqlite3} errorMsg]} {
        putlog "\[approve\] Error :: $errorMsg"
        return 0
    }

    if {[catch {sqlite3 db $filePath} errorMsg]} {
        putlog "\[approve\] Error :: Unable to open database \"$filePath\" - $errorMsg"
        return 0
    }

    db function StrCaseEq {string equal -nocase}

    set ids [db eval {SELECT id FROM Releases WHERE StrCaseEq(release,$release)}]
    if {$ids == ""} {
        putserv "PRIVMSG $chan :ERROR: \002$release\002 has not been indexed yet, can't approve yet"
        catch {db close}
        return 0
    } else {
        foreach id $ids {
            if {[catch {db eval {UPDATE Releases SET timestamp=$unixtime, approved=1 WHERE id=$id;}} errorMsg]} {
                # script sometimes runs into locking issues with the sqlite db
                utimer 10 [list inc:approve $nick $uhost $hand $chan $arg]
                return 0
            }
            inc:cleanup $release
        }
    }

    putserv "PRIVMSG $chan :Successfully approved \002$release\002 and removed incompletes link to it"

    catch {db close}
}

proc inc:cleanup {release} {
    set path "/opt/glftpd/site/incompletes/"
    append path $release

    if {![file exists $path]} { return 0 }
    if {[file type $path] != "link"} { return 0 }

    file delete $path

    return 1
}
