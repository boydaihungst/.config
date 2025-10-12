function crontab --wraps crontab --description 'Safe crontab wrapper'
    set args $argv

    # If no args → just list jobs
    if test (count $args) -eq 0
        command crontab -e
        return
    end

    # If using -r (remove all crontabs)
    if contains -- -r $args
        if not contains -- -i $args
            set args -i $args
        end
    end

    # Forward to real crontab
    command crontab $args
end
