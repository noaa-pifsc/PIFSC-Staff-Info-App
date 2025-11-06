<?php

//define the secrets file names/environment variable names that are used in the various application pages
// SECRET_MAPPING_ARR['SECRET_TYPE'] (e.g. DB_USERNAME for the database username)
// SECRET_MAPPING_ARR['SECRET_TYPE']['FILE'] (e.g. PRI_RIA_DB_USERNAME_FILE for the database username's secret file name)
// SECRET_MAPPING_ARR['SECRET_TYPE']['ENV'] (e.g. PRI_RIA_DB_USERNAME for the database username environment variable name)
define ("SECRET_MAPPING_ARR", array("DB_USERNAME"=>array("FILE"=>"DB_USERNAME_FILE", "ENV"=>"DB_USERNAME"), "DB_PASSWORD"=>array("FILE"=>"DB_PASSWORD_FILE", "ENV"=>"DB_PASSWORD")));



?>