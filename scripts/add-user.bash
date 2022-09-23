#!/bin/bash

if ! command -v psql &> /dev/null
then
    printf "psql could not be found\n\n"
    printf "  execute the following command to install psql:\n"
    printf "  -----------------------\n"
    printf "  brew install libpq\n"
    exit 1
fi

read -p "Please state user email: " email
echo "  => USER_EMAIL=\"${email}\""
read -p "Should user email be an admin? [y/N]: " is_admin

function set_add_normal_user_command() {
	command_to_execute=$(cat <<-EOM
    INSERT INTO users (id, email, display_name, created_at, updated_at, whitelisted, confirmed, admin)
    VALUES (gen_random_uuid(),'$email', '$email',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,TRUE,TRUE,FALSE)
    ON CONFLICT (email)
    DO UPDATE SET
    confirmed = true,
    whitelisted = true,
    admin = false,
    updated_at = CURRENT_TIMESTAMP;
	EOM
	)
}
function set_add_admin_command() {
	command_to_execute=$(cat <<-EOM
    INSERT INTO users (id, email, display_name, created_at, updated_at, whitelisted, confirmed, admin)
    VALUES (gen_random_uuid(),'$email', '$email',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,TRUE,TRUE,TRUE)
    ON CONFLICT (email)
    DO UPDATE SET
    confirmed = true,
    whitelisted = true,
    admin = true,
    updated_at = CURRENT_TIMESTAMP;
	EOM
	)
}

case "$is_admin" in
	y|Y ) set_add_admin_command ;;
	* ) set_add_normal_user_command ;;
esac
echo "  => COMMAND=\"${command_to_execute}\""

PSQL_TARGET="postgresql://postgres:postgres@127.0.0.1:5432?sslmode=disable&dbname=registry"
echo "  => PSQL_TARGET=\"${PSQL_TARGET}\""

read -p "Confirm? [y/N]: " choice
case "$choice" in
	y|Y) echo "  => CONFIRMED=true";;
	* ) exit 1;;
esac

echo "$ psql \"$PSQL_TARGET\" -c \"$command_to_execute\""
psql "$PSQL_TARGET" -c "$command_to_execute"

exit 0
