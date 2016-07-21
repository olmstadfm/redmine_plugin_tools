#!/bin/bash

# Pre-requisites
if ! git --version > /dev/null ; then
    echo "Install git first."
    exit 1
fi

# Command-line arguments
while :; do
    case $1 in
          --old=?*) declare -g   old=${1#*=} ;;
          --new=?*) declare -g   new=${1#*=} ;;
	--reset=?*) declare -g reset=${1#*=} ;;
                 *)                    break ;;
    esac
    
    shift
done

# Helpers

function merge () {

    if [[ -z "$old" || -z "$new" ]] ; then
	echo "Invocation format: bash mergeviews.sh --old=old_redmine_path --new=new_redmine_path"
	exit 1
    fi

    if  [ ! -d "$new" ] || [ ! -d "$old" ] ; then
	echo "Wrong path."
	exit 1
    fi

    # Variables
    plugins=$old/plugins

    old_views=$(find $old/app/views -type f)
    plugin_views=$(find $plugins -wholename '*app/views*' -type f)

    affected_plugins="\nFollowing plugins were affected:\n"

    conflict=0
    success=0

    # Action
    for view_path in $plugin_views; do

	name=$(echo $view_path | grep -oP 'app/views.+' )

	if [[ $old_views =~ $name ]] ; then
            
            git merge-file $view_path $old/$name $new/$name

            log="./$view_path:1:"

            view_conflicts_count=$(grep --count '<<<<<' $view_path)
            if (( view_conflicts_count > 0 )) ; then
		log="$log (conflict $view_conflicts_count)"
		let "conflict+=view_conflicts_count"
            else
		log="$log (success)"
		let "success+=1"
            fi
            echo $log
            
            plugin=$(echo $view_path | cut -d'/' -f 3 )
            if [[ ! $affected_plugins =~ $plugin ]] ; then
		affected_plugins="$affected_plugins  - $plugin\n"
            fi
	fi
	
    done

    # Stats output

    echo -e $affected_plugins

    echo -e "\nMerge stats:\n"
    echo -e "  - successful  $success"
    echo -e "  - conflicts $conflict"

}

function reset() {
    
    if  [ ! -d "$reset" ] ; then
	echo "Wrong path."
	exit 1
    fi

    plugins="$reset/plugins/"
    
    for plugin in $(find "$plugins" -maxdepth 1 -mindepth 1 -type d)
    do
	( cd $plugin && git reset --hard HEAD )
    done

}

# Merge or reset?
if [[ -n "$reset" ]] ; then
    reset
else
    merge
fi
