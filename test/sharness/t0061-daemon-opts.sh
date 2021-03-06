#!/bin/sh
#
# Copyright (c) 2014 Juan Batiz-Benet
# MIT Licensed; see the LICENSE file in this repository.
#

test_description="Test daemon command"

. lib/test-lib.sh


test_init_ipfs

test_launch_ipfs_daemon --unrestricted-api --disable-transport-encryption

gwyaddr=$GWAY_ADDR
apiaddr=$API_ADDR

test_expect_success 'api gateway should be unrestricted' '
  echo "hello mars :$gwyaddr :$apiaddr" >expected &&
  HASH=$(ipfs add -q expected) &&
  curl -sfo actual1 "http://$gwyaddr/ipfs/$HASH" &&
  curl -sfo actual2 "http://$apiaddr/ipfs/$HASH" &&
  test_cmp expected actual1 &&
  test_cmp expected actual2
'

# Odd. this fails here, but the inverse works on t0060-daemon.
test_expect_success 'transport should be unencrypted' '
  nc -w 1 localhost $SWARM_PORT > swarmnc < ../t0060-data/mss-ls &&
  test_must_fail grep -q "/secio" swarmnc &&
  grep -q "/plaintext" swarmnc ||
  test_fsh cat swarmnc
'

test_kill_ipfs_daemon

test_done
