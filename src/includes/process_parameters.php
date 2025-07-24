<?php

	//function that processes the $_REQUEST variable for the $name parameter and returns it.  If it's not set then return null
	function get_parameter_value ($name)
	{
		if (isset($_REQUEST[$name]))
		{
			if (!is_null($_REQUEST[$name]))
				$var = $_REQUEST[$name];
			else
				$var = null;
		}
		else
			$var = null;
		
		return $var;
	}


?>