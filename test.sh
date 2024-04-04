#!/nix/store/a1s263pmsci9zykm5xcdf7x9rv26w6d5-bash-5.2p26/bin/bash
set -e
echo "Executing " '/nix/store/40nmd5yhm78p9i5bwlbaamihk90r6f3w-push-image.sh' ", logs will appear in the systemd journal. View those logs with:" >&2
echo "journalctl --identifier 'hydra-fitness-tracker-push-image'" >&2
echo "Starting '/nix/store/40nmd5yhm78p9i5bwlbaamihk90r6f3w-push-image.sh'..." | /nix/store/4npvfi1zh3igsgglxqzwg0w7m2h7sr9b-systemd-255.4/bin/systemd-cat --identifier 'hydra-fitness-tracker-push-image'
/nix/store/4npvfi1zh3igsgglxqzwg0w7m2h7sr9b-systemd-255.4/bin/systemd-cat --identifier 'hydra-fitness-tracker-push-image' '/nix/store/40nmd5yhm78p9i5bwlbaamihk90r6f3w-push-image.sh'
