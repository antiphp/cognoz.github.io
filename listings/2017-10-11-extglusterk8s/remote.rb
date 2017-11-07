/usr/lib/pcsd/remote.rb

L773
def remote_pcsd_restart(params, request, auth_user)
  sleep 5
  pcsd_restart()
  return JSON.generate({
    :success => true,
    :instance_signature => DAEMON_INSTANCE_SIGNATURE,
  })
end
