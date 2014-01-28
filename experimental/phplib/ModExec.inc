<?php
function GrabModExec($driver, $module, $auth) {
  $perl = new Perl();
  $perl->eval("use ModExec");

  $obj = new Perl("ModExec", "new", "driver", $driver, "module", $module, "auth", $auth);

  return $obj;
}
?>