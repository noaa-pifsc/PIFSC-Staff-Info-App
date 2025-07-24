<?php

	//function that processes the $_REQUEST variable for the $name parameter and returns it.  If it's not set then return null
	function get_parameter_value ($name)
	{
		if (isset($_REQUEST[$name]))
		{
			//the request parameter is defined
			if (!is_null($_REQUEST[$name]))
				$var = $_REQUEST[$name];	//the request parameter value is not null, return the request parameter value
			else
				$var = null;	//the request parameter value is null, return null
		}
		else
			$var = null;	//the request parameter is not defined, return null
		
		return $var;
	}

?>