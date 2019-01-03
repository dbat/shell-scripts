@for /d %%d in (*) do (
  pushd "%%d"
  call sync_linktimedir %~1
  popd
)
call sync_linktimedir %~1
