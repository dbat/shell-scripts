::@echo OFF
w32tm /stripchart /computer:0.pool.ntp.org /dataonly /samples:0
@rem "@echo.|date"
@rem "@echo.|time"
@echo %DATE% %TIME%
::w32tm /resync
net stop w32time
net start w32time
::w32tm /unregister
::w32tm /register
w32tm /config /syncfromflags:manual /manualpeerlist:"0.asia.pool.ntp.org"
w32tm /config /update
w32tm /resync /rediscover
@rem "@echo.|date"
@rem "@echo.|time"
@echo %DATE% %TIME%
